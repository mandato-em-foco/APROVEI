-- APROVEI | Conteúdos programáticos CRP-05 e São João de Meriti/RJ
-- Fontes: edital FGV CRP-05/2026 (Anexo II) e edital IBAM São João de Meriti 01/2026 (Anexo III).
-- Importação idempotente: cria cargos, disciplinas, assuntos e vínculos por cargo.
-- Os tópicos abaixo são organizados a partir dos itens do edital; reexecute com segurança.

begin;

-- Localiza os dois concursos já cadastrados.
do $$
begin
  if not exists (select 1 from public.contests where title ilike '%CRP-05%' and title ilike '%01/2026%') then
    raise exception 'Concurso CRP-05 01/2026 não encontrado em public.contests.';
  end if;
  if not exists (select 1 from public.contests where title ilike '%São João de Meriti%' and title ilike '%01/2026%') then
    raise exception 'Concurso São João de Meriti 01/2026 não encontrado em public.contests.';
  end if;
end $$;

-- Cargos/empregos do CRP-05.
insert into public.contest_positions (contest_id,title,level,source_url,notes)
select c.id,v.title,v.level,'https://conhecimento.fgv.br/sites/default/files/concursos/edital-01-2026-abertura-do-concurso-publico-crp-05.pdf',
       'Conteúdo conforme Anexo II do Edital FGV nº 01/2026.'
from public.contests c
cross join (values
 ('Técnico Administrativo – Nível Superior','Superior'),
 ('Contador','Superior'),
 ('Técnico – Tecnologia da Informação','Superior'),
 ('Jornalista','Superior'),
 ('Psicóloga(o)','Superior'),
 ('Agente Administrativo','Médio')
) v(title,level)
where c.title ilike '%CRP-05%' and c.title ilike '%01/2026%'
on conflict (contest_id,title) do nothing;

-- Cargos do concurso de São João de Meriti.
insert into public.contest_positions (contest_id,title,level,source_url,notes)
select c.id,v.title,v.level,'https://www.ibam-concursos.org.br/documento/ed-sjm0126.pdf',
       'Conteúdo conforme Anexo III do Edital IBAM nº 01/2026.'
from public.contests c
cross join (values
 ('Professor I – Ciências','Superior / Formação Docente'),
 ('Professor I – Educação Artística','Superior / Formação Docente'),
 ('Professor I – Educação Física','Superior / Formação Docente'),
 ('Professor I – Geografia','Superior / Formação Docente'),
 ('Professor I – História','Superior / Formação Docente'),
 ('Professor I – Língua Inglesa','Superior / Formação Docente'),
 ('Professor I – Língua Portuguesa','Superior / Formação Docente'),
 ('Professor I – Matemática','Superior / Formação Docente'),
 ('Professor II','Formação Docente'),
 ('Professor II – Mediador','Formação Docente')
) v(title,level)
where c.title ilike '%São João de Meriti%' and c.title ilike '%01/2026%'
on conflict (contest_id,title) do nothing;

-- Disciplinas (nomes identificados por concurso para preservar a organização do edital).
insert into public.subjects(name) values
 ('CRP-05 | Língua Portuguesa'),
 ('CRP-05 | Legislação Institucional e Ética'),
 ('CRP-05 | Raciocínio Lógico'),
 ('CRP-05 | Conhecimentos Específicos — Contador'),
 ('CRP-05 | Conhecimentos Específicos — Jornalista'),
 ('CRP-05 | Conhecimentos Específicos — Psicóloga(o)'),
 ('CRP-05 | Conhecimentos Específicos — Técnico Administrativo'),
 ('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação'),
 ('CRP-05 | Conhecimentos Específicos — Agente Administrativo'),
 ('São João de Meriti | Português'),
 ('São João de Meriti | Legislação Educacional'),
 ('São João de Meriti | Conhecimentos Gerais do Município'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Ciências'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Educação Artística'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Educação Física'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Geografia'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I História'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Língua Inglesa'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Língua Portuguesa'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Matemática'),
 ('São João de Meriti | Conhecimentos Específicos — Professor II'),
 ('São João de Meriti | Conhecimentos Específicos — Professor II Mediador')
on conflict (name) do nothing;

