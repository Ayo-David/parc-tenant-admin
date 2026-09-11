import pino, { type Logger } from "pino";
import type { AppConfig } from "../config/env.js";

export function createLogger(config: AppConfig): Logger {
  return pino({
    level: config.LOG_LEVEL,
    base: { service: config.SERVICE_NAME, version: config.SERVICE_VERSION },
    redact: {
      paths: [
        "req.headers.authorization",
        "req.headers.cookie",
        "req.body.password",
        "req.body.otp",
        "req.body.token",
        "req.body.secret",
        "req.body.api_key",
        "req.body.credentials",
        "res.headers.set-cookie",
      ],
      censor: "[REDACTED]",
    },
  });
}
