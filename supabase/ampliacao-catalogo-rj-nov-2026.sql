-- APROVEI — ampliação do catálogo RJ (verificação em 17/11/2026)
-- Fontes primárias: IBAM, Prefeitura de Saquarema, FGV/CRP-05 e MOBI-Rio.
-- Inclui apenas oportunidades com edital/página oficial localizados.
-- Script idempotente: pode ser executado novamente sem duplicar concursos, matérias ou assuntos.

begin;

-- 1) Oportunidades verificadas
insert into public.contests (
  title, sphere, state, city, level, status, vacancies,
  salary_min, salary_max, registration_start, deadline, exam_date,
  official_url, registration_url, source_url, last_verified_at
)
select
  'Prefeitura de Saquarema - RJ — Processo Seletivo Público Saúde 001/2026',
  'municipal','RJ','Saquarema','Nível médio','open',217,
  3242.00,3242.00,null,date '2026-12-22',date '2027-01-31',
  'https://www.saquarema.rj.gov.br/concursos/',
  'https://www.ibam-concursos.org.br/',
  'https://www.saquarema.rj.gov.br/prefeitura-abre-processo-seletivo-publico-para-vagas-na-area-da-saude/',
  now()
where not exists (select 1 from public.contests where title = 'Prefeitura de Saquarema - RJ — Processo Seletivo Público Saúde 001/2026');

insert into public.contests (
  title, sphere, state, city, level, status, vacancies,
  salary_min, salary_max, registration_start, deadline, exam_date,
  official_url, registration_url, source_url, last_verified_at
)
select
  'Conselho Regional de Psicologia da 5ª Região (CRP-05) — Concurso Público 01/2026',
  'federal','RJ','Rio de Janeiro','Médio e superior','open',37,
  3077.42,7313.35,date '2026-11-16',date '2026-12-17',date '2027-02-28',
  'https://conhecimento.fgv.br/crp05',
  'https://conhecimento.fgv.br/crp05',
  'https://conhecimento.fgv.br/sites/default/files/concursos/edital-01-2026-abertura-do-concurso-publico-crp-05.pdf',
  now()
where not exists (select 1 from public.contests where title = 'Conselho Regional de Psicologia da 5ª Região (CRP-05) — Concurso Público 01/2026');

insert into public.contests (
  title, sphere, state, city, level, status, vacancies,
  salary_min, salary_max, registration_start, deadline,
  official_url, registration_url, source_url, last_verified_at
)
select
  'MOBI-Rio — Processo Seletivo Simplificado 024/2026',
  'municipal','RJ','Rio de Janeiro','Fundamental e médio','open',63,
  1739.12,5960.63,date '2026-11-13',date '2026-11-21',null,
  'https://mobi-rio.rio.br/processoseletivomobirio/',
  'https://mobi-rio.rio.br/processoseletivomobirio/',
  'https://mobi-rio.rio.br/processoseletivomobirio/',
  now()
where not exists (select 1 from public.contests where title = 'MOBI-Rio — Processo Seletivo Simplificado 024/2026');

insert into public.contests (
  title, sphere, state, city, level, status, vacancies,
  exam_date, official_url, registration_url, source_url, last_verified_at
)
select
  'Prefeitura de São João de Meriti - RJ — Concurso Público Educação 01/2026',
  'municipal','RJ','São João de Meriti','Médio e superior','upcoming',546,
  date '2027-01-24',
  'https://www.ibam-concursos.org.br/',
  'https://www.ibam-concursos.org.br/',
  'https://www.ibam-concursos.org.br/documento/ed-sjm0126.pdf',
  now()
where not exists (select 1 from public.contests where title = 'Prefeitura de São João de Meriti - RJ — Concurso Público Educação 01/2026');

-- 2) Matérias do edital Saquarema e CRP-05
insert into public.subjects(name) values
 ('Legislação do SUS'),
 ('Conhecimentos Gerais do Município'),
 ('Conhecimentos Específicos - Agente Comunitário de Saúde'),
 ('Conhecimentos Específicos - Agente de Combate às Endemias'),
 ('Legislação Institucional e Ética'),
 ('Conhecimentos Específicos')
on conflict (name) do nothing;

