-- APROVEI — conteúdo programático oficial: Guarda Municipal de São Gonçalo/RJ
-- Fonte: Edital 001/PMSG/2026 consolidado com Retificações 01 e 02 (16/10/2026).
-- Execute uma única vez no Supabase SQL Editor. Script idempotente.

begin;

insert into public.subjects(name) values
  ('Direito Penal'),
  ('Direito Processual Penal'),
  ('Legislação Extravagante'),
  ('Conhecimentos Específicos - Guarda Municipal')
on conflict (name) do nothing;

with syllabus(subject_name, topic_name, sort_order) as (
  values
  ('Língua Portuguesa','Compreensão e interpretação de textos de gêneros variados',1),
  ('Língua Portuguesa','Reconhecimento de tipos e gêneros textuais',2),
  ('Língua Portuguesa','Ortografia oficial, emprego das letras e acentuação gráfica',3),
  ('Língua Portuguesa','Coesão textual, referenciação, substituição, repetição e conectores',4),
  ('Língua Portuguesa','Emprego e correlação de tempos e modos verbais',5),
  ('Língua Portuguesa','Estrutura morfossintática do período e classes de palavras',6),
  ('Língua Portuguesa','Coordenação e subordinação entre orações e termos da oração',7),
  ('Língua Portuguesa','Pontuação, concordância verbal e nominal',8),
  ('Língua Portuguesa','Emprego do sinal indicativo de crase',9),
  ('Língua Portuguesa','Colocação dos pronomes átonos',10),
  ('Língua Portuguesa','Reescrita de textos de diferentes gêneros e níveis de formalidade',11),
  ('Língua Portuguesa','Correspondência oficial e Manual de Redação da Presidência da República',12),
  ('Língua Portuguesa','Adequação da linguagem ao documento e do formato ao gênero',13),

  ('Direito Constitucional','Princípios fundamentais da Constituição Federal (arts. 1º a 4º)',1),
  ('Direito Constitucional','Direitos e garantias fundamentais: direitos individuais, coletivos e sociais',2),
  ('Direito Constitucional','Nacionalidade e direitos políticos (arts. 5º a 16)',3),
  ('Direito Constitucional','Organização político-administrativa, União, Estados e Municípios (arts. 18 a 31)',4),
  ('Direito Constitucional','Administração Pública e servidores públicos (arts. 37 a 41)',5),
  ('Direito Constitucional','Princípios da Administração Pública e princípios constitucionais de natureza ética',6),
  ('Direito Constitucional','Organização dos Poderes (arts. 44 a 135) e Segurança Pública (art. 144)',7),

  ('Direito Penal','Princípios básicos e aplicação da lei penal no tempo e no espaço',1),
  ('Direito Penal','Tempo e lugar do crime; territorialidade e extraterritorialidade',2),
  ('Direito Penal','Conflito aparente de normas penais',3),
  ('Direito Penal','Fato típico, ilicitude, culpabilidade, consumação e tentativa',4),
  ('Direito Penal','Concurso de pessoas e concurso de crimes',5),
  ('Direito Penal','Crimes contra a pessoa, patrimônio e dignidade sexual',6),
  ('Direito Penal','Crimes contra a fé pública, Administração Pública e Administração da Justiça',7),
  ('Direito Penal','Disposições constitucionais aplicáveis ao Direito Penal',8),

  ('Direito Processual Penal','Código de Processo Penal: disposições preliminares e inquérito policial',1),
  ('Direito Processual Penal','Notícia do crime, formas de instauração e investigação criminal',2),
  ('Direito Processual Penal','Indiciamento e direitos e garantias do investigado',3),
  ('Direito Processual Penal','Prisão em flagrante, preventiva e temporária; liberdade provisória',4),
  ('Direito Processual Penal','Garantias constitucionais e Lei nº 9.099/1995 (Juizados Especiais Criminais)',5),

  ('Direito Administrativo','Atos administrativos: conceito, elementos, atributos, classificação e espécies',1),
  ('Direito Administrativo','Formação, efeitos, extinção, anulação e revogação dos atos administrativos',2),
  ('Direito Administrativo','Poderes da Administração: hierárquico, disciplinar e regulamentar',3),
  ('Direito Administrativo','Uso e abuso de poder; poder de polícia, competências, limites e sanções',4),
  ('Direito Administrativo','Responsabilidade civil, administrativa e penal dos agentes públicos',5),
  ('Direito Administrativo','Responsabilidade civil do Estado',6),
  ('Direito Administrativo','Agentes e servidores públicos: regime jurídico, direitos, deveres e responsabilidades',7),
  ('Direito Administrativo','Concurso público, provimento, acessibilidade, estabilidade, remuneração e acumulação',8),
  ('Direito Administrativo','Processo Administrativo Disciplinar e Improbidade Administrativa (Lei nº 8.429/1992)',9),

  ('Legislação Extravagante','Crimes Hediondos - Lei nº 8.072/1990',1),
  ('Legislação Extravagante','Abuso de Autoridade - Lei nº 13.869/2019',2),
  ('Legislação Extravagante','Lei de Tortura - Lei nº 9.455/1997',3),
  ('Legislação Extravagante','Estatuto da Criança e do Adolescente - Lei nº 8.069/1990 (crimes)',4),
  ('Legislação Extravagante','Estatuto do Desarmamento - Lei nº 10.826/2003',5),
  ('Legislação Extravagante','Crimes contra o Meio Ambiente - Lei nº 9.605/1998',6),
  ('Legislação Extravagante','Lei Maria da Penha - Lei nº 11.340/2006',7),
  ('Legislação Extravagante','Lei de Drogas - Lei nº 11.343/2006',8),
  ('Legislação Extravagante','Organizações Criminosas - Lei nº 12.850/2013',9),
  ('Legislação Extravagante','Código de Trânsito Brasileiro - Lei nº 9.503/1997',10),

  ('Conhecimentos Específicos - Guarda Municipal','Sistema Único de Segurança Pública - Lei Federal nº 13.675/2018',1),
  ('Conhecimentos Específicos - Guarda Municipal','Estatuto Geral das Guardas Municipais - Lei Federal nº 13.022/2014',2),
  ('Conhecimentos Específicos - Guarda Municipal','Estatuto dos Servidores Públicos de São Gonçalo - Lei Municipal nº 1.416/2022',3),
  ('Conhecimentos Específicos - Guarda Municipal','Estatuto da Guarda Municipal de São Gonçalo - Lei Municipal nº 1.625/2026',4),

  ('Informática','Conceitos de informática, hardware e software',1),
  ('Informática','Sistemas operacionais Windows, Linux e software livre',2),
  ('Informática','Processadores de texto: Microsoft Word e LibreOffice Writer',3),
  ('Informática','Planilhas eletrônicas: Microsoft Excel e LibreOffice Calc',4),
  ('Informática','Apresentações: Microsoft PowerPoint e LibreOffice Impress',5),
  ('Informática','Redes de computadores, equipamentos, transmissão, topologias, cabeamento e protocolos',6),
  ('Informática','Internet, intranet, Web 2.0 e Web 3.0',7),
  ('Informática','Navegadores e ferramentas de busca e pesquisa na Web',8),
  ('Informática','Correio eletrônico, webmail, colaboração, fóruns, wikis e redes sociais',9),
  ('Informática','Segurança da informação, ameaças, vulnerabilidades, backup, vírus, antivírus, criptografia e assinatura digital',10),
  ('Informática','Tecnologias multimídia, áudio, vídeo e formatos de arquivos e imagens',11)
)
insert into public.topics(subject_id, name, sort_order)
select s.id, syllabus.topic_name, syllabus.sort_order
from syllabus
join public.subjects s on s.name = syllabus.subject_name
on conflict (subject_id, name) do nothing;

insert into public.contest_subjects(contest_id, subject_id, priority, suggested_weekly_minutes)
select c.id, s.id,
  case s.name
    when 'Direito Constitucional' then 5
    when 'Direito Penal' then 5
    when 'Direito Processual Penal' then 4
    when 'Legislação Extravagante' then 5
    when 'Conhecimentos Específicos - Guarda Municipal' then 5
    when 'Língua Portuguesa' then 5
    when 'Direito Administrativo' then 4
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
from public.contests c
cross join public.subjects s
where c.title = 'Prefeitura Municipal de São Gonçalo - RJ — Guarda Municipal Nível II 2026'
  and s.name in (
    'Língua Portuguesa',
    'Direito Constitucional',
    'Direito Penal',
    'Direito Processual Penal',
    'Direito Administrativo',
    'Legislação Extravagante',
    'Conhecimentos Específicos - Guarda Municipal',
    'Informática'
  )
on conflict (contest_id, subject_id) do nothing;

update public.contests
set vacancies = 100,
    level = 'Nível médio',
    last_verified_at = now()
where title = 'Prefeitura Municipal de São Gonçalo - RJ — Guarda Municipal Nível II 2026';

commit;
