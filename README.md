# St Eric Robotics Club — Website (Supabase-backed)

## Files
- `index.html` — public homepage (Home, projects grouped by team, Achievements, Gallery, Follow Us)
- `future-innovators.html` / `future-engineers.html` / `robostarters.html` — dedicated pages, each showing only that group's projects (spotlight + filterable card grid)
- `project.html` — individual project page (`project.html?slug=your-slug`), shows full build details + build log
- `admin-login.html` — admin sign-in
- `admin-dashboard.html` — add/edit/delete projects (incl. which group they belong to), upload images & videos, post build-log updates
- `style.css` — shared design system
- `supabase-config.js` — your Supabase URL + anon key go here (database + auth)
- `r2-config.js` — the URL of your deployed R2 upload Worker goes here (file storage)
- `r2-worker/` — the Cloudflare Worker + wrangler config that fronts your R2 bucket (deploy separately from the site)
- `schema.sql` — database schema to run once in Supabase (fresh install)
- `migration-add-groups.sql` — run this instead if you already have a live database from before groups existed
- `migration-add-slides.sql` — run this if you already have a live database from before the slide/hotspot editor existed (fresh installs already get these tables from `schema.sql`)
- `migration-add-gallery.sql` — run this if you already have a live database from before the general gallery existed (fresh installs already get this table from `schema.sql`)
- `admin-gallery.html` — manage the general Gallery (photos/videos not tied to any project), linked from the "Gallery Manager" button in the admin dashboard header
- `project-editor.html` — per-project slide/hotspot editor, opened from the "Slide Editor" link next to each project in the admin dashboard

## Setup (10 minutes)

1. **Create a Supabase project** at https://supabase.com (free tier is enough).
2. **Run the schema**: open the SQL Editor in your Supabase dashboard, paste in the full contents of `schema.sql`, and run it. This creates the `projects`, `project_media`, and `build_logs` tables, sets up security rules, and seeds one example project.
3. **Get your Supabase API keys**: Project Settings → API → copy the "Project URL" and "anon public" key. Fill both into `supabase-config.js`.
4. **Create your admin account**: Authentication → Users → Add User (set an email + password). There's no public sign-up page on purpose — only accounts you create here can log in to `admin-dashboard.html`.
5. **Set up Cloudflare R2** (this replaces Supabase Storage — see the dedicated section below for the full walkthrough).
6. Open `admin-login.html`, sign in, and start adding projects.
7. Deploy the whole folder to GitHub Pages (or any static host) — it's just HTML/CSS/JS, no build step needed.

## Setting up R2 file storage

Images and videos are stored in Cloudflare R2 instead of Supabase Storage. R2 is cheaper at scale (free egress) but, unlike Supabase, it has no safe-to-expose public key — so uploads go through a small Cloudflare Worker instead of straight from the browser.

1. **Create an R2 bucket**: Cloudflare dashboard → R2 → Create bucket, e.g. `steric-robotics-media`.
2. **Enable public access** on the bucket (Settings → Public access → allow either the `r2.dev` dev subdomain, or connect your own custom domain like `media.yourclub.org` — either works, just note the resulting base URL).
3. **Install Wrangler** if you don't have it: `npm install -g wrangler`, then `wrangler login`.
4. **Edit `r2-worker/wrangler.toml`**: set `bucket_name` to your bucket's name, and fill in `SUPABASE_URL`, `SUPABASE_ANON_KEY` (same values as `supabase-config.js`), and `R2_PUBLIC_BASE` (the base URL from step 2).
5. **Deploy the Worker**: `cd r2-worker && wrangler deploy`. Wrangler prints a `*.workers.dev` URL when it's done.
6. **Paste that URL** into `r2-config.js` as `R2_WORKER_URL`.
7. In production, tighten the Worker's `Access-Control-Allow-Origin` in `worker.js` from `*` to your actual site domain, then redeploy.

The Worker checks that whoever is uploading has a valid Supabase login (the same admin accounts as the dashboard) before it writes anything to R2 — so file storage and your admin accounts stay in sync even though they're on two different platforms.

## Notes on the current security setup
Any logged-in (authenticated) user can add/edit/delete projects, media, and build-log entries — there's no separate "admin" role table. For a small club with one or two trusted admins this is simplest: just don't hand out admin accounts casually. If you later want tighter control (e.g. a specific allow-list of admin emails), that can be added to the RLS policies in `schema.sql`.

## What changed from the static version
- The **Timeline section is removed** from the homepage. Progress is now tracked per-project as a **Build Log** on each project's own page — added from the admin dashboard.
- Project cards on the homepage now link to real, individually addressable pages (`project.html?slug=...`) instead of opening a modal — this is the "separate project pages" setup, but data-driven instead of one static HTML file per robot.
- **Projects now belong to a group** — Future Innovators, Future Engineers, or RoboStarters — set from a dropdown in the admin dashboard. The homepage shows projects sectioned by group; each group also gets its own dedicated page showing only its projects, styled as a big spotlight card plus a filterable grid.
- **File storage moved from Supabase to Cloudflare R2**, fronted by a small Worker (`r2-worker/`). The database (projects, media metadata, build logs) is still Supabase — only where the actual image/video bytes live has changed. Anything you uploaded before this switch is still on Supabase Storage and will keep working; only new uploads go to R2. If you want everything on R2, you'd need to re-upload old files through the dashboard once it's pointed at the new Worker.
- Permissions are still simple on purpose: any account you create in Supabase Auth can edit anything. Per-project admin permissions (so a group can only edit their own projects) were intentionally deferred — flag it when you're ready to tackle that, since it means rebuilding the security model.
- The Achievements section is still a static placeholder — the Gallery is now live and pulls from the database.

## Using the general gallery
The Gallery section on the homepage shows photos/videos that aren't tied to any specific project (workshop shots, events, etc.), separate from each project's own media.

1. In `admin-dashboard.html`, click **Gallery Manager**.
2. Upload a photo or video. Caption, tags (comma separated), and a link are all optional.
3. If any items share tags, a filter row of pills appears above the gallery grid on the homepage so visitors can browse by tag.
4. Clicking a gallery photo opens it in a larger view showing the caption, tags, and link (if set), with arrows/swipe to move to the next item — similar to scrolling through a social media post.

## Using the per-project slide editor
Each project can have its own horizontal set of "slides" (images) with invisible clickable buttons layered on top of them — visitors just see the image, but tapping certain areas navigates somewhere.

1. In `admin-dashboard.html`, click **Slide Editor** next to any project.
2. Click **+** to upload a slide image (goes through the same R2 Worker as everything else).
3. Click a slide thumbnail to select it, then **click-and-drag** anywhere on the image to draw a box — a prompt appears asking what that button should do: go Home, scroll to top, jump to Contact/Follow Us, open another project, or open any URL (WhatsApp, YouTube, etc.).
4. Buttons and slides can be deleted with the ✕ on them. There's no reorder-by-drag yet — slides show in upload order.
5. On the live project page, slides show as a swipeable strip (arrows/dots appear once there's more than one) with the buttons fully invisible to visitors.
