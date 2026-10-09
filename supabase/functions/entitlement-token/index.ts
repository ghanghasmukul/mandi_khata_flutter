// entitlement-token: a signed snapshot of a business's subscription, for
// devices that must enforce the plan while offline (docs/domain/saas-rules.md
// section 3).
//
// POST { tenant_id } with the caller's JWT. The caller must be an active
// member of the business (row-level security on tenant_subscriptions decides).
// Returns { token }: an ES256 JWT with
//   tid, plan, iat, valid_until, terms{...}, modules{...}, limits{...}
// The app verifies it with the public key and only trusts it when it is
// newer than the synced subscription row.
//
// Secrets: ENTITLEMENT_PRIVATE_KEY  PKCS8 PEM of the ES256 (P-256) key; line
//          breaks may be written as \n.
//          The matching public key goes into the apps' ENTITLEMENT_PUBLIC_KEY.
//
// Entitlements come from the SQL function admin_tenant_entitlements(), so the
// plan / add-on / override maths exists in one place (khata_core and SQL).

import { createClient } from "npm:@supabase/supabase-js@2";
import { importPKCS8, SignJWT } from "npm:jose@5";

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

const DAY = 24 * 60 * 60 * 1000;

// When full access ends: trial end, or grace_until, or period end + grace.
function validUntil(s: Record<string, unknown>): string | null {
  if (s.status === "trial") return (s.trial_ends_at as string) ?? null;
  if (s.grace_until) return s.grace_until as string;
  if (s.current_period_end) {
    const end = new Date(s.current_period_end as string).getTime();
    return new Date(end + Number(s.grace_days ?? 7) * DAY).toISOString();
  }
  return null;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const auth = req.headers.get("Authorization");
  if (!auth) return json({ error: "not_signed_in" }, 401);

  let input: Record<string, unknown>;
  try {
    input = await req.json();
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  const tenantId = String(input.tenant_id ?? "");
  if (!/^[0-9a-f-]{36}$/i.test(tenantId)) return json({ error: "bad_request" }, 400);

  const pem = (Deno.env.get("ENTITLEMENT_PRIVATE_KEY") ?? "").replaceAll("\\n", "\n");
  if (!pem) return json({ error: "not_configured" }, 503);

  const url = Deno.env.get("SUPABASE_URL")!;
  const caller = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: auth } },
  });
  const { data: sub, error } = await caller
    .from("tenant_subscriptions")
    .select("*")
    .eq("tenant_id", tenantId)
    .maybeSingle();
  if (error) return json({ error: "failed" }, 500);
  if (!sub) return json({ error: "not_a_member" }, 403);

  const service = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const { data: ent, error: entError } = await service.rpc(
    "admin_tenant_entitlements",
    { p_tenant_id: tenantId },
  );
  if (entError) return json({ error: "failed" }, 500);

  try {
    const key = await importPKCS8(pem, "ES256");
    const token = await new SignJWT({
      tid: tenantId,
      plan: sub.plan_code,
      valid_until: validUntil(sub),
      terms: {
        status: sub.status,
        trial_ends_at: sub.trial_ends_at,
        current_period_end: sub.current_period_end,
        grace_days: sub.grace_days,
        grace_until: sub.grace_until,
        cancelled_at: sub.cancelled_at,
        cancelled_readonly_days: sub.cancelled_readonly_days,
      },
      modules: ent?.modules ?? {},
      limits: ent?.limits ?? {},
    })
      .setProtectedHeader({ alg: "ES256", typ: "JWT" })
      .setIssuedAt()
      .sign(key);
    return json({ token });
  } catch (e) {
    console.error("sign", e);
    return json({ error: "failed" }, 500);
  }
});
