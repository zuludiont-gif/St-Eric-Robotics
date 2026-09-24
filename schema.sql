-- =========================================================
-- St Eric Robotics Club — Supabase schema
-- Run this whole file once in Supabase SQL Editor
-- =========================================================

create extension if not exists "pgcrypto";

-- ---------- projects ----------
create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  group_slug text not null default 'robostarters' check (group_slug in ('future-innovators','future-engineers','robostarters')),
  status text not null default 'planned' check (status in ('planned','progress','testing','completed')),
  short_description text,
  goal text,
  components text[] default '{}',
  how_it_works text,
  what_we_learned text[] default '{}',
  challenges text,
  code_snippet text,
  tags text[] default '{}',
  cover_image_url text,
  video_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ---------- project_media (gallery images/videos per project) ----------
create table if not exists project_media (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  media_type text not null check (media_type in ('image','video')),
  url text not null,
  caption text,
  created_at timestamptz default now()
);

-- ---------- build_logs (per-project update log — replaces the old static timeline) ----------
create table if not exists build_logs (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  title text not null,
  note text,
  status text not null default 'progress' check (status in ('planned','progress','testing','completed')),
  created_at timestamptz default now()
);

-- ---------- project_slides (horizontal slide/hotspot editor, per project) ----------
create table if not exists project_slides (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  image_url text not null,
  sort_order int not null default 0,
  created_at timestamptz default now()
);

-- x/y/w/h stored as percentages (0-100) of the slide image so hotspots
-- stay correctly positioned at any screen size.
create table if not exists project_slide_buttons (
  id uuid primary key default gen_random_uuid(),
  slide_id uuid references project_slides(id) on delete cascade,
  x numeric not null,
  y numeric not null,
  w numeric not null,
  h numeric not null,
  label text,
  action_type text not null check (action_type in ('home','scroll_top','contact','project_link','url')),
  action_value text,
  created_at timestamptz default now()
);

-- ---------- gallery_items (general photos/videos, not tied to a project) ----------
create table if not exists gallery_items (
  id uuid primary key default gen_random_uuid(),
  media_url text not null,
  media_type text not null default 'image' check (media_type in ('image','video')),
  caption text,
  tags text[],
  link_url text,
  created_at timestamptz default now()
);

-- ---------- Row Level Security ----------
alter table projects enable row level security;
alter table project_media enable row level security;
alter table build_logs enable row level security;
alter table project_slides enable row level security;
alter table project_slide_buttons enable row level security;
alter table gallery_items enable row level security;

-- Public (anonymous) visitors can READ everything
create policy "public read projects" on projects for select using (true);
create policy "public read project_media" on project_media for select using (true);
create policy "public read build_logs" on build_logs for select using (true);

-- Only logged-in (authenticated) users — i.e. admins you create manually
-- in Supabase Auth — can write. See README.md for creating an admin user.
create policy "admin write projects" on projects for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin write project_media" on project_media for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin write build_logs" on build_logs for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "public read project_slides" on project_slides for select using (true);
create policy "public read project_slide_buttons" on project_slide_buttons for select using (true);
create policy "admin write project_slides" on project_slides for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "admin write project_slide_buttons" on project_slide_buttons for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "public read gallery_items" on gallery_items for select using (true);
create policy "admin write gallery_items" on gallery_items for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ---------- keep updated_at fresh ----------
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_projects_updated_at on projects;
create trigger trg_projects_updated_at
  before update on projects
  for each row execute function set_updated_at();

-- ---------- optional: seed the Obstacle Avoiding Robot example ----------
insert into projects (slug, title, group_slug, status, short_description, goal, components, how_it_works, what_we_learned, challenges, code_snippet, tags)
values (
  'obstacle-avoider',
  'Obstacle Avoiding Robot',
  'robostarters',
  'completed',
  'Uses an ultrasonic sensor to detect obstacles and automatically change direction.',
  'Build a robot that can move without hitting obstacles.',
  array['Raspberry Pi Pico WH','HC-SR04 ultrasonic sensor','L298N motor driver','2 DC motors'],
  'The sensor measures distance in front of the robot. If an object is detected closer than 15 cm, the robot stops, reverses, and turns before moving forward again.',
  array['PWM motor control','Distance measurement','Turning algorithms'],
  'Motors did not rotate at the same speed, so the robot drifted to one side.',
  'while True:
    dist = read_distance()
    if dist < 15:
        stop()
        reverse(0.3)
        turn_right(0.4)
    else:
        forward()',
  array['sensors','autonomous','pico']
) on conflict (slug) do nothing;
