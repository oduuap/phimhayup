// Cloudflare Worker - TMDB API proxy
//
// Deploy:
// 1. Create a Cloudflare Worker.
// 2. Add a secret named TMDB_API_KEY with `wrangler secret put TMDB_API_KEY`
//    or in Dashboard -> Worker -> Settings -> Variables.
// 3. Point AppConfig.tmdbProxyUrl to this worker with the `/3` path.

export default {
  async fetch(request, env) {
    if (!env.TMDB_API_KEY) {
      return new Response(JSON.stringify({ error: 'TMDB_API_KEY is not set' }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const url = new URL(request.url);
    url.searchParams.set('api_key', env.TMDB_API_KEY);
    url.hostname = 'api.themoviedb.org';

    const tmdbRequest = new Request(url.toString(), {
      method: request.method,
      headers: {
        accept: 'application/json',
      },
    });

    try {
      const response = await fetch(tmdbRequest);
      return new Response(response.body, {
        status: response.status,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      });
    } catch (error) {
      return new Response(JSON.stringify({ error: 'Proxy error' }), {
        status: 502,
        headers: { 'Content-Type': 'application/json' },
      });
    }
  },
};
