-- APROVEI — conclusão automática e protegida das sessões planejadas
-- Execute no Supabase: SQL Editor > New query.
-- Uma sessão de estudo registrada conclui automaticamente um único item
-- pendente da mesma matéria e do mesmo dia, em um planejamento ativo.

begin;

drop policy if exists "Users manage own study completions"
  on public.study_plan_item_completions;
drop policy if exists "Users read own study completions"
  on public.study_plan_item_completions;

-- Os registros anteriores dependiam de marcação manual e não são confiáveis.
-- Reinicia as conclusões para que, daqui em diante, só o gatilho automático registre.
delete from public.study_plan_item_completions;

create policy "Users read own study completions"
  on public.study_plan_item_completions
  for select
  to authenticated
  using (auth.uid() = user_id);

revoke insert, update, delete
  on public.study_plan_item_completions
  from anon, authenticated;

grant select
  on public.study_plan_item_completions
  to authenticated;

create or replace function public.mark_planned_study_completed()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  local_study_at timestamp;
  local_study_date date;
  study_weekday integer;
  matching_item_id uuid;
begin
  if new.subject_id is null then
    return new;
  end if;

  local_study_at := new.studied_at at time zone 'America/Sao_Paulo';
  local_study_date := local_study_at::date;
  study_weekday := extract(dow from local_study_at)::integer;

  select item.id
    into matching_item_id
  from public.study_plan_items item
  join public.study_plans plan
    on plan.id = item.plan_id
   and plan.user_id = item.user_id
  where item.user_id = new.user_id
    and item.subject_id = new.subject_id
    and item.weekday = study_weekday
    and plan.is_active = true
    and not exists (
      select 1
      from public.study_plan_item_completions completion
      where completion.user_id = new.user_id
        and completion.plan_item_id = item.id
        and completion.completed_on = local_study_date
    )
  order by item.sort_order asc, item.created_at asc, item.id asc
  limit 1;

  if matching_item_id is not null then
    insert into public.study_plan_item_completions (
      user_id, plan_item_id, completed_on, completed_at
    )
    values (
      new.user_id, matching_item_id, local_study_date, new.studied_at
    )
    on conflict (user_id, plan_item_id, completed_on) do nothing;
  end if;

  return new;
end;
$$;

revoke all on function public.mark_planned_study_completed() from public, anon, authenticated;

drop trigger if exists trg_mark_planned_study_completed
  on public.study_sessions;

create trigger trg_mark_planned_study_completed
after insert on public.study_sessions
for each row
execute function public.mark_planned_study_completed();

commit;
