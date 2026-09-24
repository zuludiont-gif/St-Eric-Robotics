-- =========================================================
-- St Eric Robotics Club — General Gallery migration
-- Run this once in the Supabase SQL Editor (after schema.sql)
-- Adds a gallery of photos/videos that are NOT tied to any
-- specific project — general club/workshop/event media, with
-- optional caption, tags, and an outbound link per item.
-- =========================================================

create extension if not exists "pgcrypto";

create table if not exists gallery_items (
  id uuid primary key default gen_random_uuid(),
  media_url text not null,
  media_type text not null default 'image' check (media_type in ('image','video')),
  caption text,       -- optional
  tags text[],         -- optional, e.g. '{"workshop","robostarters"}'
  link_url text,       -- optional, e.g. a WhatsApp/Instagram/YouTube link
  created_at timestamptz default now()
);

alter table gallery_items enable row level security;

create policy "public read gallery_items" on gallery_items for select using (true);
create policy "admin write gallery_items" on gallery_items for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
