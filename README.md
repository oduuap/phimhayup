# phimhayup

phimhayup is a Flutter movie discovery app for Vietnamese users. It helps users explore movie information, watch public YouTube trailers, save personal collections, track upcoming releases, and open search pages on legal streaming platforms.

phimhayup does not host, stream, download, sell, or distribute copyrighted movies.

## Product Positioning

- Category: Entertainment
- Core features: movie discovery, trailers, watchlist, personal collections, mood-based discovery, release countdown, and legal platform search
- Data source: TMDB via backend proxy
- Trailer source: YouTube
- Streaming behavior: opens external legal platform search pages only

## Production Checklist

Before uploading a production build:

1. Keep `TMDB_API_KEY` only in the Cloudflare Worker secret.
2. Confirm `AppConfig.tmdbProxyUrl` points to the production Worker.
3. Publish Privacy Policy, Terms, and Support URLs.
4. Verify TMDB attribution is visible in app/store/support materials.
5. Regenerate launcher icons after replacing `assets/icon/icon.png`.
6. Run `flutter analyze` and `flutter test`.
7. Build release AAB with `flutter build appbundle --release`.

Store submission copy is available in `docs/store_submission_vi.md`.
