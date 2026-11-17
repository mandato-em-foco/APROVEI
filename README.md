# APROVEI — base inicial

Projeto inicial do site responsivo APROVEI, preparado para conectar ao Supabase.

## Requisitos
- Node.js 20 ou superior
- Projeto Supabase separado do Mandato em Foco

## 1. Instalar
```bash
npm install
```

## 2. Configurar Supabase
1. No painel Supabase, abra **Project Settings → API**.
2. Copie a **Project URL** e a chave pública/anon (ou publishable key compatível).
3. Crie `.env.local` na raiz usando `.env.example` como modelo:

```env
VITE_SUPABASE_URL=https://SEU-PROJETO.supabase.co
VITE_SUPABASE_ANON_KEY=SUA_CHAVE_PUBLICAVEL
```

Não use a chave `service_role` no navegador e nunca a publique no GitHub.

## 3. Criar as tabelas
No Supabase, abra **SQL Editor → New query**, copie todo o conteúdo de `supabase/schema.sql` e execute.

## 4. Executar localmente
```bash
npm run dev
```
Abra o endereço local mostrado pelo Vite.

## 5. Gerar versão de produção
```bash
npm run build
```
A pasta gerada será `dist`.

## Estado desta entrega
- Página inicial e navegação responsiva.
- Telas iniciais de concursos, planejamento, videoaulas e desempenho.
- Cadastro/login Supabase (após configurar `.env.local`).
- Leitura de concursos abertos no banco.
- Esquema inicial com RLS.

## Ainda não implementado
- Painel administrativo seguro para cadastrar concursos e videoaulas.
- Importação nacional automática e validação de editais.
- Planejamento, cronômetro, revisões e estatísticas funcionais.
- Integração real do Mercado Pago e webhooks.
- Aplicativo publicado nas lojas.
- Não cadastre editais fictícios: só publique oportunidades conferidas em fonte oficial.

## Deploy
Configure a hospedagem para executar `npm run build` e publicar a pasta `dist`.
Variáveis de ambiente necessárias: `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY`.
