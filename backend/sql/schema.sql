-- =====================================================================
-- PrepNest - Supabase PostgreSQL schema
-- Run this whole file once in: Supabase Dashboard -> SQL Editor.
-- It only creates structure. Run seed.sql afterwards to load content.
--
-- Already ran an older PrepNest schema.sql? Run reset.sql FIRST
-- (it drops the PrepNest tables) and then this file.
-- =====================================================================

create extension if not exists pgcrypto;

-- Keeps updated_at current on every UPDATE.
create or replace function set_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ---------------------------------------------------------------------
-- 1. profiles  (one row per user; the id is an anonymous per-device UUID
--    until real authentication is added)
-- ---------------------------------------------------------------------
create table if not exists profiles (
  id          uuid primary key,
  full_name   text,
  email       text,
  branch      text,
  year        text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 2. categories  (module -> category -> topics shown in the UI)
--    module: aptitude | technical | coding | hr | interview
--    kind:   mcq (has option-based questions) | prompt (open questions)
-- ---------------------------------------------------------------------
create table if not exists categories (
  id           text primary key,
  module       text not null check (module in ('aptitude','technical','coding','hr','interview')),
  name         text not null,
  description  text,
  topics       jsonb not null default '[]'::jsonb,
  kind         text not null default 'mcq' check (kind in ('mcq','prompt')),
  sort_order   int  not null default 0,
  is_active    boolean not null default true,
  created_at   timestamptz not null default now()
);
create index if not exists idx_categories_module on categories (module, sort_order);

-- ---------------------------------------------------------------------
-- 3. questions  (single source of truth for every question bank)
-- ---------------------------------------------------------------------
create table if not exists questions (
  id             uuid primary key default gen_random_uuid(),
  module         text not null check (module in ('aptitude','technical','hr','interview')),
  category_id    text not null references categories(id) on delete cascade,
  topic          text not null,
  question       text not null,
  options        jsonb not null default '[]'::jsonb,
  correct_index  int,
  explanation    text,
  difficulty     text not null default 'Medium' check (difficulty in ('Easy','Medium','Hard')),
  sort_order     int  not null default 0,
  is_active      boolean not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint chk_correct_index check (
    jsonb_array_length(options) = 0
    or (correct_index is not null and correct_index >= 0 and correct_index < jsonb_array_length(options))
  )
);
create index if not exists idx_questions_lookup on questions (module, category_id, topic) where is_active;
create index if not exists idx_questions_topic  on questions (topic);
create unique index if not exists uq_questions_text on questions (category_id, topic, md5(question));
drop trigger if exists trg_questions_updated on questions;
create trigger trg_questions_updated before update on questions for each row execute function set_updated_at();

-- ---------------------------------------------------------------------
-- 4. coding_problems
-- ---------------------------------------------------------------------
create table if not exists coding_problems (
  id            uuid primary key default gen_random_uuid(),
  category_id   text not null references categories(id) on delete cascade,
  title         text not null,
  difficulty    text not null check (difficulty in ('Easy','Medium','Hard')),
  statement     text not null,
  input         text,
  output        text,
  examples      jsonb not null default '[]'::jsonb,   -- [{"input": "...", "output": "..."}]
  constraints   text,
  starter_code  jsonb not null default '{}'::jsonb,   -- {"Python": "def solve(...): ..."}
  solution      text,
  sort_order    int not null default 0,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (category_id, title)
);
create index if not exists idx_coding_category on coding_problems (category_id, sort_order) where is_active;
drop trigger if exists trg_coding_updated on coding_problems;
create trigger trg_coding_updated before update on coding_problems for each row execute function set_updated_at();

-- ---------------------------------------------------------------------
-- 5. companies  (company preparation)
-- ---------------------------------------------------------------------
create table if not exists companies (
  id            text primary key,
  name          text not null,
  color         text,
  overview      text,
  eligibility   text,
  process       jsonb not null default '[]'::jsonb,   -- ["Aptitude","Technical","Coding","HR"]
  focus_topics  jsonb not null default '{}'::jsonb,   -- {"aptitude": [...topics], "technical": [...topics]}
  sections      jsonb not null default '{}'::jsonb,   -- {"Aptitude Preparation": "text", ...}
  sort_order    int not null default 0,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 6. presentation_topics
-- ---------------------------------------------------------------------
create table if not exists presentation_topics (
  id            uuid primary key default gen_random_uuid(),
  title         text not null unique,
  description   text,
  prep_seconds  int not null default 60,
  speak_seconds int not null default 120,
  tips          jsonb not null default '[]'::jsonb,
  sort_order    int not null default 0,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 7. gd_categories / 8. gd_topics
-- ---------------------------------------------------------------------
create table if not exists gd_categories (
  id           text primary key,
  name         text not null,
  description  text,
  sort_order   int not null default 0,
  is_active    boolean not null default true,
  created_at   timestamptz not null default now()
);

create table if not exists gd_topics (
  id           uuid primary key default gen_random_uuid(),
  category_id  text not null references gd_categories(id) on delete cascade,
  topic        text not null,
  sort_order   int not null default 0,
  is_active    boolean not null default true,
  created_at   timestamptz not null default now(),
  unique (category_id, topic)
);
create index if not exists idx_gd_topics_category on gd_topics (category_id, sort_order) where is_active;

-- ---------------------------------------------------------------------
-- 9. test_attempts  (every finished quiz / mock / coding submission)
-- ---------------------------------------------------------------------
create table if not exists test_attempts (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references profiles(id) on delete cascade,
  module           text not null,                 -- aptitude | technical | coding | hr | company
  category_id      text,
  topic            text,
  difficulty       text,
  mode             text not null default 'practice' check (mode in ('practice','full-mock','company-mock')),
  score            int  not null check (score between 0 and 100),
  correct          int  not null default 0,
  wrong            int  not null default 0,
  unanswered       int  not null default 0,
  total            int  not null default 0,
  duration_seconds int  not null default 0,
  created_at       timestamptz not null default now()
);
create index if not exists idx_attempts_user_time  on test_attempts (user_id, created_at desc);
create index if not exists idx_attempts_user_topic on test_attempts (user_id, module, category_id, topic);

-- ---------------------------------------------------------------------
-- 10. interview_results  (AI / HR / resume interview reports)
-- ---------------------------------------------------------------------
create table if not exists interview_results (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references profiles(id) on delete cascade,
  interview_type   text,
  role             text,
  difficulty       text,
  overall          int  not null check (overall between 0 and 100),
  categories       jsonb not null default '{}'::jsonb,
  strengths        jsonb not null default '[]'::jsonb,
  improve          jsonb not null default '[]'::jsonb,
  duration_seconds int  not null default 0,
  transcript       jsonb not null default '[]'::jsonb,
  created_at       timestamptz not null default now()
);
create index if not exists idx_interviews_user_time on interview_results (user_id, created_at desc);

-- ---------------------------------------------------------------------
-- 11. bookmarks
-- ---------------------------------------------------------------------
create table if not exists bookmarks (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  item_type   text not null,                      -- question | coding_problem
  item_id     text not null,
  module      text,
  label       text,
  meta        jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default now(),
  unique (user_id, item_type, item_id)
);
create index if not exists idx_bookmarks_user on bookmarks (user_id, created_at desc);

-- ---------------------------------------------------------------------
-- Security: Supabase exposes every table in the public schema through a REST
-- API that the public "anon" key can call. Row Level Security with NO policies
-- blocks that completely. The FastAPI backend uses the service_role key, which
-- bypasses RLS, so it is the only thing that can read or write these tables.
-- ---------------------------------------------------------------------
alter table profiles            enable row level security;
alter table categories          enable row level security;
alter table questions           enable row level security;
alter table coding_problems     enable row level security;
alter table companies           enable row level security;
alter table presentation_topics enable row level security;
alter table gd_categories       enable row level security;
alter table gd_topics           enable row level security;
alter table test_attempts       enable row level security;
alter table interview_results   enable row level security;
alter table bookmarks           enable row level security;
