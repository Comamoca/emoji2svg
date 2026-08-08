import { exports } from "cloudflare:workers";
import { afterEach, it, vi } from "vitest";

const TWEMOJI_URL =
  "https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/svg/1f363.svg";

afterEach(() => {
  vi.restoreAllMocks();
});

it("returns SVG for a valid emoji", async ({ expect }) => {
  // Mock the outbound fetch to the twemoji CDN (workerd cannot
  // verify the TLS certificate of external hosts in tests)
  vi.spyOn(globalThis, "fetch").mockImplementation(async (input, init) => {
    const request = new Request(input, init);
    const url = new URL(request.url);

    if (request.method === "GET" && url.href === TWEMOJI_URL) {
      return new Response('<svg xmlns="http://www.w3.org/2000/svg"></svg>', {
        headers: { "content-type": "image/svg+xml" },
      });
    }

    throw new Error(`No mock found for ${request.url}`);
  });

  const response = await exports.default.fetch(
    "http://example.com/api/%F0%9F%8D%A3",
  );
  expect(response.status).toBe(200);
  expect(response.headers.get("content-type")).toBe("image/svg+xml");
  expect(await response.text()).toContain("<svg");
});

it("returns 500 when the twemoji CDN fetch fails", async ({ expect }) => {
  vi.spyOn(globalThis, "fetch").mockImplementation(async () => {
    throw new Error("network error");
  });

  const response = await exports.default.fetch(
    "http://example.com/api/%F0%9F%8D%A3",
  );
  expect(response.status).toBe(500);
  expect(await response.text()).toBe("Error");
});

it("returns 404 for unknown routes", async ({ expect }) => {
  const response = await exports.default.fetch("http://example.com/");
  expect(response.status).toBe(404);
  expect(await response.text()).toBe("not found");
});
