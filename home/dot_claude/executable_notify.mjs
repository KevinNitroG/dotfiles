#!/usr/bin/env node
// Cross-platform notify hook for Claude Code (Stop / Notification / PermissionRequest).
// Usage: notify.mjs <stop|notification|permission>
import { execFile } from "node:child_process";

const EVENTS = {
  stop: { title: "Claude", body: "Task finished!", sound: true },
  notification: { title: "Claude", body: "Prompt waiting for your input!", sound: false },
  permission: { title: "Claude", body: "Permission requested", sound: true },
};

const event = EVENTS[process.argv[2]];
if (!event) process.exit(0);

function run(cmd, args) {
  execFile(cmd, args, () => {}); // best-effort; ignore missing binaries/errors
}

switch (process.platform) {
  case "darwin": {
    const script = `display notification ${JSON.stringify(event.body)} with title ${JSON.stringify(event.title)}`;
    run("osascript", ["-e", script]);
    if (event.sound) run("afplay", ["/System/Library/Sounds/Glass.aiff"]);
    break;
  }
  case "win32": {
    // Uses the WinRT toast API built into Windows 10/11 (no module install
    // required, unlike BurntToast). Silently no-ops on older Windows.
    const ps = `
      try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] > $null
        $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
        $text = $xml.GetElementsByTagName('text')
        $text.Item(0).AppendChild($xml.CreateTextNode('${event.title}')) > $null
        $text.Item(1).AppendChild($xml.CreateTextNode('${event.body}')) > $null
        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code').Show($toast)
      } catch {}
      ${event.sound ? "[console]::beep(600,150)" : ""}
    `;
    run("powershell", ["-NoProfile", "-NonInteractive", "-Command", ps]);
    break;
  }
  default: {
    // Linux and other freedesktop-compatible systems
    run("notify-send", [event.title, event.body, "--icon=dialog-information"]);
    if (event.sound) run("paplay", ["/usr/share/sounds/freedesktop/stereo/complete.oga"]);
    break;
  }
}
