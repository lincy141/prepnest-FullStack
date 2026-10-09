-- =====================================================================
-- PrepNest - DEV RESET. DELETES ALL PrepNest TABLES AND THEIR DATA.
-- Only run this on a development project (e.g. if you ran an older
-- schema.sql and want a clean start). Then run schema.sql and seed.sql.
-- =====================================================================
drop table if exists bookmarks           cascade;
drop table if exists interview_results   cascade;
drop table if exists test_attempts       cascade;
drop table if exists gd_topics           cascade;
drop table if exists gd_categories       cascade;
drop table if exists presentation_topics cascade;
drop table if exists companies           cascade;
drop table if exists coding_problems     cascade;
drop table if exists questions           cascade;
drop table if exists categories          cascade;
drop table if exists profiles            cascade;
drop function if exists set_updated_at() cascade;
