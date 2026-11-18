-- APROVEI | Painel nacional de concursos e autorizações
-- Esta tabela é separada de concursos com edital publicado.
-- Não exige disciplinas, assuntos ou materiais de estudo.

begin;

create table if not exists public.contest_authorizations (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  agency text not null,
  sphere text not null default 'state'
    check (sphere in ('federal','state','municipal')),
  state char(2),
  city text,
  positions text,
  vacancies integer,
  salary_min numeric(12,2),
  salary_max numeric(12,2),
  status text not null default 'authorized'
    check (status in ('authorized','commission_formed','organizing_board','in_preparation')),
  authorized_at date,
  source_url text,
  notes text,
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists contest_authorizations_state_idx
  on public.contest_authorizations(state);
create index if not exists contest_authorizations_status_idx
  on public.contest_authorizations(status);
create index if not exists contest_authorizations_authorized_at_idx
  on public.contest_authorizations(authorized_at desc);

alter table public.contest_authorizations enable row level security;
drop policy if exists "Public can read contest authorizations" on public.contest_authorizations;
create policy "Public can read contest authorizations"
  on public.contest_authorizations for select using (true);

commit;

-- Inserções e atualizações desta tabela devem ser feitas por administração
-- segura (Supabase SQL Editor/service role), nunca pelo navegador do aluno.
