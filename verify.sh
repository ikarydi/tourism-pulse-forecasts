#!/usr/bin/env bash
# Check every batch: the SHA-256 matches, and the timestamp token is valid
# for that file. Needs sha256sum and openssl.
set -euo pipefail
cd "$(dirname "$0")"
status=0
for batch in batches/*/; do
  name=$(basename "$batch")
  if (cd "$batch" && sha256sum --quiet -c forecasts.csv.sha256) \
    && openssl ts -verify -data "$batch/forecasts.csv" -in "$batch/forecasts.csv.tsr" \
      -CAfile tsa/cacert.pem -untrusted tsa/tsa.crt >/dev/null 2>&1; then
    stamp=$(openssl ts -reply -in "$batch/forecasts.csv.tsr" -text 2>/dev/null \
      | sed -n 's/^Time stamp: //p')
    echo "OK    $name  timestamped $stamp"
  else
    echo "FAIL  $name"
    status=1
  fi
done
exit $status
