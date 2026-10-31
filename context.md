# Project Context — M96 Backlight Control

> **Session start:** `AGENTS.md` is the router: task → agent pack + max. 2 context files.
> This file is the chronicle, **not** the entry point — grep it deliberately, never preload.
> **Convention:** after every session, add a "Changes This Prompt" note at the top.

---

## 31. Oktober 2026 (2) — VS Code theme: neon green status bar

### Changes This Prompt

- **Workspace theme (this window only):** `.vscode/settings.json` — status bar neon green
  (`#39FF14`, black foreground, darker green border) + light tint (`#C9FFB8`) for hover and
  debugging states. Scoped to this workspace so other VS Code windows stay untouched.
- No code or agent changes.

### Session end — 31.10.2026

- Committed; see `main` for state.

---

## 31. Oktober 2026 — Project foundation, agent packs, README, GitHub (initial deploy)

### Changes This Prompt

- **Repo established:** M96 was a loose folder (`src/main.swift`, `src/Info.plist`,
  `index.html`, built `M96 Control.app`) — now a git repo with structure, docs, agents, CI.
- **Agents created** (mirroring the Bielefeld_Scrape / Google-Review-Pilot pattern):
  - `AGENTS.md` → router: task → agent pack → max. 2 context files, hard invariants.
  - `.opencode/agents/`: `swift-app-ag.md`, `web-preview-ag.md`, `hid-re-ag.md`, `release-ag.md`.
  - `agents/HID_PROTOCOL.md` — all known protocol facts (vendor 0x32C2, product 0x6621,
    output report 2 single byte: 0x00 off, 0xFF full, 0x02 caps probe) + open questions.
  - `agents/PROJECT_STRUCTURE.md` — file map and build pipeline.
- **Build script:** `scripts/build-app.sh` — `swiftc -O` (arm64, macOS 13 target) → app
  bundle → ad-hoc codesign. Replaces the manually built bundle; `M96 Control.app` is now
  git-ignored as a build artifact.
- **CI:** `.github/workflows/ci.yml` — macOS runner builds on every push, uploads the app
  as an artifact; tags get a release with a zipped app.
- **README:** covers hardware truth (fixed rainbow LEDs, no software lighting interface
  beyond report 2), hardware shortcuts, build/usage for app and web preview.
- **GitHub:** repo `ModernAmusements/m96-control` (public — user decision 31.10.2026, so the
  macOS CI runner is free; no secrets in the repo), branch `main`, pushed.

### Known hardware facts (status quo)

- M96BT2 exposes one output report (ID 2, 1 byte). App sends brightness as
  `UInt8(brightness * 255)`, pulse test `255 → 0 → 204`, caps LED probe `0x02`.
- LED layer is fixed rainbow — no color control, red not available. HTML preview says so.
- Hardware-only: `Fn + Del` power/mode, `Fn + ↑/↓` brightness, `Fn + ←/→` speed,
  knob volume, hold knob 5 s mode, `Fn + Tab` Win/Mac, `Esc + Q` pairing.

### Open questions (parked in `agents/HID_PROTOCOL.md`)

- Input reports (keystrokes, battery level) — unobserved.
- Whether report 2 byte values above/below the observed range map to modes.
- Any additional output report IDs beyond 2.

### Session end — 31.10.2026

- Repo live at `github.com/ModernAmusements/m96-control` (public — keeps macOS CI free; the
  repo contains only source, docs and workflows, no secrets), `main` = origin/main.
- Local tree clean; `M96 Control.app` untracked by design (artifact).
- Build verified locally: script produces arm64 bundle, ad-hoc signature ok.
- Next: observe hardware responses and grow `agents/HID_PROTOCOL.md` with device-verified facts only.
