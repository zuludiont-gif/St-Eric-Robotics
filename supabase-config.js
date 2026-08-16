/* =========================================================
   Supabase connection settings
   ---------------------------------------------------------
   1. Create a free project at https://supabase.com
   2. Go to Project Settings → API
   3. Copy your "Project URL" and "anon public" key below
   4. Run schema.sql in the Supabase SQL Editor (see README.md)
   5. Create a storage bucket named "project-media" and make it PUBLIC
   ========================================================= */
const SUPABASE_URL = https://hpnizjlclivfpjmqphes.supabase.co; // e.g. https://abcdefgh.supabase.co
const SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhwbml6amxjbGl2ZnBqbXFwaGVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4NzQxMjcsImV4cCI6MjEwMjQ1MDEyN30.NKmLE9tZgpwQTO6-_g8W55xeQaXrCBOH4Ui39pfZp1c;

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
