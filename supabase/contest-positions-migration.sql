-- APROVEI — planejamento por cargo/emprego e conteúdo programático
-- Etapa 3: estrutura de cargos e disciplinas específicas por cargo.
-- Seguro para reexecução: tabelas, colunas, índices e políticas idempotentes.

begin;

create table if not exists public.contest_positions (
  id uuid primary key default gen_random_uuid(),
  contest_id uuid not null references public.contests(id) on delete cascade,
  title text not null,
  vacancies integer,
  level text,
  salary_min numeric(12,2),
  salary_max numeric(12,2),
  source_url text,
  notes text,
  created_at timestamptz not null default now(),
  unique (contest_id, title),
  unique (id, contest_id)
);

create table if not exists public.contest_position_subjects (
  id uuid primary key default gen_random_uuid(),
  position_id uuid not null references public.contest_positions(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  priority integer not null default 1 check (priority >= 0),
  suggested_weekly_minutes integer not null default 120
    check (suggested_weekly_minutes between 15 and 10080),
  created_at timestamptz not null default now(),
  unique (position_id, subject_id)
);

alter table public.study_plans
  add column if not exists position_id uuid;

-- Garante que o cargo selecionado pertença ao mesmo concurso do plano.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'study_plans_position_contest_fk'
      and conrelid = 'public.study_plans'::regclass
  ) then
    alter table public.study_plans
      add constraint study_plans_position_contest_fk
      foreign key (position_id, contest_id)
      references public.contest_positions(id, contest_id)
      on delete set null (position_id);
  end if;
end;
$$;

create index if not exists contest_positions_contest_idx
  on public.contest_positions(contest_id, title);
create index if not exists contest_position_subjects_position_idx
  on public.contest_position_subjects(position_id, priority desc);
create index if not exists study_plans_position_idx
  on public.study_plans(position_id);

alter table public.contest_positions enable row level security;
alter table public.contest_position_subjects enable row level security;

drop policy if exists "Contest positions are readable" on public.contest_positions;
create policy "Contest positions are readable"
  on public.contest_positions for select using (true);

drop policy if exists "Contest position subjects are readable" on public.contest_position_subjects;
create policy "Contest position subjects are readable"
  on public.contest_position_subjects for select using (true);

-- 1) Cargos identificados de forma expressa nos editais já cadastrados.
insert into public.contest_positions (
  contest_id, title, vacancies, level, salary_min, salary_max, source_url, notes
)
select c.id, p.title, p.vacancies, p.level, p.salary_min, p.salary_max, p.source_url, p.notes
from public.contests c
cross join (values
  (
    'Guarda Municipal Nível II',
    100,
    'Nível médio',
    null::numeric,
    null::numeric,
    'https://anexos-r2.selecao.net.br/uploads/746/concursos/73/anexos/70806270-5032-4fd8-afb7-6a89b5327fc8.pdf',
    'Cargo conforme Edital 001/PMSG/2026 e retificações.'
  )
) as p(title, vacancies, level, salary_min, salary_max, source_url, notes)
where c.title = 'Prefeitura Municipal de São Gonçalo - RJ — Guarda Municipal Nível II 2026'
on conflict (contest_id, title) do update set
  vacancies = excluded.vacancies,
  level = excluded.level,
  source_url = excluded.source_url,
  notes = excluded.notes;

insert into public.contest_positions (
  contest_id, title, vacancies, level, salary_min, salary_max, source_url, notes
)
select c.id, p.title, p.vacancies, p.level, p.salary_min, p.salary_max, p.source_url, p.notes
from public.contests c
cross join (values
  (
    'Agente Comunitário de Saúde (ACS)',
    null::integer,
    'Nível médio',
    null::numeric,
    null::numeric,
    'https://www.ibam-concursos.org.br/documento/ed26_acs_ace.pdf',
    'Vagas e remuneração devem ser consultadas por função no edital oficial.'
  ),
  (
    'Agente de Combate às Endemias (ACE)',
    null::integer,
    'Nível médio',
    null::numeric,
    null::numeric,
    'https://www.ibam-concursos.org.br/documento/ed26_acs_ace.pdf',
    'Vagas e remuneração devem ser consultadas por função no edital oficial.'
  )
) as p(title, vacancies, level, salary_min, salary_max, source_url, notes)
where c.title = 'Prefeitura de Saquarema - RJ — Processo Seletivo Público Saúde 001/2026'
on conflict (contest_id, title) do update set
  level = excluded.level,
  source_url = excluded.source_url,
  notes = excluded.notes;

