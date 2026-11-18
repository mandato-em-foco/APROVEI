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


-- Complemento: programas específicos dos cargos de Professor I (Anexo III do IBAM).
begin;

insert into public.subjects(name) values
 ('São João de Meriti | Conhecimentos Específicos — Professor I Ciências'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Educação Artística'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Educação Física'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Geografia'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I História'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Língua Inglesa'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Língua Portuguesa'),
 ('São João de Meriti | Conhecimentos Específicos — Professor I Matemática')
on conflict (name) do nothing;

with syllabus(subject_name,topic_name,sort_order) as (values
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Terra e Universo: atmosfera, água, tratamento de água e esgoto, crosta, rochas, fósseis, solo, erosão, movimentos da Terra, Sol e Lua, placas tectônicas e deriva continental.',1),
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Seres vivos: cinco Reinos e três Domínios, vírus, fisiologia animal, reprodução e fisiologia vegetal.',2),
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Biologia celular: composição química, células procarióticas e eucarióticas, membrana, transporte, organelas, núcleo, cromossomos e divisão celular.',3),
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Histologia animal e vegetal: tecidos epitelial, conjuntivo, muscular, nervoso, meristemas, parênquima, xilema, floema e tecidos de revestimento.',4),
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Anatomia e fisiologia humanas: sistemas digestivo, respiratório, circulatório, urinário, endócrino, nervoso, reprodutor, locomotor e sentidos.',5),
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Genética: leis de Mendel, genealogias, herança, sistemas ABO e Rh, cromossomos sexuais e aneuploidias.',6),
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Origem da vida e evolução: abiogênese, biogênese, hipóteses sobre a origem da vida e teorias evolutivas.',7),
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Ecologia: níveis de organização, ecossistemas, biomas, cadeias, teias, energia, ciclos biogeoquímicos, relações ecológicas e impactos ambientais; Leis nº 9.795/1999 e nº 9.985/2000.',8),
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Saúde: conceitos de saúde e doença, epidemias, endemias, pandemias, imunidade, antibióticos, vacinas, viroses, bacterioses, protozooses e verminoses.',9),
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Química Geral: medições, unidades, matéria, energia, substâncias, misturas, átomo, ligações, funções e reações químicas.',10),
('São João de Meriti | Conhecimentos Específicos — Professor I Ciências','Física Básica: mecânica, energia, temperatura, calor, ondas, instrumentos ópticos, eletricidade e magnetismo.',11),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Artística','História da arte brasileira e universal: manifestações de diferentes épocas, características e artistas.',1),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Artística','História do ensino de arte no Brasil: fundamentos e tendências pedagógicas.',2),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Artística','Parâmetros Curriculares Nacionais e ensino de arte nas diferentes linguagens.',3),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Artística','Base Nacional Comum Curricular (BNCC) e arte na educação.',4),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Artística','Arte na educação escolar: objetivos, conteúdos, métodos, avaliação, elementos básicos e relações compositivas.',5),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Artística','Folclore brasileiro e manifestações artístico-culturais populares.',6),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Artística','Arte na atualidade: tecnologias e novas formas de manifestações artísticas.',7),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Física','Educação Física no contexto da Educação, função social, objetivos gerais, avaliação e papel do professor.',1),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Física','Metodologia, didática, organização do conhecimento, abordagens metodológicas e seleção de conteúdos.',2),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Física','Novas perspectivas, BNCC, sociedade, cultura e história da Educação Física no Brasil.',3),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Física','Aprendizagem motora, desenvolvimento motor e Psicologia da Aprendizagem.',4),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Física','Fisiologia do exercício, atividade física, promoção da saúde e Educação Física escolar.',5),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Física','Esporte escolar, jogos, brincadeiras, lutas, danças e ginásticas.',6),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Física','Educação Física inclusiva; Leis nº 10.639/2003 e nº 11.645/2008.',7),
('São João de Meriti | Conhecimentos Específicos — Professor I Educação Física','Dimensões filosóficas, antropológicas e sociais; lazer, primeiros socorros, cidadania e projeto político-pedagógico.',8),
('São João de Meriti | Conhecimentos Específicos — Professor I Geografia','Objeto de estudo, conceitos fundamentais, teoria e história do pensamento geográfico; espaço como produto histórico e social.',1),
('São João de Meriti | Conhecimentos Específicos — Professor I Geografia','Cartografia: escalas, projeções, convenções, mapas, gráficos, coordenadas geográficas, fusos horários e leitura de representações.',2),
('São João de Meriti | Conhecimentos Específicos — Professor I Geografia','Natureza e meio ambiente: sistema solar, dinâmica geológica, recursos naturais, sustentabilidade, solos, atmosfera, clima, hidrografia e vegetação.',3),
('São João de Meriti | Conhecimentos Específicos — Professor I Geografia','Globalização, política neoliberal, economia global, poder, tecnologias da informação e ciberespaço.',4),
('São João de Meriti | Conhecimentos Específicos — Professor I Geografia','Espaço industrial: industrialização, modelos produtivos, revoluções técnico-científicas e divisão internacional do trabalho.',5),
('São João de Meriti | Conhecimentos Específicos — Professor I Geografia','Espaço urbano: urbanização, relações campo-cidade, problemas urbanos, meio ambiente urbano e planejamento.',6),
('São João de Meriti | Conhecimentos Específicos — Professor I Geografia','População: crescimento, estrutura, migrações, teorias demográficas, transição demográfica, desigualdades e refugiados.',7),
('São João de Meriti | Conhecimentos Específicos — Professor I Geografia','Espaço agrário: estrutura fundiária, conflitos, modernização, agricultura, produção e comércio internacional.',8),
('São João de Meriti | Conhecimentos Específicos — Professor I Geografia','Comércio, transportes e serviços; fake news, circulação de informação e cultura.',9),
('São João de Meriti | Conhecimentos Específicos — Professor I Geografia','Geopolítica: blocos de poder, Estados, organismos multilaterais, conflitos, Guerra Fria, ordem mundial e regionalização brasileira.',10),
('São João de Meriti | Conhecimentos Específicos — Professor I História','Teoria da História e correntes historiográficas: positivismo, materialismo histórico, Escola dos Annales, história oral e do cotidiano.',1),
('São João de Meriti | Conhecimentos Específicos — Professor I História','Relações entre sociedade, economia, cultura, natureza e terra na História do Brasil, das Américas e da África.',2),
('São João de Meriti | Conhecimentos Específicos — Professor I História','Relações de trabalho: escravização indígena e africana, resistências, emancipação, imigração, trabalho urbano, rural, feminino e infantil.',3),
('São João de Meriti | Conhecimentos Específicos — Professor I História','Organizações de trabalhadores, sindicatos, movimentos sociais e relações de trabalho em diferentes sociedades e períodos.',4),
('São João de Meriti | Conhecimentos Específicos — Professor I História','Cidadania no Brasil e no mundo: direitos, constituições, autoritarismo, democracia, revoluções e movimentos políticos.',5),
('São João de Meriti | Conhecimentos Específicos — Professor I Língua Inglesa','Métodos e abordagens de ensino: metodologias pré-comunicativas, humanísticas e comunicativas; competência comunicativa e Inglês Instrumental.',1),
('São João de Meriti | Conhecimentos Específicos — Professor I Língua Inglesa','Compreensão de textos: estratégias de leitura global e pontual, gêneros, inferência, dedução, contexto, coesão e coerência.',2),
('São João de Meriti | Conhecimentos Específicos — Professor I Língua Inglesa','Léxico-gramática: derivação, sintagmas nominal, verbal, adverbial e preposicional, tempos, aspecto, modalidade, voz, concordância e verbos frasais.',3),
('São João de Meriti | Conhecimentos Específicos — Professor I Língua Inglesa','Perspectivas discursivas: discurso direto e relatado, funções comunicativas e inglês escrito e falado nas novas tecnologias.',4),
('São João de Meriti | Conhecimentos Específicos — Professor I Língua Portuguesa','Abordagens de ensino: língua, gramática, concepções de ensino, texto literário, leitura e escrita.',1),
('São João de Meriti | Conhecimentos Específicos — Professor I Língua Portuguesa','Construção e sentido dos textos: gêneros, tipologias, progressão temática, coesão, coerência, parágrafo e argumentação.',2),
('São João de Meriti | Conhecimentos Específicos — Professor I Língua Portuguesa','Perspectivas enunciativas: enunciador, interlocutor, espaço, tempo, polifonia, intertextualidade, inferência, pressuposição e variação linguística.',3),
('São João de Meriti | Conhecimentos Específicos — Professor I Língua Portuguesa','Semântica e estilística: sentido dos vocábulos, tempos e modos verbais, concordância, figuras, polissemia, sinonímia, antonímia e paronímia.',4),
('São João de Meriti | Conhecimentos Específicos — Professor I Língua Portuguesa','Morfossintaxe: classes gramaticais, formação e flexão de palavras, termos da oração, coordenação, subordinação, regência e colocação pronominal.',5),
('São João de Meriti | Conhecimentos Específicos — Professor I Língua Portuguesa','Elementos da escrita: grafia, acentuação e pontuação.',6),
('São João de Meriti | Conhecimentos Específicos — Professor I Matemática','Números e operações: conjuntos, conjuntos numéricos, operações, múltiplos, divisores, MDC, MMC, primos, porcentagem e médias.',1),
('São João de Meriti | Conhecimentos Específicos — Professor I Matemática','Álgebra e funções: polinômios, frações algébricas, funções inversa e composta, afim, quadrática, exponencial e logarítmica.',2),
('São João de Meriti | Conhecimentos Específicos — Professor I Matemática','Equações, inequações, sistemas, progressões, juros simples e compostos, matrizes, determinantes e análise combinatória.',3),
('São João de Meriti | Conhecimentos Específicos — Professor I Matemática','Espaço e forma: geometria analítica, polígonos, circunferência, semelhança, trigonometria e sólidos geométricos.',4),
('São João de Meriti | Conhecimentos Específicos — Professor I Matemática','Grandezas e medidas: unidades, comprimento da circunferência, áreas, áreas e volumes de sólidos.',5),
('São João de Meriti | Conhecimentos Específicos — Professor I Matemática','Tratamento da informação: proporcionalidade, estatística, variáveis, frequências, gráficos, histogramas, medidas, probabilidade e BNCC.',6)
)
insert into public.topics(subject_id,name,sort_order)
select s.id,x.topic_name,x.sort_order
from syllabus x join public.subjects s on s.name=x.subject_name
on conflict (subject_id,name) do nothing;

