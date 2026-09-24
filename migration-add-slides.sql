-- =========================================================
-- St Eric Robotics Club — Slide Editor migration
-- Run this once in the Supabase SQL Editor (after schema.sql)
-- Adds: per-project horizontal slides, each with transparent
-- clickable "hotspot" buttons placed on top of the image.
-- =========================================================

create extension if not exists "pgcrypto";

-- ---------- project_slides ----------
create table if not exists project_slides (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  image_url text not null,
  sort_order int not null default 0,
  created_at timestamptz default now()
);

-- ---------- project_slide_buttons (transparent hotspots on a slide) ----------
-- x, y, w, h are all stored as PERCENTAGES (0-100) of the slide image's
-- width/height, so buttons stay correctly positioned at any screen size.
create table if not exists project_slide_buttons (
  id uuid primary key default gen_random_uuid(),
  slide_id uuid references project_slides(id) on delete cascade,
  x numeric not null,
  y numeric not null,
  w numeric not null,
  h numeric not null,
  label text, -- admin-facing only, not shown to visitors (button is transparent)
  action_type text not null check (action_type in ('home','scroll_top','contact','project_link','url')),
  action_value text, -- project slug (for project_link) or full URL (for url); unused for home/scroll_top/contact
  created_at timestamptz default now()
);

-- ---------- Row Level Security ----------
alter table project_slides enable row level security;
alter table project_slide_buttons enable row level security;

create policy "public read project_slides" on project_slides for select using (true);
create policy "public read project_slide_buttons" on project_slide_buttons for select using (true);

create policy "admin write project_slides" on project_slides for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin write project_slide_buttons" on project_slide_buttons for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
