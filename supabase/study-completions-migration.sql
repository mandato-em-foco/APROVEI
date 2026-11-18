-- APROVEI — registro de sessões de estudo concluídas
-- Execute no Supabase: SQL Editor > New query.
-- A conclusão é registrada por sessão e por data, permitindo repetir a grade semanal.

begin;

create table if not exists public.study_plan_item_completions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plan_item_id uuid not null references public.study_plan_items(id) on delete cascade,
  completed_on date not null default current_date,
  completed_at timestamptz not null default now(),
  unique (user_id, plan_item_id, completed_on)
);

create index if not exists study_plan_item_completions_user_date_idx
  on public.study_plan_item_completions (user_id, completed_on);

alter table public.study_plan_item_completions enable row level security;

drop policy if exists "Users manage own study completions"
  on public.study_plan_item_completions;

create policy "Users manage own study completions"
  on public.study_plan_item_completions
  for all
  to authenticated
  using (
    auth.uid() = user_id
    and exists (
      select 1
      from public.study_plan_items item
      where item.id = plan_item_id
        and item.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() = user_id
    and exists (
      select 1
      from public.study_plan_items item
      where item.id = plan_item_id
        and item.user_id = auth.uid()
    )
  );

commit;
