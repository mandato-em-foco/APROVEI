-- APROVEI | Carga nacional inicial de editais publicados
-- Levantamento consultado em 18/11/2026. Fonte de descoberta: Gran Cursos.
-- Os links source_url levam à página do edital/notícia de cada seleção; sempre conferir
-- retificações e a página da banca antes de efetuar inscrição.
-- Idempotente por título + UF.

insert into public.contests
(title,sphere,state,city,level,status,employment_type,vacancies,salary_min,salary_max,
 registration_start,deadline,exam_date,official_url,registration_url,source_url,last_verified_at)
select v.title,v.sphere,v.state,v.city,v.level,v.status,v.employment_type,v.vacancies,
       v.salary_min,v.salary_max,v.registration_start::date,v.deadline::date,
       v.exam_date::date,null,null,v.source_url,now()
from (values
('Polícia Militar de São Paulo — Soldado 2026/2027','state','SP','São Paulo','Nível médio','open','permanent',2000,null::numeric,8149.55,'2026-11-09','2026-12-22','2027-02-28','https://blog.grancursosonline.com.br/concurso-pm-sp/'),
('Polícia Militar de Pernambuco — Soldado','state','PE','Pernambuco','Nível médio','open','permanent',1320,null::numeric,12937.33,null,'2026-11-23',null,'https://blog.grancursosonline.com.br/concurso-pm-pe'),
('Corpo de Bombeiros Militar de Pernambuco','state','PE','Pernambuco','Nível médio','open','permanent',570,null::numeric,12937.33,null,'2026-11-23',null,'https://blog.grancursosonline.com.br/concurso-bombeiros-pe/'),
('Polícia Penal de Pernambuco','state','PE','Pernambuco','Nível médio','open','permanent',700,null::numeric,5667.92,'2026-11-12','2027-01-04','2027-03-21','https://blog.grancursosonline.com.br/concurso-policia-penal-pe/'),
('Guarda Municipal de Santana','municipal','AP','Santana/AP','Nível médio','open','permanent',50,null::numeric,2100,'2026-09-30','2026-12-03','2027-01-17','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/09/30173433/Edital-GCM-Santana-AP-2026.pdf'),
('Guarda Municipal de São Roque','municipal','SP','São Roque/SP','Nível médio','open','permanent',30,null::numeric,5108.16,null,'2026-11-19','2026-12-06','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/10/19170847/Edital-GCM-Sao-Roque-SP-2026.pdf'),
('Guarda Municipal de Marituba','municipal','PA','Marituba/PA','Nível médio','open','permanent',60,null::numeric,null,null,'2026-12-08','2027-02-14','https://blog.grancursosonline.com.br/concurso-guarda-marituba-pa/'),
('Guarda Municipal de Nova Odessa','municipal','SP','Nova Odessa/SP','Nível médio','open','permanent',6,null::numeric,3336.58,null,'2026-12-07','2027-01-31','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/11/09111918/Edital-GCM-Nova-Odessa-SP-2026.pdf'),
('Polícia Civil do Acre — Delegado e cargos policiais','state','AC','Acre','Nível superior','open','permanent',139,null::numeric,19505.66,'2026-11-11','2026-12-14','2027-01-24','https://blog.grancursosonline.com.br/concurso-policia-civil-acre/'),
('Guarda Municipal de Marabá','municipal','PA','Marabá/PA','Nível médio','open','permanent',60,null::numeric,2076.40,null,'2026-12-28','2027-01-24','https://blog.grancursosonline.com.br/concurso-gcm-maraba-pa/'),
('Guarda Municipal de Campinas','municipal','SP','Campinas/SP','Nível médio','open','permanent',100,null::numeric,3796.61,null,'2027-01-08','2027-03-21','https://blog.grancursosonline.com.br/concurso-gcm-campinas-sp/'),
('Polícia Militar de Minas Gerais — Oficial','state','MG','Minas Gerais','Nível superior','open','permanent',90,null::numeric,12170.61,'2026-11-10','2026-12-10','2027-01-10','https://blog.grancursosonline.com.br/concurso-oficial-pm-mg/'),
('Instituto Federal de São Paulo — Técnico-Administrativo','federal','SP','Diversas unidades/SP','Nível médio e superior','open','permanent',6,null::numeric,10318.93,null,'2027-01-04','2027-01-31','https://blog.grancursosonline.com.br/concurso-ifsp-tae-edital-publicado-2026/'),
('Universidade Federal de Mato Grosso do Sul — UFMS','federal','MS','Mato Grosso do Sul','Nível médio e superior','open','permanent',154,null::numeric,5215.39,'2026-11-04','2026-12-04','2027-01-17','https://blog.grancursosonline.com.br/concurso-ufms/'),
('Secretaria Municipal de Educação de Blumenau','municipal','SC','Blumenau/SC','Conforme cargo','open','permanent',18,null::numeric,5130.63,'2026-11-07','2026-12-09','2027-01-31','https://blog.grancursosonline.com.br/concurso-sme-blumenau-sc/'),
('Secretaria Municipal de Educação de Aparecida de Goiânia','municipal','GO','Aparecida de Goiânia/GO','Conforme cargo','open','permanent',2956,null::numeric,4508.28,null,'2026-12-09',null,'https://blog.grancursosonline.com.br/concurso-sme-aparecida-de-goiania-go/'),
('Secretaria Municipal de Educação de Brasnorte','municipal','MT','Brasnorte/MT','Conforme cargo','open','permanent',28,null::numeric,5771.72,null,'2026-11-26','2026-12-13','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/10/20143704/Edital-SME-Brasnorte-MT-2026.pdf'),
('Universidade Estadual do Paraná — UNESPAR (concurso público)','state','PR','Paraná','Nível superior','open','permanent',5,null::numeric,7997.72,'2026-11-16','2026-11-30','2027-02-21','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/11/09093554/edital-unespar-pr-edital50.pdf'),
('Fundação Escola Técnica Liberato Salzano Vieira da Cunha','state','RS','Rio Grande do Sul','Conforme cargo','open','permanent',34,null::numeric,8655.54,null,'2026-12-08','2027-03-07','https://blog.grancursosonline.com.br/concurso-fundacao-liberato-rs-edital-publicado-2026/'),
('Secretaria Municipal de Educação de Barra do Garças','municipal','MT','Barra do Garças/MT','Conforme cargo','open','permanent',387,null::numeric,5771.96,'2026-11-18','2027-01-07','2027-01-31','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/11/16123730/Edital-SME-Barra-do-Garcas-MT-2026.pdf'),
('Secretaria Municipal de Educação de Porto Firme','municipal','MG','Porto Firme/MG','Conforme cargo','open','permanent',19,null::numeric,3873.30,null,'2026-12-17','2027-01-17','https://blog.grancursosonline.com.br/concurso-sme-porto-firme-mg/'),
('Secretaria Municipal de Educação de Praia Grande','municipal','SP','Praia Grande/SP','Conforme cargo','open','permanent',23,null::numeric,6573.49,null,'2026-12-10','2027-01-24','https://blog.grancursosonline.com.br/concurso-sme-praia-grande-sp/'),
('Secretaria Municipal de Educação de São Carlos','municipal','SP','São Carlos/SP','Conforme cargo','open','permanent',21,null::numeric,9701,null,'2026-12-01','2026-12-20','https://blog.grancursosonline.com.br/concurso-sme-sao-carlos-sp/'),
('Câmara Municipal de Aracruz','municipal','ES','Aracruz/ES','Conforme cargo','open','permanent',9,null::numeric,6614.93,null,'2026-11-30','2026-12-20','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/11/06144245/Edital-Camara-Aracruz-ES-2026.pdf'),
('Consórcio Intermunicipal de Saúde de Itu — CIS Itu','municipal','SP','Itu/SP','Conforme cargo','open','permanent',28,null::numeric,7553.69,null,'2026-12-07','2027-01-17','https://blog.grancursosonline.com.br/concurso-cis-itu-sp/'),
('Tribunal de Justiça de Santa Catarina — Juiz','state','SC','Santa Catarina','Nível superior','open','permanent',15,null::numeric,35874.14,null,'2026-11-26','2027-01-31','https://blog.grancursosonline.com.br/concurso-tj-sc-juiz/'),
('Defensoria Pública do Amazonas','state','AM','Amazonas','Nível médio e superior','upcoming','permanent',5,null::numeric,8006.38,'2026-11-30','2027-01-04','2027-03-07','https://blog.grancursosonline.com.br/concurso-dpe-am/'),
('Tribunal Regional Federal da 3ª Região','federal','SP','São Paulo e Mato Grosso do Sul','Nível superior','open','permanent',11,null::numeric,20013.11,null,'2026-11-23','2027-01-31','https://blog.grancursosonline.com.br/concurso-trf3/'),
('Tribunal de Justiça de São Paulo — Escrevente','state','SP','São Paulo','Nível médio','open','permanent',null::integer,null::numeric,7424.95,null,'2026-12-10','2027-03-14','https://blog.grancursosonline.com.br/concurso-tj-sp-edital-publicado-2026/'),
('Tribunal de Justiça de São Paulo — Oficial de Justiça','state','SP','São Paulo','Nível superior','open','permanent',132,null::numeric,10276.04,null,'2026-12-10','2027-03-14','https://blog.grancursosonline.com.br/concurso-tj-sp-oficial-de-justica-edital-publicado-2026/'),
('Câmara Municipal de Guarabira','municipal','PB','Guarabira/PB','Conforme cargo','open','permanent',5,null::numeric,3354.70,null,'2026-11-22',null,'https://blog.grancursosonline.com.br/concurso-camara-guarabira-pb/'),
('Câmara Municipal de Portel','municipal','PA','Portel/PA','Conforme cargo','open','permanent',27,null::numeric,4723.31,null,'2026-11-29','2026-12-20','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/10/26171302/Edital-Camara-Portel-PA-2026.pdf'),
('Câmara Municipal de Petrolina','municipal','PE','Petrolina/PE','Conforme cargo','open','permanent',17,null::numeric,8561.42,null,'2026-12-05','2027-01-17','https://blog.grancursosonline.com.br/concurso-camara-petrolina-pe/'),
('Câmara Municipal de Alto do Rodrigues','municipal','RN','Alto do Rodrigues/RN','Conforme cargo','open','permanent',12,null::numeric,2500,null,'2026-12-13','2026-12-27','https://blog.grancursosonline.com.br/wp-content/uploads/2026/11/12094343/Edital-Camara-Alto-do-Rodrigues-RN-2026.pdf'),
('Câmara Municipal de Picuí','municipal','PB','Picuí/PB','Conforme cargo','upcoming','permanent',7,null::numeric,3900,'2026-11-23','2026-12-27','2027-02-14','https://blog.grancursosonline.com.br/wp-content/uploads/2026/11/12114754/Edital-Camara-de-Picui-PB-2026.pdf'),
('Câmara Municipal de Paraíso do Tocantins','municipal','TO','Paraíso do Tocantins/TO','Conforme cargo','open','permanent',14,null::numeric,6244.07,'2026-11-18','2026-12-18','2027-01-17','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/11/16111356/Edital-Camara-Paraiso-do-Tocantins-TO-2026.pdf'),
('Câmara Municipal de Croatá','municipal','CE','Croatá/CE','Conforme cargo','open','permanent',15,null::numeric,1621,null,'2026-11-27','2026-12-20','https://blog.grancursosonline.com.br/concurso-publico-13-novembro-2026/'),
('Grupo Hospitalar Conceição — GHC','federal','RS','Rio Grande do Sul','Conforme cargo','open','public_enterprise',null::integer,2010.60,12974.40,'2026-11-05','2026-12-04',null,'https://blog.grancursosonline.com.br/concurso-ghc/'),
('Secretaria Municipal de Saúde de Munhoz','municipal','MG','Munhoz/MG','Conforme cargo','open','permanent',6,null::numeric,1621,null,'2026-12-22','2027-01-24','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/09/23155819/Edital-SMS-Munhoz-MG-2026.pdf'),
('Instituto de Meio Ambiente de Santa Catarina — IMA','state','SC','Santa Catarina','Nível superior','open','permanent',18,7810,12300,'2026-11-13','2026-12-14','2027-02-14','https://blog.grancursosonline.com.br/concurso-ima-sc/'),
('Instituto de Previdência de Porto Velho — IPAM','municipal','RO','Porto Velho/RO','Conforme cargo','open','permanent',71,null::numeric,5000,null,'2026-12-07','2027-02-21','https://blog.grancursosonline.com.br/concurso-ipam-porto-velho-ro/'),
('Concurso público IBGE — Recenseador (temporário)','federal',null::char(2),'Nacional','Nível fundamental','open','temporary',27279,null::numeric,4370,'2026-11-06','2026-11-25','2027-01-31','https://blog.grancursosonline.com.br/concurso-ibge-temporarios/'),
('Processo seletivo Ministério da Saúde — temporários','federal',null::char(2),'Nacional','Nível superior','open','temporary',759,4740.51,11546.29,null,'2026-12-14','2027-01-17','https://blog.grancursosonline.com.br/concurso-ministerio-da-saude-temporarios/'),
('Instituto Federal de São Paulo — Professor Substituto (temporário)','federal','SP','Diversas unidades/SP','Nível superior','open','temporary',null::integer,null::numeric,null,null,'2027-01-05',null,'https://blog-preparatorio-static.infra.grancursosonline.com.br/wp-content/uploads/2026/11/17120236/edital-ifsp-professor-substituto-2026.pdf'),
('Câmara Municipal de São Francisco do Sul','municipal','SC','São Francisco do Sul/SC','Conforme cargo','open','permanent',17,null::numeric,10924.72,'2026-11-06','2026-12-07','2027-01-24','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/10/28180611/Edital-Camara-Sao-Francisco-do-Sul-SC-2026.pdf'),
('Câmara Municipal de Santa Helena de Goiás','municipal','GO','Santa Helena de Goiás/GO','Conforme cargo','open','permanent',25,null::numeric,3386.33,null,'2027-01-13','2027-02-21','https://blog-static.infra.grancursosonline.com.br/wp-content/uploads/2026/11/05161709/Edital-Camara-Santa-Helena-de-Goias-GO-2026.pdf')
) as v(title,sphere,state,city,level,status,employment_type,vacancies,salary_min,salary_max,registration_start,deadline,exam_date,source_url)
where not exists (
  select 1 from public.contests c
  where lower(c.title)=lower(v.title)
    and coalesce(c.state,'')=coalesce(v.state,'')
);
