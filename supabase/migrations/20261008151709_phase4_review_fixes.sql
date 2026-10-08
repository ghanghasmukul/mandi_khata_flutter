-- Phase 4 review fixes: close the reverse-vs-return race on the server.
-- A return may not join a reversed sale / purchase, and a sale / purchase
-- may not be reversed while a posted return exists for it. The parent row is
-- locked FOR SHARE by the return insert, so a concurrent reversal (which
-- needs the row lock for UPDATE) and a return serialise, and whichever comes
-- second sees the other's result.

create or replace function private.guard_shop_return_parent()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_status text;
begin
  select s.status into v_status
  from public.shop_sales s
  where s.id = new.sale_id and s.tenant_id = new.tenant_id
  for share;
  if v_status = 'reversed' then
    raise exception 'a reversed sale cannot take a return' using errcode = '23514';
  end if;
  return new;
end;
$$;

create or replace function private.guard_purchase_return_parent()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_status text;
begin
  select p.status into v_status
  from public.purchases p
  where p.id = new.purchase_id and p.tenant_id = new.tenant_id
  for share;
  if v_status = 'reversed' then
    raise exception 'a reversed purchase cannot take a return' using errcode = '23514';
  end if;
  return new;
end;
$$;

create or replace function private.guard_shop_sale_reversal()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status = 'reversed' and old.status is distinct from 'reversed' and exists (
    select 1 from public.shop_returns r
    where r.sale_id = new.id and r.tenant_id = new.tenant_id and r.status <> 'reversed'
  ) then
    raise exception 'a sale with a posted return cannot be reversed' using errcode = '23514';
  end if;
  return new;
end;
$$;

create or replace function private.guard_purchase_reversal()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status = 'reversed' and old.status is distinct from 'reversed' and exists (
    select 1 from public.purchase_returns r
    where r.purchase_id = new.id and r.tenant_id = new.tenant_id and r.status <> 'reversed'
  ) then
    raise exception 'a purchase with a posted return cannot be reversed'
      using errcode = '23514';
  end if;
  return new;
end;
$$;

revoke execute on function private.guard_shop_return_parent(),
  private.guard_purchase_return_parent(),
  private.guard_shop_sale_reversal(),
  private.guard_purchase_reversal() from public, anon, authenticated;

create trigger shop_returns_guard_parent before insert on public.shop_returns
  for each row execute function private.guard_shop_return_parent();
create trigger purchase_returns_guard_parent before insert on public.purchase_returns
  for each row execute function private.guard_purchase_return_parent();
create trigger shop_sales_guard_reversal before update on public.shop_sales
  for each row execute function private.guard_shop_sale_reversal();
create trigger purchases_guard_reversal before update on public.purchases
  for each row execute function private.guard_purchase_reversal();
