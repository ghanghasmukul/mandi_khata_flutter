// admin-api: everything the super-admin console does (apps/mk_admin).
//
// POST { action, ...params } with the caller's JWT. The caller must be in
// public.platform_admins; every other check is done here with the service
// role, and every change writes public.admin_audit_log (directly, or inside
// the SQL function that makes the change). Customers' data is only returned
// by `support_start`, which opens a session the customer can see.
//
// Secrets: none beyond the project's own (SUPABASE_URL, SUPABASE_ANON_KEY,
//          SUPABASE_SERVICE_ROLE_KEY).

import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

class Problem extends Error {
  constructor(public code: string, public status = 400) {
    super(code);
  }
}

type Params = Record<string, unknown>;
type Admin = { id: string; email: string };

const str = (v: unknown, name: string): string => {
  if (typeof v !== "string" || v.trim() === "") throw new Problem(`missing_${name}`);
  return v.trim();
};
const uuid = (v: unknown, name: string): string => {
  const s = str(v, name);
  if (!/^[0-9a-f-]{36}$/i.test(s)) throw new Problem(`bad_${name}`);
  return s;
};
const obj = (v: unknown, name: string): Record<string, unknown> => {
  if (v === null || typeof v !== "object" || Array.isArray(v)) {
    throw new Problem(`bad_${name}`);
  }
  return v as Record<string, unknown>;
};

async function audit(
  db: SupabaseClient,
  admin: Admin,
  action: string,
  fields: {
    tenant?: string | null;
    type?: string;
    id?: string;
    before?: unknown;
    after?: unknown;
    note?: string | null;
  } = {},
) {
  const { error } = await db.from("admin_audit_log").insert({
    admin_user_id: admin.id,
    admin_email: admin.email,
    action,
    target_tenant_id: fields.tenant ?? null,
    target_type: fields.type ?? null,
    target_id: fields.id ?? null,
    before: fields.before ?? null,
    after: fields.after ?? null,
    note: fields.note ?? null,
  });
  if (error) throw new Problem("audit_failed", 500);
}

function check<T>(res: { data: T; error: { message: string; code?: string } | null }): T {
  if (res.error) {
    console.error(res.error);
    const m = res.error.message;
    if (res.error.code === "23505") throw new Problem("already_exists", 409);
    if (res.error.code === "22023" || res.error.code === "23514") {
      throw new Problem("invalid", 422);
    }
    throw new Problem(m.includes("reason is required") ? "reason_required" : "failed", 500);
  }
  return res.data;
}

// Plan / add-on columns an admin may write.
const PLAN_FIELDS = [
  "name", "description", "price_monthly_paise", "price_yearly_paise", "max_users",
  "max_devices", "modules", "limits", "default_settings", "is_public", "is_active",
  "sort_order",
];
const ADDON_FIELDS = [
  "name", "description", "grants_limits", "grants_modules", "price_monthly_paise",
  "price_yearly_paise", "max_quantity", "is_active", "sort_order",
];
const pick = (src: Params, fields: string[]) =>
  Object.fromEntries(fields.filter((f) => f in src).map((f) => [f, src[f]]));

// 12 characters from an unambiguous alphabet (no 0/O, 1/l/I).
function randomPassword(): string {
  const alphabet = "abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  const bytes = crypto.getRandomValues(new Uint8Array(12));
  return Array.from(bytes, (b) => alphabet[b % alphabet.length]).join("");
}

