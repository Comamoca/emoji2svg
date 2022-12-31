import { Application, Router } from 'https://deno.land/x/oak/mod.ts'
import 	{ parse } from "npm:twemoji-parser"

function emoji2Url(emoji: string): string {
	const entities = parse(emoji)
	return entities[0].url
}

const app = new Application();
const router = new Router()

router.get("/", async (ctx) => {
	const htmlUrl = new URL("index.html", import.meta.url).toString();
	const res = await fetch(htmlUrl)
	ctx.response.body = res.body
})

router.get("/api/:emoji", async (ctx) => {
	console.log(emoji2Url(ctx.params.emoji))
	const response = await fetch(emoji2Url(ctx.params.emoji))
	ctx.response.headers.set('Content-Type', 'image/svg+xml')
	// ctx.response.headers.set('Content-Type', 'text')
	const svg = await response.text()
	ctx.response.body = svg
})

app.use(router.routes());
app.use(router.allowedMethods())

await app.listen({ port: 8000 });
