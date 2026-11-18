-- APROVEI — migração do módulo de planejamento
-- Execute este arquivo uma única vez no Supabase: SQL Editor > New query.
-- Compatível com o esquema inicial em supabase/schema.sql.

begin;

create table if not exists public.study_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  contest_id uuid not null references public.contests(id) on delete restrict,
  title text not null default 'Meu planejamento',
  mode text not null check (mode in ('automatic', 'student')),
  daily_goal_minutes integer not null check (daily_goal_minutes between 15 and 1440),
  weekly_goal_minutes integer not null default 1 check (weekly_goal_minutes > 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id)
);

create table if not exists public.study_plan_items (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete restrict,
  weekday smallint not null check (weekday between 0 and 6),
  duration_minutes integer not null check (duration_minutes between 1 and 1440),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  foreign key (plan_id, user_id)
    references public.study_plans(id, user_id) on delete cascade
);

create table if not exists public.contest_subjects (
  id uuid primary key default gen_random_uuid(),
  contest_id uuid not null references public.contests(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  priority integer not null default 1 check (priority >= 0),
  suggested_weekly_minutes integer not null default 120
    check (suggested_weekly_minutes between 15 and 10080),
  created_at timestamptz not null default now(),
  unique (contest_id, subject_id)
);

create index if not exists study_plans_user_active_idx
  on public.study_plans (user_id, is_active, created_at desc);

create index if not exists study_plan_items_plan_idx
  on public.study_plan_items (plan_id, weekday, sort_order);

create index if not exists study_plan_items_user_idx
  on public.study_plan_items (user_id);

create index if not exists contest_subjects_contest_idx
  on public.contest_subjects (contest_id, priority desc);

alter table public.study_plans enable row level security;
alter table public.study_plan_items enable row level security;
alter table public.contest_subjects enable row level security;

drop policy if exists "Users manage own study plans" on public.study_plans;
create policy "Users manage own study plans"
  on public.study_plans
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Users manage own study plan items" on public.study_plan_items;
create policy "Users manage own study plan items"
  on public.study_plan_items
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Contest subjects are readable" on public.contest_subjects;
create policy "Contest subjects are readable"
  on public.contest_subjects
  for select
  using (true);

commit;
