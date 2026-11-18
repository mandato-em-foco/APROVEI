import Planner from "./components/Planner";
import { useEffect, useMemo, useState } from "react";
import type { FormEvent, ReactNode } from "react";
import {
  ArrowRight, BookOpen, CalendarDays, Check, CheckCircle2, ChevronDown,
  ChevronLeft, ChevronRight, Clock3, FileText, GraduationCap, Headphones,
  LayoutDashboard, LogIn, LogOut, Menu, Play, Search, ShieldCheck,
  Target, TrendingUp, Users, Video, X, Zap, Award, BookMarked
} from "lucide-react";
import { isSupabaseConfigured, supabase } from "./lib/supabase";

type Page = "landing" | "login" | "signup" | "dashboard" | "contests" | "planner" | "videos" | "progress";

type Contest = {
  id: string;
  title: string;
  state: string | null;
  city: string | null;
  level: string | null;
  status: string;
  deadline: string | null;
  official_url: string | null;
};

type Subject = { id: string; name: string };

type StudySession = {
  id: string;
  duration_minutes: number;
  studied_at: string;
  notes: string | null;
  subject_id: string | null;
};

type Lesson = {
  id: string;
  title: string;
  youtube_video_id: string;
  channel_name: string | null;
};

const plans = [
  {
    name: "Essencial",
    description: "O necessário para começar com organização e constância.",
    annual: "9,90",
    semiannual: "12,90",
    quarterly: "14,90",
    features: ["Organização dos estudos", "Acesso aos concursos", "Registro de estudos", "Acompanhamento básico"],
    featured: false
  },
  {
    name: "Avançado",
    description: "Mais recursos para aprofundar sua preparação.",
    annual: "19,90",
    semiannual: "22,90",
    quarterly: "25,90",
    features: ["Tudo do Essencial", "Planejamento de estudos", "Videoaulas organizadas", "Acompanhamento de desempenho", "Recursos de revisão"],
    featured: true
  },
  {
    name: "Aprovação",
    description: "Uma experiência completa para sua jornada.",
    annual: "33,90",
    semiannual: "35,90",
    quarterly: "39,90",
    features: ["Tudo do Avançado", "Recursos avançados de preparação", "Organização por edital", "Ferramentas de produtividade", "Experiência completa"],
    featured: false
  }
];

const demoContent = [
  {
    label: "Planejamento",
    title: "Sua rotina, organizada em um só lugar.",
    text: "Monte uma rotina de estudos, registre o tempo dedicado e acompanhe sua constância.",
    icon: <CalendarDays />,
    items: ["Defina suas disciplinas", "Registre cada sessão", "Acompanhe seu histórico"]
  },
  {
    label: "Concursos",
    title: "Encontre oportunidades para sua carreira.",
    text: "Consulte concursos federais, estaduais e municipais em uma área organizada.",
    icon: <Search />,
    items: ["Pesquise por órgão e cargo", "Filtre por estado", "Consulte a fonte oficial"]
  },
  {
    label: "Videoaulas",
    title: "Conteúdo organizado para facilitar sua preparação.",
    text: "Encontre aulas públicas do YouTube organizadas por assunto e disciplina.",
    icon: <Video />,
    items: ["Aulas por disciplina", "Acesso direto ao YouTube", "Estude no seu ritmo"]
  }
];

const faqs = [
  {
    q: "O que é o APROVEI?",
    a: "O APROVEI é uma plataforma de apoio à preparação para concursos públicos. A proposta é reunir organização dos estudos, oportunidades, videoaulas e acompanhamento de desempenho em um só ambiente."
  },
  {
    q: "Posso estudar para qualquer concurso?",
    a: "A plataforma foi planejada para atender diferentes áreas e níveis de escolaridade, incluindo concursos policiais, administrativos, tribunais, educação, área fiscal, bancos e Forças Armadas."
  },
  {
    q: "Os planos são cobrados mensalmente?",
    a: "Os valores exibidos representam o equivalente mensal de cada modalidade: trimestral, semestral ou anual. A forma e o valor total da cobrança serão informados claramente antes da confirmação da contratação."
  },
  {
    q: "Como faço para começar?",
    a: "Você poderá criar sua conta pela opção de cadastro. Depois, poderá acessar a área do aluno e utilizar os recursos que estiverem disponíveis no seu plano."
  },
  {
    q: "As videoaulas são do APROVEI?",
    a: "O catálogo inicial poderá reunir videoaulas públicas disponíveis no YouTube, organizadas por disciplina. O conteúdo continua hospedado nos canais responsáveis."
  }
];

const states = [
  "Todos os estados", "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES",
  "GO", "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ",
  "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"
];

function money(value: string) {
  return `R$ ${value}`;
}