with mapping(position_title,subject_name) as (values
('Professor I – Ciências','São João de Meriti | Conhecimentos Específicos — Professor I Ciências'),
('Professor I – Educação Artística','São João de Meriti | Conhecimentos Específicos — Professor I Educação Artística'),
('Professor I – Educação Física','São João de Meriti | Conhecimentos Específicos — Professor I Educação Física'),
('Professor I – Geografia','São João de Meriti | Conhecimentos Específicos — Professor I Geografia'),
('Professor I – História','São João de Meriti | Conhecimentos Específicos — Professor I História'),
('Professor I – Língua Inglesa','São João de Meriti | Conhecimentos Específicos — Professor I Língua Inglesa'),
('Professor I – Língua Portuguesa','São João de Meriti | Conhecimentos Específicos — Professor I Língua Portuguesa'),
('Professor I – Matemática','São João de Meriti | Conhecimentos Específicos — Professor I Matemática')
)
insert into public.contest_position_subjects(position_id,subject_id,priority,suggested_weekly_minutes)
select p.id,s.id,1,180
from mapping m
join public.subjects s on s.name=m.subject_name
join public.contest_positions p on p.title=m.position_title
join public.contests c on c.id=p.contest_id
where c.title ilike '%São João de Meriti%' and c.title ilike '%01/2026%'
on conflict (position_id,subject_id) do nothing;

commit;
