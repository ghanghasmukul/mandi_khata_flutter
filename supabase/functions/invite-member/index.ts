// invite-member: an owner invites a phone number to their business.
//
// 1. Calls the SQL function create_member_invite() with the CALLER's JWT, so
//    only a member with admin.manage can invite and the invite is audited.
// 2. Sends the invite by WhatsApp or SMS through Twilio when its secrets are
//    set. Without them nothing is sent: the response carries the message and
//    `delivery: "none"`, and the app offers to share it by hand.
//
// Secrets (supabase secrets set ...), all optional:
//   APP_URL                  where people open the app (link in the message)
//   TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
//   TWILIO_SMS_FROM          e.g. +1555..., or a messaging service number
//   TWILIO_WHATSAPP_FROM     e.g. whatsapp:+1555... (approved sender)
//
// The invite becomes a membership when the person signs in with that number
// (accept_member_invites()), so the message only has to say where to go.

import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type Language = "en" | "hi" | "pa";

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

const roleNames: Record<string, Record<Language, string>> = {
  accountant: { en: "Accountant", hi: "मुनीम (लेखाकार)", pa: "ਮੁਨੀਮ (ਲੇਖਾਕਾਰ)" },
  munshi: { en: "Munshi", hi: "मुंशी", pa: "ਮੁਨਸ਼ੀ" },
  custom: { en: "team member", hi: "टीम सदस्य", pa: "ਟੀਮ ਮੈਂਬਰ" },
};

export function inviteMessage(
  language: Language,
  inviter: string,
  business: string,
  role: string,
  link: string,
): string {
  const r = roleNames[role]?.[language] ?? role;
  switch (language) {
    case "hi":
      return `${inviter} ने आपको "${business}" में ${r} के रूप में Mandi Khata पर जोड़ा है। इसी मोबाइल नंबर से साइन इन करें: ${link}`;
    case "pa":
      return `${inviter} ਨੇ ਤੁਹਾਨੂੰ "${business}" ਵਿੱਚ ${r} ਵਜੋਂ Mandi Khata ਨਾਲ ਜੋੜਿਆ ਹੈ। ਇਸੇ ਮੋਬਾਈਲ ਨੰਬਰ ਨਾਲ ਸਾਈਨ ਇਨ ਕਰੋ: ${link}`;
    default:
      return `${inviter} added you to "${business}" on Mandi Khata as ${r}. Sign in with this mobile number: ${link}`;
  }
}

async function sendTwilio(
  to: string,
  body: string,
  channel: "whatsapp" | "sms",
): Promise<boolean> {
  const sid = Deno.env.get("TWILIO_ACCOUNT_SID");
  const token = Deno.env.get("TWILIO_AUTH_TOKEN");
  const from = Deno.env.get(
    channel === "whatsapp" ? "TWILIO_WHATSAPP_FROM" : "TWILIO_SMS_FROM",
  );
  if (!sid || !token || !from) return false;
  const target = channel === "whatsapp" ? `whatsapp:+${to}` : `+${to}`;
  const res = await fetch(
    `https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`,
    {
      method: "POST",
      headers: {
        Authorization: "Basic " + btoa(`${sid}:${token}`),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({ To: target, From: from, Body: body }),
    },
  );
  if (!res.ok) console.error("twilio", res.status, await res.text());
  return res.ok;
}

// Postgres error text -> a stable code the app translates.
function errorCode(message: string): string {
  for (
    const code of [
      "invalid_phone",
      "invalid_role",
      "invalid_permissions",
      "already_member",
      "already_invited",
      "limit_reached",
    ]
  ) {
    if (message.includes(code)) return code;
  }
  if (message.includes("only the owner")) return "not_allowed";
  if (message.includes("not signed in")) return "not_signed_in";
  return "failed";
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
  const language = (["en", "hi", "pa"].includes(String(input.language))
    ? input.language
    : "en") as Language;
  const channel = input.channel === "sms" ? "sms" : "whatsapp";
  if (!/^[0-9a-f-]{36}$/i.test(tenantId)) return json({ error: "bad_request" }, 400);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: auth } } },
  );

  const { data: invite, error } = await supabase.rpc("create_member_invite", {
    p_tenant_id: tenantId,
    p_phone: String(input.phone ?? ""),
    p_role: String(input.role ?? ""),
    p_custom_permissions: input.custom_permissions ?? {},
    p_full_name: input.full_name ? String(input.full_name) : null,
    p_device_id: input.device_id ? String(input.device_id) : null,
  });
  if (error) {
    const code = errorCode(error.message);
    return json({ error: code }, code === "not_allowed" ? 403 : 400);
  }

  // Names for the message (RLS: members can read both).
  const { data: tenant } = await supabase.from("tenants").select("name")
    .eq("id", tenantId).maybeSingle();
  const { data: userData } = await supabase.auth.getUser();
  const { data: me } = await supabase.from("app_users").select("full_name")
    .eq("id", userData.user?.id ?? "").maybeSingle();

  const link = Deno.env.get("APP_URL") ?? "https://mandikhata.app";
  const message = inviteMessage(
    language,
    me?.full_name ?? "Your business owner",
    tenant?.name ?? "your business",
    invite.role,
    link,
  );

  let delivery: "whatsapp" | "sms" | "none" = "none";
  if (await sendTwilio(invite.phone, message, channel)) {
    delivery = channel;
  } else if (channel === "whatsapp" && await sendTwilio(invite.phone, message, "sms")) {
    delivery = "sms";
  }

  return json({ invite, delivery, message, link });
});
