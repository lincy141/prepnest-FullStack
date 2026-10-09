# PrepNest

Placement-preparation app: **React (Vite) frontend → FastAPI backend → Supabase PostgreSQL**.

```
React frontend  ──►  FastAPI backend (backend/)  ──►  Supabase (PostgreSQL)
      │
      └──►  api/ai-interview.js  (xAI / Grok scorer - unchanged)
```

- All questions, coding problems, companies, GD / presentation content, test results, bookmarks and
  interview results live in Supabase. Nothing in React is a hardcoded question bank.
- Only the FastAPI backend holds the Supabase service-role key.
- The AI Interview (`api/ai-interview.js`, xAI/Grok) is unchanged. Real interview reports are now also stored.

## Quick start

**1. Supabase** - create a project, then in the SQL Editor run `backend/sql/schema.sql` and then `backend/sql/seed.sql`
(if you ran an older schema first, run `backend/sql/reset.sql` before them). Copy the Project URL and the `service_role` key.

**2. Backend** (Python 3.10+)

```bash
cd backend
python -m venv venv
venv\Scripts\activate            # macOS/Linux: source venv/bin/activate
pip install -r requirements.txt
copy .env.example .env           # macOS/Linux: cp .env.example .env   -> fill in SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY
uvicorn app.main:app --reload --port 8000
```

Health check: <http://localhost:8000/api/health> (`"database": "connected"`).

**3. Frontend** (project root)

```bash
copy .env.example .env           # macOS/Linux: cp .env.example .env
# .env: VITE_API_URL=http://localhost:8000/api     and your XAI_API_KEY for the AI Interview
npm install
npm run dev                      # http://localhost:5173
```

`npm run dev` also serves `api/ai-interview.js` locally (via a small dev-only plugin in `vite.config.js`),
so the AI Interview works without the Vercel CLI. `XAI_API_KEY` is read from the same `.env`.

## Environment variables

| File | Variable | Notes |
|---|---|---|
| `backend/.env` | `SUPABASE_URL` | Supabase project URL |
| `backend/.env` | `SUPABASE_SERVICE_ROLE_KEY` | **Secret**, backend only |
| `backend/.env` | `FRONTEND_URL` | CORS origin(s), default `http://localhost:5173` |
| `.env` (root) | `VITE_API_URL` | `http://localhost:8000/api` locally |
| `.env` (root) | `XAI_API_KEY` | For `api/ai-interview.js` |

## How the pieces connect

1. A page calls `src/services/api.js` (the only file that knows the backend URL).
2. The service sends e.g. `GET {VITE_API_URL}/questions?module=aptitude&category_id=quant&topic=Percentage`.
3. FastAPI resolves the topic, queries Supabase with the service-role key and returns JSON.
4. When a test finishes, the app `POST`s `/api/attempts`; the dashboard, module pages and Performance page are
   computed from the saved `test_attempts` and `interview_results`.

Loading, error (with **Try again**) and empty states are handled for every API-backed screen.

## Database tables

`profiles`, `categories`, `questions`, `coding_problems`, `companies`, `presentation_topics`, `gd_categories`,
`gd_topics`, `test_attempts`, `interview_results`, `bookmarks`. Row Level Security is enabled on all of them with
no public policies, so the public `anon` key cannot read or write them - only the backend can.

## Testing each section

1. **Aptitude**: Aptitude → Quantitative Aptitude → Percentage → Start Practice. Every question is about percentages. Try Logical Reasoning → Number Series.
2. **Technical**: Technical → Python → Start MCQ; then DBMS. Each only shows its own topic.
3. **Coding**: Coding → Arrays shows 3 array problems; open one - the editor starts with the stored starter code. Submit saves a submission.
4. **Results**: finish any test; the result page says "Result saved". Reload the browser, then open Performance and the module pages: the numbers persist.
5. **Bookmarks**: click the bookmark icon on a question, coding problem or HR question; reload; open Bookmarks.
6. **GD / Presentation / Company**: choose a category/topic/company; content and timings come from Supabase. "Start Company Mock" builds a test from that company's focus topics.
7. **AI Interview**: start one; questions come from Supabase, scoring uses `api/ai-interview.js`, and the report is saved to `interview_results`.

## Known limitations

- **No login yet.** Each browser gets an anonymous id, so data is per browser. Use Supabase Auth to add accounts.
- **Coding "Run Code" / "Submit" don't execute code.** The original UI always showed "Passed"; that is unchanged. Submit now records a submission, but real judging needs a code-execution service (e.g. Judge0).
- **GD and Presentation feedback scores are still static sample numbers** (nothing evaluates them yet), so those two sessions are not saved and show "—" on the Performance page.
- The Resume Interview's resume analysis is still the original demo; its AI interview part is real.
- Correct answers are sent to the browser (the quiz UI grades locally), fine for practice but not for proctored exams.
- Production: deploy FastAPI anywhere that runs Python, set `FRONTEND_URL` to your site, and build the frontend with `VITE_API_URL` pointing at it. `api/ai-interview.js` still deploys as a Vercel function.
