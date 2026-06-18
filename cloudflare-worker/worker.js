// Cloudflare Worker — TMDB API proxy
// Deploy: https://dash.cloudflare.com -> Workers & Pages -> Create Worker -> paste this

export default {
  async fetch(request) {
    const url = new URL(request.url);

    // Rewrite host to TMDB API, keep path + query unchanged
    url.hostname = 'api.themoviedb.org';

    const tmdbRequest = new Request(url.toString(), {
      method: request.method,
      headers: request.headers,
    });

    const response = await fetch(tmdbRequest);
    return response;
  },
};