async function handle(
  db: SupabaseClient,
  admin: Admin,
  action: string,
  p: Params,
): Promise<unknown> {
  switch (action) {
    // ---- businesses -------------------------------------------------------
    case "overview":
      return check(await db.rpc("admin_tenant_overview"));

    // Upload lag and device freshness per business (step 6.6).
    case "sync_health": {
      const days = typeof p.days === "number" ? Math.min(Math.max(p.days, 1), 90) : 7;
      return check(await db.rpc("admin_sync_health", { p_days: days }));
    }

    case "tenant_detail": {
      const id = uuid(p.tenant_id, "tenant_id");
      const [sub, ent, reqs, audits] = await Promise.all([
        db.from("tenant_subscriptions").select("*").eq("tenant_id", id).maybeSingle(),
        db.rpc("admin_tenant_entitlements", { p_tenant_id: id }),
        db.from("plan_requests").select("*").eq("tenant_id", id)
          .order("created_at", { ascending: false }).limit(20),
        db.from("admin_audit_log").select("*").eq("target_tenant_id", id)
          .order("created_at", { ascending: false }).limit(50),
      ]);
      const { data: tenant } = await db.from("tenants").select(
        "id, name, state_code, mandi_name, business_type, referral_code, referral_valid, created_at",
      ).eq("id", id).maybeSingle();
      const { data: settings } = await db.from("settings").select("key, value")
        .eq("tenant_id", id).eq("scope", "tenant");
      return {
        tenant,
        subscription: check(sub),
        entitlements: check(ent),
        requests: check(reqs),
        admin_log: check(audits),
        settings: settings ?? [],
      };
    }

    case "update_subscription":
      return check(await db.rpc("admin_update_subscription", {
        p_admin_id: admin.id,
        p_admin_email: admin.email,
        p_tenant_id: uuid(p.tenant_id, "tenant_id"),
        p_changes: obj(p.changes, "changes"),
        p_note: typeof p.note === "string" ? p.note : null,
      }));

    case "set_tenant_setting":
      check(await db.rpc("admin_set_tenant_setting", {
        p_admin_id: admin.id,
        p_admin_email: admin.email,
        p_tenant_id: uuid(p.tenant_id, "tenant_id"),
        p_key: str(p.key, "key"),
        p_value: p.value ?? null,
        p_note: typeof p.note === "string" ? p.note : null,
      }));
      return { ok: true };

    // ---- read-only support ----------------------------------------------
    case "support_start": {
      const tenant = uuid(p.tenant_id, "tenant_id");
      const sessionId = check(await db.rpc("admin_start_support_session", {
        p_admin_id: admin.id,
        p_admin_email: admin.email,
        p_tenant_id: tenant,
        p_reason: str(p.reason, "reason"),
      }));
      const snapshot = check(await db.rpc("admin_support_snapshot", { p_tenant_id: tenant }));
      return { session_id: sessionId, snapshot };
    }
    case "support_end":
      check(await db.rpc("admin_end_support_session", {
        p_admin_id: admin.id,
        p_admin_email: admin.email,
        p_session_id: uuid(p.session_id, "session_id"),
      }));
      return { ok: true };

    // ---- plan requests ------------------------------------------------------
    case "requests_list": {
      const q = db.from("plan_requests").select("*, tenants(name)")
        .order("created_at", { ascending: false }).limit(100);
      return check(p.status ? await q.eq("status", String(p.status)) : await q);
    }
    case "request_resolve": {
      const id = uuid(p.id, "id");
      const status = str(p.status, "status");
      if (!["done", "rejected"].includes(status)) throw new Problem("bad_status");
      const row = check(await db.from("plan_requests").update({
        status,
        handled_note: typeof p.note === "string" ? p.note : null,
      }).eq("id", id).select().single());
      await audit(db, admin, "resolve_plan_request", {
        tenant: row.tenant_id, type: "plan_requests", id, after: { status }, note: p.note as string,
      });
      return row;
    }

    // ---- plans and add-ons ---------------------------------------------------
    case "plans_list":
      return {
        plans: check(await db.from("plans").select("*").order("sort_order")),
        addons: check(await db.from("plan_addons").select("*").order("sort_order")),
      };
    case "plan_upsert": {
      const code = str(p.code, "code");
      const row = { code, ...pick(p, PLAN_FIELDS) };
      const before = (await db.from("plans").select("*").eq("code", code).maybeSingle()).data;
      const saved = check(await db.from("plans").upsert(row, { onConflict: "code" }).select().single());
      await audit(db, admin, before ? "update_plan" : "create_plan", {
        type: "plans", id: code, before, after: saved,
      });
      return saved;
    }
    case "addon_upsert": {
      const code = str(p.code, "code");
      const row = { code, ...pick(p, ADDON_FIELDS) };
      const before = (await db.from("plan_addons").select("*").eq("code", code).maybeSingle()).data;
      const saved = check(await db.from("plan_addons").upsert(row, { onConflict: "code" }).select().single());
      await audit(db, admin, before ? "update_addon" : "create_addon", {
        type: "plan_addons", id: code, before, after: saved,
      });
      return saved;
    }

    // ---- platform settings, presets, crops, referrals, announcements ----------
    case "platform_settings_list":
      return check(await db.from("platform_settings").select("*").order("key"));
    case "platform_setting_set": {
      const key = str(p.key, "key");
      const before = (await db.from("platform_settings").select("*").eq("key", key).maybeSingle()).data;
      const saved = check(await db.from("platform_settings").upsert({
        key,
        value: p.value,
        is_public: before?.is_public ?? Boolean(p.is_public),
        description: before?.description ?? (typeof p.description === "string" ? p.description : null),
      }, { onConflict: "key" }).select().single());
      await audit(db, admin, "set_platform_setting", { type: "platform_settings", id: key, before, after: saved });
      return saved;
    }

    case "presets_list":
      return check(await db.from("state_presets").select("*").order("state_code"));
    case "preset_upsert": {
      const code = str(p.state_code, "state_code");
      const before = (await db.from("state_presets").select("*").eq("state_code", code).maybeSingle()).data;
      const saved = check(await db.from("state_presets").upsert({
        state_code: code,
        name: str(p.name, "name"),
        settings: obj(p.settings ?? {}, "settings"),
        is_active: p.is_active !== false,
      }, { onConflict: "state_code" }).select().single());
      await audit(db, admin, "upsert_state_preset", { type: "state_presets", id: code, before, after: saved });
      return saved;
    }

    case "crops_list":
      return check(await db.from("crop_master").select("*").order("sort_order"));
    case "crop_upsert": {
      const code = str(p.code, "code");
      const before = (await db.from("crop_master").select("*").eq("code", code).maybeSingle()).data;
      const saved = check(await db.from("crop_master").upsert({
        code,
        name_en: str(p.name_en, "name_en"),
        name_hi: p.name_hi ?? null,
        name_pa: p.name_pa ?? null,
        msp_or_std_rate: p.msp_or_std_rate ?? null,
        sort_order: Number(p.sort_order ?? 0),
        is_active: p.is_active !== false,
      }, { onConflict: "code" }).select().single());
      await audit(db, admin, "upsert_crop_master", { type: "crop_master", id: code, before, after: saved });
      return saved;
    }
    case "crops_push": {
      const added = check(await db.rpc("push_crop_master", { p_update_rates: p.update_rates === true }));
      await audit(db, admin, "push_crop_master", { after: { added, update_rates: p.update_rates === true } });
      return { added };
    }

    case "referrals_list":
      return check(await db.from("referral_codes").select("*").order("created_at", { ascending: false }));
    case "referral_upsert": {
      const code = str(p.code, "code").toUpperCase();
      const before = (await db.from("referral_codes").select("*").eq("code", code).maybeSingle()).data;
      const saved = check(await db.from("referral_codes").upsert({
        code,
        owner_name: str(p.owner_name, "owner_name"),
        commission_pct: Number(p.commission_pct ?? 0),
        is_active: p.is_active !== false,
        note: typeof p.note === "string" ? p.note : null,
      }, { onConflict: "code" }).select().single());
      await audit(db, admin, "upsert_referral", { type: "referral_codes", id: code, before, after: saved });
      return saved;
    }

    case "announcements_list":
      return check(await db.from("announcements").select("*").order("created_at", { ascending: false }));
    case "announcement_upsert": {
      const row = {
        ...(p.id ? { id: uuid(p.id, "id") } : {}),
        title_en: str(p.title_en, "title_en"),
        title_hi: p.title_hi ?? null,
        title_pa: p.title_pa ?? null,
        body_en: typeof p.body_en === "string" ? p.body_en : "",
        body_hi: p.body_hi ?? null,
        body_pa: p.body_pa ?? null,
        severity: ["info", "warning", "critical"].includes(String(p.severity)) ? p.severity : "info",
        plan_codes: Array.isArray(p.plan_codes) && p.plan_codes.length ? p.plan_codes : null,
        starts_at: p.starts_at ?? null,
        ends_at: p.ends_at ?? null,
        is_active: p.is_active !== false,
      };
      const saved = check(await db.from("announcements").upsert(row).select().single());
      await audit(db, admin, "upsert_announcement", { type: "announcements", id: saved.id, after: saved });
      return saved;
    }

    case "audit_list": {
      let q = db.from("admin_audit_log").select("*").order("created_at", { ascending: false }).limit(200);
      if (p.tenant_id) q = q.eq("target_tenant_id", uuid(p.tenant_id, "tenant_id"));
      return check(await q);
    }

    // ---- users and their feature access -------------------------------------
    case "users_list":
      return check(await db.rpc("admin_users"));

    case "user_create": {
      const email = str(p.email, "email").toLowerCase();
      if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) throw new Problem("bad_email");
      const generated = typeof p.password !== "string" || p.password === "";
      const password = generated ? randomPassword() : String(p.password);
      if (password.length < 8) throw new Problem("weak_password");
      const phone = typeof p.phone === "string" && p.phone.trim() !== ""
        ? p.phone.replace(/\D/g, "")
        : null;
      if (phone !== null && !/^91[6-9]\d{9}$/.test(phone)) throw new Problem("bad_phone");
      const fullName = typeof p.full_name === "string" ? p.full_name.trim() : "";
      const { data, error } = await db.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        ...(phone ? { phone, phone_confirm: true } : {}),
        user_metadata: { full_name: fullName },
      });
      if (error || !data.user) {
        console.error(error);
        throw new Problem(error?.message?.toLowerCase().includes("already") ? "already_exists" : "failed",
          error?.message?.toLowerCase().includes("already") ? 409 : 500);
      }
      await audit(db, admin, "create_user", {
        type: "users", id: data.user.id, after: { email, phone, full_name: fullName },
      });
      let membership: unknown = null;
      if (p.tenant_id) {
        membership = check(await db.rpc("admin_set_member_access", {
          p_admin_id: admin.id,
          p_admin_email: admin.email,
          p_tenant_id: uuid(p.tenant_id, "tenant_id"),
          p_user_id: data.user.id,
          p_role: typeof p.role === "string" ? p.role : "munshi",
          p_custom: p.custom_permissions ?? null,
          p_is_active: true,
          p_device_limit: typeof p.device_limit === "number" ? p.device_limit : null,
          p_note: "created with the user",
        }));
      }
      // The password is returned once so the admin can hand it over.
      return { user_id: data.user.id, email, password, generated, membership };
    }

    case "user_reset_password": {
      const id = uuid(p.user_id, "user_id");
      const generated = typeof p.password !== "string" || p.password === "";
      const password = generated ? randomPassword() : String(p.password);
      if (password.length < 8) throw new Problem("weak_password");
      const { error } = await db.auth.admin.updateUserById(id, { password });
      if (error) {
        console.error(error);
        throw new Problem("failed", 500);
      }
      await audit(db, admin, "reset_user_password", { type: "users", id });
      return { user_id: id, password, generated };
    }

    case "user_set_banned": {
      const id = uuid(p.user_id, "user_id");
      if (id === admin.id) throw new Problem("cannot_ban_self", 422);
      const banned = p.banned === true;
      const { error } = await db.auth.admin.updateUserById(id, {
        ban_duration: banned ? "876000h" : "none",
      });
      if (error) {
        console.error(error);
        throw new Problem("failed", 500);
      }
      await audit(db, admin, banned ? "disable_user" : "enable_user", { type: "users", id });
      return { user_id: id, banned };
    }

    case "member_set_access":
      return check(await db.rpc("admin_set_member_access", {
        p_admin_id: admin.id,
        p_admin_email: admin.email,
        p_tenant_id: uuid(p.tenant_id, "tenant_id"),
        p_user_id: uuid(p.user_id, "user_id"),
        p_role: typeof p.role === "string" ? p.role : null,
        p_custom: p.custom_permissions === undefined ? null : obj(p.custom_permissions, "custom_permissions"),
        p_is_active: typeof p.is_active === "boolean" ? p.is_active : null,
        p_device_limit: typeof p.device_limit === "number" ? p.device_limit : null,
        p_note: typeof p.note === "string" ? p.note : null,
      }));

    case "businesses_brief":
      return check(await db.from("tenants").select("id, name").order("name"));

    case "me":
      return { id: admin.id, email: admin.email };

    default:
      throw new Problem("unknown_action", 404);
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const auth = req.headers.get("Authorization");
  if (!auth) return json({ error: "not_signed_in" }, 401);

  const url = Deno.env.get("SUPABASE_URL")!;
  const caller = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: auth } },
  });
  const { data: userData, error: userError } = await caller.auth.getUser();
  if (userError || !userData.user) return json({ error: "not_signed_in" }, 401);

  const db = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const { data: isAdmin } = await db.from("platform_admins").select("user_id")
    .eq("user_id", userData.user.id).maybeSingle();
  if (!isAdmin) return json({ error: "not_allowed" }, 403);

  let input: Params;
  try {
    input = await req.json();
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  const admin: Admin = { id: userData.user.id, email: userData.user.email ?? "" };
  try {
    const result = await handle(db, admin, String(input.action ?? ""), input);
    return json({ data: result });
  } catch (e) {
    if (e instanceof Problem) return json({ error: e.code }, e.status);
    console.error(e);
    return json({ error: "failed" }, 500);
  }
});
