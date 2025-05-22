import * as functions from "firebase-functions";
import express, {Request, Response} from "express";
import cors from "cors";
import {default as rateLimit} from "express-rate-limit";

// Constants
const MAX_URL_LENGTH = 2048;
const ALLOWED_HOSTS = new Set([
  "books.google.com",
  "covers.openlibrary.org",
]);

const app = express();

// Middleware: CORS + Rate Limit + IP Trust
app.use(cors({origin: true}));
app.set("trust proxy", 1); 

app.use(rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 60, // limit each IP to 60 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  handler: (_req, res) => res.status(429).send("Too many requests. Try again later."),
}));

// Main Proxy Route
app.get("*", async (req: Request, res: Response) => {
  const rawUrl = Array.isArray(req.query.url) ? req.query.url[0] : req.query.url;

  if (typeof rawUrl !== "string") {
    res.status(400).send("Missing or invalid `url` parameter.");
    return;
  }

  if (rawUrl.length > MAX_URL_LENGTH) {
    res.status(414).send("URL too long.");
    return;
  }

  let parsedUrl: URL;
  try {
    parsedUrl = new URL(rawUrl);
  } catch {
    res.status(400).send("Malformed URL.");
    return;
  }

  if (!["http:", "https:"].includes(parsedUrl.protocol)) {
    res.status(400).send("Unsupported protocol.");
    return;
  }

  if (!ALLOWED_HOSTS.has(parsedUrl.host)) {
    res.status(403).send("Host not allowed.");
    return;
  }

  try {
    const response = await fetch(parsedUrl.toString(), {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
          "(KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36",
      },
    });

    if (!response.ok) {
      res.status(response.status).send(response.statusText);
      return;
    }

    const contentType = response.headers.get("content-type") || "application/octet-stream";
    res.setHeader("Content-Type", contentType);
    res.setHeader("Cache-Control", "public, max-age=3600");

    const arrayBuffer = await response.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    res.send(buffer); // ✅ No return
  } catch {
    res.status(502).send("Upstream fetch failed. {error}");
  }
});

// Export the function to Firebase
export const imageProxy = functions.https.onRequest(app);
