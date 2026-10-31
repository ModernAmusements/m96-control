# M96 — Agent Router

> This file only decides **which agent and context files** load for a task.
> Task rules live in the packs under `.opencode/agents/`. Don't duplicate them here.

## 1. Session start (3 steps)

1. **Clarify the task.** If unclear: ask, don't guess.
2. **Route** via the table in section 3. Load only the named agent and its
   **max. 2 context files**.
3. **State check:** `git status --short` + `git log --oneline -3` — know where the repo stands
   before touching anything.

**Don't preload:** `context.md`, `agents/**` — only what the task needs. A task that needs
multiple packs is too big; split it.

## 2. Hard invariants (always apply)

- **The user is right.** If they say something doesn't work, it doesn't. Ask what they see;
  don't argue from theory.
- **Verify instead of claiming.** Nothing is "done" unless it was checked: a build
  (`bash scripts/build-app.sh`), a browser check of `index.html`, or a device test.
- **Never invent HID reports.** `agents/HID_PROTOCOL.md` values come from hardware
  observation only. Unknowns stay "unknown" with a question, not a guess.
- **One commit per task.** Small, clear message. Push is collected and done with user approval.
- **No auto-deploy.** GitHub pushes and releases only after explicit go-ahead.
- **Don't loop.** If you're going in circles or stuck: stop, ask.
- **The `.app` bundle is generated** — never edit it; change `src/` and rebuild.

## 3. Router

| Task | Agent | Context (max. 2 files) |
|---|---|---|
| macOS app — SwiftUI, IOKit, HID send/receive | `.opencode/agents/swift-app-ag.md` | `agents/HID_PROTOCOL.md` · `agents/PROJECT_STRUCTURE.md` |
| Web preview — `index.html` UI/behavior | `.opencode/agents/web-preview-ag.md` | `agents/HID_PROTOCOL.md` |
| HID reverse engineering — protocol facts, unknown reports | `.opencode/agents/hid-re-ag.md` | `agents/HID_PROTOCOL.md` |
| Build, release, GitHub Actions, tags | `.opencode/agents/release-ag.md` | `agents/PROJECT_STRUCTURE.md` |
| README, docs, agent packs, structure | `general` | `agents/PROJECT_STRUCTURE.md` |

**Router rules:**

- A pack names **max. 2** context files. Needs more → the task is too big.
- The agent reads its context files **itself** — not the main context.
- No pack fits? Use `general` + `agents/PROJECT_STRUCTURE.md`, then adapt.

## 4. Build & release

- Build gate: `bash scripts/build-app.sh` — must exit 0 and produce `M96 Control.app`
  (arm64, ad-hoc signed) before anything is called done.
- CI (`.github/workflows/ci.yml`) builds on every push and attaches a release asset on tags.
- No sleeps/polling loops; run the build once and read the result.
- Push only with user approval — commits are local until then.
