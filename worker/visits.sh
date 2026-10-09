#!/bin/bash
# Show the most recent site visits. Usage: ./worker/visits.sh [number of rows, default 25]
set -euo pipefail

limit="${1:-100}"
if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
  echo "Usage: $0 [number of rows]" >&2
  exit 1
fi

cd "$(dirname "$0")"

echo "Fetching the last $limit visits..." >&2

# --yes and </dev/null keep npx and wrangler from waiting on a prompt that the pipe would hide.
npx --yes wrangler d1 execute visitor-log --remote --json --command \
  "SELECT time, org, city, region, country, path, referrer, ip FROM visits ORDER BY time DESC LIMIT $limit" </dev/null |
  node -e '
    const rows = JSON.parse(require("fs").readFileSync(0, "utf8"))[0].results;
    if (!rows.length) { console.log("No visits yet."); process.exit(0); }
    console.table(rows.map((r) => ({
      when: new Date(r.time).toLocaleString(),
      org: r.org,
      location: [r.city, r.region, r.country].filter(Boolean).join(", "),
      path: r.path,
      referrer: r.referrer ?? "",
      ip: r.ip,
    })));
  '
