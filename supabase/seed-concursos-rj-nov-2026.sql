-- Primeira carga de concursos do RJ conferidos em 17/11/2026.
-- Execute no Supabase SQL Editor. Os registros são inseridos apenas se ainda não existirem.
insert into public.contests (
  title, sphere, state, city, level, status, vacancies,
  registration_start, deadline, official_url, registration_url, source_url,
  last_verified_at
)
select
  'Prefeitura Municipal de Sumidouro - RJ — Edital nº 001/2026',
  'municipal', 'RJ', 'Sumidouro', null, 'open', 74,
  date '2026-11-12', date '2026-11-25',
  'https://w2l.selecao.net.br/informacoes/60/',
  'https://w2l.selecao.net.br/informacoes/60/',
  'https://concursor.com.br/editais/prefeitura-municipal-de-sumidouro-rj-edital-no-001-2026-evolucao-consultoria-ltda',
  now()
where not exists (
  select 1 from public.contests
  where title = 'Prefeitura Municipal de Sumidouro - RJ — Edital nº 001/2026'
);

insert into public.contests (
  title, sphere, state, city, level, status, vacancies,
  registration_start, deadline, official_url, registration_url, source_url,
  last_verified_at
)
select
  'Prefeitura Municipal de São Gonçalo - RJ — Guarda Municipal Nível II 2026',
  'municipal', 'RJ', 'São Gonçalo', null, 'open', 100,
  date '2026-09-28', date '2026-11-18',
  'https://selecon.selecao.net.br/informacoes/73/',
  'https://selecon.selecao.net.br/informacoes/73/',
  'https://concursor.com.br/editais/prefeitura-municipal-de-sao-goncalo-rj-guarda-municipal-nivel-ii-2026-selecon-instituto-nacional-de',
  now()
where not exists (
  select 1 from public.contests
  where title = 'Prefeitura Municipal de São Gonçalo - RJ — Guarda Municipal Nível II 2026'
);
