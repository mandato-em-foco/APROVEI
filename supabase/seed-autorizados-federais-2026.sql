-- APROVEI | Primeiras autorizações federais confirmadas em fonte oficial
-- Dados conferidos em publicação do Ministério da Gestão em 16/07/2026.
-- Reexecução segura: evita duplicar órgão + título.

insert into public.contest_authorizations
  (title, agency, sphere, state, positions, vacancies, status, authorized_at, source_url, notes, last_verified_at)
select v.title, v.agency, v.sphere, v.state, v.positions, v.vacancies, v.status,
       v.authorized_at::date, v.source_url, v.notes, now()
from (values
  (
    'Concurso Receita Federal 2026',
    'Secretaria Especial da Receita Federal do Brasil',
    'federal', null::char(2),
    'Analista Tributário (116); Auditor-Fiscal (30)',
    146, 'authorized', '2026-07-03',
    'https://www.gov.br/gestao/pt-br/assuntos/editoria-defeso-eleitoral/publicadas-portarias-que-autorizam-concurso-na-receita-federal-e-no-banco-central',
    'Autorização pela Portaria MGI nº 5.505/2026. Edital ainda não publicado na data da verificação.',
    null::text
  ),
  (
    'Concurso Banco Central 2026',
    'Banco Central do Brasil',
    'federal', null::char(2),
    'Auditor (100); Técnico (50); Procurador (20)',
    170, 'authorized', '2026-07-03',
    'https://www.bcb.gov.br/acessoinformacao/concursospublicos',
    'Autorização pela Portaria MGI nº 5.508/2026. A página oficial do Banco Central informa que o edital ainda não foi publicado.',
    null::text
  )
) as v(title, agency, sphere, state, positions, vacancies, status, authorized_at, source_url, notes, unused)
where not exists (
  select 1 from public.contest_authorizations a
  where a.title = v.title and a.agency = v.agency
);
