-- Permite criar planejamento de estudo geral, sem concurso previamente cadastrado.
-- Execute no Supabase SQL Editor uma única vez.
alter table public.study_plans alter column contest_id drop not null;