-- 2) Disciplinas por cargo: Guarda Municipal de São Gonçalo.
insert into public.contest_position_subjects (
  position_id, subject_id, priority, suggested_weekly_minutes
)
select p.id, s.id,
  case s.name
    when 'Língua Portuguesa' then 5
    when 'Direito Constitucional' then 5
    when 'Direito Penal' then 5
    when 'Direito Processual Penal' then 4
    when 'Direito Administrativo' then 4
    when 'Legislação Extravagante' then 5
    when 'Conhecimentos Específicos - Guarda Municipal' then 5
    else 3
  end,
  case s.name
    when 'Língua Portuguesa' then 180
    when 'Direito Constitucional' then 150
    when 'Direito Penal' then 150
    when 'Direito Processual Penal' then 120
    when 'Direito Administrativo' then 120
    when 'Legislação Extravagante' then 150
    when 'Conhecimentos Específicos - Guarda Municipal' then 120
    else 120
  end
from public.contest_positions p
join public.contests c on c.id = p.contest_id
join public.subjects s on s.name in (
  'Língua Portuguesa',
  'Direito Constitucional',
  'Direito Penal',
  'Direito Processual Penal',
  'Direito Administrativo',
  'Legislação Extravagante',
  'Conhecimentos Específicos - Guarda Municipal',
  'Informática'
)
where c.title = 'Prefeitura Municipal de São Gonçalo - RJ — Guarda Municipal Nível II 2026'
  and p.title = 'Guarda Municipal Nível II'
on conflict (position_id, subject_id) do update set
  priority = excluded.priority,
  suggested_weekly_minutes = excluded.suggested_weekly_minutes;

-- 3) Disciplinas comuns e específicas do cargo ACS.
insert into public.contest_position_subjects (
  position_id, subject_id, priority, suggested_weekly_minutes
)
select p.id, s.id,
  case when s.name like 'Conhecimentos Específicos%' then 5 else 4 end,
  case s.name
    when 'Língua Portuguesa' then 150
    when 'Legislação do SUS' then 150
    when 'Conhecimentos Gerais do Município' then 90
    else 150
  end
from public.contest_positions p
join public.contests c on c.id = p.contest_id
join public.subjects s on s.name in (
  'Língua Portuguesa',
  'Legislação do SUS',
  'Conhecimentos Gerais do Município',
  'Conhecimentos Específicos - Agente Comunitário de Saúde'
)
where c.title = 'Prefeitura de Saquarema - RJ — Processo Seletivo Público Saúde 001/2026'
  and p.title = 'Agente Comunitário de Saúde (ACS)'
on conflict (position_id, subject_id) do update set
  priority = excluded.priority,
  suggested_weekly_minutes = excluded.suggested_weekly_minutes;

-- 4) Disciplinas comuns e específicas do cargo ACE.
insert into public.contest_position_subjects (
  position_id, subject_id, priority, suggested_weekly_minutes
)
select p.id, s.id,
  case when s.name like 'Conhecimentos Específicos%' then 5 else 4 end,
  case s.name
    when 'Língua Portuguesa' then 150
    when 'Legislação do SUS' then 150
    when 'Conhecimentos Gerais do Município' then 90
    else 150
  end
from public.contest_positions p
join public.contests c on c.id = p.contest_id
join public.subjects s on s.name in (
  'Língua Portuguesa',
  'Legislação do SUS',
  'Conhecimentos Gerais do Município',
  'Conhecimentos Específicos - Agente de Combate às Endemias'
)
where c.title = 'Prefeitura de Saquarema - RJ — Processo Seletivo Público Saúde 001/2026'
  and p.title = 'Agente de Combate às Endemias (ACE)'
on conflict (position_id, subject_id) do update set
  priority = excluded.priority,
  suggested_weekly_minutes = excluded.suggested_weekly_minutes;

commit;
