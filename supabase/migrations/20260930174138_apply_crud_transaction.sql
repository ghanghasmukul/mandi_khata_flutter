-- Step 1.1: upload one local transaction all-or-nothing (phase 0 review R3).
--
-- The app used to send each change of a local transaction as its own
-- request, so a rejected change could leave the rest (e.g. its audit row, or
-- one half of a reversal pair) on the server. This function applies every
-- change of one local transaction inside a single database transaction: if
-- any change fails, none are kept, and the error's HINT says which one
-- ("op 3").
--
-- SECURITY INVOKER: RLS, grants and guard triggers apply exactly as for a
-- direct request. Only tables in the `powersync` publication can be touched
-- and only real columns are written; names are quoted with %I.
--
-- ops: [{"op": "PUT" | "PATCH" | "DELETE", "table": "...", "id": "...",
--        "data": {...}}]
--   PUT    insert; on an existing id: update (tables the user may update)
--          or skip (append-only tables: a retry of a row that already landed)
--   PATCH  update the given columns; no row changed (missing or hidden by
--          RLS) is an error, never a silent success
--   DELETE delete; no row deleted is an error

create or replace function public.apply_crud_transaction(ops jsonb)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_op jsonb;
  v_index int := 0;
  v_kind text;
  v_table text;
  v_id uuid;
  v_data jsonb;
  v_keys text[];
  v_unknown text;
  v_cols text;
  v_rows int;
  v_state text;
  v_message text;
  v_detail text;
begin
  if jsonb_typeof(ops) is distinct from 'array' then
    raise exception 'ops must be a JSON array' using errcode = '22023';
  end if;

  begin
    for v_op in select value from jsonb_array_elements(ops) loop
      v_index := v_index + 1;
      v_kind := v_op ->> 'op';
      v_table := v_op ->> 'table';
      v_id := (v_op ->> 'id')::uuid;
      v_data := coalesce(v_op -> 'data', '{}'::jsonb) - 'id';

      if v_id is null then
        raise exception 'id is required' using errcode = '22023';
      end if;
      if not exists (
        select 1 from pg_catalog.pg_publication_tables p
        where p.pubname = 'powersync' and p.schemaname = 'public'
          and p.tablename = v_table
      ) then
        raise exception 'table % is not synced', v_table using errcode = '42501';
      end if;
      if jsonb_typeof(v_data) is distinct from 'object' then
        raise exception 'data must be a JSON object' using errcode = '22023';
      end if;

      select array_agg(k order by k) into v_keys from jsonb_object_keys(v_data) k;
      v_keys := coalesce(v_keys, '{}');
      select k into v_unknown from unnest(v_keys) k
      where not exists (
        select 1 from pg_catalog.pg_attribute a
        where a.attrelid = pg_catalog.format('public.%I', v_table)::regclass
          and a.attname = k and a.attnum > 0 and not a.attisdropped
      )
      limit 1;
      if v_unknown is not null then
        raise exception 'column %.% does not exist', v_table, v_unknown
          using errcode = '42703';
      end if;

      case v_kind
        when 'PUT' then
          v_keys := array_prepend('id', v_keys);
          v_data := v_data || jsonb_build_object('id', v_id);
          select string_agg(pg_catalog.format('%I', k), ', ') into v_cols
          from unnest(v_keys) k;
          if pg_catalog.has_table_privilege(
            pg_catalog.format('public.%I', v_table), 'UPDATE'
          ) then
            execute pg_catalog.format(
              'insert into public.%1$I (%2$s) '
              'select %2$s from pg_catalog.jsonb_populate_record(null::public.%1$I, $1) '
              'on conflict (id) do update set %3$s',
              v_table,
              v_cols,
              coalesce(
                (select string_agg(pg_catalog.format('%1$I = excluded.%1$I', k), ', ')
                 from unnest(v_keys) k where k <> 'id'),
                'id = excluded.id'
              )
            ) using v_data;
          else
            execute pg_catalog.format(
              'insert into public.%1$I (%2$s) '
              'select %2$s from pg_catalog.jsonb_populate_record(null::public.%1$I, $1) '
              'on conflict (id) do nothing',
              v_table,
              v_cols
            ) using v_data;
          end if;

        when 'PATCH' then
          if cardinality(v_keys) > 0 then
            execute pg_catalog.format(
              'update public.%1$I t set %2$s '
              'from pg_catalog.jsonb_populate_record(null::public.%1$I, $1) r '
              'where t.id = $2',
              v_table,
              (select string_agg(pg_catalog.format('%1$I = r.%1$I', k), ', ')
               from unnest(v_keys) k)
            ) using v_data, v_id;
            get diagnostics v_rows = row_count;
            if v_rows = 0 then
              raise exception '%/% not found or not allowed to change', v_table, v_id
                using errcode = '42501';
            end if;
          end if;

        when 'DELETE' then
          execute pg_catalog.format('delete from public.%I where id = $1', v_table)
            using v_id;
          get diagnostics v_rows = row_count;
          if v_rows = 0 then
            raise exception '%/% not found or not allowed to delete', v_table, v_id
              using errcode = '42501';
          end if;

        else
          raise exception 'unknown op %', v_kind using errcode = '22023';
      end case;
    end loop;
  exception when others then
    -- Re-raise with the position of the failing change; raising rolls back
    -- every change made above.
    get stacked diagnostics
      v_state = returned_sqlstate,
      v_message = message_text,
      v_detail = pg_exception_detail;
    raise exception '%', v_message
      using errcode = v_state, detail = coalesce(v_detail, ''),
        hint = pg_catalog.format('op %s', v_index);
  end;
end;
$$;

revoke execute on function public.apply_crud_transaction(jsonb) from public, anon;
grant execute on function public.apply_crud_transaction(jsonb) to authenticated;
