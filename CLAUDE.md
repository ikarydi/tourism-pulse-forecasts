# tourism-pulse-forecasts (public, append-only record)

- Never edit, move, or delete anything under `batches/` or existing rows of `manifest.csv`. Only add a new batch folder and append a manifest row.
- Every batch must have `forecasts.csv`, its `.sha256`, and a freetsa.org RFC 3161 `.tsr`. Run `./verify.sh` before committing.
- Never force-push, rebase, or rewrite history in this repo.
- Batches are produced by the Tourism-Pulse repo. Do not hand-edit forecast values.
