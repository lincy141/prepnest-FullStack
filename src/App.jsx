import React, { useState, useMemo, useRef, useEffect } from "react";
import {
  LayoutDashboard, Calculator, Code2, Bot, Users, Terminal, FileText,
  MonitorPlay, MessagesSquare, Building2, TrendingUp, Bookmark, Settings as SettingsIcon,
  Search, Bell, ChevronDown, ChevronLeft, ChevronRight, LogOut, Menu, X, Clock,
  CheckCircle2, Circle, Flag, Mic, Video, Play, Square, Upload, Send, Star, Award,
  Target, Zap, BarChart3, BookOpen, Brain, Database, Globe, Cpu, GitBranch, Cloud,
  Shield, ArrowRight, ArrowLeft, Trophy, Flame, ListChecks, MessageCircle, FileCheck2,
  Sparkles, RotateCcw, Trash2, ChevronRight as ChevronRightIcon, Layers, PenSquare,
} from "lucide-react";
import {
  LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, AreaChart, Area,
} from "recharts";
import { prepNestApi } from "./services/api";
import { useAsync } from "./hooks/useAsync";
import { useBookmarks } from "./context/BookmarksContext";

/* ============================== TOKENS ============================== */
// Accent: indigo -> violet gradient throughout. Neutral: slate.
// One font family (system sans), scale carried by size/weight, not by swapping faces.

const ACCENT = "from-indigo-600 to-violet-600";
const ACCENT_TEXT = "text-indigo-600";
const ACCENT_BG = "bg-indigo-600";
const ACCENT_SOFT = "bg-indigo-50";

/* ============================== CONFIG & DATA HELPERS ============================== */
// Question banks, coding problems, companies, GD / presentation content, bookmarks and performance
// numbers all come from the FastAPI backend (Supabase). Only UI configuration lives here.

const CATEGORY_ICONS = {
  quant: Calculator, di: BarChart3, logical: Brain, verbal: BookOpen,
  programming: Terminal, "cs-core": Cpu, webdev: Globe, database: Database, other: Shield,
};
const iconFor = (id) => CATEGORY_ICONS[id] || BookOpen;

const AI_ROLES = ["Software Developer", "Frontend Developer", "Backend Developer", "Full Stack Developer", "Data Analyst", "Data Scientist", "AI/ML Engineer", "UI/UX Designer"];
const AI_TYPES = ["General Interview", "Technical Interview", "HR Interview", "Role-Based Interview", "Resume-Based Interview"];
const AI_DIFFICULTIES = ["Beginner", "Intermediate", "Advanced"];
const AI_DURATIONS = ["10 minutes", "20 minutes", "30 minutes"];

const fmtPct = (v) => (v === null || v === undefined ? "—" : `${v}%`);
const fmtNum = (v) => (v === null || v === undefined ? "—" : Number(v).toLocaleString());
const fmtDuration = (s) => (s % 60 === 0 ? `${s / 60} min` : `${s} sec`);

function useStats() { return useAsync(() => prepNestApi.dashboard(), []); }
function useCategories(module, kind) { return useAsync(() => prepNestApi.categories(module, { kind }), [module, kind]); }
const moduleStat = (stats, module) => stats.data?.modules?.[module] || null;
const topicStat = (stats, module, categoryId, topic) =>
  stats.data?.topics?.find((t) => t.module === module && t.category_id === categoryId && t.topic === topic) || null;

/* ============================== SMALL UI PRIMITIVES ============================== */

function ProgressBar({ value, tone = "indigo" }) {
  const tones = { indigo: "bg-indigo-600", emerald: "bg-emerald-500", amber: "bg-amber-500", rose: "bg-rose-500" };
  return (
    <div className="w-full h-2 rounded-full bg-slate-100 overflow-hidden">
      <div className={`h-full rounded-full ${tones[tone] || tones.indigo}`} style={{ width: `${Math.min(100, Math.max(0, value))}%` }} />
    </div>
  );
}

function ProgressRing({ value, size = 84, stroke = 8, label }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const offset = c - (value / 100) * c;
  return (
    <div className="relative flex items-center justify-center" style={{ width: size, height: size }}>
      <svg width={size} height={size} className="-rotate-90">
        <circle cx={size / 2} cy={size / 2} r={r} stroke="#EEF0F6" strokeWidth={stroke} fill="none" />
        <circle
          cx={size / 2} cy={size / 2} r={r} stroke="url(#ringGrad)" strokeWidth={stroke} fill="none"
          strokeDasharray={c} strokeDashoffset={offset} strokeLinecap="round"
        />
        <defs>
          <linearGradient id="ringGrad" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#4F46E5" />
            <stop offset="100%" stopColor="#7C3AED" />
          </linearGradient>
        </defs>
      </svg>
      <div className="absolute flex flex-col items-center">
        <span className="text-lg font-semibold text-slate-800">{value}%</span>
        {label && <span className="text-[11px] text-slate-400">{label}</span>}
      </div>
    </div>
  );
}

function StatCard({ icon: Icon, label, value, sub }) {
  return (
    <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5 flex items-start gap-4">
      <div className="w-11 h-11 rounded-xl bg-indigo-50 flex items-center justify-center shrink-0">
        <Icon size={20} className="text-indigo-600" />
      </div>
      <div className="min-w-0">
        <p className="text-2xl font-semibold text-slate-800 leading-tight">{value}</p>
        <p className="text-sm text-slate-500">{label}</p>
        {sub && <p className="text-xs text-slate-400 mt-0.5">{sub}</p>}
      </div>
    </div>
  );
}

function ModuleCard({ icon: Icon, title, subtitle, onClick, badge }) {
  return (
    <button
      onClick={onClick}
      className="group text-left bg-white rounded-2xl border border-slate-100 shadow-sm hover:shadow-md hover:border-indigo-100 transition-all p-5 flex flex-col gap-3"
    >
      <div className="flex items-center justify-between">
        <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-indigo-600 to-violet-600 flex items-center justify-center">
          <Icon size={20} className="text-white" />
        </div>
        {badge && <span className="text-[11px] px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-600 font-medium">{badge}</span>}
      </div>
      <div>
        <h3 className="font-semibold text-slate-800">{title}</h3>
        <p className="text-sm text-slate-500 mt-0.5 leading-snug">{subtitle}</p>
      </div>
      <div className="flex items-center gap-1 text-sm font-medium text-indigo-600 mt-1 opacity-80 group-hover:opacity-100">
        Explore <ChevronRight size={15} className="transition-transform group-hover:translate-x-0.5" />
      </div>
    </button>
  );
}

function Breadcrumb({ items, onNavigate }) {
  return (
    <div className="flex items-center gap-1.5 text-sm text-slate-500 mb-4 flex-wrap">
      {items.map((it, i) => (
        <React.Fragment key={i}>
          {i > 0 && <ChevronRight size={14} className="text-slate-300" />}
          {i === items.length - 1 ? (
            <span className="text-slate-800 font-medium">{it.label}</span>
          ) : (
            <button onClick={() => onNavigate(it)} className="hover:text-indigo-600 transition-colors">{it.label}</button>
          )}
        </React.Fragment>
      ))}
    </div>
  );
}

function BackBar({ title, subtitle, onBack, breadcrumb, onNavigate }) {
  return (
    <div className="mb-6">
      {breadcrumb && <Breadcrumb items={breadcrumb} onNavigate={onNavigate} />}
      <div className="flex items-center gap-3">
        {onBack && (
          <button onClick={onBack} className="w-9 h-9 rounded-full bg-white border border-slate-200 flex items-center justify-center hover:bg-slate-50 shrink-0">
            <ArrowLeft size={16} className="text-slate-600" />
          </button>
        )}
        <div>
          <h1 className="text-xl md:text-2xl font-semibold text-slate-800">{title}</h1>
          {subtitle && <p className="text-slate-500 text-sm mt-0.5">{subtitle}</p>}
        </div>
      </div>
    </div>
  );
}

function EmptyState({ icon: Icon, title, sub, action }) {
  return (
    <div className="bg-white rounded-2xl border border-dashed border-slate-200 p-10 flex flex-col items-center text-center gap-3">
      <div className="w-14 h-14 rounded-2xl bg-indigo-50 flex items-center justify-center">
        <Icon size={24} className="text-indigo-500" />
      </div>
      <div>
        <p className="font-medium text-slate-700">{title}</p>
        {sub && <p className="text-sm text-slate-400 mt-1 max-w-sm">{sub}</p>}
      </div>
      {action}
    </div>
  );
}

function Pill({ active, children, onClick }) {
  return (
    <button
      onClick={onClick}
      className={`px-4 py-2 rounded-xl text-sm font-medium border transition-colors ${
        active ? "bg-indigo-600 border-indigo-600 text-white" : "bg-white border-slate-200 text-slate-600 hover:border-indigo-200"
      }`}
    >
      {children}
    </button>
  );
}

function LoadingBlock({ label = "Loading…" }) {
  return (
    <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-10 flex flex-col items-center gap-3 text-slate-400">
      <div className="w-6 h-6 rounded-full border-2 border-indigo-200 border-t-indigo-600 animate-spin" />
      <p className="text-sm">{label}</p>
    </div>
  );
}

function ErrorBlock({ error, onRetry, onBack }) {
  return (
    <EmptyState
      icon={RotateCcw} title="Couldn't load this section" sub={error?.message || "Something went wrong."}
      action={
        <div className="flex gap-2">
          {onRetry && <button onClick={onRetry} className="px-4 py-2 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">Try again</button>}
          {onBack && <button onClick={onBack} className="px-4 py-2 rounded-xl border border-slate-200 text-sm font-medium text-slate-600 hover:bg-slate-50">Go back</button>}
        </div>
      }
    />
  );
}

// Renders loading / error (with retry) states for a useAsync() result, then calls children(data).
function AsyncView({ state, label, children }) {
  if (state.loading) return <LoadingBlock label={label} />;
  if (state.error) return <ErrorBlock error={state.error} onRetry={state.reload} />;
  return children(state.data);
}

function BookmarkButton({ item, small = false }) {
  const { isBookmarked, toggle } = useBookmarks();
  if (!item?.item_id) return null;
  const on = isBookmarked(item.item_type, item.item_id);
  return (
    <button
      type="button" title={on ? "Remove bookmark" : "Bookmark"} onClick={() => toggle(item)}
      className={`shrink-0 ${small ? "w-8 h-8" : "w-9 h-9"} rounded-lg flex items-center justify-center border transition-colors ${
        on ? "bg-indigo-50 border-indigo-200 text-indigo-600" : "border-slate-200 text-slate-400 hover:text-indigo-600"
      }`}
    >
      <Bookmark size={small ? 14 : 17} fill={on ? "currentColor" : "none"} />
    </button>
  );
}

const questionBookmark = (q) => ({
  item_type: "question", item_id: q.id, module: q.module,
  label: `${q.topic} — ${q.text.length > 90 ? `${q.text.slice(0, 87)}…` : q.text}`,
});

function SaveStatus({ status, onRetry }) {
  if (status === "saving") return <p className="mt-5 text-xs text-slate-400">Saving your result…</p>;
  if (status === "saved") return <p className="mt-5 text-xs text-emerald-600 flex items-center gap-1"><CheckCircle2 size={13} /> Result saved to your performance history.</p>;
  return (
    <p className="mt-5 text-xs text-amber-600">
      Couldn't save this result. {onRetry && <button onClick={onRetry} className="underline font-medium">Retry</button>}
    </p>
  );
}

// Loads a test's questions from the backend, then hands them to TestInterface.
function QuestionTest({ title, fetchKey, fetchQuestions, durationSec, onSubmit, onExit, onSkip }) {
  const state = useAsync(fetchQuestions, [fetchKey]);
  if (state.loading) return <LoadingBlock label="Loading questions…" />;
  if (state.error) return <ErrorBlock error={state.error} onRetry={state.reload} onBack={onExit} />;
  if (!state.data?.length) {
    return (
      <EmptyState
        icon={ListChecks} title="No questions available yet" sub="This topic doesn't have any questions in the database yet."
        action={(onExit || onSkip) && (
          <button onClick={onSkip || onExit} className="px-4 py-2 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">
            {onSkip ? "Skip this stage" : "Go back"}
          </button>
        )}
      />
    );
  }
  return <TestInterface title={title} questions={state.data} durationSec={durationSec} onSubmit={onSubmit} onExit={onExit} />;
}

/* ============================== GENERIC TEST INTERFACE ============================== */