-- Assuntos textuais do edital. Cada item numerado vira um assunto rastreável no APROVEI.
with syllabus(subject_name,topic_name,sort_order) as (values
('CRP-05 | Língua Portuguesa','Interpretação e compreensão de textos; organização estrutural; coesão, coerência, intertextualidade e modos discursivos.',1),
('CRP-05 | Língua Portuguesa','Tipos textuais informativo, normativo e didático; textos literários e não literários; tipologia e estrutura da frase; norma culta; pontuação.',2),
('CRP-05 | Língua Portuguesa','Organização sintática das frases: termos, orações, ordem direta e inversa e tipos de discurso.',3),
('CRP-05 | Língua Portuguesa','Linguagem: registros, funções, elementos da comunicação, estrutura e formação de palavras, abreviações, classes de palavras e modalizadores.',4),
('CRP-05 | Língua Portuguesa','Semântica: sentido próprio e figurado, antônimos, sinônimos, parônimos, hiperônimos, polissemia e ambiguidade.',5),
('CRP-05 | Língua Portuguesa','Dicionários: tipos e organização de verbetes.',6),
('CRP-05 | Língua Portuguesa','Vocabulário: neologismos, arcaísmos, estrangeirismos, latinismos, ortografia e acentuação gráfica.',7),
('CRP-05 | Legislação Institucional e Ética','Lei nº 5.766/1971: criação, natureza jurídica, finalidade, organização, estrutura, funcionamento e competências do CFP e dos CRPs.',1),
('CRP-05 | Legislação Institucional e Ética','Decreto nº 79.822/1977: regulamentação da Lei nº 5.766/1971 e funcionamento do Sistema Conselhos de Psicologia.',2),
('CRP-05 | Legislação Institucional e Ética','Lei nº 4.119/1962: regulamentação da profissão de psicólogo.',3),
('CRP-05 | Legislação Institucional e Ética','Regimentos internos do Conselho Federal de Psicologia e do Conselho Regional de Psicologia do Rio de Janeiro.',4),
('CRP-05 | Legislação Institucional e Ética','Código de Ética Profissional do Psicólogo — Resolução CFP nº 010/2005.',5),
('CRP-05 | Legislação Institucional e Ética','Código de Processamento Disciplinar do Sistema Conselhos de Psicologia.',6),
('CRP-05 | Legislação Institucional e Ética','Política de Orientação e Fiscalização — Resolução CFP nº 010/2017.',7),
('CRP-05 | Legislação Institucional e Ética','Registro documental e prontuários — Resoluções CFP nº 001/2009 e nº 005/2010.',8),
('CRP-05 | Legislação Institucional e Ética','Documentos psicológicos — Resolução CFP nº 006/2019.',9),
('CRP-05 | Legislação Institucional e Ética','Psicoterapia — Resolução CFP nº 013/2022; atendimento por tecnologias digitais — Resolução CFP nº 009/2024.',10),
('CRP-05 | Legislação Institucional e Ética','Caráter laico da prática psicológica — Resolução CFP nº 007/2023; redes sociais e publicidade — Nota Técnica CFP nº 01/2022.',11),
('CRP-05 | Legislação Institucional e Ética','Avaliação psicológica e SATEPSI — Resolução CFP nº 031/2022; avaliação em concursos — Resolução CFP nº 008/2025.',12),
('CRP-05 | Legislação Institucional e Ética','Registro de pessoas jurídicas e responsabilidade técnica — Resolução CFP nº 016/2019; especialidades — Resolução CFP nº 023/2022.',13),
('CRP-05 | Legislação Institucional e Ética','Estágio em Psicologia: Lei nº 11.788/2008, Resolução CFP nº 005/2025 e Nota Técnica CFP nº 31/2024.',14),
('CRP-05 | Legislação Institucional e Ética','ECA, Estatuto da Pessoa Idosa e Estatuto da Pessoa com Deficiência: sigilo, notificação e proteção contra violências.',15),
('CRP-05 | Legislação Institucional e Ética','Atuação psicológica nos níveis de atenção à saúde — Resolução CFP nº 017/2022; perícia psicológica no trânsito — Resolução CFP nº 001/2019.',16),
('CRP-05 | Legislação Institucional e Ética','Resolução CRPRJ nº 002/2022 — COMSCC; Lei nº 13.140/2015 — Lei da Mediação.',17),
('CRP-05 | Raciocínio Lógico','Lógica: proposições, conectivos, equivalências lógicas, quantificadores e predicados.',1),
('CRP-05 | Raciocínio Lógico','Conjuntos, operações e diagramas.',2),
('CRP-05 | Raciocínio Lógico','Números inteiros, racionais e reais; operações e porcentagem.',3),
('CRP-05 | Raciocínio Lógico','Proporcionalidade direta e inversa.',4),
('CRP-05 | Raciocínio Lógico','Medidas de comprimento, área, volume, massa e tempo.',5),
('CRP-05 | Raciocínio Lógico','Relações arbitrárias, dedução de informações e avaliação das condições de uma estrutura lógica.',6),
('CRP-05 | Raciocínio Lógico','Raciocínio verbal, matemático, sequencial, reconhecimento de padrões e orientação espacial e temporal.',7),
('CRP-05 | Raciocínio Lógico','Interpretação de gráficos e tabelas; problemas de lógica e raciocínio.',8),
('CRP-05 | Conhecimentos Específicos — Contador','Contabilidade Geral: patrimônio, fatos e atos contábeis, contas patrimoniais e de resultado, partidas dobradas, escrituração, lançamentos e demonstrações.',1),
('CRP-05 | Conhecimentos Específicos — Contador','Contabilidade Pública: NBC TSP, MCASP, PCASP, regimes e registros contábeis patrimoniais, orçamentários e de controle.',2),
('CRP-05 | Conhecimentos Específicos — Contador','Administração Financeira e Orçamentária: Lei nº 4.320/1964, LRF, orçamento, receitas, despesas, créditos adicionais, restos a pagar e suprimento de fundos.',3),
('CRP-05 | Conhecimentos Específicos — Contador','Demonstrações contábeis e análise de balanços: balanços, variações patrimoniais, fluxos de caixa, notas explicativas e indicadores.',4),
('CRP-05 | Conhecimentos Específicos — Contador','Contabilidade patrimonial e custos: bens, inventário, depreciação, amortização, exaustão, provisões, contingências e custos públicos.',5),
('CRP-05 | Conhecimentos Específicos — Contador','Auditoria, controle interno e prestação de contas: procedimentos, conciliações, irregularidades, transparência e relatórios.',6),
('CRP-05 | Conhecimentos Específicos — Contador','Contabilidade tributária: tributos, retenções, obrigações acessórias, folha, recolhimentos e declarações fiscais.',7),
('CRP-05 | Conhecimentos Específicos — Contador','Licitações e contratos — Lei nº 14.133/2021; execução da despesa, empenho, liquidação, pagamento e fiscalização financeira.',8),
('CRP-05 | Conhecimentos Específicos — Contador','Gestão financeira dos conselhos profissionais: anuidades, taxas, créditos, inadimplência, dívida ativa e prestação de contas.',9),
('CRP-05 | Conhecimentos Específicos — Jornalista','Fundamentos do jornalismo: teorias, gêneros, noticiabilidade, apuração, checagem, fontes, ética e responsabilidade.',1),
('CRP-05 | Conhecimentos Específicos — Jornalista','Redação e produção jornalística: notícias, reportagens, entrevistas, artigos, notas, títulos, leads, revisão e edição.',2),
('CRP-05 | Conhecimentos Específicos — Jornalista','Comunicação pública e institucional: transparência, interesse público, direito à informação, planejamento e reputação.',3),
('CRP-05 | Conhecimentos Específicos — Jornalista','Assessoria de imprensa: releases, notas, coletivas, porta-vozes, clipping, media training e gestão de crises.',4),
('CRP-05 | Conhecimentos Específicos — Jornalista','Jornalismo digital e mídias sociais: formatos digitais, multimídia, hipertextualidade, distribuição e métricas.',5),
('CRP-05 | Conhecimentos Específicos — Jornalista','Comunicação visual e multimídia: fotografia, vídeo, podcast, materiais gráficos, editoração, identidade e acessibilidade.',6),
('CRP-05 | Conhecimentos Específicos — Jornalista','Planejamento e gestão da comunicação: campanhas, públicos, canais, comunicação interna e externa e indicadores.',7),
('CRP-05 | Conhecimentos Específicos — Jornalista','Legislação e ética: liberdade de imprensa, direitos autorais e de imagem, resposta, proteção de dados e combate à desinformação.',8),
('CRP-05 | Conhecimentos Específicos — Psicóloga(o)','Fundamentos e campos da Psicologia: abordagens, processos psicológicos, desenvolvimento humano e relações indivíduo-sociedade-cultura.',1),
('CRP-05 | Conhecimentos Específicos — Psicóloga(o)','Ética profissional: deveres, vedações, sigilo, confidencialidade, relações e dilemas éticos.',2),
('CRP-05 | Conhecimentos Específicos — Psicóloga(o)','Orientação e fiscalização: competências das comissões, fiscalização de pessoas e organizações, responsabilidade técnica e denúncias.',3),
('CRP-05 | Conhecimentos Específicos — Psicóloga(o)','Processos éticos: infrações, representações, instrução processual, garantias e penalidades.',4),
('CRP-05 | Conhecimentos Específicos — Psicóloga(o)','Avaliação psicológica: métodos, instrumentos, validade, precisão, testes e SATEPSI.',5),
('CRP-05 | Conhecimentos Específicos — Psicóloga(o)','Documentos e registros: declarações, atestados, relatórios, laudos, pareceres, guarda e sigilo.',6),
('CRP-05 | Conhecimentos Específicos — Psicóloga(o)','Políticas públicas: SUS, RAPS, SUAS, educação, justiça, saúde mental e Reforma Psiquiátrica.',7),
('CRP-05 | Conhecimentos Específicos — Psicóloga(o)','Direitos humanos e diversidade: relações étnico-raciais, gênero, sexualidade, deficiência e práticas não discriminatórias.',8),
('CRP-05 | Conhecimentos Específicos — Psicóloga(o)','Psicologia do trabalho: saúde mental, riscos psicossociais, assédio e organização do trabalho.',9),
('CRP-05 | Conhecimentos Específicos — Psicóloga(o)','Práticas contemporâneas: psicoterapia, atendimento digital, interdisciplinaridade e limites técnicos e éticos.',10),
('CRP-05 | Conhecimentos Específicos — Técnico Administrativo','Administração: funções administrativas, estruturas, eficiência, eficácia e efetividade.',1),
('CRP-05 | Conhecimentos Específicos — Técnico Administrativo','Administração Pública: modelos, organização, governança, resultados, accountability, transparência e controle.',2),
('CRP-05 | Conhecimentos Específicos — Técnico Administrativo','Gestão de pessoas: comportamento, liderança, motivação, comunicação, equipes, conflitos e desempenho.',3),
('CRP-05 | Conhecimentos Específicos — Técnico Administrativo','Gestão de processos e qualidade: mapeamento, fluxogramas, padronização, indicadores e melhoria contínua.',4),
('CRP-05 | Conhecimentos Específicos — Técnico Administrativo','Gestão documental e redação oficial: protocolo, classificação, tramitação, arquivo e comunicações administrativas.',5),
('CRP-05 | Conhecimentos Específicos — Técnico Administrativo','Recursos materiais e patrimoniais: compras, estoques, almoxarifado, inventário e controle de bens.',6),
('CRP-05 | Conhecimentos Específicos — Técnico Administrativo','Licitações e contratos — Lei nº 14.133/2021: modalidades, contratação direta, planejamento e fiscalização.',7),
('CRP-05 | Conhecimentos Específicos — Técnico Administrativo','Administração financeira e orçamentária: orçamento, receitas, despesas, empenho, liquidação, pagamento e prestação de contas.',8),
('CRP-05 | Conhecimentos Específicos — Técnico Administrativo','Atendimento ao público e comunicação institucional: qualidade, acessibilidade, resolutividade e tratamento de demandas.',9),
('CRP-05 | Conhecimentos Específicos — Técnico Administrativo','Tecnologia aplicada: sistemas gerenciais, produtividade, planilhas, dados, digitalização e segurança da informação.',10),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','Fundamentos de TI: arquitetura de computadores, hardware, dispositivos, sistemas de numeração, dados e software.',1),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','Sistemas operacionais: processos, memória, arquivos, Windows, Linux, usuários, permissões, serviços e manutenção.',2),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','Redes: OSI, TCP/IP, IPv4/IPv6, LAN, Wi-Fi, roteamento, VLAN, DNS, DHCP, HTTP/HTTPS e VPN.',3),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','Segurança e LGPD: confidencialidade, integridade, disponibilidade, autenticação, criptografia, firewall, backup e incidentes.',4),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','Banco de dados: SGBD, modelo relacional, modelagem, normalização, SQL, integridade e recuperação.',5),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','Programação: lógica, algoritmos, estruturas de dados, orientação a objetos, HTML, CSS, JavaScript, APIs, versionamento e testes.',6),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','Infraestrutura e nuvem: servidores, virtualização, contêineres, armazenamento, IaaS, PaaS, SaaS e monitoramento.',7),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','Governança e serviços de TI: COBIT, ITIL, incidentes, problemas, mudanças, ativos, SLA e indicadores.',8),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','Suporte: diagnóstico, instalação, configuração, manutenção, suporte remoto, chamados e inventário.',9),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','TI na administração pública: transformação digital, interoperabilidade, dados abertos, acessibilidade e contratação de TI.',10),
('CRP-05 | Conhecimentos Específicos — Tecnologia da Informação','IA e dados: machine learning, deep learning, IA generativa, LLMs, prompts, mineração, Big Data, automação, vieses e ética.',11),
('CRP-05 | Conhecimentos Específicos — Agente Administrativo','Noções de Administração: conceitos, planejamento, organização, direção, controle e estruturas organizacionais.',1),
('CRP-05 | Conhecimentos Específicos — Agente Administrativo','Rotinas administrativas: organização do trabalho, procedimentos, tramitação e controle de documentos.',2),
('São João de Meriti | Português','Leitura e compreensão de textos; modos de organização do discurso e gêneros textuais.',1),
('São João de Meriti | Português','Coesão, coerência, relações entre partes do texto, conectivos e efeitos de sentido.',2),
('São João de Meriti | Português','Verbos, vozes verbais, transitividade, estrutura e formação de palavras, classes e flexões.',3),
('São João de Meriti | Português','Regência verbal e nominal; pronomes, formas de tratamento e colocação pronominal.',4),
('São João de Meriti | Português','Figuras e funções da linguagem; sinônimos, antônimos, parônimos e homônimos.',5),
('São João de Meriti | Português','Acentuação, pontuação, recursos gráficos, sintaxe do período simples, coordenação, subordinação, crase e ortografia.',6),
('São João de Meriti | Legislação Educacional','Estatuto da Criança e do Adolescente — Lei nº 8.069/1990.',1),
('São João de Meriti | Legislação Educacional','Lei de Diretrizes e Bases da Educação — Lei nº 9.394/1996.',2),
('São João de Meriti | Legislação Educacional','Lei Brasileira de Inclusão — Lei nº 13.146/2015.',3),
('São João de Meriti | Legislação Educacional','Plano Nacional de Educação — Lei nº 15.388/2026.',4),
('São João de Meriti | Legislação Educacional','Diretrizes Curriculares Nacionais para Educação Básica, Educação Infantil e Ensino Fundamental.',5),
('São João de Meriti | Legislação Educacional','Educação das Relações Étnico-Raciais — Resolução CNE/CP nº 1/2004; Leis nº 10.639/2003 e nº 11.645/2008.',6),
('São João de Meriti | Legislação Educacional','Diretrizes Operacionais Nacionais para EJA — Resolução CNE/CEB nº 3/2025.',7),
('São João de Meriti | Legislação Educacional','Sistema Nacional de Educação — Lei Complementar nº 220/2025.',8),
('São João de Meriti | Legislação Educacional','Política Nacional de Educação Especial Inclusiva — Decretos nº 12.686/2025 e nº 12.773/2025.',9),
('São João de Meriti | Legislação Educacional','Proteção contra violência nas escolas — Lei nº 14.811/2024.',10),
('São João de Meriti | Legislação Educacional','Computação na Educação Básica — Resolução CNE/CEB nº 1/2022.',11),
('São João de Meriti | Conhecimentos Gerais do Município','Origem da região, primeiras ocupações, povoamento e evolução histórica e administrativa.',1),
('São João de Meriti | Conhecimentos Gerais do Município','Aspectos físicos e geográficos: clima, relevo, população, localização, área, limites, distritos e características urbanas.',2),
('São João de Meriti | Conhecimentos Gerais do Município','Atividades econômicas, patrimônio natural, cultural, histórico e arquitetônico; turismo, lazer e datas comemorativas.',3),
('São João de Meriti | Conhecimentos Gerais do Município','Personalidades, indicadores sociais, econômicos, educacionais e financeiros.',4),
('São João de Meriti | Conhecimentos Gerais do Município','Serviços municipais, estrutura administrativa da Prefeitura e relação regional com municípios vizinhos.',5),
('São João de Meriti | Conhecimentos Gerais do Município','Lei Orgânica, bandeira e hino do Município.',6),
('São João de Meriti | Conhecimentos Específicos — Professor II','Teorias da aprendizagem e desenvolvimento infantil cognitivo, afetivo, motor e perceptivo.',1),
('São João de Meriti | Conhecimentos Específicos — Professor II','Avaliação, planejamento, prática pedagógica e construção do conhecimento.',2),
('São João de Meriti | Conhecimentos Específicos — Professor II','Interdisciplinaridade, projetos, gestão democrática e democratização da escola pública.',3),
('São João de Meriti | Conhecimentos Específicos — Professor II','Metodologias ativas, Projeto Político-Pedagógico, currículo e teorias do currículo.',4),
('São João de Meriti | Conhecimentos Específicos — Professor II','Educação inclusiva, atendimento a alunos com deficiência e currículo adaptado.',5),
('São João de Meriti | Conhecimentos Específicos — Professor II','Bullying e cyberbullying — Lei nº 13.185/2015.',6),
('São João de Meriti | Conhecimentos Específicos — Professor II','Recursos de ensino, tecnologias digitais, educação digital e inteligência artificial na educação.',7),
('São João de Meriti | Conhecimentos Específicos — Professor II','História da Educação e aspectos filosóficos, psicológicos e sociológicos.',8),
('São João de Meriti | Conhecimentos Específicos — Professor II','IDEB, avaliações em larga escala, transtornos e dificuldades de aprendizagem.',9),
('São João de Meriti | Conhecimentos Específicos — Professor II','Temas contemporâneos transversais: saúde, economia, meio ambiente, cidadania, multiculturalismo, ciência e tecnologia.',10),
('São João de Meriti | Conhecimentos Específicos — Professor II','EJA — Resolução CNE/CEB nº 3/2025; Sistema Nacional de Educação — LC nº 220/2025.',11),
('São João de Meriti | Conhecimentos Específicos — Professor II','Educação Especial Inclusiva — Decretos nº 12.686/2025 e nº 12.773/2025; BNCC e legislação educacional atualizada.',12),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','Educação Especial: conceito, evolução, tendências e inclusão da pessoa com deficiência.',1),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','Fundamentos filosóficos, teóricos, pedagógicos e legais da Educação Especial.',2),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','Legislação: Constituição Federal, LDB, ECA e Lei Brasileira de Inclusão.',3),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','Política Nacional de Proteção dos Direitos da Pessoa com TEA — Lei nº 12.764/2012.',4),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','Política Nacional de Educação Especial Inclusiva — Decretos nº 12.686/2025 e nº 12.773/2025.',5),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','Acompanhamento de educandos com dislexia, TDAH e transtornos de aprendizagem — Lei nº 14.254/2021.',6),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','Língua Brasileira de Sinais — Lei nº 10.436/2002; Convenção sobre os Direitos das Pessoas com Deficiência — Decreto nº 6.949/2009.',7),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','BNCC, atribuições do cargo de AEE, transtornos, dificuldades de aprendizagem e altas habilidades.',8),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','Relação entre sociedade, escola, família e aluno com deficiência; formação docente em Educação Especial.',9),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','Flexibilizações e adaptações curriculares, tecnologias assistivas e comunicação alternativa.',10),
('São João de Meriti | Conhecimentos Específicos — Professor II Mediador','Plano Nacional de Educação — Lei nº 15.388/2026; Computação na Educação Básica — Resolução CNE/CEB nº 1/2022.',11)
)
insert into public.topics(subject_id,name,sort_order)
select s.id,x.topic_name,x.sort_order
from syllabus x join public.subjects s on s.name=x.subject_name
on conflict (subject_id,name) do nothing;