export default function App() {
  const [page, setPage] = useState<Page>("landing");
  const [mobileMenu, setMobileMenu] = useState(false);
  const [demoTab, setDemoTab] = useState(0);
  const [faqOpen, setFaqOpen] = useState<number | null>(0);
  const [billing, setBilling] = useState<"annual" | "semiannual" | "quarterly">("annual");
  const [session, setSession] = useState<any>(null);
  const [rememberMe, setRememberMe] = useState(true);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [fullName, setFullName] = useState("");
  const [authMessage, setAuthMessage] = useState("");
  const [contests, setContests] = useState<Contest[]>([]);
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [sessions, setSessions] = useState<StudySession[]>([]);
  const [lessons, setLessons] = useState<Lesson[]>([]);
  const [search, setSearch] = useState("");
  const [stateFilter, setStateFilter] = useState("Todos os estados");
  const [subjectId, setSubjectId] = useState("");
  const [minutes, setMinutes] = useState("60");
  const [notes, setNotes] = useState("");
  const [message, setMessage] = useState("");

  async function refresh(userId?: string) {
    if (!supabase) return;

    const [contestResult, subjectResult, lessonResult] = await Promise.all([
      supabase.from("contests")
        .select("id,title,state,city,level,status,deadline,official_url")
        .in("status", ["open", "upcoming"])
        .order("deadline", { ascending: true })
        .limit(100),
      supabase.from("subjects").select("id,name").order("name"),
      supabase.from("video_lessons")
        .select("id,title,youtube_video_id,channel_name")
        .eq("is_published", true)
        .order("created_at", { ascending: false })
        .limit(100)
    ]);

    if (contestResult.data) setContests(contestResult.data as Contest[]);
    if (subjectResult.data) setSubjects(subjectResult.data as Subject[]);
    if (lessonResult.data) setLessons(lessonResult.data as Lesson[]);

    if (userId) {
      const result = await supabase.from("study_sessions")
        .select("id,duration_minutes,studied_at,notes,subject_id")
        .eq("user_id", userId)
        .order("studied_at", { ascending: false })
        .limit(100);

      if (result.data) setSessions(result.data as StudySession[]);
    }
  }

  useEffect(() => {
    if (!supabase) return;

    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      if (data.session) {
        setPage("dashboard");
        void refresh(data.session.user.id);
      }
    });

    const { data } = supabase.auth.onAuthStateChange((_event, next) => {
      setSession(next);
      if (next) void refresh(next.user.id);
      else setSessions([]);
    });

    return () => data.subscription.unsubscribe();
  }, []);

  function go(next: Page) {
    setPage(next);
    setMobileMenu(false);
    setMessage("");
    setAuthMessage("");
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  function goToSection(id: string) {
    setMobileMenu(false);
    if (page !== "landing") setPage("landing");
    window.setTimeout(() => {
      document.getElementById(id)?.scrollIntoView({ behavior: "smooth" });
    }, 80);
  }

  function choosePlan() {
    go(session ? "dashboard" : "signup");
  }

  async function handleAuth(event: FormEvent) {
    event.preventDefault();
    setAuthMessage("");

    if (!supabase) {
      setAuthMessage("A conexão com o sistema ainda não está configurada. Tente novamente mais tarde.");
      return;
    }

    if (typeof window !== "undefined") {
      window.localStorage.setItem("aprovei-remember-session", rememberMe ? "true" : "false");
      if (!rememberMe) window.localStorage.removeItem("aprovei-last-session");
    }

    const result = page === "signup"
      ? await supabase.auth.signUp({
          email,
          password,
          options: { data: { full_name: fullName.trim() } }
        })
      : await supabase.auth.signInWithPassword({ email, password });

    if (result.error) {
      setAuthMessage(result.error.message);
      return;
    }

    if (page === "signup") {
      setAuthMessage("Cadastro recebido! Confira seu e-mail para confirmar a conta.");
    } else {
      setAuthMessage("Login realizado. Sua área de estudos está sendo carregada.");
      if (result.data.session) go("dashboard");
    }
  }

  async function handleSignOut() {
    await supabase?.auth.signOut();
    go("landing");
  }

  async function addStudySession(event: FormEvent) {
    event.preventDefault();
    if (!supabase || !session) return;

    const duration = Number(minutes);
    if (!Number.isFinite(duration) || duration < 1 || duration > 1440) {
      setMessage("Informe uma duração entre 1 e 1.440 minutos.");
      return;
    }

    const { error } = await supabase.from("study_sessions").insert({
      user_id: session.user.id,
      subject_id: subjectId || null,
      duration_minutes: duration,
      notes: notes.trim() || null
    });

    if (error) {
      setMessage("Não foi possível salvar: " + error.message);
      return;
    }

    setMessage("Sessão registrada com sucesso!");
    setNotes("");
    await refresh(session.user.id);
  }

  const filteredContests = useMemo(() => contests.filter(contest => {
    const searchable = [
      contest.title, contest.city || "", contest.state || "", contest.level || ""
    ].join(" ").toLowerCase();

    return searchable.includes(search.toLowerCase()) &&
      (stateFilter === "Todos os estados" || contest.state === stateFilter);
  }), [contests, search, stateFilter]);

  const totalMinutes = sessions.reduce((total, item) => total + item.duration_minutes, 0);
  const totalHours = Math.floor(totalMinutes / 60);
  const remainingMinutes = totalMinutes % 60;
  const todayForStats = new Date();
  const weekStart = new Date(todayForStats);
  weekStart.setHours(0, 0, 0, 0);
  weekStart.setDate(weekStart.getDate() - ((weekStart.getDay() + 6) % 7));
  const weekEnd = new Date(weekStart);
  weekEnd.setDate(weekEnd.getDate() + 7);
  const weekSessions = sessions.filter(item => {
    const date = new Date(item.studied_at);
    return date >= weekStart && date < weekEnd;
  });
  const weekMinutes = weekSessions.reduce((sum, item) => sum + item.duration_minutes, 0);
  const weekHours = Math.floor(weekMinutes / 60);
  const weekRemainder = weekMinutes % 60;
  const activeStudyDays = new Set(weekSessions.map(item => {
    const date = new Date(item.studied_at);
    return `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`;
  })).size;
  const weekDayStats = Array.from({ length: 7 }, (_, index) => {
    const date = new Date(weekStart);
    date.setDate(weekStart.getDate() + index);
    const key = `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`;
    const minutes = weekSessions.filter(item => {
      const studied = new Date(item.studied_at);
      return `${studied.getFullYear()}-${studied.getMonth()}-${studied.getDate()}` === key;
    }).reduce((sum, item) => sum + item.duration_minutes, 0);
    return { label: date.toLocaleDateString("pt-BR", { weekday: "short" }).replace(".", ""), minutes };
  });
  const maxWeekDayMinutes = Math.max(60, ...weekDayStats.map(day => day.minutes));
    if (page === "landing") {
    return (
      <div className="site-shell">
        <header className="site-header">
          <button className="brand" onClick={() => go("landing")} aria-label="APROVEI - início">
            <span className="brand-symbol">A<span>✓</span></span>
            <span className="brand-words">APROVEI<small>SUA APROVAÇÃO COMEÇA AQUI!</small></span>
          </button>
          <nav className={mobileMenu ? "main-nav open" : "main-nav"}>
            <button onClick={() => goToSection("inicio")}>Início</button>
            <button onClick={() => goToSection("recursos")}>Recursos</button>
            <button onClick={() => goToSection("concursos")}>Concursos</button>
            <button onClick={() => goToSection("planos")}>Planos</button>
            <button onClick={() => goToSection("duvidas")}>Dúvidas</button>
            <button className="mobile-login" onClick={() => go("login")}>Entrar</button>
          </nav>
          <div className="header-actions">
            <button className="button button-outline" onClick={() => go("login")}>Entrar</button>
            <button className="button button-primary" onClick={() => go("signup")}>Começar agora <ArrowRight size={16} /></button>
          </div>
          <button className="menu-toggle" onClick={() => setMobileMenu(!mobileMenu)} aria-label="Abrir menu">
            {mobileMenu ? <X /> : <Menu />}
          </button>
        </header>

        <main>
          <section className="hero" id="inicio">
            <div className="hero-content">
              <span className="hero-kicker"><Zap size={15} /> SUA JORNADA RUMO À APROVAÇÃO</span>
              <h1>Seu futuro não espera. <span>Sua aprovação começa aqui.</span></h1>
              <p>Organize seus estudos, encontre oportunidades e acompanhe sua evolução. Tudo o que você precisa para transformar esforço em resultado.</p>
              <div className="hero-actions">
                <button className="button button-primary button-large" onClick={() => go("signup")}>Quero começar <ArrowRight size={18} /></button>
                <button className="button button-outline button-large" onClick={() => goToSection("recursos")}><Play size={17} /> Conhecer a plataforma</button>
              </div>
              <div className="hero-trust">
                <span><CheckCircle2 /> Organização</span>
                <span><CheckCircle2 /> Estratégia</span>
                <span><CheckCircle2 /> Evolução</span>
              </div>
            </div>
            <div className="hero-visual">
              <div className="hero-glow" />
              <div className="dashboard-preview">
                <div className="preview-top">
                  <div><span className="preview-dot" /><span className="preview-dot" /><span className="preview-dot" /></div>
                  <span>APROVEI • ÁREA DO ALUNO</span>
                </div>
                <div className="preview-welcome">
                  <span className="eyebrow">BEM-VINDO À SUA JORNADA</span>
                  <h3>Um passo de cada vez.</h3>
                  <p>Seu progresso começa com consistência.</p>
                </div>
                <div className="preview-stats">
                  <div><span className="preview-stat-icon"><Clock3 /></span><strong>02h 30</strong><small>Tempo de estudo</small></div>
                  <div><span className="preview-stat-icon"><Target /></span><strong>85%</strong><small>Meta semanal</small></div>
                </div>
                <div className="preview-progress">
                  <div><b>Meta de estudos</b><span>5 de 6 dias</span></div>
                  <div className="progress-track"><span /></div>
                </div>
                <div className="preview-task"><span><Check /></span><div><b>Revisão de Português</b><small>Disciplina • 30 minutos</small></div><CheckCircle2 /></div>
              </div>
              <div className="floating-note"><span><Award /></span><div><b>Foco no objetivo</b><small>Seu próximo passo começa hoje.</small></div></div>
            </div>
          </section>

          <section className="proof-strip">
            <div><strong>01</strong><span>Organize sua rotina</span></div>
            <div><strong>02</strong><span>Encontre oportunidades</span></div>
            <div><strong>03</strong><span>Acompanhe seu progresso</span></div>
            <div><strong>04</strong><span>Avance com estratégia</span></div>
          </section>

          <section className="section features-section" id="recursos">
            <div className="section-heading">
              <span className="eyebrow">UMA PLATAFORMA, MUITAS POSSIBILIDADES</span>
              <h2>Mais organização. <span>Mais direção.</span></h2>
              <p>Ferramentas para tornar sua preparação mais clara, produtiva e consistente.</p>
            </div>
            <div className="feature-grid">
              <FeatureCard icon={<CalendarDays />} title="Planejamento inteligente" text="Organize suas disciplinas, registre seus estudos e construa uma rotina que faça sentido." />
              <FeatureCard icon={<Search />} title="Concursos em foco" text="Pesquise oportunidades e consulte informações e fontes oficiais." />
              <FeatureCard icon={<Video />} title="Videoaulas" text="Encontre conteúdos públicos organizados para apoiar sua preparação." />
              <FeatureCard icon={<TrendingUp />} title="Seu desempenho" text="Acompanhe o tempo dedicado e visualize seu histórico de estudos." />
            </div>
          </section>

          <section className="section demo-section">
            <div className="demo-copy">
              <span className="eyebrow">CONHEÇA POR DENTRO</span>
              <h2>Uma preparação mais <span>simples de administrar.</span></h2>
              <p>Explore algumas das áreas que fazem parte da experiência APROVEI.</p>
              <div className="demo-tabs">
                {demoContent.map((item, index) => (
                  <button key={item.label} className={demoTab === index ? "demo-tab active" : "demo-tab"} onClick={() => setDemoTab(index)}>
                    <span>{item.icon}</span>{item.label}<ChevronRight size={17} />
                  </button>
                ))}
              </div>
            </div>
            <div className="demo-panel">
              <div className="demo-panel-top"><span>APROVEI / RECURSOS</span><span className="live-dot">EXPERIÊNCIA</span></div>
              <div className="demo-panel-icon">{demoContent[demoTab].icon}</div>
              <h3>{demoContent[demoTab].title}</h3>
              <p>{demoContent[demoTab].text}</p>
              <ul>{demoContent[demoTab].items.map(item => <li key={item}><CheckCircle2 />{item}</li>)}</ul>
              <button className="button button-primary" onClick={() => go("signup")}>Quero experimentar <ArrowRight size={16} /></button>
            </div>
          </section>

          <section className="section audience-section" id="concursos">
            <div className="section-heading">
              <span className="eyebrow">SEU OBJETIVO É O NOSSO PONTO DE PARTIDA</span>
              <h2>Prepare-se para a carreira que <span>você deseja.</span></h2>
              <p>Uma plataforma pensada para diferentes áreas do serviço público.</p>
            </div>
            <div className="audience-grid">
              <Audience icon={<ShieldCheck />} title="Segurança pública" text="Polícia Federal, PRF, Polícias Civis e Militares." />
              <Audience icon={<LandmarkIcon />} title="Tribunais e Judiciário" text="Tribunais, Ministério Público e Defensorias." />
              <Audience icon={<BriefcaseIcon />} title="Administrativa" text="Órgãos federais, estaduais e municipais." />
              <Audience icon={<BookOpen />} title="Educação" text="Instituições de ensino e redes públicas." />
              <Audience icon={<FileText />} title="Fiscal e controle" text="Receita, controladorias e tribunais de contas." />
              <Audience icon={<Users />} title="Outras carreiras" text="INSS, bancos, Forças Armadas e muito mais." />
            </div>
          </section>

          <section className="section plans-section" id="planos">
            <div className="section-heading">
              <span className="eyebrow">ESCOLHA SUA JORNADA</span>
              <h2>O plano certo para <span>seu próximo passo.</span></h2>
              <p>Conheça as opções e escolha o período que faz sentido para sua preparação.</p>
            </div>
            <div className="billing-switch">
              <button className={billing === "quarterly" ? "active" : ""} onClick={() => setBilling("quarterly")}>Trimestral</button>
              <button className={billing === "semiannual" ? "active" : ""} onClick={() => setBilling("semiannual")}>Semestral</button>
              <button className={billing === "annual" ? "active" : ""} onClick={() => setBilling("annual")}>Anual <span>MAIOR ECONOMIA</span></button>
            </div>
            <div className="plans-grid">
              {plans.map(plan => (
                <article className={plan.featured ? "plan-card featured" : "plan-card"} key={plan.name}>
                  {plan.featured && <span className="plan-badge">MAIS ESCOLHIDO</span>}
                  <h3>{plan.name}</h3>
                  <p>{plan.description}</p>
                  <div className="plan-price">
                    <span>R$</span>
                    <strong>{plan[billing]}</strong>
                    <small>/mês</small>
                  </div>
                  <span className="plan-period">
                    {billing === "annual" ? "12 meses" : billing === "semiannual" ? "6 meses" : "3 meses"}
                  </span>
                  <ul>{plan.features.map(feature => <li key={feature}><CheckCircle2 />{feature}</li>)}</ul>
                  <button className={plan.featured ? "button button-primary" : "button button-outline"} onClick={choosePlan}>Escolher plano <ArrowRight size={16} /></button>
                </article>
              ))}
            </div>
            <p className="plans-note">Os valores apresentados são equivalentes mensais. A contratação e as condições de pagamento serão informadas antes da confirmação.</p>
          </section>

          <section className="section faq-section" id="duvidas">
            <div className="faq-intro">
              <span className="eyebrow">PERGUNTAS FREQUENTES</span>
              <h2>Ficou com alguma <span>dúvida?</span></h2>
              <p>Veja algumas respostas para começar com tranquilidade.</p>
              <button className="button button-outline" onClick={() => go("signup")}>Começar agora <ArrowRight size={16} /></button>
            </div>
            <div className="faq-list">
              {faqs.map((faq, index) => (
                <article className={faqOpen === index ? "faq-item open" : "faq-item"} key={faq.q}>
                  <button onClick={() => setFaqOpen(faqOpen === index ? null : index)}>
                    <span>{faq.q}</span><ChevronDown />
                  </button>
                  {faqOpen === index && <p>{faq.a}</p>}
                </article>
              ))}
            </div>
          </section>

          <section className="final-cta">
            <div><span className="eyebrow">O SEU FUTURO COMEÇA COM UMA DECISÃO</span><h2>Chegou a hora de levar sua preparação a sério.</h2><p>Organize seus estudos e dê hoje o próximo passo.</p></div>
            <button className="button button-light button-large" onClick={() => go("signup")}>Criar minha conta <ArrowRight size={18} /></button>
          </section>
        </main>

        <footer className="site-footer">
          <div className="footer-brand">
            <span className="brand-symbol">A<span>✓</span></span>
            <div><b>APROVEI</b><small>Sua aprovação começa aqui!</small></div>
          </div>
          <p>Organização, estratégia e evolução para sua preparação.</p>
          <div className="footer-links"><button onClick={() => go("login")}>Entrar</button><button onClick={() => go("signup")}>Criar conta</button><button onClick={() => goToSection("duvidas")}>Ajuda</button></div>
          <small>© {new Date().getFullYear()} APROVEI. Todos os direitos reservados.</small>
        </footer>
      </div>
    );
  }

  if (page === "login" || page === "signup") {
    const isSignup = page === "signup";
    return (
      <div className="auth-shell">
        <header className="auth-header">
          <button className="brand" onClick={() => go("landing")}>
            <span className="brand-symbol">A<span>✓</span></span>
            <span className="brand-words">APROVEI<small>SUA APROVAÇÃO COMEÇA AQUI!</small></span>
          </button>
          <button className="button button-outline" onClick={() => go("landing")}><ChevronLeft size={17} /> Voltar ao início</button>
        </header>
        <main className="auth-main">
          <div className="auth-promo">
            <span className="eyebrow">SUA JORNADA CONTINUA</span>
            <h1>{isSignup ? "Comece a construir sua aprovação." : "Bom ter você de volta."}</h1>
            <p>{isSignup ? "Crie sua conta e dê o primeiro passo para uma preparação mais organizada." : "Entre na sua conta e continue avançando na sua preparação."}</p>
            <div className="auth-promo-points">
              <span><CheckCircle2 /> Organização dos estudos</span>
              <span><CheckCircle2 /> Acompanhamento da evolução</span>
              <span><CheckCircle2 /> Oportunidades em um só lugar</span>
            </div>
          </div>
          <form className="auth-card" onSubmit={handleAuth}>
            <span className="auth-card-icon"><GraduationCap size={27} /></span>
            <h2>{isSignup ? "Criar minha conta" : "Acessar minha conta"}</h2>
            <p>{isSignup ? "Preencha os dados para começar." : "Informe seus dados de acesso."}</p>

            {isSignup && (
              <label>Nome completo
                <input type="text" required autoComplete="name" value={fullName}
                  onChange={event => setFullName(event.target.value)} placeholder="Seu nome" />
              </label>
            )}
            <label>E-mail
              <input type="email" required autoComplete="email" value={email}
                onChange={event => setEmail(event.target.value)} placeholder="voce@email.com" />
            </label>
            <label>Senha
              <input type="password" required minLength={6}
                autoComplete={isSignup ? "new-password" : "current-password"}
                value={password} onChange={event => setPassword(event.target.value)}
                placeholder="Mínimo de 6 caracteres" />
            </label>
            {!isSignup && (
              <label className="remember-session">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={event => setRememberMe(event.target.checked)}
                />
                <span><strong>Manter-me conectado</strong><small>Não precisar entrar novamente neste dispositivo.</small></span>
              </label>
            )}
            <button className="button button-primary auth-submit" type="submit">
              {isSignup ? "Criar conta" : "Entrar"} <ArrowRight size={17} />
            </button>
            {authMessage && <p className="auth-feedback" role="status">{authMessage}</p>}
            <div className="auth-switch">
              {isSignup ? "Já tem uma conta?" : "Ainda não tem uma conta?"}
              <button type="button" onClick={() => { setAuthMessage(""); go(isSignup ? "login" : "signup"); }}>
                {isSignup ? "Entrar" : "Cadastre-se"}
              </button>
            </div>
            {!isSupabaseConfigured && <p className="auth-warning">A conexão com o Supabase precisa ser configurada no ambiente de hospedagem.</p>}
          </form>
        </main>
        <footer className="auth-footer">© {new Date().getFullYear()} APROVEI — Sua aprovação começa aqui!</footer>
      </div>
    );
                  }
  
  const navItems: { id: Page; label: string; icon: ReactNode }[] = [
    { id: "dashboard", label: "Visão geral", icon: <LayoutDashboard /> },
    { id: "contests", label: "Concursos", icon: <Search /> },
    { id: "planner", label: "Planejamento", icon: <CalendarDays /> },
    { id: "videos", label: "Videoaulas", icon: <Video /> },
    { id: "progress", label: "Meu desempenho", icon: <TrendingUp /> }
  ];

  return (
    <div className="student-shell">
      <aside className={mobileMenu ? "student-sidebar open" : "student-sidebar"}>
        <button className="brand student-brand" onClick={() => go("landing")}>
          <span className="brand-symbol">A<span>✓</span></span>
          <span className="brand-words">APROVEI<small>ÁREA DO ALUNO</small></span>
        </button>

        <div className="student-profile">
          <span className="profile-avatar"><GraduationCap /></span>
          <div>
            <b>{session?.user?.user_metadata?.full_name || "Estudante"}</b>
            <small>Minha preparação</small>
          </div>
        </div>

        <nav className="student-nav">
          {navItems.map(item => (
            <button
              key={item.id}
              className={page === item.id ? "active" : ""}
              onClick={() => go(item.id)}
            >
              {item.icon}
              <span>{item.label}</span>
            </button>
          ))}
        </nav>

        <div className="sidebar-bottom">
          <button onClick={() => go("landing")}><LogIn /> Página inicial</button>
          <button onClick={handleSignOut}><LogOut /> Sair da conta</button>
        </div>
      </aside>

      <div className="student-main">
        <header className="student-topbar">
          <button
            className="menu-toggle student-menu-toggle"
            onClick={() => setMobileMenu(!mobileMenu)}
            aria-label="Abrir menu"
          >
            {mobileMenu ? <X /> : <Menu />}
          </button>

          <div>
            <span className="eyebrow">ÁREA DO ALUNO</span>
            <h1>
              Olá, {session?.user?.user_metadata?.full_name?.split(" ")[0] || "estudante"}!
            </h1>
          </div>

          <button className="topbar-action" onClick={() => go("landing")}>
            <span>APROVEI</span><ArrowRight />
          </button>
        </header>

        <main className="student-content">
          {page === "dashboard" && (
            <section>
              <PageHeading
                eyebrow="SUA JORNADA"
                title="Visão geral"
                subtitle="Pequenos avanços diários constroem grandes resultados."
              />

              <div className="student-metrics">
                <Metric
                  icon={<Clock3 />}
                  value={`${totalHours}h ${remainingMinutes}min`}
                  label="Tempo total de estudo"
                />
                <Metric
                  icon={<BookOpen />}
                  value={String(sessions.length)}
                  label="Sessões registradas"
                />
                <Metric
                  icon={<Target />}
                  value={String(contests.length)}
                  label="Oportunidades disponíveis"
                />
              </div>

              <div className="student-grid">
                <section className="student-panel">
                  <div className="panel-heading">
                    <div>
                      <span className="eyebrow">COMECE POR AQUI</span>
                      <h2>Seu próximo passo</h2>
                    </div>
                  </div>

                  <div className="quick-actions">
                    <ActionCard
                      icon={<CalendarDays />}
                      title="Planejar estudos"
                      text="Organize sua rotina."
                      onClick={() => go("planner")}
                    />
                    <ActionCard
                      icon={<Search />}
                      title="Ver concursos"
                      text="Encontre oportunidades."
                      onClick={() => go("contests")}
                    />
                    <ActionCard
                      icon={<Video />}
                      title="Assistir aulas"
                      text="Acesse conteúdos."
                      onClick={() => go("videos")}
                    />
                  </div>
                </section>

                <section className="student-panel welcome-panel">
                  <span className="welcome-icon"><Award /></span>
                  <span className="eyebrow">MENSAGEM PARA VOCÊ</span>
                  <h2>Consistência vale mais que pressa.</h2>
                  <p>
                    Defina uma meta possível, cumpra o que planejou e mantenha o foco na sua aprovação.
                  </p>
                </section>
              </div>

              <section className="student-panel">
                <div className="panel-heading">
                  <div>
                    <span className="eyebrow">RECENTES</span>
                    <h2>Últimos estudos</h2>
                  </div>
                  <button className="text-link" onClick={() => go("progress")}>
                    Ver histórico <ArrowRight size={15} />
                  </button>
                </div>

                {sessions.length === 0 ? (
                  <Empty text="Você ainda não registrou sessões. Comece hoje e acompanhe sua evolução." />
                ) : (
                  <div className="history-list">
                    {sessions.slice(0, 4).map(item => (
                      <article className="history-item" key={item.id}>
                        <div>
                          <b>
                            {subjects.find(subject => subject.id === item.subject_id)?.name || "Estudo livre"}
                          </b>
                          <p>{item.notes || "Sessão de estudo"}</p>
                          <small>{new Date(item.studied_at).toLocaleString("pt-BR")}</small>
                        </div>
                        <strong>{item.duration_minutes} min</strong>
                      </article>
                    ))}
                  </div>
                )}
              </section>
            </section>
          )}

          {page === "contests" && (
            <section>
              <PageHeading
                eyebrow="OPORTUNIDADES"
                title="Concursos públicos"
                subtitle="Pesquise oportunidades e consulte os detalhes publicados pelos órgãos responsáveis."
              />

              <div className="filter-bar">
                <label className="search-field">
                  <Search />
                  <input
                    value={search}
                    onChange={event => setSearch(event.target.value)}
                    placeholder="Buscar por órgão, cargo ou cidade..."
                  />
                </label>

                <select
                  value={stateFilter}
                  onChange={event => setStateFilter(event.target.value)}
                >
                  {states.map(state => <option key={state}>{state}</option>)}
                </select>
              </div>

              {filteredContests.length === 0 ? (
                <div className="student-panel contest-empty-panel">
                  <span className="welcome-icon"><Search /></span>
                  <span className="eyebrow">CATÁLOGO EM ATUALIZAÇÃO</span>
                  <h2>Nenhum concurso cadastrado ainda</h2>
                  <p>Não vamos inventar oportunidades nem exibir editais sem fonte oficial. Enquanto o catálogo é alimentado com dados verificados, você já pode montar seu plano de estudos por disciplina.</p>
                  <button className="button button-primary" onClick={() => go("planner")}>Começar a planejar meus estudos <ArrowRight size={16} /></button>
                </div>
              ) : (
                <div className="contest-grid">
                  {filteredContests.map(contest => (
                    <article className="contest-card" key={contest.id}>
                      <span className="contest-status">
                        {contest.status === "open" ? "Inscrições abertas" : "Em breve"}
                      </span>
                      <h3>{contest.title}</h3>
                      <p>
                        <span>{contest.city || "Local não informado"}</span>
                        {contest.state ? ` • ${contest.state}` : ""}
                      </p>

                      <div className="contest-meta">
                        <span>{contest.level || "Escolaridade não informada"}</span>
                        {contest.deadline && (
                          <span>
                            Prazo: {new Date(contest.deadline).toLocaleDateString("pt-BR")}
                          </span>
                        )}
                      </div>

                      {contest.official_url && (
                        <a
                          className="button button-outline"
                          href={contest.official_url}
                          target="_blank"
                          rel="noreferrer"
                        >
                          Consultar fonte oficial <ArrowRight size={15} />
                        </a>
                      )}
                    </article>
                  ))}
                </div>
              )}
            </section>
          )}

          
{page === "planner" && (
  <section>
    <PageHeading
      eyebrow="ROTINA E CONSTÂNCIA"
      title="Planejamento de estudos"
      subtitle="Escolha como deseja organizar sua preparação e construa sua rotina rumo à aprovação."
    />

    <Planner
      contests={contests}
      subjects={subjects}
      userId={session.user.id}
    />

    <div className="planner-session-area">
      <div className="page-heading">
        <span className="eyebrow">ACOMPANHAMENTO DIÁRIO</span>
        <h2>Registrar sessão de estudo</h2>
        <p>Registre o tempo que você realmente dedicou aos estudos e acompanhe sua evolução.</p>
      </div>

      <div className="planner-layout">
        <form className="student-panel study-form" onSubmit={addStudySession}>
          <span className="eyebrow">NOVA SESSÃO</span>
          <h2>Registrar estudo</h2>

          <label>
            Disciplina
            <select
              value={subjectId}
              onChange={event => setSubjectId(event.target.value)}
            >
              <option value="">Estudo livre / não selecionada</option>
              {subjects.map(subject => (
                <option key={subject.id} value={subject.id}>
                  {subject.name}
                </option>
              ))}
            </select>
          </label>

          <label>
            Tempo dedicado (minutos)
            <input
              type="number"
              min="1"
              max="1440"
              value={minutes}
              onChange={event => setMinutes(event.target.value)}
            />
          </label>

          <label>
            Observações
            <textarea
              rows={3}
              value={notes}
              onChange={event => setNotes(event.target.value)}
              placeholder="O que você estudou hoje?"
            />
          </label>

          <button className="button button-primary" type="submit">
            <CheckCircle2 size={17} /> Salvar sessão
          </button>

          {message && (
            <p className="form-message" role="status">{message}</p>
          )}
        </form>

        <section className="student-panel planner-tip">
          <span className="welcome-icon"><Target /></span>
          <span className="eyebrow">DICA DE ESTUDO</span>
          <h2>Foco na regularidade.</h2>
          <p>
            Uma rotina sustentável é mais eficiente do que estudar muitas horas em um único dia e abandonar o planejamento depois.
          </p>
        </section>
      </div>
    </div>
  </section>
)}
          
          {page === "videos" && (
            <section>
              <PageHeading
                eyebrow="CONTEÚDO PARA SUA PREPARAÇÃO"
                title="Videoaulas"
                subtitle="Acesse aulas públicas organizadas para complementar seus estudos."
              />

              {lessons.length === 0 ? (
                <Empty text="Ainda não há videoaulas publicadas. O catálogo será exibido aqui quando receber conteúdos." />
              ) : (
                <div className="lesson-grid">
                  {lessons.map(lesson => (
                    <article className="lesson-card" key={lesson.id}>
                      <div className="lesson-thumb">
                        <Play size={28} /><span>VIDEOAULA</span>
                      </div>
                      <div className="lesson-body">
                        <h3>{lesson.title}</h3>
                        <p>{lesson.channel_name || "Canal do YouTube"}</p>
                        <a
                          href={`https://www.youtube.com/watch?v=${lesson.youtube_video_id}`}
                          target="_blank"
                          rel="noreferrer"
                        >
                          Assistir no YouTube <ArrowRight size={15} />
                        </a>
                      </div>
                    </article>
                  ))}
                </div>
              )}

              <Notice text="Os vídeos permanecem hospedados em seus canais de origem. O APROVEI organiza o acesso ao conteúdo público." />
            </section>
          )}

          {page === "progress" && (
            <section className="performance-page">
              <PageHeading
                eyebrow="SUA EVOLUÇÃO"
                title="Meu desempenho"
                subtitle="Veja sua dedicação nesta semana, identifique seus dias mais produtivos e acompanhe sua constância."
              />

              <div className="ap-performance-grid">
                <article className="ap-performance-card ap-perf-coral">
                  <div className="ap-perf-top"><span className="ap-perf-icon"><Clock3 /></span><span className="ap-perf-tag">ESTA SEMANA</span></div>
                  <div className="ap-perf-value">{weekHours}<small>h</small> {weekRemainder}<small>min</small></div>
                  <div className="ap-perf-label">Tempo dedicado</div>
                  <div className="ap-perf-foot">De segunda a domingo</div>
                </article>
                <article className="ap-performance-card ap-perf-violet">
                  <div className="ap-perf-top"><span className="ap-perf-icon"><BookOpen /></span><span className="ap-perf-tag">REGISTROS</span></div>
                  <div className="ap-perf-value">{weekSessions.length}</div>
                  <div className="ap-perf-label">Sessões registradas</div>
                  <div className="ap-perf-foot">Estudos lançados nesta semana</div>
                </article>
                <article className="ap-performance-card ap-perf-aqua">
                  <div className="ap-perf-top"><span className="ap-perf-icon"><CalendarDays /></span><span className="ap-perf-tag">CONSTÂNCIA</span></div>
                  <div className="ap-perf-value">{activeStudyDays}<small>/7</small></div>
                  <div className="ap-perf-label">Dias com estudo</div>
                  <div className="ap-perf-foot">Dias diferentes com atividade registrada</div>
                </article>
                <article className="ap-performance-card ap-perf-gold">
                  <div className="ap-perf-top"><span className="ap-perf-icon"><Target /></span><span className="ap-perf-tag">MÉDIA</span></div>
                  <div className="ap-perf-value">{weekSessions.length ? Math.round(weekMinutes / weekSessions.length) : 0}<small>min</small></div>
                  <div className="ap-perf-label">Por sessão</div>
                  <div className="ap-perf-foot">Média de duração dos estudos</div>
                </article>
              </div>

              <section className="ap-performance-chart">
                <div className="ap-performance-chart-heading">
                  <div><span className="eyebrow">RITMO DA SEMANA</span><h2>Seu ritmo de estudos</h2></div>
                  <span className="ap-chart-total">{weekHours}h {weekRemainder}min no total</span>
                </div>
                <div className="ap-week-bars">
                  {weekDayStats.map((day, index) => (
                    <div className="ap-week-day" key={day.label + index}>
                      <strong>{day.minutes ? `${day.minutes} min` : "—"}</strong>
                      <div className="ap-week-track"><span style={{ height: `${Math.max(day.minutes ? 8 : 0, day.minutes / maxWeekDayMinutes * 100)}%` }} /></div>
                      <small>{day.label}</small>
                    </div>
                  ))}
                </div>
                <p className="ap-chart-note">O gráfico considera os estudos registrados no APROVEI nesta semana. Registre suas sessões para acompanhar sua evolução.</p>
              </section>

              <section className="student-panel ap-history-panel">
                <div className="panel-heading">
                  <div><span className="eyebrow">HISTÓRICO</span><h2>Suas sessões de estudo</h2></div>
                  <span className="ap-history-count">{sessions.length} registros</span>
                </div>
                {sessions.length === 0 ? (
                  <Empty text="Quando você registrar seus estudos, seu histórico aparecerá aqui." />
                ) : (
                  <div className="history-list">
                    {sessions.map(item => (
                      <article className="history-item" key={item.id}>
                        <div>
                          <b>{subjects.find(subject => subject.id === item.subject_id)?.name || "Estudo livre"}</b>
                          <p>{item.notes || "Sessão de estudo"}</p>
                          <small>{new Date(item.studied_at).toLocaleString("pt-BR")}</small>
                        </div>
                        <strong>{item.duration_minutes} min</strong>
                      </article>
                    ))}
                  </div>
                )}
              </section>
            </section>
          )}
        </main>
      </div>
    </div>
  );
}

