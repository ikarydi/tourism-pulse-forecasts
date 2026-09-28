# Tourism Pulse forecasts

Monthly forecasts of nights spent at tourist accommodation in EU countries
and regions, published here **before** Eurostat releases the months they
forecast. Nothing in this repository is ever edited: each batch adds a new
folder, so anyone can later score the forecasts against the official figures.

## What is here

| Path | Contents |
|---|---|
| `batches/<published-at>/forecasts.csv` | Every forecast issued since the previous batch |
| `batches/<published-at>/forecasts.csv.sha256` | SHA-256 of that file |
| `batches/<published-at>/forecasts.csv.tsr` | An RFC 3161 timestamp token for that hash, signed by [freetsa.org](https://freetsa.org) |
| `manifest.csv` | One row per batch: when it was published, when its forecasts were issued, how many, and the hash |
| `tsa/` | freetsa.org's certificates, also downloadable from [freetsa.org/files](https://freetsa.org/files/) |
| `verify.sh` | Checks every batch's hash and timestamp token |

A new batch appears when a new official month is published and the forecasts
roll forward. Forecasts already published are never revised.

## Checking that a forecast came first

Git commit dates are set by whoever commits, so they prove nothing. The
timestamp token does: an independent authority signed the file's SHA-256 at
the time shown in the token, so the file existed then, unchanged.

```bash
./verify.sh
```

or for one batch, with OpenSSL:

```bash
cd batches/<published-at>
sha256sum -c forecasts.csv.sha256
openssl ts -reply -in forecasts.csv.tsr -text | grep "Time stamp"
openssl ts -verify -data forecasts.csv -in forecasts.csv.tsr \
  -CAfile ../../tsa/cacert.pem -untrusted ../../tsa/tsa.crt
```

Then compare the token's time with the date Eurostat published the target
month (dataset `tour_occ_nim` for countries, `tour_occ_nin2m` for regions).

## Columns of `forecasts.csv`

| Column | Meaning |
|---|---|
| `place_id`, `place`, `place_type` | The place: `country`, `region` (NUTS 2) or `destination` |
| `code` | Eurostat geo code (NUTS 0 for countries, e.g. `EL` for Greece; NUTS 2 for regions) |
| `series` | `tourism_nights`: nights spent at hotels, holiday and other short-stay accommodation and campsites (NACE I55.1-I55.3), all residents |
| `validated` | `yes` if the model passed a pre-registered backtest at this level (countries only); `no` otherwise |
| `model` | Which model produced the forecast (see below) |
| `issued_at` | When the forecast was computed (UTC) |
| `origin` | The last month with an official figure when the forecast was made |
| `target` | The month forecast |
| `horizon` | Months from origin to target (1-12) |
| `forecast` | Point forecast, in nights |
| `low_80`, `high_80`, `low_95`, `high_95` | 80% and 95% ranges, in nights |

## The forecasts

**Countries (`validated = yes`).** Model `POOL_GR_WG`: one regression per
horizon, pooled across countries, of year-on-year growth in nights on recent
growth in nights plus growth in Wikipedia views of the country's articles and
in its share of tourism news coverage (GDELT), and the change in that
coverage's tone. The ranges are quantiles of the model's residuals. A
country missing an attention series falls back to the same model without it
(`POOL_GR_W`, then `POOL_GR`).

In a pre-registered backtest on 30 countries, with July 2025 to June 2026
held out and run once, this model beat last year's figure in 20 of 30
countries (mean absolute percentage error 4.96% against 5.35%), and its 80%
ranges covered 81% of outcomes. Wikipedia and GDELT improved it in 26 of 30
countries, with the gain 4-12 months ahead. It did **not** meet the
pre-registered bar of beating last year's figure by 10% in most countries,
so these forecasts are an outlook with ranges, not a claim to beat last
year's value. This record is the real test.

**Regions and destinations (`validated = no`).** The same method on nights
alone (`POOL_GR`). Regional monthly series start in 2020, too short for a
clean backtest, so these have no validation yet.

## Notes on the first batch

The first batch's forecasts were issued on 27 September 2026 and published
here on 28 September 2026. At that point Eurostat's latest national figures
were for June 2026 (dataset last updated 22 September 2026), and every
country forecast in the batch targets July 2026 or later.

## Sources

Built from [Eurostat](https://ec.europa.eu/eurostat) tourism statistics,
[Wikimedia pageviews](https://wikitech.wikimedia.org/wiki/Analytics/AQS/Pageviews)
and the [GDELT Project](https://www.gdeltproject.org/). Forecasts are produced
by Tourism Pulse.
