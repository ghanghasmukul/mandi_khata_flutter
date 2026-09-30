-- Step 0.4: logical-replication publication that PowerSync reads from.
--
-- PowerSync requires the name `powersync`. Tables are listed explicitly
-- (not FOR ALL TABLES) so a future server-only table is never streamed by
-- accident; every new synced table must be added here and to
-- powersync/sync-streams.yaml.
--
-- The replication login role (`powersync_role`) has a password, so it is
-- created by hand in the dashboard, not here — see docs/SETUP.md.

create publication powersync for table
  public.tenants,
  public.app_users,
  public.tenant_members,
  public.devices,
  public.settings,
  public.audit_log,
  public.parties,
  public.party_roles,
  public.number_series;
