import { useEffect, useState } from "react";
import type { FormEvent } from "react";
import {
  BookOpen, CalendarDays, ChartNoAxesCombined, CircleHelp, Clock3,
  GraduationCap, LogIn, LogOut, Menu, Search, ShieldCheck, Video,
  X, MapPin, ArrowRight, CheckCircle2
} from "lucide-react";
import { isSupabaseConfigured, supabase } from "./lib/supabase";

type Contest = {
  id: string; title: string; state: string; city: string; level: string;
  status: string; deadline: string | null; official_url: string | null;
};

const navItems = [
  ["Visão geral", "home"], ["Concursos", "contests"], ["Meu planejamento", "planner"],
  ["Videoaulas", "videos"], ["Meu desempenho", "progress"]
] as const;

const states = ["Todos os estados","AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"];

export default function App() {
  const [page, setPage] = useState("home");
  const [mobileMenu, setMobileMenu] = useState(false);
  const [session, setSession] = useState<any>(null);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [authMode, setAuthMode] = useState<"login"|"signup">("login");
  const [authMessage, setAuthMessage] = useState("");
  const [contests, setContests] = useState<Contest[]>([]);
  const [contestSearch, setContestSearch] = useState("");
  const [stateFilter, setStateFilter] = useState("Todos os estados");
  const [loadingContests, setLoadingContests] = useState(false);

  useEffect(() => {
    if (!supabase) return;
    supabase.auth.getSession().then(({ data }) => setSession(data.session));
    const { data: listener } = supabase.auth.onAuthStateChange((_event, next) => setSession(next));
    return () => listener.subscription.unsubscribe();
  }, []);

  useEffect(() => {
    if (!supabase || page !== "contests") return;
    let alive = true;
    setLoadingContests(true);
    supabase.from("contests")
      .select("id,title,state,city,level,status,deadline,official_url")
      .eq("status", "open")
      .order("deadline", { ascending: true })
      .limit(100)
      .then(({ data, error }) => {
        if (!alive) return;
        if (!error && data) setContests(data as Contest[]);
        setLoadingContests(false);
      });
    return () => { alive = false; };
  }, [page]);

  async function handleAuth(e: FormEvent) {
    e.preventDefault();
    setAuthMessage("");
    if (!supabase) {
      setAuthMessage("Configure as variáveis do Supabase no arquivo .env.local antes de usar o login.");
      return;
    }
    const result = authMode === "signup"
      ? await supabase.auth.signUp({ email, password })
      : await supabase.auth.signInWithPassword({ email, password });
    setAuthMessage(result.error?.message ?? (authMode === "signup"
      ? "Cadastro enviado. Confira seu e-mail para confirmar a conta."
      : "Login realizado."));
  }

  async function logout() {
    await supabase?.auth.signOut();
    setSession(null);
  }

  const filteredContests = contests.filter(c =>
    `${c.title} ${c.city} ${c.state} ${c.level}`.toLowerCase().includes(contestSearch.toLowerCase()) &&
    (stateFilter === "Todos os estados" || c.state === stateFilter)
  );

  function go(next: string) { setPage(next); setMobileMenu(false); }

  return <div className="app-shell">
    <header className="topbar">
      <button className="menu-button" onClick={() => setMobileMenu(!mobileMenu)} aria-label="Abrir menu">
        {mobileMenu ? <X/> : <Menu/>}
      </button>
      <button className="brand" onClick={() => go("home")}><span className="brand-mark">A<span>✓</span></span><span>APROVEI<small>SUA APROVAÇÃO COMEÇA AQUI</small></span></button>
      <div className="top-actions">
        {session ? <><span className="user-email">{session.user.email}</span><button className="icon-button" onClick={logout} title="Sair"><LogOut size={18}/></button></> : <button className="login-link" onClick={() => go("account")}><LogIn size={17}/> Entrar</button>}
      </div>
    </header>

    <div className="layout">
      <aside className={`sidebar ${mobileMenu ? "open" : ""}`}>
        <div className="side-label">ÁREA DO ALUNO</div>
        {navItems.map(([label,key]) => <button key={key} className={`nav-item ${page===key?"active":""}`} onClick={() => go(key)}>
          {key==="home"?<ChartNoAxesCombined/>:key==="contests"?<Search/>:key==="planner"?<CalendarDays/>:key==="videos"?<Video/>:<Clock3/>}{label}
        </button>)}
        <div className="sidebar-bottom"><ShieldCheck/><span>Estude com estratégia.<br/><b>Conquiste sua aprovação.</b></span></div>
      </aside>

      <main className="content">
        {page==="home" && <Home onNavigate={go} configured={isSupabaseConfigured} session={session}/>}
        {page==="contests" && <section>
          <PageHeading eyebrow="OPORTUNIDADES" title="Concursos públicos" subtitle="Encontre editais federais, estaduais e municipais em um só lugar."/>
          <div className="filters">
            <label className="searchbox"><Search size={18}/><input value={contestSearch} onChange={e=>setContestSearch(e.target.value)} placeholder="Buscar órgão, cargo ou município"/></label>
            <select value={stateFilter} onChange={e=>setStateFilter(e.target.value)}>{states.map(s=><option key={s}>{s}</option>)}</select>
          </div>
          {!isSupabaseConfigured ? <Notice text="Conecte o Supabase e execute o arquivo supabase/schema.sql. Depois, os concursos cadastrados aparecerão aqui."/> :
            loadingContests ? <p>Carregando concursos...</p> :
            filteredContests.length===0 ? <Empty text="Nenhum concurso aberto cadastrado ainda. O painel administrativo será usado para incluir editais verificados."/> :
            <div className="contest-grid">{filteredContests.map(c=><article className="contest-card" key={c.id}>
              <span className="status-pill">Inscrições abertas</span><h3>{c.title}</h3><p><MapPin size={15}/> {c.city} / {c.state}</p><p><GraduationCap size={15}/> {c.level}</p>
              {c.deadline && <p><CalendarDays size={15}/> Até {new Date(c.deadline+"T12:00:00").toLocaleDateString("pt-BR")}</p>}
              {c.official_url && <a href={c.official_url} target="_blank" rel="noreferrer">Consultar edital <ArrowRight size={15}/></a>}
            </article>)}</div>}
        </section>}
        {page==="planner" && <Placeholder icon={<CalendarDays/>} title="Meu planejamento" text="Nesta etapa vamos implementar ciclo de estudos, calendário semanal, metas e revisões programadas."/>}
        {page==="videos" && <Placeholder icon={<Video/>} title="Sala de videoaulas" text="Aqui ficarão as aulas do YouTube organizadas por concurso, disciplina e assunto, com registro de progresso."/>}
        {page==="progress" && <Placeholder icon={<ChartNoAxesCombined/>} title="Meu desempenho" text="Acompanhe horas estudadas, assuntos concluídos, revisões e evolução por disciplina."/>}
        {page==="account" && <section className="auth-wrap"><div className="auth-card">
          <div className="auth-icon"><GraduationCap/></div><h1>{authMode==="login"?"Bem-vindo de volta!":"Crie sua conta"}</h1><p>Acesse seu espaço de preparação no APROVEI.</p>
          <form onSubmit={handleAuth}><label>E-mail<input type="email" required value={email} onChange={e=>setEmail(e.target.value)} placeholder="voce@email.com"/></label><label>Senha<input type="password" minLength={6} required value={password} onChange={e=>setPassword(e.target.value)} placeholder="Mínimo de 6 caracteres"/></label><button className="primary full" type="submit">{authMode==="login"?"Entrar":"Criar conta"}</button></form>
          {authMessage && <p className="auth-message">{authMessage}</p>}
          <button className="text-button" onClick={()=>{setAuthMode(authMode==="login"?"signup":"login");setAuthMessage("");}}>{authMode==="login"?"Ainda não tem conta? Cadastre-se":"Já tem conta? Entrar"}</button>
          {!isSupabaseConfigured && <p className="small-note">O login será ativado após configurar o Supabase.</p>}
        </div></section>}
      </main>
    </div>
    <footer>© {new Date().getFullYear()} APROVEI · Plataforma independente de preparação para concursos públicos.</footer>
  </div>;
}

