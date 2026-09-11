# St Eric Robotics Club — Website (Supabase-backed)

## Files
- `index.html` — public homepage (Home, projects grouped by team, Achievements, Gallery, Follow Us)
- `future-innovators.html` / `future-engineers.html` / `robostarters.html` — dedicated pages, each showing only that group's projects
- `project.html` — individual project page (`project.html?slug=your-slug`), shows full build details + build log
- `admin-login.html` — admin sign-in
- `admin-dashboard.html` — add/edit/delete projects (incl. which group they belong to), upload images & videos, post build-log updates
- `style.css` — shared design system
- `supabase-config.js` — your Supabase URL + anon key go here
- `schema.sql` — database schema to run once in Supabase (fresh install)
- `migration-add-groups.sql` — run this instead if you already have a live database from before groups existed

## Setup (10 minutes)

1. **Create a Supabase project** at https://supabase.com (free tier is enough).
2. **Run the schema**: open the SQL Editor in your Supabase dashboard, paste in the full contents of `schema.sql`, and run it. This creates the `projects`, `project_media`, and `build_logs` tables, sets up security rules, and seeds one example project.
3. **Create a storage bucket**: go to Storage → New Bucket → name it exactly `project-media` → toggle it **Public**. This is where cover images, gallery photos, and uploaded videos live.
4. **Get your API keys**: Project Settings → API → copy the "Project URL" and "anon public" key.
5. **Fill in `supabase-config.js`** with those two values.
6. **Create your admin account**: Authentication → Users → Add User (set an email + password). There's no public sign-up page on purpose — only accounts you create here can log in to `admin-dashboard.html`.
7. Open `admin-login.html`, sign in, and start adding projects.
8. Deploy the whole folder to GitHub Pages (or any static host) — it's just HTML/CSS/JS, no build step needed.

## Notes on the current security setup
Any logged-in (authenticated) user can add/edit/delete projects, media, and build-log entries — there's no separate "admin" role table. For a small club with one or two trusted admins this is simplest: just don't hand out admin accounts casually. If you later want tighter control (e.g. a specific allow-list of admin emails), that can be added to the RLS policies in `schema.sql`.

## What changed from the static version
- The **Timeline section is removed** from the homepage. Progress is now tracked per-project as a **Build Log** on each project's own page — added from the admin dashboard.
- Project cards on the homepage now link to real, individually addressable pages (`project.html?slug=...`) instead of opening a modal — this is the "separate project pages" setup, but data-driven instead of one static HTML file per robot.
- **Projects now belong to a group** — Future Innovators, Future Engineers, or RoboStarters — set from a dropdown in the admin dashboard. The homepage shows projects sectioned by group; each group also gets its own dedicated page showing only its projects.
- Permissions are still simple on purpose: any account you create in Supabase Auth can edit anything. Per-project admin permissions (so a group can only edit their own projects) were intentionally deferred — flag it when you're ready to tackle that, since it means rebuilding the security model.
- The Achievements and homepage Gallery sections are still static placeholders — happy to wire the Gallery to real uploaded photos next if you want it pulling from all projects automatically.
