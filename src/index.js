import { main } from "./emoji2svg.mjs";

export default {
  async fetch(req, env, ctx) {
    return await main()(req, ctx);
  },
};