-- 3) Assuntos do edital Saquarema (IBAM, Edital 001/2026)
with syllabus(subject_name, topic_name, ord) as (
 values
 ('Língua Portuguesa','Leitura e compreensão de textos; gêneros e modos de organização do discurso',1),
 ('Língua Portuguesa','Coesão, coerência, conectivos e relações entre partes do texto',2),
 ('Língua Portuguesa','Verbos, vozes verbais, transitividade, estrutura e formação de palavras',3),
 ('Língua Portuguesa','Classes de palavras, flexão nominal e verbal, regência',4),
 ('Língua Portuguesa','Pronomes, formas de tratamento e colocação',5),
 ('Língua Portuguesa','Figuras e funções da linguagem; sinônimos, antônimos, parônimos e homônimos',6),
 ('Língua Portuguesa','Acentuação, pontuação, sintaxe, coordenação, subordinação, crase e ortografia',7),
 ('Legislação do SUS','Sistemas de saúde e história das políticas de saúde no Brasil; Reforma Sanitária',1),
 ('Legislação do SUS','SUS: fundamentos, diretrizes, bases, organização e gestão',2),
 ('Legislação do SUS','Descentralização, regionalização, financiamento, regulação e participação popular',3),
 ('Legislação do SUS','Atenção Básica, Estratégia Saúde da Família e Redes de Atenção à Saúde',4),
 ('Legislação do SUS','Epidemiologia, prevenção de doenças, vigilância e promoção da saúde',5),
 ('Legislação do SUS','Constituição Federal, arts. 196 a 200; controle social e humanização',6),
 ('Legislação do SUS','Sistemas de informação em saúde e doenças de notificação compulsória',7),
 ('Conhecimentos Gerais do Município','História, cultura, símbolos, hino, turismo e dados de Saquarema',1),
 ('Conhecimentos Gerais do Município','Planos municipais, órgãos do governo e serviços públicos',2),
 ('Conhecimentos Gerais do Município','Alberto de Oliveira: dados biográficos',3),
 ('Conhecimentos Gerais do Município','Lei Orgânica do Município de Saquarema e atualizações',4),
 ('Conhecimentos Específicos - Agente Comunitário de Saúde','Rede de atenção à saúde e Estratégia Saúde da Família',1),
 ('Conhecimentos Específicos - Agente Comunitário de Saúde','Trabalho do ACS, família e problemas comuns na prática profissional',2),
 ('Conhecimentos Específicos - Agente Comunitário de Saúde','Vigilância em saúde, saneamento básico e processo saúde-doença',3),
 ('Conhecimentos Específicos - Agente Comunitário de Saúde','Estatuto da Pessoa Idosa e Estatuto da Criança e do Adolescente',4),
 ('Conhecimentos Específicos - Agente Comunitário de Saúde','Amamentação, vacinação e arboviroses',5),
 ('Conhecimentos Específicos - Agente Comunitário de Saúde','SUS, ética, cidadania e sistemas de informação em saúde',6),
 ('Conhecimentos Específicos - Agente Comunitário de Saúde','Promoção da saúde e determinantes e condicionantes das doenças',7),
 ('Conhecimentos Específicos - Agente de Combate às Endemias','Ética, cidadania e atuação do agente no serviço público',1),
 ('Conhecimentos Específicos - Agente de Combate às Endemias','SUS, vigilância e educação em saúde',2),
 ('Conhecimentos Específicos - Agente de Combate às Endemias','Epidemiologia, saneamento e determinantes ambientais das doenças',3),
 ('Conhecimentos Específicos - Agente de Combate às Endemias','Sistemas de informação em saúde e visita domiciliar',4),
 ('Conhecimentos Específicos - Agente de Combate às Endemias','Territorialização, cadastramento de imóveis e áreas de risco',5),
 ('Conhecimentos Específicos - Agente de Combate às Endemias','Doenças: leishmaniose, cólera, dengue, Chagas, esquistossomose, raiva, leptospirose, peste, malária, esporotricose e febre amarela',6),
 ('Conhecimentos Específicos - Agente de Combate às Endemias','Biologia dos vetores, reconhecimento geográfico e operações de campo',7),
 ('Conhecimentos Específicos - Agente de Combate às Endemias','Controle químico, biológico e integrado; EPI e segurança do trabalho',8),
 ('Conhecimentos Específicos - Agente de Combate às Endemias','Organização de campo e relação entre ambiente, saneamento e doenças',9)
)
insert into public.topics(subject_id,name,sort_order)
select s.id,syllabus.topic_name,syllabus.ord
from syllabus join public.subjects s on s.name=syllabus.subject_name
on conflict (subject_id,name) do nothing;