function LandmarkIcon() {
  return <BookMarked />;
}

function BriefcaseIcon() {
  return <FileText />;
}

function Metric({ icon, value, label }: {
  icon: ReactNode;
  value: string;
  label: string;
}) {
  return (
    <article className="metric-card">
      <span className="metric-icon">{icon}</span>
      <div>
        <strong>{value}</strong>
        <small>{label}</small>
      </div>
    </article>
  );
}

function FeatureCard({ icon, title, text }: {
  icon: ReactNode;
  title: string;
  text: string;
}) {
  return (
    <article className="feature-card">
      <span className="feature-icon">{icon}</span>
      <h3>{title}</h3>
      <p>{text}</p>
    </article>
  );
}

function Audience({ icon, title, text }: {
  icon: ReactNode;
  title: string;
  text: string;
}) {
  return (
    <article className="audience-card">
      <span>{icon}</span>
      <div>
        <h3>{title}</h3>
        <p>{text}</p>
      </div>
    </article>
  );
}

function ActionCard({ icon, title, text, onClick }: {
  icon: ReactNode;
  title: string;
  text: string;
  onClick: () => void;
}) {
  return (
    <button className="action-card" onClick={onClick}>
      <span className="action-icon">{icon}</span>
      <strong>{title}</strong>
      <p>{text}</p>
      <ArrowRight size={18} />
    </button>
  );
}

function PageHeading({ eyebrow, title, subtitle }: {
  eyebrow: string;
  title: string;
  subtitle: string;
}) {
  return (
    <div className="page-heading">
      <span className="eyebrow">{eyebrow}</span>
      <h1>{title}</h1>
      <p>{subtitle}</p>
    </div>
  );
}

function Empty({ text }: { text: string }) {
  return (
    <div className="empty-state">
      <span><BookOpen size={25} /></span>
      <p>{text}</p>
    </div>
  );
}

function Notice({ text }: { text: string }) {
  return (
    <div className="notice">
      <span><ShieldCheck size={20} /></span>
      <p>{text}</p>
    </div>
  );
                                        }
    
