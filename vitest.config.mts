import { cloudflareTest } from "@cloudflare/vitest-pool-workers";
import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [
    cloudflareTest({
      // Load the Gleam-built worker as the main worker so tests
      // run in the same isolate and can mock globalThis.fetch
      main: "./build/dev/javascript/emoji2svg/index.js",
      miniflare: {
        compatibilityDate: "2023-09-22",
      },
    }),
  ],
  test: {
    globalSetup: ["./global-setup.ts"],
    include: ["vitest-test/integration.test.ts"],
  },
  server: {
    watch: {
      // Exclude nix/direnv source trees and build artifacts from the
      // file watcher to avoid hitting the OS inotify limit
      ignored: ["**/.direnv/**", "**/node_modules/**", "**/build/**"],
    },
  },
});
