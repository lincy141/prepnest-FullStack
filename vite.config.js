import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";

// In production the AI interview scorer is the Vercel function in /api/ai-interview.js.
// This dev-only plugin serves that SAME file under `npm run dev`, so the AI Interview works
// locally without the Vercel CLI. It does not change api/ai-interview.js in any way.
function aiInterviewDevApi(env) {
  return {
    name: "prepnest-ai-interview-dev-api",
    apply: "serve",
    configureServer(server) {
      // Make XAI_API_KEY / XAI_MODEL from .env visible to the function, like Vercel env vars.
      for (const [key, value] of Object.entries(env)) {
        if (key.startsWith("XAI_") && process.env[key] === undefined) process.env[key] = value;
      }
      server.middlewares.use("/api/ai-interview", async (req, res) => {
        const send = (status, body) => {
          res.statusCode = status;
          res.setHeader("Content-Type", "application/json");
          res.end(JSON.stringify(body));
        };
        try {
          const chunks = [];
          for await (const chunk of req) chunks.push(chunk);
          const raw = Buffer.concat(chunks).toString("utf8");
          req.body = raw ? JSON.parse(raw) : {};
          res.status = (code) => { res.statusCode = code; return res; };
          res.json = (body) => send(res.statusCode || 200, body);
          const { default: handler } = await server.ssrLoadModule("/api/ai-interview.js");
          await handler(req, res);
        } catch (e) {
          console.error("ai-interview dev handler error:", e);
          if (!res.writableEnded) send(500, { error: e.message || "AI interview handler failed" });
        }
      });
    },
  };
}

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  return {
    plugins: [react(), aiInterviewDevApi(env)],
    server: { port: 5173, host: true },
  };
});
