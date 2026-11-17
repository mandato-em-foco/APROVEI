
import { useEffect, useMemo, useState } from "react";
import type { FormEvent } from "react";
import {
  BookOpen, CalendarDays, ChartNoAxesCombined,
  Clock3, GraduationCap, LogIn, LogOut, Menu, Search,
  ShieldCheck, Video, X, MapPin, ArrowRight, CheckCircle2,
  PlayCircle, Plus, Target
} from "lucide-react";
import { isSupabaseConfigured, supabase } from "./lib/supabase";

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

type Subject = {
  id: string;
  name: string;
};

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

const navigation = [
  ["Visão geral", "home"],
  ["Concursos", "contests"],
  ["Meu planejamento", "planner"],
  ["Videoaulas", "videos"],
  ["Meu desempenho", "progress"]
] as const;

const states = [
  "Todos os estados", "AC", "AL", "AP", "AM", "BA", "CE", "DF",
  "ES", "GO", "MA", "MT", "MS", "MG", "PA", "PB", "PR", "PE",
  "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"
];

export default function App() {
  const [page, setPage] = useState("home");
  const [mobile, setMobile] = useState(false);
  const [session, setSession] = useState<any>(null);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [mode, setMode] = useState<"login" | "signup">("login");
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

    const [c, s, v, ss] = await Promise.all([
      supabase.from("contests")
        .select("id,title,state,city,level,status,deadline,official_url")
        .in("status", ["open", "upcoming"])
        .order("deadline", { ascending: true })
        .limit(100),

      supabase.from("subjects")
        .select("id,name")
        .order("name"),

      supabase.from("video_lessons")
        .select("id,title,youtube_video_id,channel_name")
        .eq("is_published", true)
        .order("created_at", { ascending: false })
        .limit(100),

      userId
        ? supabase.from("study_sessions")
            .select("id,duration_minutes,studied_at,notes,subject_id")
            .eq("user_id", userId)
            .order("studied_at", { ascending: false })
            .limit(100)
        : Promise.resolve({ data: [] })
    ]);

    if (c.data) setContests(c.data as Contest[]);
    if (s.data) setSubjects(s.data as Subject[]);
    if (v.data) setLessons(v.data as Lesson[]);
    if (ss.data) setSessions(ss.data as StudySession[]);
  }

  useEffect(() => {
    if (!supabase) return;

    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      if (data.session) {
        void refresh(data.session.user.id);
      }
    });

    const { data } = supabase.auth.onAuthStateChange((_event, next) => {
      setSession(next);

      if (next) {
        void refresh(next.user.id);
      } else {
        setSessions([]);
      }
    });

    return () => data.subscription.unsubscribe();
  }, []);

  function navigate(next: string) {
    setPage(next);
    setMobile(false);
    setMessage("");
  }

  async function handleAuth(e: FormEvent) {
    e.preventDefault();
    setAuthMessage("");

    if (!supabase) {
      setAuthMessage("O Supabase não está configurado.");
      return;
    }

    const result = mode === "signup"
      ? await supabase.auth.signUp({ email, password })
      : await supabase.auth.signInWithPassword({ email, password });

    setAuthMessage(
      result.error?.message ??
      (mode === "signup"
        ? "Cadastro enviado. Confira seu e-mail para confirmar a conta."
        : "Login realizado com sucesso.")
    );
  }

  async function addStudySession(e: FormEvent) {
    e.preventDefault();

    if (!supabase || !session) return;

    const duration = Number(minutes);

    if (!Number.isFinite(duration) || duration < 1) {
      setMessage("Informe uma duração válida.");
      return;
    }

    const { error } = await supabase.from("study_sessions").insert({
      user_id: session.user.id,
      subject_id: subjectId || null,
      duration_minutes: duration,
      notes: notes.trim() || null
    });

    if (error) {
      setMessage("Erro ao salvar: " + error.message);
      return;
    }

    setMessage("Sessão registrada com sucesso!");
    setNotes("");
    await refresh(session.user.id);
  }

  const filteredContests = useMemo(() =>
    contests.filter(c =>
      `${c.title} ${c.city ?? ""} ${c.state ?? ""} ${c.level ?? ""}`
        .toLowerCase()
        .includes(search.toLowerCase()) &&
      (stateFilter === "Todos os estados" || c.state === stateFilter)
    ), [contests, search, stateFilter]);

  const totalMinutes = sessions.reduce(
    (sum, item) => sum + item.duration_minutes,
    0
  );

  const hours = Math.floor(totalMinutes / 60);
  const remainingMinutes = totalMinutes % 60;

  return (
    <div className="app-shell">
      <header className="topbar">
        <button
          className="menu-button"
          onClick={() => setMobile(!mobile)}
          aria-label="Menu"
        >
          {mobile ? <X /> : <Menu />}
        </button>

        <button className="brand" onClick={() => navigate("home")}>
          <span className="brand-mark">
            A<span>✓</span>
          </span>
          <span>
            APROVEI
            <small>SUA APROVAÇÃO COMEÇA AQUI</small>
          </span>
        </button>

        <div className="top-actions">
          {session ? (
            <>
              <span className="user-email">{session.user.email}</span>
              <button
                className="icon-button"
                onClick={() => supabase?.auth.signOut()}
                title="Sair"
              >
                <LogOut size={18} />
              </button>
            </>
          ) : (
            <button
              className="login-link"
              onClick={() => navigate("account")}
            >
              <LogIn size={17} /> Entrar
            </button>
          )}
        </div>
      </header>

      <div className="layout">
        <aside className={`sidebar ${mobile ? "open" : ""}`}>
          <div className="side-label">ÁREA DO ALUNO</div>

          {navigation.map(([label, key]) => (
            <button
              key={key}
              className={`nav-item ${page === key ? "active" : ""}`}
              onClick={() => navigate(key)}
            >
              {key === "home" ? <ChartNoAxesCombined /> :
               key === "contests" ? <Search /> :
               key === "planner" ? <CalendarDays /> :
               key === "videos" ? <Video /> : <Clock3 />}
              {label}
            </button>
          ))}

          <div className="sidebar-bottom">
            <ShieldCheck />
            <span>
              Estude com estratégia.
              <br />
              <b>Conquiste sua aprovação.</b>
            </span>
          </div>
        </aside>

        <main className="content">
          {page === "home" && (
            <>
              <section className="hero">
                <div className="hero-copy">
                  <span className="eyebrow">
                    SUA JORNADA COMEÇA AGORA
                  </span>

                  <h1>
                    Seu próximo cargo público começa com <em>APROVEI.</em>
                  </h1>

                  <p>
                    Organize seus estudos, acompanhe editais e transforme
                    sua preparação em resultados.
                  </p>

                  <div className="hero-actions">
                    <button
                      className="primary"
                      onClick={() => navigate(session ? "planner" : "account")}
                    >
                      {session
                        ? "Registrar meus estudos"
                        : "Começar gratuitamente"}
                      <ArrowRight size={17} />
                    </button>

                    <button
                      className="secondary"
                      onClick={() => navigate("contests")}
                    >
                      Ver concursos abertos
                    </button>
                  </div>

                  <div className="hero-proof">
                    <span><CheckCircle2 /> Planejamento</span>
                    <span><CheckCircle2 /> Editais</span>
                    <span><CheckCircle2 /> Videoaulas</span>
                  </div>
                </div>

                <div className="hero-visual">
                  <div className="orbit orbit-one" />
                  <div className="orbit orbit-two" />
                  <div className="hero-badge">
                    <GraduationCap size={45} />
                  </div>

                  <div className="floating-card card-top">
                    <span>FOCO</span>
                    <b>Disciplina diária</b>
                  </div>

                  <div className="floating-card card-bottom">
                    <span>PROGRESSO</span>
                    <b>Um passo por vez ✓</b>
                  </div>
                </div>
              </section>

              <div className="metric-grid">
                <Metric
                  icon={<Clock3 />}
                  value={session ? `${hours}h ${remainingMinutes}min` : "—"}
                  label="Tempo registrado"
                />

                <Metric
                  icon={<BookOpen />}
                  value={String(sessions.length)}
                  label="Sessões de estudo"
                />

                <Metric
                  icon={<Target />}
                  value={String(contests.length)}
                  label="Editais disponíveis"
                />
              </div>

              <section className="feature-grid">
                <Feature
                  icon={<Search />}
                  title="Concursos em todo o Brasil"
                  text="Pesquise oportunidades por estado, município e escolaridade."
                />

                <Feature
                  icon={<CalendarDays />}
                  title="Planejamento de estudos"
                  text="Registre sessões e acompanhe seu tempo dedicado."
                />

                <Feature
                  icon={<Video />}
                  title="Videoaulas organizadas"
                  text="Acesse aulas públicas do YouTube por assunto."
                />

                <Feature
                  icon={<ChartNoAxesCombined />}
                  title="Acompanhe sua evolução"
                  text="Visualize sua rotina e mantenha o foco."
                />
              </section>

              <section className="plans">
                <span className="eyebrow">PLANOS APROVEI</span>
                <h2>Escolha seu ritmo de preparação</h2>
                <p>
                  Valores da proposta inicial. A cobrança ainda será
                  integrada ao Mercado Pago.
                </p>

                <div className="plan-grid">
                  <Plan
                    name="Essencial"
                    price="14,90"
                    desc="Para organizar sua rotina."
                  />

                  <Plan
                    name="Avançado"
                    price="24,90"
                    desc="Para aprofundar a preparação."
                    featured
                  />

                  <Plan
                    name="Aprovação"
                    price="39,90"
                    desc="Para uma experiência completa."
                  />
                </div>
              </section>
            </>
          )}

          {page === "contests" && (
            <section>
              <Heading
                eyebrow="OPORTUNIDADES"
                title="Concursos públicos"
                subtitle="Encontre editais federais, estaduais e municipais."
              />

              <div className="filters">
                <label className="searchbox">
                  <Search size={18} />
                  <input
                    value={search}
                    onChange={e => setSearch(e.target.value)}
                    placeholder="Buscar órgão, cargo ou município"
                  />
                </label>

                <select
                  value={stateFilter}
                  onChange={e => setStateFilter(e.target.value)}
                >
                  {states.map(s => <option key={s}>{s}</option>)}
                </select>
              </div>

              {!isSupabaseConfigured ? (
                <Notice text="Configure as variáveis do Supabase para carregar os editais." />
              ) : filteredContests.length === 0 ? (
                <Empty text="Nenhum concurso aberto cadastrado ainda. Os editais aparecerão aqui quando forem cadastrados." />
              ) : (
                <div className="contest-grid">
                  {filteredContests.map(c => (
                    <article className="contest-card" key={c.id}>
                      <span className="status-pill">
                        {c.status === "open"
                          ? "Inscrições abertas"
                          : "Em breve"}
                      </span>

                      <h3>{c.title}</h3>

                      <p>
                        <MapPin size={15} />
                        {c.city || "Local não informado"} / {c.state || "BR"}
                      </p>

                      <p>
                        <GraduationCap size={15} />
                        {c.level || "Escolaridade não informada"}
                      </p>

                      {c.deadline && (
                        <p>
                          <CalendarDays size={15} />
                          Até {new Date(
                            c.deadline + "T12:00:00"
                          ).toLocaleDateString("pt-BR")}
                        </p>
                      )}

                      {c.official_url && (
                        <a
                          href={c.official_url}
                          target="_blank"
                          rel="noreferrer"
                        >
                          Consultar edital <ArrowRight size={15} />
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
              <Heading
                eyebrow="ROTINA E CONSTÂNCIA"
                title="Meu planejamento"
                subtitle="Registre o que estudou e construa seu histórico de preparação."
              />

              {!session ? (
                <Notice text="Entre na sua conta para registrar e consultar suas sessões de estudo." />
              ) : (
                <>
                  <form
                    className="session-form"
                    onSubmit={addStudySession}
                  >
                    <h3>
                      <Plus size={19} /> Registrar sessão de estudo
                    </h3>

                    <label>
                      Disciplina
                      <select
                        value={subjectId}
                        onChange={e => setSubjectId(e.target.value)}
                      >
                        <option value="">Selecione uma disciplina</option>
                        {subjects.map(s => (
                          <option key={s.id} value={s.id}>
                            {s.name}
                          </option>
                        ))}
                      </select>
                    </label>

                    <label>
                      Duração em minutos
                      <input
                        type="number"
                        min="1"
                        max="1440"
                        required
                        value={minutes}
                        onChange={e => setMinutes(e.target.value)}
                      />
                    </label>

                    <label>
                      O que você estudou? (opcional)
                      <textarea
                        value={notes}
                        onChange={e => setNotes(e.target.value)}
                        placeholder="Ex.: concordância verbal, questões de provas anteriores..."
                      />
                    </label>

                    <button className="primary" type="submit">
                      Salvar sessão <CheckCircle2 size={17} />
                    </button>

                    {message && (
                      <p className="form-message">{message}</p>
                    )}
                  </form>

                  <h3 className="section-subtitle">Histórico recente</h3>

                  {sessions.length === 0 ? (
                    <Empty text="Você ainda não registrou sessões. Comece adicionando seu primeiro estudo!" />
                  ) : (
                    <div className="history-list">
                      {sessions.map(s => (
                        <article key={s.id} className="history-item">
                          <div>
                            <b>
                              {subjects.find(x => x.id === s.subject_id)?.name
                                || "Estudo livre"}
                            </b>
                            <p>{s.notes || "Sessão de estudo"}</p>
                            <small>
                              {new Date(s.studied_at).toLocaleString("pt-BR")}
                            </small>
                          </div>

                          <strong>{s.duration_minutes} min</strong>
                        </article>
                      ))}
                    </div>
                  )}
                </>
              )}
            </section>
          )}

          {page === "videos" && (
            <section>
              <Heading
                eyebrow="SALA DE AULA"
                title="Videoaulas"
                subtitle="Aulas publicadas organizadas para sua preparação."
              />

              <div className="video-grid">
                {lessons.length === 0 ? (
                  <Empty text="Ainda não há videoaulas publicadas. Quando forem adicionadas ao catálogo, aparecerão aqui." />
                ) : (
                  lessons.map(l => (
                    <article className="video-card" key={l.id}>
                      <a
                        className="video-thumb"
                        href={`https://www.youtube.com/watch?v=${l.youtube_video_id}`}
                        target="_blank"
                        rel="noreferrer"
                      >
                        <img
                          src={`https://img.youtube.com/vi/${l.youtube_video_id}/hqdefault.jpg`}
                          alt="Miniatura da videoaula"
                        />
                        <PlayCircle />
                      </a>

                      <h3>{l.title}</h3>
                      <p>{l.channel_name || "YouTube"}</p>

                  
