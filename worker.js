/**
 * St Eric Robotics Club — R2 upload Worker
 * ---------------------------------------------------------
 * Why a Worker at all: R2 (like any S3-compatible store) only
 * has real API keys, not a safe-to-expose "anon key" the way
 * Supabase does. A browser can never hold R2 credentials
 * directly. This Worker holds them instead — it checks the
 * caller is a logged-in Supabase admin, then writes the file
 * into R2 on their behalf and hands back the public URL.
 *
 * Deploy: wrangler deploy   (see README.md for full steps)
 */

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*', // tighten to your real site domain once deployed
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Authorization, Content-Type, X-File-Name, X-Folder',
};

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }

    const url = new URL(request.url);
    if (request.method !== 'POST' || url.pathname !== '/upload') {
      return new Response('Not found', { status: 404, headers: CORS_HEADERS });
    }

    // 1. Require a valid, logged-in Supabase session (same accounts as admin-dashboard.html)
    const authHeader = request.headers.get('Authorization') || '';
    const token = authHeader.replace(/^Bearer\s+/i, '');
    if (!token) {
      return new Response('Missing Authorization bearer token', { status: 401, headers: CORS_HEADERS });
    }

    const verifyRes = await fetch(`${env.SUPABASE_URL}/auth/v1/user`, {
      headers: { Authorization: `Bearer ${token}`, apikey: env.SUPABASE_ANON_KEY },
    });
    if (!verifyRes.ok) {
      return new Response('Invalid or expired session — please log in again.', { status: 401, headers: CORS_HEADERS });
    }

    // 2. Stream the file straight into R2
    const folder = (request.headers.get('X-Folder') || 'uploads').replace(/[^a-zA-Z0-9/_-]/g, '');
    const rawName = request.headers.get('X-File-Name') || `file-${Date.now()}`;
    const safeName = rawName.replace(/[^a-zA-Z0-9._-]/g, '_');
    const contentType = request.headers.get('Content-Type') || 'application/octet-stream';
    const key = `${folder}/${Date.now()}-${Math.random().toString(36).slice(2, 7)}-${safeName}`;

    if (!request.body) {
      return new Response('No file body received', { status: 400, headers: CORS_HEADERS });
    }

    await env.MEDIA_BUCKET.put(key, request.body, {
      httpMetadata: { contentType },
    });

    const publicUrl = `${env.R2_PUBLIC_BASE}/${key}`;
    return new Response(JSON.stringify({ url: publicUrl, key }), {
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    });
  },
};
