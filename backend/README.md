# PrepNest Backend (FastAPI + Supabase)

React → **FastAPI** → **Supabase PostgreSQL**. This folder is the API layer. The browser never sees a Supabase secret.

```
backend/
  app/
    main.py            FastAPI app, CORS, /api/health
    config.py          settings from backend/.env
    supabase.py        async client for the Supabase REST API (service-role key)
    topics.py          exact-topic resolution ("Percentages" -> "Percentage")
    stats.py           dashboard / performance calculations
    users.py           creates the profile row for a user id on first write
    routes/            categories, questions, coding, companies, gd, presentation,
                       performance (attempts + dashboard), bookmarks, interviews
  sql/
    schema.sql         all tables, indexes, constraints, RLS
    seed.sql           starter content (294 questions, 36 coding problems, 9 companies, ...)
    reset.sql          DEV ONLY: drops the PrepNest tables
  requirements.txt
  .env.example
```

Requires **Python 3.10+**.

## 1. Supabase setup

1. Create a project at <https://supabase.com> (free tier is fine).
2. Open **SQL Editor → New query**.
3. *(Only if you already ran an older PrepNest schema)* paste and run `sql/reset.sql` first. It deletes the PrepNest tables.
4. Paste all of `sql/schema.sql` → **Run**.
5. Paste all of `sql/seed.sql` → **Run**. (Safe to re-run; it never touches user data.)
6. **Project Settings → API**: copy the **Project URL** and the **`service_role`** key (not the `anon` key).

## 2. Backend setup

```bash
cd backend
python -m venv venv
# Windows:  venv\Scripts\activate        macOS/Linux:  source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env        # Windows: copy .env.example .env
# edit .env: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
uvicorn app.main:app --reload --port 8000
```

Check it: <http://localhost:8000/api/health> should show `"database": "connected"`.
Interactive docs: <http://localhost:8000/docs>.

If `database` shows `error`, the `detail` field says why (wrong key, schema not run, ...).

## Environment variables (`backend/.env`)

| Variable | Meaning |
|---|---|
| `SUPABASE_URL` | Project URL, e.g. `https://abcd1234.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | **Secret.** Server only. Never put it in the React app or a `VITE_*` variable. |
| `FRONTEND_URL` | Allowed browser origin(s) for CORS. Comma-separate several. Default `http://localhost:5173` |

## API

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/health` | API + database status |
| GET | `/api/categories?module=&kind=&counts=` | Categories and topics (`counts=true` adds question/problem counts) |
| GET | `/api/questions?module=&category_id=&topic=&difficulty=&limit=&shuffle=` | Questions for exactly one topic |
| GET | `/api/questions/count?module=&category_id=&topic=` | Number of questions |
| GET | `/api/coding/problems?category_id=&difficulty=` | Coding problems (solutions are not returned) |
| GET | `/api/coding/problems/{id}` | One problem including its solution |
| GET | `/api/companies`, `/api/companies/{id}` | Company preparation data |
| GET | `/api/companies/{id}/mock-questions?limit=` | Mock test built from the company's focus topics |
| GET | `/api/gd/categories`, `/api/gd/topics?category_id=` | Group discussion |
| GET | `/api/presentation/topics` | Presentation topics |
| POST | `/api/attempts` | Save a finished test |
| GET | `/api/performance?user_id=` | Charts / category scores |
| GET | `/api/dashboard?user_id=` | Totals, per-module and topic-wise results |
| POST / GET / DELETE | `/api/bookmarks` | Bookmarks |
| POST / GET | `/api/interview-results` | AI / HR interview reports |

### Exact topic filtering

`GET /api/questions?module=aptitude&category_id=quant&topic=Percentage` returns only questions stored under
the topic `Percentage`. The requested topic is first mapped to its canonical name from the `categories` table
(so `Percentages`, `percentage`, `Time Speed Distance` and `Coding-Decoding` also work) and then applied as an
exact `eq` filter - `C` never returns `C++` questions.

### Users

PrepNest has no login yet. The browser creates an anonymous UUID (stored in `localStorage`) and sends it as
`user_id`. The backend creates the matching `profiles` row on first write. When you add real authentication
(e.g. Supabase Auth), verify the token in FastAPI and use its user id instead of the client-supplied one.

### Adding content

Insert rows in the Supabase Table Editor (or SQL): a new question needs `module`, `category_id`, `topic`
(must match a name in `categories.topics`), `question`, `options` (JSON array), `correct_index`. Nothing in the
frontend needs to change. New topics: add the name to the category's `topics` array.