-- Associa disciplinas comuns e específicas a cada cargo.
with mapping(position_title,subject_name) as (values
('Técnico Administrativo – Nível Superior','CRP-05 | Língua Portuguesa'),
('Técnico Administrativo – Nível Superior','CRP-05 | Legislação Institucional e Ética'),
('Técnico Administrativo – Nível Superior','CRP-05 | Raciocínio Lógico'),
('Técnico Administrativo – Nível Superior','CRP-05 | Conhecimentos Específicos — Técnico Administrativo'),
('Contador','CRP-05 | Língua Portuguesa'),
('Contador','CRP-05 | Legislação Institucional e Ética'),
('Contador','CRP-05 | Raciocínio Lógico'),
('Contador','CRP-05 | Conhecimentos Específicos — Contador'),
('Técnico – Tecnologia da Informação','CRP-05 | Língua Portuguesa'),
('Técnico – Tecnologia da Informação','CRP-05 | Legislação Institucional e Ética'),
('Técnico – Tecnologia da Informação','CRP-05 | Raciocínio Lógico'),
('Técnico – Tecnologia da Informação','CRP-05 | Conhecimentos Específicos — Tecnologia da Informação'),
('Jornalista','CRP-05 | Língua Portuguesa'),
('Jornalista','CRP-05 | Legislação Institucional e Ética'),
('Jornalista','CRP-05 | Raciocínio Lógico'),
('Jornalista','CRP-05 | Conhecimentos Específicos — Jornalista'),
('Psicóloga(o)','CRP-05 | Língua Portuguesa'),
('Psicóloga(o)','CRP-05 | Legislação Institucional e Ética'),
('Psicóloga(o)','CRP-05 | Raciocínio Lógico'),
('Psicóloga(o)','CRP-05 | Conhecimentos Específicos — Psicóloga(o)'),
('Agente Administrativo','CRP-05 | Língua Portuguesa'),
('Agente Administrativo','CRP-05 | Legislação Institucional e Ética'),
('Agente Administrativo','CRP-05 | Raciocínio Lógico'),
('Agente Administrativo','CRP-05 | Conhecimentos Específicos — Agente Administrativo'),
('Professor I – Ciências','São João de Meriti | Português'),
('Professor I – Ciências','São João de Meriti | Legislação Educacional'),
('Professor I – Ciências','São João de Meriti | Conhecimentos Gerais do Município'),
('Professor I – Educação Artística','São João de Meriti | Português'),
('Professor I – Educação Artística','São João de Meriti | Legislação Educacional'),
('Professor I – Educação Artística','São João de Meriti | Conhecimentos Gerais do Município'),
('Professor I – Educação Física','São João de Meriti | Português'),
('Professor I – Educação Física','São João de Meriti | Legislação Educacional'),
('Professor I – Educação Física','São João de Meriti | Conhecimentos Gerais do Município'),
('Professor I – Geografia','São João de Meriti | Português'),
('Professor I – Geografia','São João de Meriti | Legislação Educacional'),
('Professor I – Geografia','São João de Meriti | Conhecimentos Gerais do Município'),
('Professor I – História','São João de Meriti | Português'),
('Professor I – História','São João de Meriti | Legislação Educacional'),
('Professor I – História','São João de Meriti | Conhecimentos Gerais do Município'),
('Professor I – Língua Inglesa','São João de Meriti | Português'),
('Professor I – Língua Inglesa','São João de Meriti | Legislação Educacional'),
('Professor I – Língua Inglesa','São João de Meriti | Conhecimentos Gerais do Município'),
('Professor I – Língua Portuguesa','São João de Meriti | Português'),
('Professor I – Língua Portuguesa','São João de Meriti | Legislação Educacional'),
('Professor I – Língua Portuguesa','São João de Meriti | Conhecimentos Gerais do Município'),
('Professor I – Matemática','São João de Meriti | Português'),
('Professor I – Matemática','São João de Meriti | Legislação Educacional'),
('Professor I – Matemática','São João de Meriti | Conhecimentos Gerais do Município'),
('Professor II','São João de Meriti | Português'),
('Professor II','São João de Meriti | Legislação Educacional'),
('Professor II','São João de Meriti | Conhecimentos Gerais do Município'),
('Professor II','São João de Meriti | Conhecimentos Específicos — Professor II'),
('Professor II – Mediador','São João de Meriti | Português'),
('Professor II – Mediador','São João de Meriti | Legislação Educacional'),
('Professor II – Mediador','São João de Meriti | Conhecimentos Gerais do Município'),
('Professor II – Mediador','São João de Meriti | Conhecimentos Específicos — Professor II Mediador')
)
insert into public.contest_position_subjects(position_id,subject_id,priority,suggested_weekly_minutes)
select p.id,s.id,1,120
from mapping m
join public.subjects s on s.name=m.subject_name
join public.contest_positions p on p.title=m.position_title
join public.contests c on c.id=p.contest_id
where (c.title ilike '%CRP-05%' and m.subject_name like 'CRP-05 |%')
   or (c.title ilike '%São João de Meriti%' and m.subject_name like 'São João de Meriti |%')
on conflict (position_id,subject_id) do nothing;

commit;
