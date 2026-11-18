
import { useEffect, useMemo, useState } from "react";
import type { FormEvent } from "react";
import {
  CalendarDays, Sparkles, PencilLine, CheckCircle2,
  ArrowLeft, LoaderCircle
} from "lucide-react";
import { supabase } from "../lib/supabase";

type Contest = {
  id: string;
  title: string;
  state: string | null;
  city: string | null;
  level: string | null;
};

type Subject = { id: string; name: string };
type SavedPlanItem = { id: string; plan_id: string; subject_id: string; weekday: number; duration_minutes: number; sort_order: number };
type SavedPlan = { id: string; title: string; mode: "automatic" | "student"; created_at: string; daily_goal_minutes: number; weekly_goal_minutes: number; is_active: boolean; items: SavedPlanItem[] };

type Props = {
  contests: Contest[];
  subjects: Subject[];
  userId: string;
};

const week = [
  { value: 1, label: "Seg" },
  { value: 2, label: "Ter" },
  { value: 3, label: "Qua" },
  { value: 4, label: "Qui" },
  { value: 5, label: "Sex" },
  { value: 6, label: "Sáb" },
  { value: 0, label: "Dom" }
];

export default function Planner({ contests, subjects, userId }: Props) {
  const [mode, setMode] = useState<"automatic" | "student" | null>(null);
  const [contestId, setContestId] = useState("");
  const [title, setTitle] = useState("Meu planejamento de estudos");
  const [days, setDays] = useState<number[]>([1, 2, 3, 4, 5]);
  const [hours, setHours] = useState("2");
  const [sessionMinutes, setSessionMinutes] = useState("60");
  const [selectedSubjects, setSelectedSubjects] = useState<string[]>([]);
  const [saving, setSaving] = useState(false);
  const [notice, setNotice] = useState("");
  const [success, setSuccess] = useState(false);
  const [savedPlans, setSavedPlans] = useState<SavedPlan[]>([]);
  const [loadingPlans, setLoadingPlans] = useState(true);
  const [expandedPlanId, setExpandedPlanId] = useState<string | null>(null);

  async function loadSavedPlans() {
    if (!supabase) { setLoadingPlans(false); return; }
    setLoadingPlans(true);
    const { data: plans, error } = await supabase.from("study_plans")
      .select("id,title,mode,created_at,daily_goal_minutes,weekly_goal_minutes,is_active")
      .eq("user_id", userId).order("created_at", { ascending: false });
    if (error || !plans?.length) { setSavedPlans([]); setLoadingPlans(false); return; }
    const ids = plans.map(plan => plan.id);
    const { data: items } = await supabase.from("study_plan_items")
      .select("id,plan_id,subject_id,weekday,duration_minutes,sort_order")
      .eq("user_id", userId).in("plan_id", ids).order("sort_order", { ascending: true });
    setSavedPlans(plans.map(plan => ({
      ...plan,
      mode: plan.mode as "automatic" | "student",
      items: (items || []).filter(item => item.plan_id === plan.id) as SavedPlanItem[]
    })) as SavedPlan[]);
    setLoadingPlans(false);
  }
  useEffect(() => { void loadSavedPlans(); }, [userId]);

  const selectedContest = contests.find(item => item.id === contestId);

  const orderedSubjects = useMemo(
    () => [...subjects].sort((a, b) => a.name.localeCompare(b.name, "pt-BR")),
    [subjects]
  );

  function toggleDay(day: number) {
    setDays(current =>
      current.includes(day)
        ? current.filter(item => item !== day)
        : [...current, day]
    );
  }

  function toggleSubject(id: string) {
    setSelectedSubjects(current =>
      current.includes(id)
        ? current.filter(item => item !== id)
        : [...current, id]
    );
  }

  function reset() {
    setMode(null);
    setNotice("");
    setSuccess(false);
  }

  async function createPlan(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setNotice("");
    setSuccess(false);

    if (!supabase) {
      setNotice("A conexão com o banco de dados não está disponível.");
      return;
    }

    if (mode === "automatic" && !contestId) {
      setNotice("Selecione o concurso ou a área de preparação.");
      return;
    }

    if (days.length === 0) {
      setNotice("Escolha pelo menos um dia da semana.");
      return;
    }

    const dailyMinutes = Math.round(Number(hours) * 60);

    if (!Number.isFinite(dailyMinutes) || dailyMinutes < 15 || dailyMinutes > 1440) {
      setNotice("Informe uma meta diária entre 15 minutos e 24 horas.");
      return;
    }

    const items: Array<{
      subject_id: string;
      weekday: number;
      duration_minutes: number;
      sort_order: number;
      user_id: string;
    }> = [];

    if (mode === "automatic") {
      const { data: mappings, error } = await supabase
        .from("contest_subjects")
        .select("subject_id,priority,suggested_weekly_minutes")
        .eq("contest_id", contestId)
        .order("priority", { ascending: false });

      if (error) {
        setNotice("Erro ao consultar disciplinas: " + error.message);
        return;
      }

      if (!mappings?.length) {
        setNotice(
          "Ainda não existem disciplinas cadastradas para esse concurso. Você pode usar o Planejamento Aluno ou escolher outro concurso."
        );
        return;
      }

      const sortedDays = [...days].sort(
        (a, b) =>
          week.findIndex(d => d.value === a) -
          week.findIndex(d => d.value === b)
      );

      let order = 0;

      mappings.forEach(mapping => {
        const weeklyMinutes = Math.max(
          15,
          Number(mapping.suggested_weekly_minutes) || 120
        );

        const base = Math.floor(weeklyMinutes / sortedDays.length);
        let remainder = weeklyMinutes % sortedDays.length;

        sortedDays.forEach(day => {
          const duration = base + (remainder-- > 0 ? 1 : 0);

          if (duration > 0) {
            items.push({
              subject_id: mapping.subject_id,
              weekday: day,
              duration_minutes: duration,
              sort_order: order++,
              user_id: userId
            });
          }
        });
      });
    } else {
      const duration = Number(sessionMinutes);

      if (!selectedSubjects.length) {
        setNotice("Selecione pelo menos uma disciplina.");
        return;
      }

      if (!Number.isFinite(duration) || duration < 15 || duration > 1440) {
        setNotice("Informe uma duração entre 15 e 1.440 minutos.");
        return;
      }

      let order = 0;

      days.forEach(day => {
        selectedSubjects.forEach(subjectId => {
          items.push({
            subject_id: subjectId,
            weekday: day,
            duration_minutes: duration,
            sort_order: order++,
            user_id: userId
          });
        });
      });
    }

    const weeklyMinutes = items.reduce(
      (sum, item) => sum + item.duration_minutes,
      0
    );

    setSaving(true);

    const { data: plan, error: planError } = await supabase
      .from("study_plans")
      .insert({
        user_id: userId,
        contest_id: contestId || null,
        title: title.trim() || "Meu planejamento",
        mode,
        daily_goal_minutes: dailyMinutes,
        weekly_goal_minutes: Math.max(1, weeklyMinutes),
        is_active: true
      })
      .select("id")
      .single();

    if (planError || !plan) {
      setSaving(false);
      setNotice("Não foi possível salvar: " + (planError?.message || "erro inesperado"));
      return;
    }

    const { error: itemsError } = await supabase
      .from("study_plan_items")
      .insert(items.map(item => ({
        ...item,
        plan_id: plan.id
      })));

    if (itemsError) {
      await supabase
        .from("study_plans")
        .delete()
        .eq("id", plan.id)
        .eq("user_id", userId);

      setSaving(false);
      setNotice("Não foi possível salvar os horários: " + itemsError.message);
      return;
    }

    setSaving(false);
    setSuccess(true);
    setNotice("Planejamento salvo com sucesso!");
    await loadSavedPlans();
    setExpandedPlanId(plan.id);
  }

  return (
    <div className="ap-planner">
      <section className="ap-saved-plans">
        <div className="ap-saved-heading">
          <div><span className="eyebrow">SUA ROTINA</span><h2>Meus planejamentos</h2><p>Seus horários ficam salvos na sua conta. Volte aqui quando quiser continuar.</p></div>
          <span className="ap-plan-count">{savedPlans.length} {savedPlans.length === 1 ? "plano" : "planos"}</span>
        </div>
        {loadingPlans ? <p className="ap-saved-empty">Carregando seus planejamentos...</p> :
          savedPlans.length === 0 ? (
            <div className="ap-saved-empty"><CalendarDays size={22}/><strong>Você ainda não tem um planejamento salvo.</strong><span>Crie sua primeira rotina logo abaixo. Ela aparecerá aqui automaticamente.</span></div>
          ) : (
            <div className="ap-saved-list">
              {savedPlans.map(plan => {
                const expanded = expandedPlanId === plan.id;
                const totalMinutes = plan.items.reduce((sum,item) => sum + item.duration_minutes,0);
                return <article className="ap-saved-card" key={plan.id}>
                  <button type="button" className="ap-saved-card-toggle" onClick={() => setExpandedPlanId(expanded ? null : plan.id)} aria-expanded={expanded}>
                    <span className="ap-saved-card-icon"><CalendarDays size={20}/></span>
                    <span className="ap-saved-card-main"><strong>{plan.title}</strong><small>{plan.mode === "student" ? "Planejamento do aluno" : "Planejamento automático"} · {plan.items.length} sessões na semana</small></span>
                    <span className="ap-saved-card-meta">{Math.floor(totalMinutes/60)}h {totalMinutes%60 ? String(totalMinutes%60)+"min" : ""}</span><ChevronDown className={expanded ? "is-expanded" : ""} size={19}/>
                  </button>
                  {expanded && <div className="ap-saved-schedule">
                    {week.map(day => {
                      const dayItems = plan.items.filter(item => item.weekday === day.value);
                      if (!dayItems.length) return null;
                      return <div className="ap-saved-day" key={day.value}><strong>{day.label}</strong><div>
                        {dayItems.map(item => {
                          const subject = subjects.find(entry => entry.id === item.subject_id);
                          return <span className="ap-saved-session" key={item.id}><b>{subject?.name || "Disciplina"}</b><small>{item.duration_minutes} min</small></span>;
                        })}
                      </div></div>;
                    })}
                    {!plan.items.length && <p>Este planejamento ainda não possui sessões.</p>}
                  </div>}
                </article>;
              })}
            </div>
          )}
      </section>
      {!mode ? (
        <>
          <div className="ap-planner-intro">
            <span className="eyebrow">ESCOLHA COMO QUER SE ORGANIZAR</span>
            <h2>Dois caminhos. Um objetivo: sua aprovação.</h2>
            <p>
              Deixe o APROVEI organizar sua rotina ou monte cada detalhe
              do seu jeito. Você poderá mudar sua escolha quando quiser.
            </p>
          </div>

          <div className="ap-planner-choices">
            <article className="ap-planner-choice ap-auto">
              <div className="ap-choice-icon"><Sparkles size={25} /></div>
              <span className="ap-choice-label">INTELIGENTE E EDITÁVEL</span>
              <h3>Planejamento APROVEI</h3>
              <p>
                Escolha seu concurso e sua disponibilidade. O APROVEI
                distribui as disciplinas cadastradas para esse concurso
                ao longo da semana.
              </p>
              <ul>
                <li>Distribuição automática das matérias</li>
                <li>Organização por dias disponíveis</li>
                <li>Metas e carga semanal</li>
                <li>Possibilidade de ajustes</li>
              </ul>
              <button
                className="button button-primary"
                type="button"
                onClick={() => {
                  setMode("automatic");
                  setTitle("Planejamento APROVEI");
                }}
              >
                Criar planejamento automático
              </button>
            </article>

            <article className="ap-planner-choice ap-manual">
              <div className="ap-choice-icon"><PencilLine size={25} /></div>
              <span className="ap-choice-label">VOCÊ NO CONTROLE</span>
              <h3>Planejamento Aluno</h3>
              <p>
                Monte sua própria grade. O APROVEI carrega as disciplinas
                do concurso escolhido para facilitar sua organização.
              </p>
              <ul>
                <li>Você escolhe as disciplinas</li>
                <li>Define os dias de estudo</li>
                <li>Determina o tempo das sessões</li>
                <li>Organiza a rotina como preferir</li>
              </ul>
              <button
                className="button button-outline"
                type="button"
                onClick={() => {
                  setMode("student");
                  setTitle("Planejamento Aluno");
                }}
              >
                Montar meu planejamento
              </button>
            </article>
          </div>

          <div className="ap-planner-footnote">
            <CheckCircle2 size={18} />
            <span>
              Nos dois modelos, suas sessões continuam alimentando
              seu histórico de desempenho.
            </span>
          </div>
        </>
      ) : (
        <form className="student-panel ap-planner-form" onSubmit={createPlan}>
          <button type="button" className="ap-back-button" onClick={reset}>
            <ArrowLeft size={16} /> Voltar às opções
          </button>

          <span className="eyebrow">
            {mode === "automatic"
              ? "PLANEJAMENTO INTELIGENTE"
              : "PLANEJAMENTO PERSONALIZADO"}
          </span>

          <h2>
            {mode === "automatic"
              ? "Vamos organizar sua preparação"
              : "Monte sua rotina de estudos"}
          </h2>

          <p className="ap-form-description">
            {mode === "automatic"
              ? "Informe sua disponibilidade. O APROVEI distribuirá as disciplinas cadastradas para o concurso."
              : "Escolha as disciplinas, os dias e o tempo de cada sessão."}
          </p>

          <label>
            Nome do planejamento
            <input
              value={title}
              onChange={event => setTitle(event.target.value)}
              maxLength={100}
            />
          </label>

          <label>
            {mode === "automatic" ? "Concurso com edital cadastrado" : "Concurso (opcional)"}
            <select
              value={contestId}
              onChange={event => setContestId(event.target.value)}
              required={mode === "automatic"}
            >
              <option value="">{mode === "automatic" ? "Selecione o concurso" : "Estudo geral — sem concurso definido"}</option>
              {contests.map(contest => (
                <option key={contest.id} value={contest.id}>
                  {contest.title}{contest.state ? " • " + contest.state : ""}
                </option>
              ))}
            </select>
          </label>

          {selectedContest && (
            <p className="ap-selected-contest">
              Selecionado: <strong>{selectedContest.title}</strong>
            </p>
          )}

          <fieldset className="ap-day-picker">
            <legend>Dias disponíveis para estudar</legend>
            <div>
              {week.map(day => (
                <button
                  key={day.value}
                  type="button"
                  className={days.includes(day.value) ? "selected" : ""}
                  onClick={() => toggleDay(day.value)}
                  aria-pressed={days.includes(day.value)}
                >
                  {day.label}
                </button>
              ))}
            </div>
          </fieldset>

          <div className="ap-planner-fields">
            <label>
              Meta diária (horas)
              <input
                type="number"
                min="0.25"
                max="24"
                step="0.25"
                value={hours}
                onChange={event => setHours(event.target.value)}
              />
            </label>

            {mode === "student" && (
              <label>
                Tempo por sessão (minutos)
                <input
                  type="number"
                  min="15"
                  max="1440"
                  step="15"
                  value={sessionMinutes}
                  onChange={event => setSessionMinutes(event.target.value)}
                />
              </label>
            )}
          </div>

          {mode === "student" && (
            <fieldset className="ap-subject-picker">
              <legend>Disciplinas que deseja incluir</legend>
              {orderedSubjects.length ? (
                <div>
                  {orderedSubjects.map(subject => (
                    <label key={subject.id}>
                      <input
                        type="checkbox"
                        checked={selectedSubjects.includes(subject.id)}
                        onChange={() => toggleSubject(subject.id)}
                      />
                      <span>{subject.name}</span>
                    </label>
                  ))}
                </div>
              ) : (
                <p>Não há disciplinas cadastradas no momento.</p>
              )}
            </fieldset>
          )}

          {mode === "automatic" && (
            <div className="ap-auto-note">
              <Sparkles size={18} />
              <p>
                O cronograma automático só será gerado quando houver
                disciplinas vinculadas ao concurso selecionado. Assim,
                evitamos apresentar uma grade genérica como se fosse
                baseada no edital.
              </p>
            </div>
          )}

          <button
            className="button button-primary ap-submit-plan"
            type="submit"
            disabled={saving}
          >
            {saving ? (
              <><LoaderCircle className="ap-spin" size={17} /> Salvando...</>
            ) : (
              <><CalendarDays size={17} /> Salvar meu planejamento</>
            )}
          </button>

          {notice && (
            <p
              className={success ? "form-message ap-success" : "form-message ap-error"}
              role="status"
            >
              {notice}
            </p>
          )}

          {success && (
            <button type="button" className="button button-outline" onClick={reset}>
              Voltar ao início do planejamento
            </button>
          )}
        </form>
      )}
    </div>
  );
      }
        
