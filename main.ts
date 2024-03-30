import { Application, Router } from "oak";
import twemoji from "npm:@twemoji/api";
import { DOMParser } from "https://deno.land/x/deno_dom/deno-dom-wasm.ts";

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

const app = new Application();
const router = new Router();

router.get("/", async (ctx) => {
  const htmlUrl = new URL("index.html", import.meta.url).toString();
  const res = await fetch(htmlUrl);
  ctx.response.body = res.body;
});

router.get("/api/:emoji", async (ctx) => {
  const emoji = ctx.params.emoji;

  const response = await fetch(emoji2Url(emoji));
  ctx.response.headers.set("Content-Type", "image/svg+xml");
  const svg = await response.text();

  ctx.response.body = svg;
});

app.use(router.routes());
app.use(router.allowedMethods());

await app.listen({ port: 8000 });