-- 4) Assuntos gerais do edital CRP-05; conhecimentos específicos variam por cargo.
with syllabus(subject_name, topic_name, ord) as (
 values
 ('Língua Portuguesa','Interpretação, compreensão, estrutura e organização dos textos',1),
 ('Língua Portuguesa','Coesão, coerência, intertextualidade e modos de organização discursiva',2),
 ('Língua Portuguesa','Tipos textuais, tipologia da frase e estrutura sintática',3),
 ('Língua Portuguesa','Linguagem, registros, funções, comunicação e formação de palavras',4),
 ('Língua Portuguesa','Classes de palavras e aspectos morfológicos, sintáticos, semânticos e textuais',5),
 ('Língua Portuguesa','Semântica, vocabulário, dicionários, ortografia e acentuação',6),
 ('Legislação Institucional e Ética','Lei nº 5.766/1971 e Decreto nº 79.822/1977: Sistema Conselhos de Psicologia',1),
 ('Legislação Institucional e Ética','Lei nº 4.119/1962: regulamentação da profissão de psicólogo',2),
 ('Legislação Institucional e Ética','Regimentos internos do CFP e do CRP-05',3),
 ('Legislação Institucional e Ética','Código de Ética Profissional e Código de Processamento Disciplinar',4),
 ('Legislação Institucional e Ética','Resoluções e notas técnicas do CFP previstas no edital',5),
 ('Legislação Institucional e Ética','ECA, Estatuto da Pessoa Idosa e Estatuto da Pessoa com Deficiência',6),
 ('Legislação Institucional e Ética','Lei nº 11.788/2008 e normas de estágio em Psicologia',7),
 ('Legislação Institucional e Ética','Lei nº 13.140/2015: mediação de conflitos',8),
 ('Raciocínio Lógico','Proposições, conectivos, equivalências, quantificadores e predicados',1),
 ('Raciocínio Lógico','Conjuntos, operações e diagramas',2),
 ('Raciocínio Lógico','Números, operações, porcentagem e proporcionalidade',3),
 ('Raciocínio Lógico','Medidas de comprimento, área, volume, massa e tempo',4),
 ('Raciocínio Lógico','Relações arbitrárias, dedução e análise de condições',5),
 ('Raciocínio Lógico','Raciocínio verbal, matemático, sequencial, espacial e temporal',6),
 ('Raciocínio Lógico','Interpretação de gráficos, tabelas e problemas de lógica',7),
 ('Conhecimentos Específicos','Conteúdo específico conforme o cargo: Contador, Jornalista, Psicóloga(o), Agente Administrativo e demais funções previstas no edital',1)
)
insert into public.topics(subject_id,name,sort_order)
select s.id,syllabus.topic_name,syllabus.ord
from syllabus join public.subjects s on s.name=syllabus.subject_name
on conflict (subject_id,name) do nothing;

-- 5) Vínculo das matérias ao concurso. São matérias oficiais, não recomendações genéricas.
insert into public.contest_subjects(contest_id,subject_id,priority,suggested_weekly_minutes)
select c.id,s.id,4,120
from public.contests c
join public.subjects s on s.name in (
 'Língua Portuguesa','Legislação do SUS','Conhecimentos Gerais do Município',
 'Conhecimentos Específicos - Agente Comunitário de Saúde',
 'Conhecimentos Específicos - Agente de Combate às Endemias'
)
where c.title='Prefeitura de Saquarema - RJ — Processo Seletivo Público Saúde 001/2026'
on conflict (contest_id,subject_id) do nothing;

insert into public.contest_subjects(contest_id,subject_id,priority,suggested_weekly_minutes)
select c.id,s.id,4,120
from public.contests c
join public.subjects s on s.name in (
 'Língua Portuguesa','Legislação Institucional e Ética','Raciocínio Lógico','Conhecimentos Específicos'
)
where c.title='Conselho Regional de Psicologia da 5ª Região (CRP-05) — Concurso Público 01/2026'
on conflict (contest_id,subject_id) do nothing;

commit;
