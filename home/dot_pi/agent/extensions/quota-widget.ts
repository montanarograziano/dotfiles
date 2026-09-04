import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";

const AUTH_PATH = `${homedir()}/.pi/agent/auth.json`;
const REFRESH_MS = 60_000;
let lastFetch = 0;
let cached: string | undefined;

function auth(provider: string): any {
  try {
    return JSON.parse(readFileSync(AUTH_PATH, "utf8"))[provider];
  } catch {
    return undefined;
  }
}

function percent(value: unknown): number {
  const n = Number(value);
  return Math.max(0, Math.min(100, n <= 1 ? n * 100 : n));
}

function compact(label: string, used: number, reset?: string): string {
  const left = Math.round(100 - used);
  const suffix = reset ? ` ↻ ${new Date(reset).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}` : "";
  return `${label} ${left}%${suffix}`;
}

async function json(url: string, init: RequestInit): Promise<any | undefined> {
  const response = await fetch(url, init);
  if (!response.ok) return undefined;
  return response.json();
}

async function fetchUsage(provider: string): Promise<string | undefined> {
  if (provider === "anthropic") {
    const entry = auth("anthropic");
    const token = entry?.type === "oauth" ? entry.access : process.env.ANTHROPIC_API_KEY;
    if (!token) return undefined;
    const data = await json("https://api.anthropic.com/api/oauth/usage", {
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: "application/json",
        "Content-Type": "application/json",
        "anthropic-beta": "oauth-2025-04-20",
      },
    });
    if (!data) return undefined;
    const parts = [];
    if (data.five_hour) parts.push(compact("Claude 5h", percent(data.five_hour.utilization), data.five_hour.resets_at));
    if (data.seven_day) parts.push(compact("week", percent(data.seven_day.utilization), data.seven_day.resets_at));
    return parts.length ? `◷ ${parts.join("  ·  ")}` : undefined;
  }

  if (provider === "openai-codex") {
    const entry = auth("openai-codex");
    let token = entry?.access;
    if (!token) return undefined;
    const headers = {
      Authorization: `Bearer ${token}`,
      Accept: "application/json",
      "User-Agent": "codex-cli",
      ...(entry.accountId ? { "ChatGPT-Account-Id": entry.accountId } : {}),
    };
    let data = await json("https://chatgpt.com/backend-api/wham/usage", { headers });
    if (!data && entry.refresh) {
      const refreshed = await json("https://auth.openai.com/oauth/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({
          grant_type: "refresh_token",
          refresh_token: entry.refresh,
          client_id: "app_EMoamEEZ73f0CkXaXp7hrann",
        }),
      });
      token = refreshed?.access_token;
      if (token) data = await json("https://chatgpt.com/backend-api/wham/usage", {
        headers: { ...headers, Authorization: `Bearer ${token}` },
      });
    }
    if (!data) return undefined;
    const primary = data.rate_limit?.primary_window;
    const secondary = data.rate_limit?.secondary_window;
    if (!primary && !secondary) return undefined;
    const parts = [];
    if (primary) parts.push(compact("Codex 5h", Number(primary.used_percent), primary.reset_at ? new Date(Number(primary.reset_at) * 1000).toISOString() : undefined));
    if (secondary) parts.push(compact("week", Number(secondary.used_percent)));
    return parts.length ? `◷ ${parts.join("  ·  ")}` : undefined;
  }

  return undefined;
}

export default function quotaWidget(pi: ExtensionAPI) {
  async function refresh(ctx: ExtensionContext): Promise<void> {
    if (Date.now() - lastFetch < REFRESH_MS) return;
    lastFetch = Date.now();
    try {
      cached = await fetchUsage(ctx.model?.provider ?? "");
      ctx.ui.setStatus("account-usage", cached ? ctx.ui.theme.fg("muted", cached) : undefined);
    } catch {
      // Quota endpoints are optional; keep the footer quiet when unavailable.
    }
  }

  pi.on("session_start", async (_event, ctx) => refresh(ctx));
  pi.on("turn_end", async (_event, ctx) => refresh(ctx));
}