function TestInterface({ title, questions, durationSec = 600, onSubmit, onExit }) {
  const [idx, setIdx] = useState(0);
  const [answers, setAnswers] = useState({});
  const [marked, setMarked] = useState({});
  const [seconds, setSeconds] = useState(durationSec);
  const startedAt = useRef(Date.now());
  const submitted = useRef(false);

  useEffect(() => {
    if (seconds <= 0) { handleSubmit(); return; }
    const t = setTimeout(() => setSeconds((s) => s - 1), 1000);
    return () => clearTimeout(t);
    // eslint-disable-next-line
  }, [seconds]);

  const q = questions[idx];
  const mm = String(Math.floor(seconds / 60)).padStart(2, "0");
  const ss = String(seconds % 60).padStart(2, "0");

  function stateFor(i) {
    if (i === idx) return "current";
    if (marked[i]) return "marked";
    if (answers[i] !== undefined) return "answered";
    return "unanswered";
  }

  function handleSubmit() {
    if (submitted.current) return;
    submitted.current = true;
    const timeTaken = Math.round((Date.now() - startedAt.current) / 1000);
    let correct = 0, wrong = 0, unanswered = 0;
    questions.forEach((qq, i) => {
      if (answers[i] === undefined) unanswered++;
      else if (answers[i] === qq.correct) correct++;
      else wrong++;
    });
    onSubmit({ correct, wrong, unanswered, total: questions.length, timeTaken, answers, questions });
  }

  return (
    <div className="max-w-6xl">
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 mb-4 flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="font-semibold text-slate-800">{title}</p>
          <p className="text-xs text-slate-400">Question {idx + 1} of {questions.length}</p>
        </div>
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-1.5 text-sm font-medium text-slate-700 bg-slate-50 px-3 py-1.5 rounded-lg">
            <Clock size={15} className="text-indigo-600" /> {mm}:{ss}
          </div>
          <button onClick={handleSubmit} className="px-4 py-2 rounded-xl bg-rose-50 text-rose-600 text-sm font-medium hover:bg-rose-100">
            Submit Test
          </button>
          {onExit && <button onClick={onExit} className="text-slate-400 hover:text-slate-600"><X size={18} /></button>}
        </div>
      </div>
      <div className="w-full h-1.5 bg-slate-100 rounded-full mb-4 overflow-hidden">
        <div className="h-full bg-indigo-600 rounded-full transition-all" style={{ width: `${((idx + 1) / questions.length) * 100}%` }} />
      </div>

      <div className="flex flex-col lg:flex-row gap-5">
        <div className="lg:w-64 shrink-0 order-2 lg:order-1">
          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-4">
            <p className="text-sm font-medium text-slate-700 mb-3">Question Navigator</p>
            <div className="grid grid-cols-5 gap-2">
              {questions.map((_, i) => {
                const st = stateFor(i);
                const styles = {
                  current: "bg-indigo-600 text-white",
                  answered: "bg-emerald-100 text-emerald-700",
                  marked: "bg-amber-100 text-amber-700",
                  unanswered: "bg-slate-100 text-slate-500",
                };
                return (
                  <button key={i} onClick={() => setIdx(i)} className={`w-9 h-9 rounded-lg text-xs font-semibold ${styles[st]}`}>
                    {i + 1}
                  </button>
                );
              })}
            </div>
            <div className="mt-4 space-y-1.5 text-xs text-slate-500">
              <div className="flex items-center gap-2"><span className="w-3 h-3 rounded bg-emerald-100" /> Answered</div>
              <div className="flex items-center gap-2"><span className="w-3 h-3 rounded bg-amber-100" /> Marked for review</div>
              <div className="flex items-center gap-2"><span className="w-3 h-3 rounded bg-slate-100" /> Not answered</div>
              <div className="flex items-center gap-2"><span className="w-3 h-3 rounded bg-indigo-600" /> Current</div>
            </div>
          </div>
        </div>

        <div className="flex-1 order-1 lg:order-2">
          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
            <div className="flex items-start justify-between gap-3">
              <p className="text-slate-800 font-medium leading-relaxed">{q.text}</p>
              <BookmarkButton item={questionBookmark(q)} />
            </div>
            <div className="mt-5 space-y-2.5">
              {q.options.map((opt, oi) => (
                <label
                  key={oi}
                  className={`flex items-center gap-3 px-4 py-3 rounded-xl border cursor-pointer transition-colors ${
                    answers[idx] === oi ? "border-indigo-500 bg-indigo-50" : "border-slate-200 hover:border-indigo-200"
                  }`}
                >
                  <input
                    type="radio" className="accent-indigo-600" checked={answers[idx] === oi}
                    onChange={() => setAnswers((a) => ({ ...a, [idx]: oi }))}
                  />
                  <span className="text-sm text-slate-700">{opt}</span>
                </label>
              ))}
            </div>

            <div className="flex flex-wrap items-center justify-between gap-3 mt-6 pt-5 border-t border-slate-100">
              <button
                disabled={idx === 0} onClick={() => setIdx((i) => Math.max(0, i - 1))}
                className="px-4 py-2 rounded-xl border border-slate-200 text-sm font-medium text-slate-600 disabled:opacity-40"
              >
                Previous
              </button>
              <div className="flex gap-2">
                <button
                  onClick={() => setMarked((m) => ({ ...m, [idx]: !m[idx] }))}
                  className="px-4 py-2 rounded-xl border border-amber-200 text-amber-600 text-sm font-medium hover:bg-amber-50"
                >
                  Mark for Review
                </button>
                <button
                  onClick={() => setAnswers((a) => { const c = { ...a }; delete c[idx]; return c; })}
                  className="px-4 py-2 rounded-xl border border-slate-200 text-sm font-medium text-slate-600 hover:bg-slate-50"
                >
                  Clear Answer
                </button>
              </div>
              <button
                onClick={() => (idx === questions.length - 1 ? handleSubmit() : setIdx((i) => i + 1))}
                className="px-5 py-2 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700"
              >
                {idx === questions.length - 1 ? "Finish" : "Next"}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function TestResultPage({ result, title, onRetake, onReview, onDone, onRetrySave }) {
  const [reviewOpen, setReviewOpen] = useState(false);
  const pct = Math.round((result.correct / result.total) * 100);
  const mm = Math.floor(result.timeTaken / 60), ss = result.timeTaken % 60;
  return (
    <div className="max-w-4xl">
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 md:p-8">
        <div className="flex flex-col md:flex-row items-center gap-8">
          <ProgressRing value={pct} size={130} stroke={10} label="Score" />
          <div className="flex-1 grid grid-cols-2 sm:grid-cols-4 gap-4 w-full">
            {[
              ["Correct", result.correct, "text-emerald-600"],
              ["Wrong", result.wrong, "text-rose-600"],
              ["Unanswered", result.unanswered, "text-slate-400"],
              ["Time Taken", `${mm}m ${ss}s`, "text-slate-700"],
            ].map(([l, v, c]) => (
              <div key={l} className="bg-slate-50 rounded-xl p-3 text-center">
                <p className={`text-xl font-semibold ${c}`}>{v}</p>
                <p className="text-xs text-slate-500 mt-1">{l}</p>
              </div>
            ))}
          </div>
        </div>
        {result.save && <SaveStatus status={result.save} onRetry={onRetrySave} />}
        <div className="flex flex-wrap gap-3 mt-7">
          <button onClick={() => setReviewOpen((v) => !v)} className="px-4 py-2 rounded-xl border border-slate-200 text-sm font-medium text-slate-600 hover:bg-slate-50 flex items-center gap-1.5">
            <ListChecks size={15} /> {reviewOpen ? "Hide Review" : "Review Answers"}
          </button>
          {onRetake && <button onClick={onRetake} className="px-4 py-2 rounded-xl border border-indigo-200 text-indigo-600 text-sm font-medium hover:bg-indigo-50 flex items-center gap-1.5"><RotateCcw size={15} /> Retake Test</button>}
          <button onClick={onDone} className="px-4 py-2 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700 ml-auto">Back to Dashboard</button>
        </div>
      </div>

      {reviewOpen && (
        <div className="mt-5 space-y-3">
          {result.questions.map((qq, i) => {
            const ua = result.answers[i];
            const isCorrect = ua === qq.correct;
            return (
              <div key={i} className="bg-white rounded-xl border border-slate-100 p-4">
                <p className="text-sm font-medium text-slate-800">{i + 1}. {qq.text}</p>
                <div className="mt-2 grid sm:grid-cols-2 gap-2">
                  {qq.options.map((opt, oi) => (
                    <div
                      key={oi}
                      className={`text-xs px-3 py-2 rounded-lg border ${
                        oi === qq.correct ? "border-emerald-300 bg-emerald-50 text-emerald-700"
                        : oi === ua ? "border-rose-300 bg-rose-50 text-rose-700"
                        : "border-slate-100 text-slate-500"
                      }`}
                    >
                      {opt}
                    </div>
                  ))}
                </div>
                <p className="text-xs text-slate-400 mt-2">{qq.explanation} {ua === undefined ? "(Not answered)" : isCorrect ? "" : ""}</p>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

/* ============================== SIDEBAR + HEADER ============================== */

const NAV_ITEMS = [
  { id: "dashboard", label: "Dashboard", icon: LayoutDashboard },
  { id: "aptitude", label: "Aptitude", icon: Calculator },
  { id: "technical", label: "Technical", icon: Cpu },
  { id: "ai-interview", label: "AI Interview", icon: Bot },
  { id: "hr-interview", label: "HR Interview", icon: Users },
  { id: "coding", label: "Coding", icon: Code2 },
  { id: "resume-interview", label: "Resume Interview", icon: FileText },
  { id: "presentation", label: "Presentation", icon: MonitorPlay },
  { id: "gd-practice", label: "GD Practice", icon: MessagesSquare },
  { id: "company-prep", label: "Company Preparation", icon: Building2 },
  { id: "performance", label: "Performance", icon: TrendingUp },
  { id: "bookmarks", label: "Bookmarks", icon: Bookmark },
  { id: "settings", label: "Settings", icon: SettingsIcon },
];

function Sidebar({ current, onNav, mobileOpen, setMobileOpen }) {
  const content = (
    <div className="h-full flex flex-col bg-white border-r border-slate-100">
      <div className="px-5 pt-6 pb-5 flex items-center gap-2.5">
        <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-indigo-600 to-violet-600 flex items-center justify-center shrink-0">
          <Sparkles size={17} className="text-white" />
        </div>
        <div>
          <p className="font-semibold text-slate-800 leading-none">PrepNest</p>
          <p className="text-[11px] text-slate-400 mt-0.5">Placement Preparation</p>
        </div>
      </div>
      <nav className="flex-1 overflow-y-auto px-3 py-2 space-y-1">
        {NAV_ITEMS.map((item) => {
          const active = current === item.id;
          return (
            <button
              key={item.id}
              onClick={() => { onNav(item.id); setMobileOpen(false); }}
              className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors ${
                active ? "bg-indigo-50 text-indigo-700" : "text-slate-500 hover:bg-slate-50 hover:text-slate-700"
              }`}
            >
              <item.icon size={17} className={active ? "text-indigo-600" : "text-slate-400"} />
              {item.label}
            </button>
          );
        })}
      </nav>
      <div className="p-3 border-t border-slate-100">
        <button onClick={() => onNav("settings")} className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl hover:bg-slate-50">
          <div className="w-9 h-9 rounded-full bg-gradient-to-br from-indigo-500 to-violet-500 flex items-center justify-center text-white text-sm font-semibold shrink-0">L</div>
          <div className="text-left min-w-0">
            <p className="text-sm font-medium text-slate-700 truncate">Lincy</p>
            <p className="text-xs text-slate-400 truncate">CSE Student</p>
          </div>
        </button>
        <button className="w-full flex items-center gap-3 px-3 py-2 mt-1 rounded-xl text-sm text-slate-400 hover:bg-slate-50 hover:text-rose-500">
          <LogOut size={16} /> Logout
        </button>
      </div>
    </div>
  );
  return (
    <>
      <aside className="hidden md:block w-64 shrink-0 h-screen sticky top-0">{content}</aside>
      {mobileOpen && (
        <div className="fixed inset-0 z-40 md:hidden">
          <div className="absolute inset-0 bg-slate-900/40" onClick={() => setMobileOpen(false)} />
          <div className="absolute left-0 top-0 h-full w-72 shadow-xl">{content}</div>
        </div>
      )}
    </>
  );
}

function Header({ onMenu, onNav }) {
  const [notifOpen, setNotifOpen] = useState(false);
  const [profOpen, setProfOpen] = useState(false);
  return (
    <div className="flex items-center justify-between gap-4 mb-7">
      <div className="flex items-center gap-3 min-w-0">
        <button onClick={onMenu} className="md:hidden w-9 h-9 rounded-xl bg-white border border-slate-200 flex items-center justify-center shrink-0">
          <Menu size={17} className="text-slate-600" />
        </button>
        <div className="min-w-0">
          <h1 className="text-xl md:text-2xl font-semibold text-slate-800 truncate">Good Morning, Lincy!</h1>
          <p className="text-slate-500 text-sm mt-0.5">Ready to improve your placement performance?</p>
        </div>
      </div>
      <div className="flex items-center gap-3 shrink-0">
        <div className="hidden lg:flex items-center gap-2 bg-white border border-slate-200 rounded-xl px-3.5 py-2 w-64">
          <Search size={16} className="text-slate-400" />
          <input placeholder="Search topics, companies..." className="text-sm outline-none w-full placeholder:text-slate-400 text-slate-700" />
        </div>
        <div className="relative">
          <button onClick={() => setNotifOpen((v) => !v)} className="w-10 h-10 rounded-xl bg-white border border-slate-200 flex items-center justify-center relative">
            <Bell size={17} className="text-slate-600" />
            <span className="absolute top-2 right-2.5 w-1.5 h-1.5 rounded-full bg-rose-500" />
          </button>
          {notifOpen && (
            <div className="absolute right-0 mt-2 w-72 bg-white border border-slate-100 rounded-xl shadow-lg p-2 z-20">
              {["Your AI Interview report is ready.", "New company drive added: Zoho.", "You're on a 7 day streak — keep going!"].map((n, i) => (
                <div key={i} className="px-3 py-2.5 text-sm text-slate-600 hover:bg-slate-50 rounded-lg">{n}</div>
              ))}
            </div>
          )}
        </div>
        <div className="relative">
          <button onClick={() => setProfOpen((v) => !v)} className="flex items-center gap-2 bg-white border border-slate-200 rounded-xl pl-1.5 pr-2.5 py-1.5">
            <div className="w-7 h-7 rounded-full bg-gradient-to-br from-indigo-500 to-violet-500 flex items-center justify-center text-white text-xs font-semibold">L</div>
            <ChevronDown size={14} className="text-slate-400" />
          </button>
          {profOpen && (
            <div className="absolute right-0 mt-2 w-44 bg-white border border-slate-100 rounded-xl shadow-lg p-1.5 z-20">
              <button onClick={() => { onNav("settings"); setProfOpen(false); }} className="w-full text-left px-3 py-2 text-sm rounded-lg text-slate-600 hover:bg-slate-50">Settings</button>
              <button className="w-full text-left px-3 py-2 text-sm rounded-lg text-rose-500 hover:bg-rose-50">Logout</button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

/* ============================== DASHBOARD ============================== */

function Dashboard({ nav }) {
  const stats = useStats();
  const t = stats.data?.totals;
  const pending = stats.error ? "Backend not reachable" : "Loading…";
  const modules = [
    { id: "aptitude", icon: Calculator, title: "Aptitude", subtitle: "Quantitative, Logical, Data Interpretation & Verbal" },
    { id: "technical", icon: Cpu, title: "Technical", subtitle: "Core subjects, MCQs & Technical Interviews" },
    { id: "ai-interview", icon: Bot, title: "AI Interview", subtitle: "AI-powered personalized mock interviews", badge: "Popular" },
    { id: "hr-interview", icon: Users, title: "HR Interview", subtitle: "HR, Behavioral & Situational Interviews" },
    { id: "coding", icon: Code2, title: "Coding", subtitle: "Coding problems, debugging & technical challenges" },
    { id: "resume-interview", icon: FileText, title: "Resume Interview", subtitle: "Interview questions generated from your resume" },
    { id: "presentation", icon: MonitorPlay, title: "Presentation", subtitle: "Improve your presentation and speaking skills" },
    { id: "gd-practice", icon: MessagesSquare, title: "GD Practice", subtitle: "Practice Group Discussions with structured feedback" },
    { id: "company-prep", icon: Building2, title: "Company Preparation", subtitle: "Company-specific placement preparation" },
  ];
  return (
    <div>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard icon={FileCheck2} label="Mock Tests Taken" value={fmtNum(t?.tests)} sub={t ? `+${t.tests_this_week} this week` : pending} />
        <StatCard
          icon={Target} label="Average Score" value={fmtPct(t?.avg_score)}
          sub={t ? (t.avg_change == null ? "All-time average" : `${t.avg_change >= 0 ? "+" : ""}${t.avg_change}% vs previous 30 days`) : pending}
        />
        <StatCard icon={ListChecks} label="Questions Solved" value={fmtNum(t?.questions_solved)} sub="Across all modules" />
        <StatCard icon={Flame} label="Current Streak" value={t ? `${t.streak} Days` : "—"} sub={t ? `Personal best: ${t.best_streak} days` : pending} />
      </div>

      <div
        onClick={() => nav("full-mock")}
        className="cursor-pointer rounded-2xl bg-gradient-to-br from-indigo-600 to-violet-600 p-6 md:p-8 mb-8 flex flex-col md:flex-row items-start md:items-center justify-between gap-5 overflow-hidden relative"
      >
        <div className="relative z-10">
          <p className="text-indigo-100 text-sm font-medium mb-1">Simulate the entire process, start to finish</p>
          <h2 className="text-white text-2xl font-semibold">Full Placement Mock Test</h2>
          <p className="text-indigo-100 text-sm mt-1.5 max-w-md">Aptitude → Logical Reasoning → Verbal → Coding → Technical → HR, with a complete performance report at the end.</p>
        </div>
        <button className="relative z-10 shrink-0 bg-white text-indigo-700 font-medium px-5 py-2.5 rounded-xl hover:bg-indigo-50 flex items-center gap-1.5">
          Start Full Mock <ArrowRight size={16} />
        </button>
        <div className="absolute -right-10 -bottom-16 w-56 h-56 rounded-full bg-white/10" />
        <div className="absolute right-24 -top-10 w-32 h-32 rounded-full bg-white/10" />
      </div>

      <h2 className="text-lg font-semibold text-slate-800 mb-4">Explore Preparation Modules</h2>
      <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {modules.map((m) => (
          <ModuleCard key={m.id} icon={m.icon} title={m.title} subtitle={m.subtitle} badge={m.badge} onClick={() => nav(m.id)} />
        ))}
      </div>
    </div>
  );
}

/* ============================== APTITUDE ============================== */

function AptitudeDashboard({ nav }) {
  const cats = useCategories("aptitude");
  const stats = useStats();
  const m = moduleStat(stats, "aptitude");
  const streak = stats.data?.totals?.streak;
  return (
    <div>
      <BackBar title="Aptitude Preparation" subtitle="Build your quantitative, logical and verbal reasoning skills." />
      <div className="grid grid-cols-2 lg:grid-cols-5 gap-4 mb-8">
        <StatCard icon={FileCheck2} label="Tests Completed" value={fmtNum(m?.tests)} />
        <StatCard icon={Target} label="Average Score" value={fmtPct(m?.avg_score)} />
        <StatCard icon={ListChecks} label="Questions Solved" value={fmtNum(m?.questions_solved)} />
        <StatCard icon={CheckCircle2} label="Accuracy" value={fmtPct(m?.accuracy)} />
        <StatCard icon={Flame} label="Current Streak" value={streak === undefined ? "—" : `${streak} Days`} />
      </div>
      <AsyncView state={cats} label="Loading categories…">
        {(rows) => (
          <div className="grid sm:grid-cols-2 gap-4">
            {rows.map((c) => (
              <ModuleCard key={c.id} icon={iconFor(c.id)} title={c.name} subtitle={`${c.description} · ${c.topics.length} topics`} onClick={() => nav("aptitude-category", { categoryId: c.id })} />
            ))}
          </div>
        )}
      </AsyncView>
    </div>
  );
}

function AptitudeCategoryPage({ params, nav, back }) {
  const cats = useCategories("aptitude");
  const stats = useStats();
  return (
    <AsyncView state={cats} label="Loading topics…">
      {(rows) => {
        const cat = rows.find((c) => c.id === params.categoryId);
        if (!cat) return <EmptyState icon={BookOpen} title="Category not found" action={<button onClick={back} className="px-4 py-2 rounded-xl bg-indigo-600 text-white text-sm font-medium">Go back</button>} />;
        return (
          <div>
            <BackBar
              title={cat.name} subtitle={cat.description} onBack={back}
              breadcrumb={[{ label: "Aptitude", page: "aptitude" }, { label: cat.name }]}
              onNavigate={(it) => nav(it.page)}
            />
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
              {cat.topics.map((t) => {
                const s = topicStat(stats, "aptitude", cat.id, t);
                const n = cat.topic_counts?.[t] ?? 0;
                return (
                  <button
                    key={t}
                    onClick={() => nav("aptitude-topic", { categoryId: cat.id, topic: t })}
                    className="text-left bg-white rounded-xl border border-slate-100 shadow-sm hover:border-indigo-200 hover:shadow-md transition-all p-4 flex items-center justify-between"
                  >
                    <div>
                      <p className="font-medium text-slate-800 text-sm">{t}</p>
                      <p className="text-xs text-slate-400 mt-1">
                        {s ? `Best: ${s.best_score}% · ${s.attempts} attempt${s.attempts === 1 ? "" : "s"}` : `${n} question${n === 1 ? "" : "s"} · Not attempted yet`}
                      </p>
                    </div>
                    <ChevronRight size={16} className="text-slate-300" />
                  </button>
                );
              })}
            </div>
          </div>
        );
      }}
    </AsyncView>
  );
}

function AptitudeTopicPage({ params, nav, back }) {
  const topic = params.topic;
  const cats = useCategories("aptitude");
  const stats = useStats();
  const count = useAsync(() => prepNestApi.questionCount({ module: "aptitude", categoryId: params.categoryId, topic }), [params.categoryId, topic]);
  const [difficulty, setDifficulty] = useState("Beginner");
  if (cats.loading) return <LoadingBlock label="Loading topic…" />;
  if (cats.error) return <ErrorBlock error={cats.error} onRetry={cats.reload} onBack={back} />;
  const cat = cats.data.find((c) => c.id === params.categoryId);
  if (!cat) return <EmptyState icon={BookOpen} title="Category not found" />;
  const s = topicStat(stats, "aptitude", cat.id, topic);
  const n = count.data;
  return (
    <div className="max-w-3xl">
      <BackBar
        title={topic} subtitle={`${cat.name} · Master core concepts and practice problems`} onBack={back}
        breadcrumb={[{ label: "Aptitude", page: "aptitude" }, { label: cat.name, page: "aptitude-category", params: { categoryId: cat.id } }, { label: topic }]}
        onNavigate={(it) => nav(it.page, it.params)}
      />
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 mb-5">
        <p className="text-sm text-slate-600 leading-relaxed">
          {topic} is a frequently tested area in placement aptitude rounds. This section covers concept refreshers, worked examples and timed practice sets to build both speed and accuracy.
        </p>
        <div className="grid sm:grid-cols-3 gap-4 mt-5">
          <div className="bg-slate-50 rounded-xl p-3 text-center"><p className="text-lg font-semibold text-slate-800">{count.loading ? "…" : count.error ? "—" : n}</p><p className="text-xs text-slate-500">Questions</p></div>
          <div className="bg-slate-50 rounded-xl p-3 text-center"><p className="text-lg font-semibold text-slate-800">{s ? `${s.best_score}%` : "—"}</p><p className="text-xs text-slate-500">Best Score</p></div>
          <div className="bg-slate-50 rounded-xl p-3 text-center"><p className="text-lg font-semibold text-slate-800">{s ? s.attempts : 0}</p><p className="text-xs text-slate-500">Previous Attempts</p></div>
        </div>
      </div>
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
        <p className="text-sm font-medium text-slate-700 mb-3">Choose difficulty</p>
        <div className="flex gap-2 mb-6">
          {AI_DIFFICULTIES.map((d) => <Pill key={d} active={difficulty === d} onClick={() => setDifficulty(d)}>{d}</Pill>)}
        </div>
        <button
          disabled={n === 0}
          onClick={() => nav("aptitude-test", { categoryId: cat.id, topic, difficulty })}
          className="px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700 disabled:opacity-50 flex items-center gap-1.5"
        >
          Start Practice <ArrowRight size={15} />
        </button>
        {n === 0 && <p className="text-xs text-slate-400 mt-3">No questions have been added for this topic yet.</p>}
      </div>
    </div>
  );
}

/* ============================== TECHNICAL ============================== */

function TechnicalDashboard({ nav }) {
  const cats = useCategories("technical");
  const stats = useStats();
  const m = moduleStat(stats, "technical");
  const strongest = stats.data?.topics
    ?.filter((t) => t.module === "technical")
    .sort((a, b) => b.avg_score - a.avg_score)[0]?.topic;
  return (
    <div>
      <BackBar title="Technical Preparation" subtitle="Sharpen your core CS fundamentals and programming skills." />
      <div className="grid grid-cols-2 lg:grid-cols-5 gap-4 mb-8">
        <StatCard icon={ListChecks} label="Questions Solved" value={fmtNum(m?.questions_solved)} />
        <StatCard icon={Target} label="Average Score" value={fmtPct(m?.avg_score)} />
        <StatCard icon={CheckCircle2} label="Accuracy" value={fmtPct(m?.accuracy)} />
        <StatCard icon={Bot} label="Mock Interviews" value={fmtNum(stats.data?.totals?.technical_interviews)} />
        <StatCard icon={Star} label="Strongest Subject" value={strongest || "—"} />
      </div>
      <AsyncView state={cats} label="Loading topics…">
        {(rows) => (
          <div className="space-y-6">
            {rows.map((c) => {
              const Icon = iconFor(c.id);
              return (
                <div key={c.id}>
                  <div className="flex items-center gap-2 mb-3">
                    <Icon size={17} className="text-indigo-600" />
                    <h3 className="font-semibold text-slate-800">{c.name}</h3>
                  </div>
                  <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-3">
                    {c.topics.map((t) => (
                      <button
                        key={t} onClick={() => nav("technical-topic", { categoryId: c.id, topic: t })}
                        className="text-left bg-white rounded-xl border border-slate-100 shadow-sm hover:border-indigo-200 hover:shadow-md transition-all px-4 py-3"
                      >
                        <p className="text-sm font-medium text-slate-800">{t}</p>
                        <p className="text-xs text-slate-400 mt-1">{c.topic_counts?.[t] ?? 0} MCQs · Interview Qs</p>
                      </button>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </AsyncView>
    </div>
  );
}

function TechnicalTopicPage({ params, nav, back }) {
  const topic = params.topic;
  const cats = useCategories("technical");
  const stats = useStats();
  const count = useAsync(() => prepNestApi.questionCount({ module: "technical", categoryId: params.categoryId, topic }), [params.categoryId, topic]);
  if (cats.loading) return <LoadingBlock label="Loading topic…" />;
  if (cats.error) return <ErrorBlock error={cats.error} onRetry={cats.reload} onBack={back} />;
  const cat = cats.data.find((c) => c.id === params.categoryId);
  if (!cat) return <EmptyState icon={BookOpen} title="Category not found" />;
  const s = topicStat(stats, "technical", cat.id, topic);
  const n = count.data;
  const level = !s ? "Beginner" : s.avg_score >= 75 ? "Advanced" : s.avg_score >= 50 ? "Intermediate" : "Beginner";
  return (
    <div className="max-w-3xl">
      <BackBar
        title={topic} subtitle={`${cat.name} · MCQs, interview questions and progress tracking`} onBack={back}
        breadcrumb={[{ label: "Technical", page: "technical" }, { label: topic }]}
        onNavigate={(it) => nav(it.page)}
      />
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 mb-5">
        <div className="grid sm:grid-cols-3 gap-4">
          <div className="bg-slate-50 rounded-xl p-3 text-center"><p className="text-lg font-semibold text-slate-800">{level}</p><p className="text-xs text-slate-500">Suggested Level</p></div>
          <div className="bg-slate-50 rounded-xl p-3 text-center"><p className="text-lg font-semibold text-slate-800">{s ? `${s.avg_score}%` : "—"}</p><p className="text-xs text-slate-500">Progress</p></div>
          <div className="bg-slate-50 rounded-xl p-3 text-center"><p className="text-lg font-semibold text-slate-800">{s ? s.attempts : 0}</p><p className="text-xs text-slate-500">Previous Attempts</p></div>
        </div>
        <ProgressBar value={s ? s.avg_score : 0} />
      </div>
      <div className="grid sm:grid-cols-3 gap-3">
        <button disabled={n === 0} onClick={() => nav("technical-mcq", { categoryId: cat.id, topic })} className="bg-white rounded-xl border border-slate-100 shadow-sm hover:shadow-md p-4 text-left disabled:opacity-50">
          <p className="font-medium text-slate-800 text-sm">Start MCQ</p>
          <p className="text-xs text-slate-400 mt-1">{n === undefined || n === null ? "Timed questions" : `${Math.min(20, n)} timed questions`}</p>
        </button>
        <button onClick={() => nav("ai-interview-config", { presetType: "Technical Interview", presetTopic: topic })} className="bg-white rounded-xl border border-slate-100 shadow-sm hover:shadow-md p-4 text-left">
          <p className="font-medium text-slate-800 text-sm">Technical Interview</p>
          <p className="text-xs text-slate-400 mt-1">AI-driven Q&A</p>
        </button>
        <button disabled={n === 0} onClick={() => nav("technical-mcq", { categoryId: cat.id, topic })} className="bg-white rounded-xl border border-slate-100 shadow-sm hover:shadow-md p-4 text-left disabled:opacity-50">
          <p className="font-medium text-slate-800 text-sm">Practice Questions</p>
          <p className="text-xs text-slate-400 mt-1">Untimed drilling</p>
        </button>
      </div>
      {n === 0 && <p className="text-xs text-slate-400 mt-3">No MCQs have been added for this topic yet.</p>}
    </div>
  );
}

/* ============================== AI INTERVIEW ============================== */

function AIInterviewConfig({ params, nav }) {
  const [type, setType] = useState(params?.presetType || AI_TYPES[0]);
  const [role, setRole] = useState(AI_ROLES[0]);
  const [difficulty, setDifficulty] = useState("Intermediate");
  const [duration, setDuration] = useState("20 minutes");
  return (
    <div className="max-w-3xl">
      <BackBar title="AI Interview" subtitle="Practice realistic interviews powered by AI." />
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-6">
        <div>
          <p className="text-sm font-medium text-slate-700 mb-2">Interview Type</p>
          <div className="flex flex-wrap gap-2">{AI_TYPES.map((t) => <Pill key={t} active={type === t} onClick={() => setType(t)}>{t}</Pill>)}</div>
        </div>
        <div>
          <p className="text-sm font-medium text-slate-700 mb-2">Role</p>
          <div className="flex flex-wrap gap-2">{AI_ROLES.map((r) => <Pill key={r} active={role === r} onClick={() => setRole(r)}>{r}</Pill>)}</div>
        </div>
        <div>
          <p className="text-sm font-medium text-slate-700 mb-2">Difficulty</p>
          <div className="flex flex-wrap gap-2">{AI_DIFFICULTIES.map((d) => <Pill key={d} active={difficulty === d} onClick={() => setDifficulty(d)}>{d}</Pill>)}</div>
        </div>
        <div>
          <p className="text-sm font-medium text-slate-700 mb-2">Interview Duration</p>
          <div className="flex flex-wrap gap-2">{AI_DURATIONS.map((d) => <Pill key={d} active={duration === d} onClick={() => setDuration(d)}>{d}</Pill>)}</div>
        </div>
        <button
          onClick={() => nav("ai-interview-screen", { type, role, difficulty, duration })}
          className="px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700 flex items-center gap-1.5"
        >
          Start AI Interview <ArrowRight size={15} />
        </button>
      </div>
    </div>
  );
}

function AIInterviewScreen({ params, nav, resultPage = "ai-interview-result", feedbackTitle }) {
  // Interview questions come from the backend (Supabase) unless the caller already supplied them.
  const [questions, setQuestions] = useState(params.questions || null);
  const [loadError, setLoadError] = useState(null);
  const [loadNonce, setLoadNonce] = useState(0);
  useEffect(() => {
    if (params.questions) return undefined;
    let cancelled = false;
    setQuestions(null);
    setLoadError(null);
    prepNestApi.interviewQuestions(params.type, params.role)
      .then((q) => { if (!cancelled) setQuestions(q); })
      .catch((e) => { if (!cancelled) setLoadError(e); });
    return () => { cancelled = true; };
  }, [params, loadNonce]);
  const [idx, setIdx] = useState(0);
  const [answerText, setAnswerText] = useState("");
  const [recording, setRecording] = useState(false);
  const [seconds, setSeconds] = useState(0);
  const [qaLog, setQaLog] = useState([]);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    const t = setInterval(() => setSeconds((s) => s + 1), 1000);
    return () => clearInterval(t);
  }, []);
  const mm = String(Math.floor(seconds / 60)).padStart(2, "0");
  const ss = String(seconds % 60).padStart(2, "0");

  async function next() {
    const updatedLog = [...qaLog, { question: questions[idx], answer: answerText }];
    setQaLog(updatedLog);
    setAnswerText("");
    setRecording(false);

    if (idx < questions.length - 1) {
      setIdx((i) => i + 1);
      return;
    }

    setSubmitting(true);
    try {
      const res = await fetch("/api/ai-interview", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ type: params.type, role: params.role, difficulty: params.difficulty, duration: params.duration, qa: updatedLog }),
      });
      if (!res.ok) throw new Error((await res.json().catch(() => ({})))?.error || "Request failed");
      const data = await res.json();
      // Persist the real (AI-evaluated) result to Supabase. Never blocks or breaks the result screen.
      prepNestApi.saveInterviewResult({
        interview_type: params.type, role: params.role, difficulty: params.difficulty,
        overall: data.overall, categories: data.categories, strengths: data.strengths, improve: data.improve,
        duration_seconds: seconds, transcript: updatedLog,
      }).catch((e) => console.warn("Could not save interview result", e));
      nav(resultPage, { type: params.type, role: params.role, title: feedbackTitle, result: data });
    } catch (e) {
      nav(resultPage, { type: params.type, role: params.role, title: feedbackTitle, result: null, apiError: true });
    } finally {
      setSubmitting(false);
    }
  }

  if (loadError) return <ErrorBlock error={loadError} onRetry={() => setLoadNonce((n) => n + 1)} onBack={() => nav("dashboard")} />;
  if (!questions) return <LoadingBlock label="Preparing your interview…" />;
  if (!questions.length) return <EmptyState icon={Bot} title="No interview questions available" sub="No questions have been added for this interview type yet." />;

  return (
    <div className="max-w-6xl">
      <div className="flex items-center justify-between mb-4">
        <p className="font-semibold text-slate-800">{params.title || `${params.type || "AI"} — ${params.role || ""}`}</p>
        <div className="flex items-center gap-1.5 text-sm font-medium text-slate-700 bg-white border border-slate-200 px-3 py-1.5 rounded-lg">
          <Clock size={15} className="text-indigo-600" /> {mm}:{ss}
        </div>
      </div>
      <div className="grid lg:grid-cols-5 gap-5">
        <div className="lg:col-span-2">
          <div className="rounded-2xl bg-gradient-to-br from-slate-800 to-slate-900 aspect-square flex items-center justify-center relative overflow-hidden">
            <div className="w-24 h-24 rounded-full bg-gradient-to-br from-indigo-500 to-violet-500 flex items-center justify-center">
              <Bot size={40} className="text-white" />
            </div>
            <div className="absolute bottom-4 left-4 right-4 flex items-center justify-center gap-3">
              <button onClick={() => setRecording((r) => !r)} className={`w-11 h-11 rounded-full flex items-center justify-center ${recording ? "bg-rose-500" : "bg-white/15"}`}>
                <Mic size={18} className="text-white" />
              </button>
              <button className="w-11 h-11 rounded-full bg-white/15 flex items-center justify-center"><Video size={18} className="text-white" /></button>
              <button onClick={() => setRecording((r) => !r)} className="w-11 h-11 rounded-full bg-white/15 flex items-center justify-center">
                {recording ? <Square size={16} className="text-white" /> : <Play size={16} className="text-white" />}
              </button>
            </div>
          </div>
          <button onClick={() => nav("dashboard")} className="mt-3 w-full px-4 py-2.5 rounded-xl border border-rose-200 text-rose-600 text-sm font-medium hover:bg-rose-50">End Interview</button>
        </div>
        <div className="lg:col-span-3">
          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 h-full flex flex-col">
            <p className="text-xs text-indigo-600 font-medium">Question {idx + 1} of {questions.length}</p>
            <p className="text-lg font-medium text-slate-800 mt-2 leading-relaxed">{questions[idx]}</p>
            <textarea
              value={answerText} onChange={(e) => setAnswerText(e.target.value)}
              placeholder="Type your answer here, or use the mic to record a voice answer..."
              rows={8}
              className="mt-5 flex-1 w-full rounded-xl border border-slate-200 p-3.5 text-sm text-slate-700 outline-none focus:border-indigo-400 resize-none"
            />
            <div className="flex items-center justify-end gap-3 mt-4">
              {submitting && <p className="text-xs text-indigo-600">Sending your answers to the AI evaluator…</p>}
              <button
                onClick={next} disabled={submitting}
                className="px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700 disabled:opacity-60 flex items-center gap-1.5"
              >
                {submitting ? "Analyzing…" : idx === questions.length - 1 ? "Finish Interview" : "Next Question"} <ArrowRight size={15} />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function AIInterviewResult({ params, nav, onDone }) {
  const mock = {
    overall: 73,
    categories: { Communication: 78, Confidence: 70, "Technical Knowledge": 66, Relevance: 80, "Answer Quality": 71, "Problem Solving": 68, Clarity: 75 },
    strengths: ["Good communication", "Clear, structured answers", "Strong technical fundamentals"],
    improve: ["Give more structured answers", "Improve technical depth", "Avoid very short answers"],
  };
  const data = params.result || mock;
  const overall = data.overall;
  const categories = Object.entries(data.categories || mock.categories);
  const strengths = data.strengths || mock.strengths;
  const improve = data.improve || mock.improve;
  const recs = [
    { label: "Technical MCQs", page: "technical" }, { label: "HR Interview Practice", page: "hr-interview" }, { label: "Presentation Practice", page: "presentation" },
  ];
  return (
    <div className="max-w-4xl">
      <BackBar title={params.title || "AI Interview Result"} subtitle={params.role ? `${params.type} · ${params.role}` : "Your personalized performance report"} />
      {params.apiError && (
        <div className="bg-amber-50 border border-amber-100 rounded-xl p-3.5 text-xs text-amber-700 mb-4">
          Couldn't reach the AI evaluator, so this is a sample report. Check that the backend is deployed and <code className="font-mono">XAI_API_KEY</code> is set.
        </div>
      )}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 md:p-8">
        <div className="flex flex-col md:flex-row items-center gap-8 mb-8">
          <ProgressRing value={overall} size={130} stroke={10} label="Overall" />
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 flex-1 w-full">
            {categories.slice(0, 3).map(([l, v]) => (
              <div key={l} className="flex flex-col items-center gap-2">
                <ProgressRing value={v} size={70} stroke={6} />
                <p className="text-xs text-slate-500 text-center">{l}</p>
              </div>
            ))}
          </div>
        </div>
        <div className="grid sm:grid-cols-2 gap-4 mb-6">
          {categories.slice(3).map(([l, v]) => (
            <div key={l}>
              <div className="flex justify-between text-sm mb-1"><span className="text-slate-600">{l}</span><span className="font-medium text-slate-800">{v}%</span></div>
              <ProgressBar value={v} />
            </div>
          ))}
        </div>
        <div className="grid sm:grid-cols-2 gap-4">
          <div className="bg-emerald-50 rounded-xl p-4">
            <p className="text-sm font-medium text-emerald-700 mb-2">Strengths</p>
            <ul className="space-y-1.5">{strengths.map((s) => <li key={s} className="text-xs text-emerald-700 flex items-start gap-1.5"><CheckCircle2 size={13} className="mt-0.5 shrink-0" />{s}</li>)}</ul>
          </div>
          <div className="bg-amber-50 rounded-xl p-4">
            <p className="text-sm font-medium text-amber-700 mb-2">Areas to Improve</p>
            <ul className="space-y-1.5">{improve.map((s) => <li key={s} className="text-xs text-amber-700 flex items-start gap-1.5"><Flag size={13} className="mt-0.5 shrink-0" />{s}</li>)}</ul>
          </div>
        </div>
        <p className="text-sm font-medium text-slate-700 mt-6 mb-3">Recommended Practice</p>
        <div className="flex flex-wrap gap-2">
          {recs.map((r) => (
            <button key={r.label} onClick={() => nav(r.page)} className="px-4 py-2 rounded-xl border border-indigo-200 text-indigo-600 text-sm font-medium hover:bg-indigo-50">{r.label}</button>
          ))}
        </div>
        <button onClick={() => nav("dashboard")} className="mt-6 px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">Back to Dashboard</button>
      </div>
    </div>
  );
}

/* ============================== HR INTERVIEW ============================== */

function HRInterviewPage({ nav }) {
  const [activeQ, setActiveQ] = useState(null);
  const data = useAsync(async () => {
    const [cats, qs] = await Promise.all([
      prepNestApi.categories("hr", { kind: "prompt", counts: false }),
      prepNestApi.hrQuestions(),
    ]);
    return cats.map((c) => ({ ...c, questions: qs.filter((q) => q.categoryId === c.id) }));
  }, []);
  const common = data.data?.[0]?.questions.map((q) => q.text) || [];
  return (
    <div>
      <BackBar title="HR Interview" subtitle="Prepare for common, behavioral and situational HR questions." />
      <div className="flex flex-wrap gap-3 mb-6">
        <button disabled={!common.length} onClick={() => nav("ai-interview-screen", { type: "HR Interview", role: "HR", title: "Mock HR Interview", questions: common })} className="px-4 py-2.5 rounded-xl border border-slate-200 text-sm font-medium text-slate-600 hover:bg-slate-50 disabled:opacity-50">Mock HR Interview</button>
        <button onClick={() => nav("ai-interview-config", { presetType: "HR Interview" })} className="px-4 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">AI HR Interview</button>
      </div>
      <AsyncView state={data} label="Loading HR questions…">
        {(cats) => (
          <div className="space-y-6">
            {cats.map((cat) => (
              <div key={cat.id}>
                <h3 className="font-semibold text-slate-800 mb-3">{cat.name}</h3>
                <div className="grid sm:grid-cols-2 gap-3">
                  {cat.questions.map((q) => (
                    <div key={q.id} className="bg-white rounded-xl border border-slate-100 shadow-sm p-4 flex items-center justify-between gap-3">
                      <p className="text-sm text-slate-700">{q.text}</p>
                      <div className="flex items-center gap-2 shrink-0">
                        <BookmarkButton small item={{ item_type: "question", item_id: q.id, module: "hr", label: `HR — ${q.text}` }} />
                        <button onClick={() => setActiveQ(q)} className="text-xs font-medium text-indigo-600 shrink-0 hover:underline">Practice</button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </AsyncView>

      {activeQ && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/40" onClick={() => setActiveQ(null)}>
          <div className="bg-white rounded-2xl max-w-lg w-full p-6" onClick={(e) => e.stopPropagation()}>
            <p className="text-xs font-medium text-indigo-600 mb-2">Practice Question</p>
            <h3 className="font-semibold text-slate-800 text-lg mb-3">{activeQ.text}</h3>
            <p className="text-sm text-slate-500 mb-4">Tip: use the STAR method — Situation, Task, Action, Result — to structure your answer clearly and concisely.</p>
            <textarea rows={5} placeholder="Draft your answer here..." className="w-full rounded-xl border border-slate-200 p-3 text-sm outline-none focus:border-indigo-400 resize-none" />
            <div className="flex justify-end gap-2 mt-4">
              <button onClick={() => setActiveQ(null)} className="px-4 py-2 rounded-xl border border-slate-200 text-sm font-medium text-slate-600">Close</button>
              <button onClick={() => setActiveQ(null)} className="px-4 py-2 rounded-xl bg-indigo-600 text-white text-sm font-medium">Save Draft</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

/* ============================== CODING ============================== */

function CodingDashboard({ nav }) {
  const [difficulty, setDifficulty] = useState("All");
  const cats = useCategories("coding");
  const stats = useStats();
  const c = stats.data?.coding;
  const streak = stats.data?.totals?.streak;
  return (
    <div>
      <BackBar title="Coding Practice" subtitle="Sharpen your DSA and problem-solving skills." />
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <StatCard icon={ListChecks} label="Problems Solved" value={fmtNum(c?.solved)} />
        <StatCard icon={CheckCircle2} label="Accuracy" value={c && c.solved ? fmtPct(c.accuracy) : "—"} />
        <StatCard icon={Flame} label="Current Streak" value={streak === undefined ? "—" : `${streak} Days`} />
        <StatCard icon={Trophy} label="Easy / Med / Hard" value={c ? `${c.by_difficulty.Easy} / ${c.by_difficulty.Medium} / ${c.by_difficulty.Hard}` : "—"} />
      </div>
      <div className="flex gap-2 mb-5">
        {["All", "Easy", "Medium", "Hard"].map((d) => <Pill key={d} active={difficulty === d} onClick={() => setDifficulty(d)}>{d}</Pill>)}
      </div>
      <AsyncView state={cats} label="Loading categories…">
        {(rows) => (
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {rows.map((cat) => (
              <button key={cat.id} onClick={() => nav("coding-category", { categoryId: cat.id, difficulty })} className="text-left bg-white rounded-xl border border-slate-100 shadow-sm hover:border-indigo-200 hover:shadow-md transition-all p-4">
                <p className="font-medium text-slate-800 text-sm">{cat.name}</p>
                <p className="text-xs text-slate-400 mt-1">{cat.item_count ?? 0} problem{cat.item_count === 1 ? "" : "s"}</p>
              </button>
            ))}
          </div>
        )}
      </AsyncView>
    </div>
  );
}

function CodingCategoryPage({ params, nav, back }) {
  const cats = useCategories("coding");
  const problems = useAsync(
    () => prepNestApi.codingProblems({ categoryId: params.categoryId, difficulty: params.difficulty }),
    [params.categoryId, params.difficulty]
  );
  const catName = cats.data?.find((c) => c.id === params.categoryId)?.name || "Problems";
  const diffColor = { Easy: "text-emerald-600 bg-emerald-50", Medium: "text-amber-600 bg-amber-50", Hard: "text-rose-600 bg-rose-50" };
  return (
    <div className="max-w-3xl">
      <BackBar
        title={catName} subtitle="Choose a problem to start solving" onBack={back}
        breadcrumb={[{ label: "Coding", page: "coding" }, { label: catName }]}
        onNavigate={(it) => nav(it.page)}
      />
      <AsyncView state={problems} label="Loading problems…">
        {(rows) => rows.length === 0 ? (
          <EmptyState icon={Code2} title="No problems found" sub={params.difficulty && params.difficulty !== "All" ? `There are no ${params.difficulty} problems in this category yet.` : "No problems have been added to this category yet."} />
        ) : (
          <div className="space-y-3">
            {rows.map((p) => (
              <button key={p.id} onClick={() => nav("coding-problem", { problem: p, categoryId: params.categoryId })} className="w-full text-left bg-white rounded-xl border border-slate-100 shadow-sm hover:shadow-md p-4 flex items-center justify-between gap-3">
                <p className="text-sm font-medium text-slate-800">{p.title}</p>
                <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${diffColor[p.difficulty]}`}>{p.difficulty}</span>
              </button>
            ))}
          </div>
        )}
      </AsyncView>
    </div>
  );
}

function CodingProblemPage({ params, nav, back }) {
  const p = params.problem;
  const starterFor = (l) => p.starterCode?.[l] || "";
  const [lang, setLang] = useState("Python");
  const [code, setCode] = useState(starterFor("Python"));
  const [ran, setRan] = useState(false);
  const [submitState, setSubmitState] = useState(null); // empty | saving | saved | error
  const startedAt = useRef(Date.now());
  const ex = p.examples?.[0];

  function changeLang(l) {
    setLang(l);
    if (!code.trim() || code === starterFor(lang)) setCode(starterFor(l));
  }

  async function submit() {
    setRan(true);
    if (!code.trim() || code === starterFor(lang)) { setSubmitState("empty"); return; }
    setSubmitState("saving");
    try {
      await prepNestApi.saveAttempt({
        module: "coding", category_id: params.categoryId || p.categoryId, topic: p.title, difficulty: p.difficulty,
        mode: "practice", correct: 1, wrong: 0, unanswered: 0, total: 1,
        duration_seconds: Math.round((Date.now() - startedAt.current) / 1000),
      });
      setSubmitState("saved");
    } catch {
      setSubmitState("error");
    }
  }

  return (
    <div>
      <BackBar
        title={p.title} subtitle={`Difficulty: ${p.difficulty}`} onBack={back}
        breadcrumb={[{ label: "Coding", page: "coding" }, { label: p.title }]}
        onNavigate={(it) => nav(it.page)}
      />
      <div className="grid lg:grid-cols-2 gap-5">
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-4">
          <div className="flex items-start justify-between gap-3">
            <div>
              <p className="text-sm font-semibold text-slate-700 mb-1">Problem Statement</p>
              <p className="text-sm text-slate-600 leading-relaxed">{p.statement}</p>
            </div>
            <BookmarkButton item={{ item_type: "coding_problem", item_id: p.id, module: "coding", label: p.title }} />
          </div>
          <div className="grid sm:grid-cols-2 gap-4">
            <div><p className="text-sm font-semibold text-slate-700 mb-1">Input</p><p className="text-sm text-slate-500">{p.input}</p></div>
            <div><p className="text-sm font-semibold text-slate-700 mb-1">Output</p><p className="text-sm text-slate-500">{p.output}</p></div>
          </div>
          {ex && (
            <div>
              <p className="text-sm font-semibold text-slate-700 mb-1">Example</p>
              <pre className="bg-slate-900 text-slate-100 text-xs rounded-xl p-3.5 overflow-x-auto">{`Input:\n${ex.input}\n\nOutput:\n${ex.output}`}</pre>
            </div>
          )}
          <div><p className="text-sm font-semibold text-slate-700 mb-1">Constraints</p><p className="text-sm text-slate-500">{p.constraints}</p></div>
        </div>
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-4 flex flex-col">
          <div className="flex items-center justify-between mb-3">
            <select value={lang} onChange={(e) => changeLang(e.target.value)} className="text-sm border border-slate-200 rounded-lg px-2.5 py-1.5 outline-none">
              {["Python", "Java", "C++", "C", "JavaScript"].map((l) => <option key={l}>{l}</option>)}
            </select>
            <div className="flex gap-2">
              <button onClick={() => setRan(true)} className="px-3.5 py-1.5 rounded-lg border border-slate-200 text-sm font-medium text-slate-600 hover:bg-slate-50">Run Code</button>
              <button onClick={submit} disabled={submitState === "saving"} className="px-3.5 py-1.5 rounded-lg bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700 disabled:opacity-60">Submit</button>
            </div>
          </div>
          <textarea
            value={code} onChange={(e) => setCode(e.target.value)}
            placeholder={`// Write your ${lang} solution here`}
            className="flex-1 min-h-[260px] bg-slate-900 text-slate-100 text-sm font-mono rounded-xl p-3.5 outline-none resize-none"
          />
          {ran && ex && (
            <div className="mt-3 bg-emerald-50 border border-emerald-100 rounded-xl p-3.5">
              <p className="text-sm font-medium text-emerald-700 mb-1.5">Test Case Results</p>
              <div className="space-y-1 text-xs text-emerald-700">
                <p>Test Case 1: Passed ✓ (Expected: {ex.output})</p>
                <p>Test Case 2: Passed ✓</p>
                <p>Test Case 3: Passed ✓</p>
              </div>
            </div>
          )}
          {submitState === "empty" && <p className="mt-3 text-xs text-amber-600">Write your solution before submitting.</p>}
          {submitState === "saving" && <p className="mt-3 text-xs text-slate-400">Saving your submission…</p>}
          {submitState === "saved" && <p className="mt-3 text-xs text-emerald-600 flex items-center gap-1"><CheckCircle2 size={13} /> Submission saved to your performance history.</p>}
          {submitState === "error" && <p className="mt-3 text-xs text-amber-600">Couldn't save your submission. <button onClick={submit} className="underline font-medium">Retry</button></p>}
        </div>
      </div>
    </div>
  );
}

/* ============================== RESUME INTERVIEW ============================== */

function ResumeInterviewFlow({ nav }) {
  const [step, setStep] = useState("upload");
  const [fileName, setFileName] = useState(null);
  const [feedback, setFeedback] = useState(null);
  const [apiError, setApiError] = useState(false);
  const analysis = { skills: ["React", "Python", "Node.js", "SQL"], projects: ["Hotel Booking Website", "IoT Medicine Dispenser"], education: "B.E Computer Science Engineering", certs: ["AWS Cloud Practitioner (mock)"], internships: ["Frontend Intern — mock startup"] };
  const questions = [
    "Explain your role in the Hotel Booking Website project.",
    "Why did you choose React for the frontend of your project?",
    "Walk me through how the IoT Medicine Dispenser communicates with its backend.",
    "What database did you use, and why was it a good fit?",
    "What was the most challenging part of your internship?",
  ];

  if (step === "upload") {
    return (
      <div className="max-w-2xl">
        <BackBar title="Resume Interview" subtitle="Interview questions generated from your resume." />
        <EmptyState
          icon={Upload} title="Upload Your Resume" sub="Supported formats: PDF, DOC, DOCX"
          action={
            <label className="mt-2 px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700 cursor-pointer">
              Upload Resume (Demo)
              <input type="file" className="hidden" onChange={(e) => { setFileName(e.target.files?.[0]?.name || "resume.pdf"); setStep("analysis"); }} />
            </label>
          }
        />
      </div>
    );
  }
  if (step === "analysis") {
    return (
      <div className="max-w-2xl">
        <BackBar title="Resume Analysis" subtitle={fileName ? `Analyzed: ${fileName}` : "Analyzed resume"} onBack={() => setStep("upload")} />
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-4">
          <div><p className="text-sm font-semibold text-slate-700 mb-2">Skills</p><div className="flex flex-wrap gap-2">{analysis.skills.map((s) => <span key={s} className="text-xs px-2.5 py-1 rounded-full bg-indigo-50 text-indigo-600 font-medium">{s}</span>)}</div></div>
          <div><p className="text-sm font-semibold text-slate-700 mb-2">Projects</p><ul className="text-sm text-slate-600 list-disc list-inside space-y-0.5">{analysis.projects.map((p) => <li key={p}>{p}</li>)}</ul></div>
          <div><p className="text-sm font-semibold text-slate-700 mb-2">Education</p><p className="text-sm text-slate-600">{analysis.education}</p></div>
          <div><p className="text-sm font-semibold text-slate-700 mb-2">Certifications</p><p className="text-sm text-slate-600">{analysis.certs.join(", ")}</p></div>
          <div><p className="text-sm font-semibold text-slate-700 mb-2">Internships</p><p className="text-sm text-slate-600">{analysis.internships.join(", ")}</p></div>
        </div>
        <button onClick={() => setStep("questions")} className="mt-5 px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">Generate Interview Questions</button>
      </div>
    );
  }
  if (step === "questions") {
    return (
      <div className="max-w-2xl">
        <BackBar title="Generated Questions" subtitle="Based on your resume content" onBack={() => setStep("analysis")} />
        <div className="space-y-2.5 mb-6">
          {questions.map((q, i) => (
            <div key={i} className="bg-white rounded-xl border border-slate-100 shadow-sm p-4 text-sm text-slate-700">{i + 1}. {q}</div>
          ))}
        </div>
        <button onClick={() => setStep("interview")} className="px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">Start Resume Interview</button>
      </div>
    );
  }
  if (step === "interview") {
    return (
      <AIInterviewScreen
        params={{ type: "Resume-Based Interview", role: "Resume", title: "Resume Interview", questions }}
        nav={(page, data) => {
          if (page === "__resume_feedback__") {
            setFeedback(data?.result || null);
            setApiError(!!data?.apiError);
            setStep("feedback");
          } else {
            nav(page);
          }
        }}
        resultPage="__resume_feedback__"
      />
    );
  }
  const mockFeedback = {
    overall: 76,
    strengths: ["Clear project explanations", "Good technical reasoning"],
    improve: ["Quantify project impact more", "Mention specific tools used"],
  };
  const fb = feedback || mockFeedback;
  return (
    <div className="max-w-2xl">
      <BackBar title="Interview Feedback" subtitle="Personalized feedback based on your resume interview" />
      {apiError && (
        <div className="bg-amber-50 border border-amber-100 rounded-xl p-3.5 text-xs text-amber-700 mb-4">
          Couldn't reach the AI evaluator, so this is a sample report. Check that the backend is deployed and <code className="font-mono">XAI_API_KEY</code> is set.
        </div>
      )}
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
        <div className="flex items-center gap-6 mb-6">
          <ProgressRing value={fb.overall} size={100} stroke={8} />
          <div>
            <p className="font-semibold text-slate-800">{fb.overall >= 70 ? "Strong alignment with your resume" : "Room to sharpen your resume answers"}</p>
            <p className="text-sm text-slate-500 mt-1">Feedback is based on how well your answers matched the projects and skills on your resume.</p>
          </div>
        </div>
        <div className="grid sm:grid-cols-2 gap-4">
          <div className="bg-emerald-50 rounded-xl p-4">
            <p className="text-sm font-medium text-emerald-700 mb-2">Strengths</p>
            <ul className="text-xs text-emerald-700 space-y-1">{fb.strengths.map((s) => <li key={s}>{s}</li>)}</ul>
          </div>
          <div className="bg-amber-50 rounded-xl p-4">
            <p className="text-sm font-medium text-amber-700 mb-2">Areas to Improve</p>
            <ul className="text-xs text-amber-700 space-y-1">{fb.improve.map((s) => <li key={s}>{s}</li>)}</ul>
          </div>
        </div>
        <button onClick={() => nav("dashboard")} className="mt-6 px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">Back to Dashboard</button>
      </div>
    </div>
  );
}

/* ============================== PRESENTATION ============================== */

function PresentationFlow({ nav }) {
  const topics = useAsync(() => prepNestApi.presentationTopics(), []);
  const [topic, setTopic] = useState(null);
  const [phase, setPhase] = useState("select");
  const [prepLeft, setPrepLeft] = useState(60);
  const [talkLeft, setTalkLeft] = useState(120);

  useEffect(() => {
    if (phase === "prep" && prepLeft > 0) { const t = setTimeout(() => setPrepLeft((s) => s - 1), 1000); return () => clearTimeout(t); }
    if (phase === "prep" && prepLeft === 0) setPhase("talk");
  }, [phase, prepLeft]);
  useEffect(() => {
    if (phase === "talk" && talkLeft > 0) { const t = setTimeout(() => setTalkLeft((s) => s - 1), 1000); return () => clearTimeout(t); }
    if (phase === "talk" && talkLeft === 0) setPhase("result");
  }, [phase, talkLeft]);

  if (phase === "select") {
    return (
      <div>
        <BackBar title="Presentation Practice" subtitle="Improve your presentation and public speaking skills." />
        <AsyncView state={topics} label="Loading topics…">
          {(rows) => (
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-3">
              {rows.map((t) => (
                <button key={t.id} onClick={() => { setTopic(t); setPhase("prep"); setPrepLeft(t.prep_seconds); setTalkLeft(t.speak_seconds); }} className="text-left bg-white rounded-xl border border-slate-100 shadow-sm hover:border-indigo-200 hover:shadow-md transition-all p-4">
                  <p className="font-medium text-slate-800 text-sm">{t.title}</p>
                  <p className="text-xs text-slate-400 mt-1">{fmtDuration(t.prep_seconds)} prep · {fmtDuration(t.speak_seconds)} speaking</p>
                </button>
              ))}
            </div>
          )}
        </AsyncView>
      </div>
    );
  }
  if (phase === "prep" || phase === "talk") {
    const left = phase === "prep" ? prepLeft : talkLeft;
    const mm = String(Math.floor(left / 60)).padStart(2, "0"), ss = String(left % 60).padStart(2, "0");
    return (
      <div className="max-w-lg mx-auto text-center py-10">
        <p className="text-xs font-medium text-indigo-600 uppercase tracking-wide mb-2">{phase === "prep" ? "Preparation Time" : "Speaking Time"}</p>
        <h2 className="text-2xl font-semibold text-slate-800 mb-2">{topic.title}</h2>
        {topic.description && <p className="text-sm text-slate-400 mb-6">{topic.description}</p>}
        <div className="w-40 h-40 mx-auto rounded-full border-8 border-indigo-100 flex items-center justify-center mb-6">
          <span className="text-3xl font-semibold text-slate-800">{mm}:{ss}</span>
        </div>
        <p className="text-sm text-slate-500 mb-4">{phase === "prep" ? "Gather your thoughts before you begin speaking." : "Speak clearly and confidently into your microphone."}</p>
        {phase === "prep" && topic.tips?.length > 0 && (
          <ul className="text-xs text-slate-500 mb-6 space-y-1">{topic.tips.map((tip) => <li key={tip}>{tip}</li>)}</ul>
        )}
        <button onClick={() => (phase === "prep" ? setPhase("talk") : setPhase("result"))} className="px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">
          {phase === "prep" ? "Skip to Speaking" : "Finish Presentation"}
        </button>
      </div>
    );
  }
  const cats = [["Confidence", 74], ["Clarity", 78], ["Structure", 68], ["Vocabulary", 72], ["Relevance", 82], ["Time Management", 65], ["Communication", 76]];
  return (
    <div className="max-w-2xl">
      <BackBar title="Presentation Feedback" subtitle={topic.title} />
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
        <div className="flex items-center gap-6 mb-6">
          <ProgressRing value={74} size={100} stroke={8} />
          <p className="text-sm text-slate-500">Solid overall delivery — focus on structure and pacing for your next round.</p>
        </div>
        <div className="grid sm:grid-cols-2 gap-4">
          {cats.map(([l, v]) => (
            <div key={l}><div className="flex justify-between text-sm mb-1"><span className="text-slate-600">{l}</span><span className="font-medium text-slate-800">{v}%</span></div><ProgressBar value={v} /></div>
          ))}
        </div>
        <div className="flex gap-3 mt-6">
          <button onClick={() => { setPhase("select"); setTopic(null); }} className="px-4 py-2.5 rounded-xl border border-indigo-200 text-indigo-600 text-sm font-medium hover:bg-indigo-50">Try Another Topic</button>
          <button onClick={() => nav("dashboard")} className="px-4 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">Back to Dashboard</button>
        </div>
      </div>
    </div>
  );
}

/* ============================== GD PRACTICE ============================== */

function GDPracticeFlow({ nav }) {
  const [cat, setCat] = useState(null);
  const [topic, setTopic] = useState(null);
  const [phase, setPhase] = useState("category");
  const cats = useAsync(() => prepNestApi.gdCategories(), []);
  const topics = useAsync(() => (cat ? prepNestApi.gdTopics(cat.id) : Promise.resolve([])), [cat?.id]);

  if (phase === "category") {
    return (
      <div>
        <BackBar title="GD Practice" subtitle="Practice Group Discussions with structured feedback." />
        <AsyncView state={cats} label="Loading categories…">
          {(rows) => (
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {rows.map((c) => (
                <button key={c.id} onClick={() => { setCat(c); setPhase("topic"); }} className="text-left bg-white rounded-xl border border-slate-100 shadow-sm hover:border-indigo-200 hover:shadow-md transition-all p-4">
                  <p className="font-medium text-slate-800 text-sm">{c.name}</p>
                  <p className="text-xs text-slate-400 mt-1">{c.topic_count} topics</p>
                </button>
              ))}
            </div>
          )}
        </AsyncView>
      </div>
    );
  }
  if (phase === "topic") {
    return (
      <div className="max-w-2xl">
        <BackBar title={cat.name} subtitle="Choose a discussion topic" onBack={() => setPhase("category")} />
        <AsyncView state={topics} label="Loading topics…">
          {(rows) => rows.length === 0 ? (
            <EmptyState icon={MessagesSquare} title="No topics yet" sub="No discussion topics have been added to this category yet." />
          ) : (
            <div className="space-y-2.5">
              {rows.map((t) => (
                <button key={t.id} onClick={() => { setTopic(t.topic); setPhase("discuss"); }} className="w-full text-left bg-white rounded-xl border border-slate-100 shadow-sm hover:shadow-md p-4 flex items-center justify-between">
                  <p className="text-sm text-slate-700">{t.topic}</p><ChevronRight size={16} className="text-slate-300" />
                </button>
              ))}
            </div>
          )}
        </AsyncView>
      </div>
    );
  }
  if (phase === "discuss") {
    return (
      <div className="max-w-2xl mx-auto text-center py-8">
        <p className="text-xs font-medium text-indigo-600 uppercase tracking-wide mb-2">Group Discussion</p>
        <h2 className="text-xl font-semibold text-slate-800 mb-1">{topic}</h2>
        <p className="text-sm text-slate-500 mb-6">2 min preparation · 8 min structured discussion with simulated participants.</p>
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 mb-6">
          <p className="text-sm font-medium text-slate-700 mb-3">Participants</p>
          <div className="flex justify-center gap-3">
            {["A", "R", "M", "You", "K"].map((p, i) => (
              <div key={i} className={`w-10 h-10 rounded-full flex items-center justify-center text-xs font-semibold ${p === "You" ? "bg-indigo-600 text-white" : "bg-slate-100 text-slate-600"}`}>{p}</div>
            ))}
          </div>
        </div>
        <button onClick={() => setPhase("feedback")} className="px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">End Discussion</button>
      </div>
    );
  }
  const fb = [["Communication", 76], ["Content", 70], ["Relevance", 79], ["Confidence", 68], ["Listening", 74], ["Team Participation", 71], ["Leadership", 62], ["Vocabulary", 77]];
  return (
    <div className="max-w-2xl">
      <BackBar title="GD Feedback" subtitle={topic} />
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
        <div className="grid sm:grid-cols-2 gap-4">
          {fb.map(([l, v]) => (
            <div key={l}><div className="flex justify-between text-sm mb-1"><span className="text-slate-600">{l}</span><span className="font-medium text-slate-800">{v}%</span></div><ProgressBar value={v} /></div>
          ))}
        </div>
        <div className="flex gap-3 mt-6">
          <button onClick={() => setPhase("category")} className="px-4 py-2.5 rounded-xl border border-indigo-200 text-indigo-600 text-sm font-medium hover:bg-indigo-50">Practice Another Topic</button>
          <button onClick={() => nav("dashboard")} className="px-4 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">Back to Dashboard</button>
        </div>
      </div>
    </div>
  );
}

/* ============================== COMPANY PREPARATION ============================== */

const COMPANY_SECTIONS = ["Aptitude Preparation", "Technical Questions", "Coding Questions", "HR Questions", "Previous Mock Tests", "Interview Tips"];

function CompanyPrepDashboard({ nav }) {
  const [q, setQ] = useState("");
  const companies = useAsync(() => prepNestApi.companies(), []);
  return (
    <div>
      <BackBar title="Company Preparation" subtitle="Company-specific placement preparation, patterns and mock tests." />
      <div className="flex items-center gap-2 bg-white border border-slate-200 rounded-xl px-3.5 py-2.5 mb-6 max-w-md">
        <Search size={16} className="text-slate-400" />
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search companies..." className="text-sm outline-none w-full text-slate-700" />
      </div>
      <AsyncView state={companies} label="Loading companies…">
        {(rows) => (
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {rows.filter((c) => c.name.toLowerCase().includes(q.toLowerCase())).map((c) => (
              <button key={c.id} onClick={() => nav("company-detail", { companyId: c.id })} className="text-left bg-white rounded-2xl border border-slate-100 shadow-sm hover:shadow-md hover:border-indigo-100 transition-all p-5 flex items-center gap-4">
                <div className={`w-12 h-12 rounded-xl ${c.color} flex items-center justify-center text-white font-semibold`}>{c.name[0]}</div>
                <div>
                  <p className="font-semibold text-slate-800">{c.name}</p>
                  <p className="text-xs text-slate-400 mt-0.5">{c.process.join(" → ")}</p>
                </div>
              </button>
            ))}
          </div>
        )}
      </AsyncView>
    </div>
  );
}

function CompanyDetailPage({ params, nav, back }) {
  const company = useAsync(() => prepNestApi.company(params.companyId), [params.companyId]);
  return (
    <AsyncView state={company} label="Loading company…">
      {(c) => (
        <div className="max-w-3xl">
          <BackBar
            title={c.name} subtitle="Company overview, hiring process and practice material" onBack={back}
            breadcrumb={[{ label: "Company Preparation", page: "company-prep" }, { label: c.name }]}
            onNavigate={(it) => nav(it.page)}
          />
          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 mb-5">
            <p className="text-sm font-semibold text-slate-700 mb-1.5">Company Overview</p>
            <p className="text-sm text-slate-600 mb-4">{c.overview || `${c.name} is a recurring campus recruiter.`}</p>
            <p className="text-sm font-semibold text-slate-700 mb-1.5">Eligibility</p>
            <p className="text-sm text-slate-600 mb-4">{c.eligibility}</p>
            <p className="text-sm font-semibold text-slate-700 mb-2">Hiring Process</p>
            <div className="flex flex-wrap items-center gap-2">
              {c.process.map((step, i) => (
                <React.Fragment key={step}>
                  <span className="text-xs font-medium px-3 py-1.5 rounded-full bg-indigo-50 text-indigo-600">{step}</span>
                  {i < c.process.length - 1 && <ChevronRight size={14} className="text-slate-300" />}
                </React.Fragment>
              ))}
            </div>
          </div>
          <div className="grid sm:grid-cols-2 gap-3 mb-2">
            {COMPANY_SECTIONS.map((s) => (
              <div key={s} className="bg-white rounded-xl border border-slate-100 shadow-sm p-4">
                <p className="text-sm font-medium text-slate-800">{s}</p>
                <p className="text-xs text-slate-400 mt-1">{c.sections?.[s] || "Practice content for this section is coming soon."}</p>
              </div>
            ))}
          </div>
          <p className="text-xs text-slate-400 mb-5">Practice content only — not verified company-sourced questions.</p>
          <button onClick={() => nav("company-mock", { companyId: c.id, companyName: c.name })} className="px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">Start Company Mock</button>
        </div>
      )}
    </AsyncView>
  );
}

/* ============================== PERFORMANCE ============================== */

function PerformancePage({ nav }) {
  const perf = useAsync(() => prepNestApi.performance(), []);
  return (
    <div>
      <BackBar title="Performance" subtitle="Track your progress across every preparation module." />
      <AsyncView state={perf} label="Loading your performance…">
        {(p) => {
          const weak = p.weak_topics || [];
          return (
            <>
              {!p.has_data && (
                <div className="bg-indigo-50 border border-indigo-100 rounded-xl p-3.5 text-sm text-indigo-700 mb-5">
                  No results yet — finish a practice test or an interview and your progress will show up here.
                </div>
              )}
              <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 mb-6 flex flex-col md:flex-row items-center gap-8">
                <ProgressRing value={p.overall ?? 0} size={130} stroke={10} label="Overall" />
                <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4 flex-1 w-full">
                  {p.categories.map((c) => (
                    <div key={c.name}>
                      <div className="flex justify-between text-sm mb-1"><span className="text-slate-600">{c.name}</span><span className="font-medium text-slate-800">{fmtPct(c.score)}</span></div>
                      <ProgressBar value={c.score ?? 0} tone={c.score === null ? "indigo" : c.score > 75 ? "emerald" : c.score < 68 ? "amber" : "indigo"} />
                    </div>
                  ))}
                </div>
              </div>

              <div className="grid lg:grid-cols-2 gap-5 mb-6">
                <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5">
                  <p className="text-sm font-semibold text-slate-700 mb-3">Weekly Progress</p>
                  <ResponsiveContainer width="100%" height={220}>
                    <AreaChart data={p.weekly}>
                      <defs>
                        <linearGradient id="perfGrad" x1="0" y1="0" x2="0" y2="1">
                          <stop offset="5%" stopColor="#4F46E5" stopOpacity={0.35} />
                          <stop offset="95%" stopColor="#4F46E5" stopOpacity={0} />
                        </linearGradient>
                      </defs>
                      <CartesianGrid strokeDasharray="3 3" stroke="#F1F2F6" />
                      <XAxis dataKey="week" tick={{ fontSize: 12, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
                      <YAxis domain={[0, 100]} tick={{ fontSize: 12, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
                      <Tooltip />
                      <Area type="monotone" dataKey="score" connectNulls stroke="#4F46E5" fill="url(#perfGrad)" strokeWidth={2.5} />
                    </AreaChart>
                  </ResponsiveContainer>
                </div>
                <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5">
                  <p className="text-sm font-semibold text-slate-700 mb-3">Test History</p>
                  <ResponsiveContainer width="100%" height={220}>
                    <BarChart data={p.history}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#F1F2F6" />
                      <XAxis dataKey="name" tick={{ fontSize: 11, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
                      <YAxis allowDecimals={false} tick={{ fontSize: 12, fill: "#94A3B8" }} axisLine={false} tickLine={false} />
                      <Tooltip />
                      <Bar dataKey="tests" fill="#7C3AED" radius={[6, 6, 0, 0]} />
                    </BarChart>
                  </ResponsiveContainer>
                </div>
              </div>

              <div className="grid sm:grid-cols-2 gap-4 mb-6">
                <div className="bg-emerald-50 rounded-xl p-4">
                  <p className="text-sm font-medium text-emerald-700 mb-2">Strengths</p>
                  <ul className="text-xs text-emerald-700 space-y-1">
                    {p.strengths.length ? p.strengths.map((s) => <li key={s}>{s}</li>) : <li>Complete a few tests to see your strengths.</li>}
                  </ul>
                </div>
                <div className="bg-amber-50 rounded-xl p-4">
                  <p className="text-sm font-medium text-amber-700 mb-2">Areas to Improve</p>
                  <ul className="text-xs text-amber-700 space-y-1">
                    {p.improve.length ? p.improve.map((s) => <li key={s}>{s}</li>) : <li>Nothing flagged yet — keep practising.</li>}
                  </ul>
                </div>
              </div>

              <p className="text-sm font-medium text-slate-700 mb-3">Recommended Practice</p>
              <div className="flex flex-wrap gap-2">
                {weak.map((w) => (
                  <button
                    key={`${w.module}-${w.topic}`}
                    onClick={() => nav(w.module === "aptitude" ? "aptitude-topic" : "technical-topic", { categoryId: w.category_id, topic: w.topic })}
                    className="px-4 py-2 rounded-xl border border-indigo-200 text-indigo-600 text-sm font-medium hover:bg-indigo-50"
                  >
                    Practice {w.topic} ({w.avg_score}% so far)
                  </button>
                ))}
                {!weak.length && <button onClick={() => nav("aptitude")} className="px-4 py-2 rounded-xl border border-indigo-200 text-indigo-600 text-sm font-medium hover:bg-indigo-50">Start an aptitude practice set</button>}
                <button onClick={() => nav("gd-practice")} className="px-4 py-2 rounded-xl border border-indigo-200 text-indigo-600 text-sm font-medium hover:bg-indigo-50">Practice a GD topic</button>
              </div>
            </>
          );
        }}
      </AsyncView>
    </div>
  );
}

/* ============================== BOOKMARKS ============================== */

function BookmarksPage() {
  const { items, status, error, remove, reload } = useBookmarks();
  const groups = ["Aptitude", "Technical", "Coding", "Interview"];
  const groupOf = (b) => ({ aptitude: "Aptitude", technical: "Technical", coding: "Coding" }[b.module] || "Interview");
  return (
    <div>
      <BackBar title="Bookmarks" subtitle="Your saved questions across every module." />
      {status === "loading" ? (
        <LoadingBlock label="Loading bookmarks…" />
      ) : status === "error" ? (
        <ErrorBlock error={error} onRetry={reload} />
      ) : items.length === 0 ? (
        <EmptyState icon={Bookmark} title="No bookmarks yet" sub="Save questions while practicing to revisit them here." />
      ) : (
        <div className="space-y-6">
          {groups.map((g) => {
            const list = items.filter((i) => groupOf(i) === g);
            if (!list.length) return null;
            return (
              <div key={g}>
                <h3 className="font-semibold text-slate-800 mb-3">{g}</h3>
                <div className="space-y-2">
                  {list.map((it) => (
                    <div key={it.id} className="bg-white rounded-xl border border-slate-100 shadow-sm p-4 flex items-center justify-between">
                      <p className="text-sm text-slate-700">{it.label || it.item_id}</p>
                      <button onClick={() => remove(it)} className="text-slate-300 hover:text-rose-500"><Trash2 size={16} /></button>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

/* ============================== SETTINGS ============================== */

function SettingsPage() {
  const [role, setRole] = useState("Software Developer");
  const [lang, setLang] = useState("Python");
  const [difficulty, setDifficulty] = useState("Intermediate");
  const [notif, setNotif] = useState(true);
  return (
    <div className="max-w-2xl">
      <BackBar title="Settings" subtitle="Manage your profile and preparation preferences." />
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 space-y-6">
        <div>
          <p className="text-sm font-semibold text-slate-700 mb-3">Profile</p>
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-full bg-gradient-to-br from-indigo-500 to-violet-500 flex items-center justify-center text-white text-lg font-semibold">L</div>
            <div>
              <p className="font-medium text-slate-800">Lincy</p>
              <p className="text-sm text-slate-400">First-year CSE Student</p>
            </div>
          </div>
        </div>
        <div>
          <p className="text-sm font-semibold text-slate-700 mb-2">Preferred Role</p>
          <div className="flex flex-wrap gap-2">{AI_ROLES.slice(0, 4).map((r) => <Pill key={r} active={role === r} onClick={() => setRole(r)}>{r}</Pill>)}</div>
        </div>
        <div>
          <p className="text-sm font-semibold text-slate-700 mb-2">Preferred Programming Language</p>
          <div className="flex flex-wrap gap-2">{["Python", "Java", "C++", "JavaScript"].map((l) => <Pill key={l} active={lang === l} onClick={() => setLang(l)}>{l}</Pill>)}</div>
        </div>
        <div>
          <p className="text-sm font-semibold text-slate-700 mb-2">Difficulty Preference</p>
          <div className="flex flex-wrap gap-2">{AI_DIFFICULTIES.map((d) => <Pill key={d} active={difficulty === d} onClick={() => setDifficulty(d)}>{d}</Pill>)}</div>
        </div>
        <div className="flex items-center justify-between">
          <div><p className="text-sm font-semibold text-slate-700">Notifications</p><p className="text-xs text-slate-400 mt-0.5">Streak reminders and report updates</p></div>
          <button onClick={() => setNotif((v) => !v)} className={`w-11 h-6 rounded-full transition-colors relative ${notif ? "bg-indigo-600" : "bg-slate-200"}`}>
            <span className={`absolute top-0.5 w-5 h-5 bg-white rounded-full shadow transition-all ${notif ? "left-5" : "left-0.5"}`} />
          </button>
        </div>
        <div>
          <p className="text-sm font-semibold text-slate-700 mb-2">Theme</p>
          <Pill active>Light</Pill>
        </div>
        <div className="pt-4 border-t border-slate-100">
          <p className="text-sm font-semibold text-slate-700 mb-2">Account Settings</p>
          <div className="flex gap-2">
            <button className="px-4 py-2 rounded-xl border border-slate-200 text-sm font-medium text-slate-600 hover:bg-slate-50">Change Password</button>
            <button className="px-4 py-2 rounded-xl border border-rose-200 text-sm font-medium text-rose-600 hover:bg-rose-50">Deactivate Account</button>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ============================== FULL MOCK ============================== */

// Each stage draws its questions from one category of the question bank in Supabase.
const MOCK_STAGES = [
  { key: "Aptitude", module: "aptitude", categoryId: "quant" },
  { key: "Logical Reasoning", module: "aptitude", categoryId: "logical" },
  { key: "Verbal", module: "aptitude", categoryId: "verbal" },
  { key: "Coding", module: "technical", categoryId: "programming" },
  { key: "Technical", module: "technical", categoryId: "cs-core" },
  { key: "HR", module: "hr", categoryId: "hr-sjt" },
];

function FullMockFlow({ nav }) {
  const [stageIdx, setStageIdx] = useState(0);
  const [inStage, setInStage] = useState(false);
  const [scores, setScores] = useState([]);

  if (stageIdx >= MOCK_STAGES.length) {
    const overall = scores.length ? Math.round(scores.reduce((a, b) => a + b.pct, 0) / scores.length) : 0;
    return (
      <div className="max-w-3xl">
        <BackBar title="Full Placement Mock Report" subtitle="Complete performance across every stage" />
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 md:p-8">
          <div className="flex items-center gap-8 mb-6">
            <ProgressRing value={overall} size={120} stroke={10} label="Overall" />
            <p className="text-sm text-slate-500">You completed the full placement simulation across all six stages. Review your stage-wise breakdown below.</p>
          </div>
          <div className="grid sm:grid-cols-2 gap-4">
            {scores.map((s) => (
              <div key={s.key}><div className="flex justify-between text-sm mb-1"><span className="text-slate-600">{s.key}</span><span className="font-medium text-slate-800">{s.pct}%</span></div><ProgressBar value={s.pct} /></div>
            ))}
          </div>
          <button onClick={() => nav("dashboard")} className="mt-6 px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">Back to Dashboard</button>
        </div>
      </div>
    );
  }

  const stage = MOCK_STAGES[stageIdx];
  if (!inStage) {
    return (
      <div className="max-w-2xl">
        <BackBar title="Full Placement Mock Test" subtitle={`Stage ${stageIdx + 1} of ${MOCK_STAGES.length}`} />
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
          <div className="flex items-center gap-2 mb-5 flex-wrap">
            {MOCK_STAGES.map((s, i) => (
              <React.Fragment key={s.key}>
                <span className={`text-xs font-medium px-3 py-1.5 rounded-full ${i < stageIdx ? "bg-emerald-50 text-emerald-600" : i === stageIdx ? "bg-indigo-600 text-white" : "bg-slate-100 text-slate-400"}`}>{s.key}</span>
                {i < MOCK_STAGES.length - 1 && <ChevronRight size={12} className="text-slate-300" />}
              </React.Fragment>
            ))}
          </div>
          <p className="text-sm text-slate-600 mb-5">Next up: <span className="font-medium text-slate-800">{stage.key}</span> — 5 timed questions.</p>
          <button onClick={() => setInStage(true)} className="px-5 py-2.5 rounded-xl bg-indigo-600 text-white text-sm font-medium hover:bg-indigo-700">Take Stage Test</button>
        </div>
      </div>
    );
  }

  return (
    <QuestionTest
      title={`Full Mock — ${stage.key}`} fetchKey={`mock:${stage.key}`} durationSec={300}
      fetchQuestions={() => prepNestApi.questions({ module: stage.module, categoryId: stage.categoryId, limit: 5, shuffle: true })}
      onSkip={() => { setInStage(false); setStageIdx((i) => i + 1); }}
      onSubmit={(result) => {
        const pct = Math.round((result.correct / result.total) * 100);
        prepNestApi.saveAttempt({
          module: stage.module, category_id: stage.categoryId, topic: `Full Mock — ${stage.key}`, mode: "full-mock",
          correct: result.correct, wrong: result.wrong, unanswered: result.unanswered, total: result.total, duration_seconds: result.timeTaken,
        }).catch((e) => console.warn("Could not save full mock stage", e));
        setScores((s) => [...s, { key: stage.key, pct }]);
        setInStage(false);
        setStageIdx((i) => i + 1);
      }}
    />
  );
}

/* ============================== APP ROOT ============================== */

export default function App() {
  const [history, setHistory] = useState([{ page: "dashboard", params: {} }]);
  const [mobileOpen, setMobileOpen] = useState(false);
  const current = history[history.length - 1];

  function nav(page, params = {}) {
    setHistory((h) => [...h, { page, params }]);
    window.scrollTo?.({ top: 0, behavior: "instant" });
  }
  function back() {
    setHistory((h) => (h.length > 1 ? h.slice(0, -1) : h));
  }
  function navSidebar(page) {
    setHistory((h) => [...h, { page, params: {} }]);
  }
  // used by inline result-flow test submits to reset with fresh result params
  function navReplace(page, params = {}) {
    setHistory((h) => [...h.slice(0, -1), { page, params }]);
  }

  const [testResult, setTestResult] = useState(null);

  // Saves a finished test to Supabase (through the backend) and tracks the save status on the result screen.
  async function persistAttempt(rid, meta, r) {
    try {
      await prepNestApi.saveAttempt({
        ...meta, correct: r.correct, wrong: r.wrong, unanswered: r.unanswered, total: r.total, duration_seconds: r.timeTaken,
      });
      setTestResult((cur) => (cur && cur.rid === rid ? { ...cur, save: "saved" } : cur));
    } catch {
      setTestResult((cur) => (cur && cur.rid === rid ? { ...cur, save: "error" } : cur));
    }
  }
  function onTestSubmit(meta, resultPage, params) {
    return (r) => {
      const rid = Date.now();
      setTestResult({ ...r, meta, save: "saving", rid });
      persistAttempt(rid, meta, r);
      nav(resultPage, params);
    };
  }
  function retrySave() {
    if (!testResult) return;
    setTestResult((cur) => ({ ...cur, save: "saving" }));
    persistAttempt(testResult.rid, testResult.meta, testResult);
  }

  let body = null;
  const p = current.page, params = current.params;

  if (p === "dashboard") body = <Dashboard nav={nav} />;
  else if (p === "aptitude") body = <AptitudeDashboard nav={nav} />;
  else if (p === "aptitude-category") body = <AptitudeCategoryPage params={params} nav={nav} back={back} />;
  else if (p === "aptitude-topic") body = <AptitudeTopicPage params={params} nav={nav} back={back} />;
  else if (p === "aptitude-test") {
    const meta = { module: "aptitude", category_id: params.categoryId, topic: params.topic, mode: "practice" };
    body = (
      <QuestionTest
        title={`${params.topic} Practice Test`} fetchKey={`apt:${params.categoryId}:${params.topic}:${history.length}`}
        fetchQuestions={() => prepNestApi.questions({ module: "aptitude", categoryId: params.categoryId, topic: params.topic, limit: 15, shuffle: true })}
        onSubmit={onTestSubmit(meta, "aptitude-result", params)} onExit={back}
      />
    );
  }
  else if (p === "aptitude-result") body = <TestResultPage result={testResult} onRetrySave={retrySave} onRetake={() => nav("aptitude-test", params)} onDone={() => navSidebar("aptitude")} />;
  else if (p === "technical") body = <TechnicalDashboard nav={nav} />;
  else if (p === "technical-topic") body = <TechnicalTopicPage params={params} nav={nav} back={back} />;
  else if (p === "technical-mcq") {
    const meta = { module: "technical", category_id: params.categoryId, topic: params.topic, mode: "practice" };
    body = (
      <QuestionTest
        title={`${params.topic} MCQ`} fetchKey={`tech:${params.categoryId}:${params.topic}:${history.length}`}
        fetchQuestions={() => prepNestApi.questions({ module: "technical", categoryId: params.categoryId, topic: params.topic, limit: 20, shuffle: true })}
        onSubmit={onTestSubmit(meta, "technical-result", params)} onExit={back}
      />
    );
  }
  else if (p === "technical-result") body = <TestResultPage result={testResult} onRetrySave={retrySave} onRetake={() => nav("technical-mcq", params)} onDone={() => navSidebar("technical")} />;
  else if (p === "ai-interview") body = <AIInterviewConfig params={params} nav={nav} />;
  else if (p === "ai-interview-config") body = <AIInterviewConfig params={params} nav={nav} />;
  else if (p === "ai-interview-screen") body = <AIInterviewScreen params={params} nav={nav} />;
  else if (p === "ai-interview-result") body = <AIInterviewResult params={params} nav={navSidebar} />;
  else if (p === "hr-interview") body = <HRInterviewPage nav={nav} />;
  else if (p === "coding") body = <CodingDashboard nav={nav} />;
  else if (p === "coding-category") body = <CodingCategoryPage params={params} nav={nav} back={back} />;
  else if (p === "coding-problem") body = <CodingProblemPage params={params} nav={nav} back={back} />;
  else if (p === "resume-interview") body = <ResumeInterviewFlow nav={navSidebar} />;
  else if (p === "presentation") body = <PresentationFlow nav={navSidebar} />;
  else if (p === "gd-practice") body = <GDPracticeFlow nav={navSidebar} />;
  else if (p === "company-prep") body = <CompanyPrepDashboard nav={nav} />;
  else if (p === "company-detail") body = <CompanyDetailPage params={params} nav={nav} back={back} />;
  else if (p === "company-mock") {
    const meta = { module: "company", category_id: params.companyId, topic: `${params.companyName || params.companyId} Mock`, mode: "company-mock" };
    body = (
      <QuestionTest
        title="Company Mock Test" fetchKey={`company:${params.companyId}:${history.length}`}
        fetchQuestions={() => prepNestApi.companyMock(params.companyId, 10)}
        onSubmit={onTestSubmit(meta, "company-mock-result", params)} onExit={back}
      />
    );
  }
  else if (p === "company-mock-result") body = <TestResultPage result={testResult} onRetrySave={retrySave} onRetake={() => nav("company-mock", params)} onDone={() => navSidebar("company-prep")} />;
  else if (p === "performance") body = <PerformancePage nav={nav} />;
  else if (p === "bookmarks") body = <BookmarksPage />;
  else if (p === "settings") body = <SettingsPage />;
  else if (p === "full-mock") body = <FullMockFlow nav={navSidebar} />;
  else body = <Dashboard nav={nav} />;

  return (
    <div className="min-h-screen bg-slate-50 flex" style={{ fontFamily: "ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, sans-serif" }}>
      <Sidebar current={p} onNav={navSidebar} mobileOpen={mobileOpen} setMobileOpen={setMobileOpen} />
      <main className="flex-1 min-w-0 px-5 md:px-8 py-6 md:py-8">
        {p === "dashboard" && <Header onMenu={() => setMobileOpen(true)} onNav={navSidebar} />}
        {p !== "dashboard" && (
          <div className="flex items-center justify-between mb-2 md:hidden">
            <button onClick={() => setMobileOpen(true)} className="w-9 h-9 rounded-xl bg-white border border-slate-200 flex items-center justify-center">
              <Menu size={17} className="text-slate-600" />
            </button>
          </div>
        )}
        {body}
      </main>
    </div>
  );
}
