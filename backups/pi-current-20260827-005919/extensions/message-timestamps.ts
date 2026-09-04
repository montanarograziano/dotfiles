import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

type TimestampData = {
  role: "user" | "assistant";
  timestamp: number;
};

function formatTimestamp(timestamp: number): string {
  const date = new Date(timestamp);
  if (Number.isNaN(date.getTime())) return "unknown time";

  return new Intl.DateTimeFormat(undefined, {
    dateStyle: "medium",
    timeStyle: "medium",
  }).format(date);
}

export default function messageTimestamps(pi: ExtensionAPI) {
  pi.registerEntryRenderer<TimestampData>("message-timestamp", (entry, _options, theme) => {
    const data = entry.data;
    if (!data) return;

    const who = data.role === "user" ? "You" : "Pi";
    return new Text(theme.fg("dim", `  ${who} · ${formatTimestamp(data.timestamp)}`), 0, 0);
  });

  pi.on("message_end", async (event, ctx) => {
    if (ctx.mode !== "tui") return;
    if (event.message.role !== "user" && event.message.role !== "assistant") return;

    pi.appendEntry<TimestampData>("message-timestamp", {
      role: event.message.role,
      timestamp: event.message.timestamp,
    });
  });
}
