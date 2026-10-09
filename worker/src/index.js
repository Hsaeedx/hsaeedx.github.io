// Logs page views to D1, then passes the request through to GitHub Pages.

const BOT_UA = /bot|crawl|spider|slurp|preview|monitor|uptime|headless|curl|wget|python|go-http|scrapy|facebookexternalhit/i;

export default {
  async fetch(request, env, ctx) {
    if (isPageView(request)) {
      ctx.waitUntil(logVisit(request, env));
    }
    return fetch(request);
  },
};

// Only count real page loads, not images/CSS/favicon requests or crawlers.
function isPageView(request) {
  if (request.method !== "GET") return false;
  if (!(request.headers.get("Accept") || "").includes("text/html")) return false;
  return !BOT_UA.test(request.headers.get("User-Agent") || "");
}

async function logVisit(request, env) {
  try {
    const url = new URL(request.url);
    const cf = request.cf || {};
    await env.DB.prepare(
      `INSERT INTO visits (time, ip, org, asn, city, region, country, path, referrer, ua)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    )
      .bind(
        new Date().toISOString(),
        request.headers.get("CF-Connecting-IP"),
        cf.asOrganization ?? null,
        cf.asn ?? null,
        cf.city ?? null,
        cf.region ?? null,
        cf.country ?? null,
        url.pathname + url.search,
        request.headers.get("Referer"),
        request.headers.get("User-Agent")
      )
      .run();
  } catch (err) {
    // Never let a logging failure affect the site itself.
    console.error("visit log failed", err);
  }
}
