/* =========================================================
   R2 upload endpoint
   ---------------------------------------------------------
   This is the URL of the Cloudflare Worker deployed from the
   r2-worker/ folder (see README.md). It replaces Supabase
   Storage for images and videos — the database (projects,
   project_media, build_logs) still lives in Supabase either way.
   ========================================================= */
const R2_WORKER_URL = "https://YOUR-WORKER-SUBDOMAIN.workers.dev";
