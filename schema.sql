-- APROVEI: esquema inicial. Execute no SQL Editor do projeto Supabase.
-- Não coloque service_role key no navegador. RLS protege dados pessoais.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.contests (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  sphere text not null check (sphere in ('federal','state','municipal')),
  state char(2),
  city text,
  level text,
  status text not null default 'draft' check (status in ('draft','open','upcoming','closed','suspended')),
  vacancies integer,
  salary_min numeric(12,2),
  salary_max numeric(12,2),
  registration_start date,
  deadline date,
  exam_date date,
  official_url text,
  registration_url text,
  source_url text,
  last_verified_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.topics (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete cascade,
  name text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique(subject_id, name)
);

create table if not exists public.video_lessons (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references public.topics(id) on delete cascade,
  title text not null,
  youtube_video_id text not null,
  channel_name text,
  duration_seconds integer,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  unique(youtube_video_id, topic_id)
);

create table if not exists public.study_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  topic_id uuid not null references public.topics(id) on delete cascade,
  status text not null default 'not_started' check (status in ('not_started','studying','completed')),
  updated_at timestamptz not null default now(),
  unique(user_id, topic_id)
);

create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subject_id uuid references public.subjects(id) on delete set null,
  topic_id uuid references public.topics(id) on delete set null,
  duration_minutes integer not null check (duration_minutes > 0),
  notes text,
  studied_at timestamptz not null default now()
);

create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  plan text not null check (plan in ('essencial','avancado','aprovacao')),
  status text not null default 'pending' check (status in ('pending','authorized','paused','cancelled','past_due')),
  provider text not null default 'mercado_pago',
  provider_subscription_id text,
  current_period_end timestamptz,
  created_at timestamptz not null default now()
);

-- Criar perfil automaticamente no cadastro.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name',''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.contests enable row level security;
alter table public.subjects enable row level security;
alter table public.topics enable row level security;
alter table public.video_lessons enable row level security;
alter table public.study_progress enable row level security;
alter table public.study_sessions enable row level security;
alter table public.subscriptions enable row level security;

-- Conteúdo publicado é público para leitura; edição será feita por backend/admin.
create policy "Published contests are readable" on public.contests
for select using (status = 'open' or status = 'upcoming');

create policy "Subjects readable by everyone" on public.subjects
for select using (true);
create policy "Topics readable by everyone" on public.topics
for select using (true);
create policy "Published videos readable" on public.video_lessons
for select using (is_published = true);

create policy "Users read own profile" on public.profiles
for select to authenticated using (auth.uid() = id);
create policy "Users update own profile" on public.profiles
for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

create policy "Users manage own progress" on public.study_progress
for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users manage own sessions" on public.study_sessions
for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users read own subscription" on public.subscriptions
for select to authenticated using (auth.uid() = user_id);

-- Importante: não criar política pública de INSERT/UPDATE/DELETE em concursos,
-- videoaulas ou assinaturas. Esses dados devem ser administrados por backend seguro.

insert into public.subjects(name) values
('Língua Portuguesa'),('Matemática'),('Raciocínio Lógico'),('Informática'),
('Direito Constitucional'),('Direito Administrativo'),('Administração Pública'),
('Ética no Serviço Público'),('Atualidades'),('Redação')
on conflict (name) do nothing;