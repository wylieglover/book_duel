"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.imageProxy = void 0;
const functions = __importStar(require("firebase-functions"));
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
// Constants
const MAX_URL_LENGTH = 2048;
const ALLOWED_HOSTS = new Set([
    "books.google.com",
    "covers.openlibrary.org",
]);
const app = (0, express_1.default)();
// Middleware: CORS + Rate Limit + IP Trust
app.use((0, cors_1.default)({ origin: true }));
app.set("trust proxy", 1);
app.use((0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 60, // limit each IP to 60 requests per window
    standardHeaders: true,
    legacyHeaders: false,
    handler: (_req, res) => res.status(429).send("Too many requests. Try again later."),
}));
// Main Proxy Route
app.get("*", async (req, res) => {
    const rawUrl = Array.isArray(req.query.url) ? req.query.url[0] : req.query.url;
    if (typeof rawUrl !== "string") {
        res.status(400).send("Missing or invalid `url` parameter.");
        return;
    }
    if (rawUrl.length > MAX_URL_LENGTH) {
        res.status(414).send("URL too long.");
        return;
    }
    let parsedUrl;
    try {
        parsedUrl = new URL(rawUrl);
    }
    catch (_a) {
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
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 " +
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
    }
    catch (_b) {
        res.status(502).send("Upstream fetch failed. {error}");
    }
});
// Export the function to Firebase
exports.imageProxy = functions.https.onRequest(app);
