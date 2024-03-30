import { Hono } from "hono";
import twemoji from "twemoji";
import { DOMParser } from "domparser";
import { serveStatic } from "middleware";

function emoji2Url(emoji: string): string {
  const html = twemoji.parse(emoji, {
    folder: "svg",
    ext: ".svg",
    base: "https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/",
  });

  const docment = new DOMParser().parseFromString(html, "text/html");
  const url = docment?.querySelector("img")?.getAttribute("src");

  if (url == null) {
    return "";
  }

  return url;
}

const app = new Hono();

app.use("/", serveStatic({ path: "./index.html" }));

app.get("/api/:emoji", async (ctx) => {
  const emoji = ctx.req.param("emoji");

  const response = await fetch(emoji2Url(emoji));
  ctx.header("Content-Type", "image/svg+xml");
  const svg = await response.text();

  return ctx.body(svg);
});

Deno.serve({ port: 8000 }, app.fetch);