function Home({onNavigate,configured,session}:{onNavigate:(s:string)=>void;configured:boolean;session:any}) {
  return <div className="home">
    <section className="hero">
      <div className="hero-copy"><span className="eyebrow">SUA JORNADA COMEÇA AGORA</span><h1>Seu próximo cargo público começa com <em>APROVEI.</em></h1><p>Organize seus estudos, acompanhe editais e transforme sua preparação em resultados.</p>
        <div className="hero-actions"><button className="primary" onClick={()=>onNavigate(session?"planner":"account")}>{session?"Organizar meus estudos":"Começar gratuitamente"} <ArrowRight size={17}/></button><button className="secondary" onClick={()=>onNavigate("contests")}>Ver concursos abertos</button></div>
        <div className="hero-proof"><span><CheckCircle2/> Planejamento</span><span><CheckCircle2/> Editais</span><span><CheckCircle2/> Videoaulas</span></div>
      </div>
      <div className="hero-visual"><div className="orbit orbit-one"/><div className="orbit orbit-two"/><div className="hero-badge"><GraduationCap size={42}/></div><div className="floating-card card-top"><span>FOCO</span><b>Disciplina diária</b></div><div className="floating-card card-bottom"><span>PROGRESSO</span><b>Um passo por vez ✓</b></div></div>
    </section>
    <section className="feature-grid">
      <Feature icon={<Search/>} title="Concursos em todo o Brasil" text="Pesquise oportunidades por estado, município, órgão e escolaridade."/>
      <Feature icon={<CalendarDays/>} title="Planejamento inteligente" text="Organize matérias, metas, revisões e seu tempo de estudo."/>
      <Feature icon={<Video/>} title="Videoaulas organizadas" text="Encontre aulas públicas do YouTube relacionadas a cada assunto."/>
      <Feature icon={<ChartNoAxesCombined/>} title="Acompanhe sua evolução" text="Visualize sua rotina e mantenha o foco na aprovação."/>
    </section>
    <section className="plans"><div><span className="eyebrow">PLANOS APROVEI</span><h2>Escolha seu ritmo de preparação</h2><p>Os valores abaixo são a proposta comercial inicial. A cobrança ainda será integrada.</p></div><div className="plan-grid">
      <Plan name="Essencial" price="14,90" desc="Para organizar a rotina."/><Plan name="Avançado" price="24,90" desc="Para aprofundar a preparação." featured/><Plan name="Aprovação" price="39,90" desc="Para uma experiência completa."/>
    </div></section>
    {!configured && <Notice text="Modo de demonstração: para ativar contas e dados reais, configure as variáveis do Supabase conforme o README."/>}
  </div>;
}
function PageHeading({eyebrow,title,subtitle}:{eyebrow:string;title:string;subtitle:string}) {return <div className="page-heading"><span className="eyebrow">{eyebrow}</span><h1>{title}</h1><p>{subtitle}</p></div>}
function Feature({icon,title,text}:{icon:any;title:string;text:string}) {return <article className="feature-card"><div className="feature-icon">{icon}</div><h3>{title}</h3><p>{text}</p></article>}
function Plan({name,price,desc,featured=false}:{name:string;price:string;desc:string;featured?:boolean}) {return <article className={`plan-card ${featured?"featured":""}`}><span>{name}</span><div className="price"><small>R$</small>{price}<small>/mês</small></div><p>{desc}</p><button className={featured?"primary":"secondary"} onClick={()=>alert("A assinatura será habilitada após a integração com o Mercado Pago.")}>Conhecer plano</button></article>}
function Placeholder({icon,title,text}:{icon:any;title:string;text:string}) {return <div className="placeholder"><div className="placeholder-icon">{icon}</div><h1>{title}</h1><p>{text}</p><span>Funcionalidade prevista para a próxima etapa de desenvolvimento.</span></div>}
function Notice({text}:{text:string}) {return <div className="notice"><CircleHelp size={20}/><span>{text}</span></div>}
function Empty({text}:{text:string}) {return <div className="empty"><BookOpen size={30}/><p>{text}</p></div>}
