import OpenAI from "openai";

// xAI's Grok API is OpenAI-compatible — same SDK, different base URL + key.
const client = new OpenAI({
  apiKey: process.env.XAI_API_KEY,
  baseURL: "https://api.x.ai/v1",
});

// Check https://docs.x.ai for the current model lineup — override via the
// XAI_MODEL env var without touching this file if xAI renames/retires a model.
const MODEL = process.env.XAI_MODEL || "grok-4-fast-non-reasoning";

const CATEGORY_KEYS = [
  "Communication",
  "Confidence",
  "Technical Knowledge",
  "Relevance",
  "Answer Quality",
  "Problem Solving",
  "Clarity",
];

export default async function handler(req, res) {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  if (!process.env.XAI_API_KEY) {
    res.status(500).json({ error: "XAI_API_KEY is not set on the server. Add it in your Vercel project's Environment Variables." });
    return;
  }

  try {
    const { type, role, difficulty, duration, qa } = req.body || {};

    if (!Array.isArray(qa) || qa.length === 0) {
      res.status(400).json({ error: "qa (an array of {question, answer}) is required" });
      return;
    }

    const transcript = qa
      .map((item, i) => `Q${i + 1}: ${item.question}\nA${i + 1}: ${item.answer?.trim() ? item.answer : "(no answer given)"}`)
      .join("\n\n");

    const systemPrompt = `You are an experienced campus placement interview evaluator. You are scoring a candidate's performance in a "${type || "General"}" interview for the role of "${role || "Software Developer"}" at "${difficulty || "Intermediate"}" difficulty.

Return ONLY a JSON object with exactly this shape, no extra commentary:
{
  "overall": <integer 0-100>,
  "categories": {
    "Communication": <integer 0-100>,
    "Confidence": <integer 0-100>,
    "Technical Knowledge": <integer 0-100>,
    "Relevance": <integer 0-100>,
    "Answer Quality": <integer 0-100>,
    "Problem Solving": <integer 0-100>,
    "Clarity": <integer 0-100>
  },
  "strengths": ["<short specific point>", "<short specific point>", "<short specific point>"],
  "improve": ["<short specific point>", "<short specific point>", "<short specific point>"]
}

Score only from what the candidate actually said. Missing or very short answers should pull the relevant category scores down. Keep "strengths" and "improve" to 2-4 short, specific bullet points each, grounded in the actual transcript — not generic advice.`;

    const completion = await client.chat.completions.create({
      model: MODEL,
      temperature: 0.4,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: transcript },
      ],
    });

    const raw = completion.choices?.[0]?.message?.content || "{}";
    let parsed;
    try {
      parsed = JSON.parse(raw);
    } catch {
      res.status(502).json({ error: "The model returned a response that wasn't valid JSON.", raw });
      return;
    }

    // Light validation so the frontend never crashes on a malformed model response.
    const categories = {};
    for (const key of CATEGORY_KEYS) {
      const v = Number(parsed?.categories?.[key]);
      categories[key] = Number.isFinite(v) ? Math.max(0, Math.min(100, Math.round(v))) : 65;
    }
    const overall = Number.isFinite(Number(parsed?.overall)) ? Math.max(0, Math.min(100, Math.round(Number(parsed.overall)))) : Math.round(Object.values(categories).reduce((a, b) => a + b, 0) / CATEGORY_KEYS.length);

    res.status(200).json({
      overall,
      categories,
      strengths: Array.isArray(parsed?.strengths) && parsed.strengths.length ? parsed.strengths.slice(0, 5) : ["Answered every question"],
      improve: Array.isArray(parsed?.improve) && parsed.improve.length ? parsed.improve.slice(0, 5) : ["Add more specific examples to your answers"],
    });
  } catch (err) {
    console.error("ai-interview error:", err);
    res.status(500).json({ error: err.message || "Something went wrong while contacting the AI evaluator." });
  }
}
