# UptimeRobots

A Flutter desktop/mobile app that aggregates monitors across **multiple UptimeRobot accounts** into one dashboard. Built for freelancers and agencies who manage uptime monitoring for several clients, each with their own UptimeRobot account, and want a single place to watch all of them.

## What it does

- **Multi-account dashboard** — add any number of UptimeRobot accounts (via their API key), see every monitor across all of them in one filterable list.
- **Local notifications** — get notified on your device when a monitor goes down or recovers. One account's bad API key or a network blip never blocks the others from syncing.
- **SSL certificate monitoring** — checks certificate expiry directly against each HTTPS monitor's host, independent of UptimeRobot's plan tier (their SSL monitoring is a paid-plan feature; this isn't).
- **Response-time & status history** — charts and a status timeline per monitor, backed by a local cache so the dashboard works offline.
- **Background + foreground sync** — a foreground timer keeps the dashboard live while the app is open; a background task (Android/iOS/macOS/Linux) keeps it fresh when it isn't.
- **Per-monitor mute**, **account export/import** (JSON via clipboard), and **light/dark/system theme**.

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel).

```bash
flutter pub get
dart run build_runner build   # generates the drift database code
flutter run                   # pick a connected device, or -d linux / -d chrome / etc.
```

You'll need an UptimeRobot API key to add an account — find yours under **My Settings → API Settings** in your UptimeRobot dashboard. The app stores keys in OS-level secure storage (Keychain/Keystore/libsecret), never in plain text.

### Linux system dependency

Building for Linux desktop needs `libsecret` (used by secure storage) and the GTK dev headers:

```bash
sudo apt install libsecret-1-dev libgtk-3-dev clang cmake ninja-build pkg-config
```

## Architecture

```
lib/
├── models/        Plain data classes (Account, Monitor, ...)
├── services/       UptimeRobot API client, drift database, notifications,
│                    background/foreground sync schedulers, SSL checker
├── providers/       Riverpod state (accounts, monitors, settings)
├── screens/         Dashboard, Accounts, Monitor detail, Settings
├── widgets/          Shared UI (monitor row, accent-bordered panels)
├── theme/           App theme, status colors, typography
└── database/        Drift schema + generated code
```

- **State**: Riverpod. Repositories are injected via providers, swapped for fakes in widget tests (no real secure storage, database, or network in tests).
- **Cache**: drift (SQLite) is the source of truth for the UI — the dashboard reads from the local cache and updates live via a stream query; syncing just writes into that cache.
- **Rate limiting**: one limiter per API key, shared across sync passes, with exponential backoff on HTTP 429.

## Building a Linux `.deb` package

`flutter build linux` only produces a bare folder — no installer, no desktop entry, no icon integration. [`packaging/linux/build-deb.sh`](packaging/linux/build-deb.sh) wraps that into a proper Debian package:

```bash
./packaging/linux/build-deb.sh
```

This produces `dist/uptimerobots-app_<version>_amd64.deb`, which installs the app to `/usr/lib/uptimerobots-app/`, symlinks the binary into `/usr/bin/`, and installs the `.desktop` entry + icon so it shows up in your app launcher with the right name and icon. Install it with:

```bash
sudo dpkg -i dist/uptimerobots-app_1.0.0_amd64.deb
```

## Testing

```bash
flutter analyze
flutter test
```

## License

Bundled fonts (IBM Plex Sans, IBM Plex Mono) are from [IBM's Plex repo](https://github.com/IBM/plex), licensed under the SIL Open Font License 1.1 — see [`assets/fonts/OFL-LICENSE.txt`](assets/fonts/OFL-LICENSE.txt).
