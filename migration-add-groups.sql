-- =========================================================
-- Migration: add project groups (Future Innovators / Future
-- Engineers / RoboStarters) to an EXISTING St Eric Robotics
-- Club database. Run this once in the Supabase SQL Editor.
-- (schema.sql has also been updated so any brand-new database
-- gets this column automatically — you don't need to run both.)
-- =========================================================

alter table projects
  add column if not exists group_slug text not null default 'robostarters'
    check (group_slug in ('future-innovators','future-engineers','robostarters'));

-- Optional: reassign the seeded example project to a group of your choice.
-- update projects set group_slug = 'future-engineers' where slug = 'obstacle-avoider';
