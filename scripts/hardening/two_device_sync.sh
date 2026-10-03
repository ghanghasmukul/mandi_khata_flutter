#!/usr/bin/env bash
# Runs the two-device conflict test against the LOCAL Supabase stack.
# Needs Docker and `supabase start` (or `supabase db reset` after it).
set -euo pipefail
cd "$(dirname "$0")/../.."
eval "$(supabase status -o env 2>/dev/null | grep -E '^(API_URL|ANON_KEY|SERVICE_ROLE_KEY)=')"
cd apps/mandi_khata_app
MK_LOCAL_API_URL="$API_URL" MK_LOCAL_ANON_KEY="$ANON_KEY" \
  MK_LOCAL_SERVICE_KEY="$SERVICE_ROLE_KEY" \
  flutter test test/hardening/two_device_sync_test.dart "$@"
