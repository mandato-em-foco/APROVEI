-- APROVEI | Complemento regional do levantamento nacional (18/11/2026)
-- Fonte de descoberta: Ache Concursos; links individuais de cada seleção.
-- Classificação temporário/permanente separada. Conferir edital/retificações na banca.
-- Idempotente por título + UF.

insert into public.contests
(title,sphere,state,city,level,status,employment_type,vacancies,salary_min,salary_max,
 registration_start,deadline,exam_date,official_url,registration_url,source_url,last_verified_at)
select v.title,v.sphere,v.state,v.city,v.level,v.status,v.employment_type,v.vacancies,
       v.salary_min,v.salary_max,v.registration_start::date,v.deadline::date,
       v.exam_date::date,null,null,v.source_url,now()
from (values
('Processo seletivo de Formosa do Rio Preto — Saúde','municipal','BA','Formosa do Rio Preto/BA','Nível técnico','open','temporary',68,null::numeric,3325,null,'2026-11-29',null,'https://www.acheconcursos.com.br/concursos-bahia/formosa-do-rio-preto-ba-2026-68-vagas-processo-seletivo-94711'),
('Processo seletivo da Prefeitura de Tucano','municipal','BA','Tucano/BA','Nível médio e superior','open','temporary',83,null::numeric,3000,null,'2026-11-25',null,'https://www.acheconcursos.com.br/concursos-bahia/prefeitura-de-tucano-ba-abre-83-vagas-processo-seletivo-94540'),
('Processo seletivo da Prefeitura de Itiúba','municipal','BA','Itiúba/BA','Nível médio, técnico e superior','open','temporary',65,null::numeric,4750,null,'2026-11-22',null,'https://www.acheconcursos.com.br/concursos-bahia/edital-itiuba-ba-prefeitura-65-vagas-via-processo-seletivo-94513'),
('Prefeitura de Mairi — Concurso Público','municipal','BA','Mairi/BA','Nível médio e superior','open','permanent',20,null::numeric,3242,null,'2026-11-23',null,'https://www.acheconcursos.com.br/concursos-bahia/prefeitura-de-mairi-ba-lanca-concurso-publico-edital-94338'),
('Defensoria Pública do Distrito Federal — Analista de Apoio à Assistência Judiciária','state','DF','Distrito Federal','Nível superior','upcoming','permanent',7,null::numeric,11514.95,'2026-12-03','2027-01-07','2027-02-21','https://blog.grancursosonline.com.br/concurso-dpdf/'),
('Prefeitura de São Mateus do Maranhão — Concurso Público','municipal','MA','São Mateus do Maranhão/MA','Fundamental, médio, técnico e superior','open','permanent',475,null::numeric,5130.65,null,'2026-12-07',null,'https://www.acheconcursos.com.br/concursos-maranhao/concurso-sao-mateus-do-maranhao-ma-3-editais-abrem-475-vagas-94675'),
('Instituto Federal do Maranhão — Professor em Barreirinhas','federal','MA','Barreirinhas/MA','Nível superior','open','temporary',1,null::numeric,8340.33,null,'2026-11-28',null,'https://www.acheconcursos.com.br/concursos-maranhao/ifma-abre-vaga-para-professor-em-barreirinhas-94547'),
('Instituto Federal do Maranhão — Professor Substituto','federal','MA','Maranhão','Nível superior','open','temporary',2,null::numeric,8340.33,null,'2026-11-22',null,'https://www.acheconcursos.com.br/concursos-maranhao/ifma-abre-vagas-para-professor-substituto-ainda-em-2026-94457'),
('Prefeitura de Ribeirãozinho do Maranhão — Concurso Público','municipal','MA','Ribeirãozinho do Maranhão/MA','Fundamental, médio, técnico e superior','open','permanent',211,null::numeric,6500,null,'2026-12-01',null,'https://www.acheconcursos.com.br/concursos-maranhao/concurso-prefeitura-de-ribeiraozinho-do-maranhao-ma-vagas-94012'),
('Prefeitura de Itinga do Maranhão — seleção de professores via PND','municipal','MA','Itinga do Maranhão/MA','Nível superior','open','temporary',33,null::numeric,null,null,'2027-01-15',null,'https://www.acheconcursos.com.br/concursos-maranhao/prefeitura-de-itinga-do-maranhao-ma-abre-33-vagas-para-professores-via-pnd-90592'),
('Câmara Municipal de São João do Piauí','municipal','PI','São João do Piauí/PI','Nível superior','open','permanent',1,null::numeric,4052.50,null,'2026-11-30',null,'https://www.acheconcursos.com.br/concursos-piaui/camara-de-sao-joao-do-piaui-pi-abre-concurso-publico-94351'),
('Prefeitura de São Julião — Concurso Público','municipal','PI','São Julião/PI','Fundamental, médio, técnico e superior','open','permanent',114,null::numeric,6000,null,'2026-12-07',null,'https://www.acheconcursos.com.br/concursos-piaui/concurso-sao-juliao-pi-2026-prefeitura-114-vagas-94308'),
('Prefeitura de Belém do Piauí — Concurso Público','municipal','PI','Belém do Piauí/PI','Fundamental, médio, técnico e superior','open','permanent',49,null::numeric,12000,null,'2026-11-25',null,'https://www.acheconcursos.com.br/concursos-piaui/concurso-prefeitura-belem-do-piaui-pi-2026-saiu-edital-94277'),
('Prefeitura de Campo Grande do Piauí — Concurso Público','municipal','PI','Campo Grande do Piauí/PI','Fundamental, médio, técnico e superior','open','permanent',90,null::numeric,8257,null,'2026-11-25',null,'https://www.acheconcursos.com.br/concursos-piaui/concurso-campo-grande-do-piaui-pi-2026-edital-94233'),
('Prefeitura de Cristalândia do Piauí — Concurso Público','municipal','PI','Cristalândia do Piauí/PI','Médio, técnico e superior','open','permanent',50,null::numeric,4750,null,'2026-11-23',null,'https://www.acheconcursos.com.br/concursos-piaui/edital-cristalandia-do-piaui-pi-2026-abre-concurso-50-vagas-94127'),
('Prefeitura de Canto do Buriti — Concurso Público','municipal','PI','Canto do Buriti/PI','Fundamental, médio, técnico e superior','open','permanent',257,null::numeric,16210,null,'2026-11-26',null,'https://www.acheconcursos.com.br/concursos-piaui/concurso-prefeitura-de-canto-do-buriti-pi-2026-edital-257-vagas-94107'),
('Prefeitura de Monsenhor Gil — Concurso Público','municipal','PI','Monsenhor Gil/PI','Fundamental, médio, técnico e superior','open','permanent',101,null::numeric,8000,null,'2026-11-23',null,'https://www.acheconcursos.com.br/concursos-piaui/concurso-prefeitura-de-monsenhor-gil-pi-2026-vagas-8-mil-94102'),
('Universidade Federal de Sergipe — Professor Titular','federal','SE','São Cristóvão/SE','Nível superior','open','permanent',2,null::numeric,26326.81,null,'2026-12-22',null,'https://www.acheconcursos.com.br/concursos-sergipe/ufs-abre-concurso-para-professor-titular-com-salario-de-r-26-mil-94683')
) as v(title,sphere,state,city,level,status,employment_type,vacancies,salary_min,salary_max,registration_start,deadline,exam_date,source_url)
where not exists (
  select 1 from public.contests c
  where lower(c.title)=lower(v.title)
    and coalesce(c.state,'')=coalesce(v.state,'')
);
