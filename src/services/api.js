// Single place where the React app talks to the FastAPI backend (which talks to Supabase).
// The backend URL comes from VITE_API_URL - never hardcode it in components.
const API_BASE = (import.meta.env.VITE_API_URL || "http://localhost:8000/api").replace(/\/+$/, "");

/* ---------- anonymous per-device user id (until real login exists) ---------- */
const USER_KEY = "prepnest_user_id";
let memoryUserId = null;

function uuidv4() {
  if (globalThis.crypto?.randomUUID) return globalThis.crypto.randomUUID();
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    return (c === "x" ? r : (r & 0x3) | 0x8).toString(16);
  });
}

export function getUserId() {
  try {
    let id = localStorage.getItem(USER_KEY);
    if (!id) {
      id = uuidv4();
      localStorage.setItem(USER_KEY, id);
    }
    return id;
  } catch {
    if (!memoryUserId) memoryUserId = uuidv4();
    return memoryUserId;
  }
}

/* ---------- request helper ---------- */
export class ApiError extends Error {
  constructor(message, status = 0) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

function qs(params = {}) {
  const p = new URLSearchParams();
  Object.entries(params).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== "") p.set(k, String(v));
  });
  const s = p.toString();
  return s ? `?${s}` : "";
}

function messageFrom(body, status) {
  const detail = body?.detail;
  if (typeof detail === "string") return detail;
  if (Array.isArray(detail)) return detail.map((d) => d.msg).join("; ");
  return `Request failed (HTTP ${status}).`;
}

async function request(path, { method = "GET", body, timeoutMs = 15000 } = {}) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  let res;
  try {
    res = await fetch(`${API_BASE}${path}`, {
      method,
      headers: body ? { "Content-Type": "application/json" } : undefined,
      body: body ? JSON.stringify(body) : undefined,
      signal: controller.signal,
    });
  } catch (e) {
    throw new ApiError(
      e.name === "AbortError"
        ? "The server took too long to respond."
        : `Can't reach the PrepNest API at ${API_BASE}. Make sure the FastAPI backend is running.`
    );
  } finally {
    clearTimeout(timer);
  }
  if (!res.ok) {
    let parsed = null;
    try { parsed = await res.json(); } catch { /* not JSON */ }
    throw new ApiError(messageFrom(parsed, res.status), res.status);
  }
  return res.json();
}

/* ---------- shape adapters (DB columns -> the props the UI components already use) ---------- */
export function normalizeQuestion(q) {
  return {
    id: q.id,
    module: q.module,
    categoryId: q.category_id,
    topic: q.topic,
    text: q.question,
    options: q.options || [],
    correct: q.correct_index,
    explanation: q.explanation || "",
    difficulty: q.difficulty,
  };
}

export function normalizeProblem(p) {
  return {
    id: p.id,
    categoryId: p.category_id,
    title: p.title,
    difficulty: p.difficulty,
    statement: p.statement,
    input: p.input,
    output: p.output,
    examples: p.examples || [],
    constraints: p.constraints,
    starterCode: p.starter_code || {},
  };
}

const INTERVIEW_CATEGORY = { "Technical Interview": "int-technical", "HR Interview": "int-hr" };

/* ---------- API methods ---------- */
export const prepNestApi = {
  health: () => request("/health"),

  categories: (module, { kind, counts = true } = {}) =>
    request(`/categories${qs({ module, kind, counts: counts ? "true" : undefined })}`),

  questions: async ({ module, categoryId, topic, difficulty, limit = 15, shuffle = false }) => {
    const rows = await request(
      `/questions${qs({ module, category_id: categoryId, topic, difficulty, limit, shuffle: shuffle ? "true" : undefined })}`
    );
    return rows.map(normalizeQuestion);
  },
  questionCount: ({ module, categoryId, topic }) =>
    request(`/questions/count${qs({ module, category_id: categoryId, topic })}`).then((r) => r.count),

  // Open-ended prompts (HR practice / AI interview questions). `{role}` is filled in here.
  hrQuestions: () => prepNestApi.questions({ module: "hr", limit: 200 }),
  interviewQuestions: async (type, role) => {
    const rows = await prepNestApi.questions({
      module: "interview",
      categoryId: INTERVIEW_CATEGORY[type] || "int-general",
      limit: 20,
    });
    return rows.map((q) => q.text.replace("{role}", role || "Software Developer"));
  },

  codingProblems: async ({ categoryId, difficulty, limit = 20 } = {}) => {
    const rows = await request(
      `/coding/problems${qs({ category_id: categoryId, difficulty: difficulty && difficulty !== "All" ? difficulty : undefined, limit })}`
    );
    return rows.map(normalizeProblem);
  },

  companies: () => request("/companies"),
  company: (id) => request(`/companies/${encodeURIComponent(id)}`),
  companyMock: async (id, limit = 10) => {
    const rows = await request(`/companies/${encodeURIComponent(id)}/mock-questions${qs({ limit })}`);
    return rows.map(normalizeQuestion);
  },

  presentationTopics: () => request("/presentation/topics"),
  gdCategories: () => request("/gd/categories"),
  gdTopics: (categoryId) => request(`/gd/topics${qs({ category_id: categoryId })}`),

  saveAttempt: (payload) => request("/attempts", { method: "POST", body: { user_id: getUserId(), ...payload } }),
  dashboard: () => request(`/dashboard${qs({ user_id: getUserId(), tz_offset: new Date().getTimezoneOffset() })}`),
  performance: () => request(`/performance${qs({ user_id: getUserId(), tz_offset: new Date().getTimezoneOffset() })}`),

  bookmarks: () => request(`/bookmarks${qs({ user_id: getUserId() })}`),
  saveBookmark: (payload) => request("/bookmarks", { method: "POST", body: { user_id: getUserId(), ...payload } }),
  deleteBookmark: ({ item_type, item_id }) =>
    request(`/bookmarks${qs({ user_id: getUserId(), item_type, item_id })}`, { method: "DELETE" }),

  saveInterviewResult: (payload) =>
    request("/interview-results", { method: "POST", body: { user_id: getUserId(), ...payload } }),
};
