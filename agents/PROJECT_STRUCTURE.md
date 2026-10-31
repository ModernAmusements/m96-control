# Project Structure — M96 Control

Repo map and build pipeline. Router: [`AGENTS.md`](../AGENTS.md) · Chronicle: [`context.md`](../context.md).

## File map

```
M96/
├── AGENTS.md                  # Router: task → agent pack → max. 2 context files
├── context.md                 # Session chronicle ("Changes This Prompt")
├── README.md                  # Project overview, hardware truth, shortcuts, build
├── index.html                 # Zero-dependency web preview (UI states + shortcut table)
├── src/
│   ├── main.swift             # SwiftUI + IOKit HID app (single file, @main)
│   └── Info.plist             # Bundle metadata (local.m96.control)
├── agents/                    # Reference docs (loaded by agent packs, max. 2 per task)
│   ├── HID_PROTOCOL.md        # Hardware-verified protocol facts + open questions
│   └── PROJECT_STRUCTURE.md   # This file
├── .opencode/agents/          # Agent packs (frontmatter: description, mode)
│   ├── swift-app-ag.md        # macOS app specialist
│   ├── web-preview-ag.md      # index.html specialist
│   ├── hid-re-ag.md           # HID reverse engineering specialist
│   └── release-ag.md          # Build / CI / release specialist
├── scripts/
│   └── build-app.sh           # swiftc → M96 Control.app → ad-hoc codesign
└── .github/workflows/
    └── ci.yml                 # Build on push + PR, release asset on tag
```

`M96 Control.app/` is a **build artifact** (git-ignored). Never edit it directly.

## Build pipeline

```
src/main.swift + src/Info.plist
        │  swiftc -O -parse-as-library -target arm64-apple-macosx14.0
        ▼
M96 Control.app/Contents/MacOS/M96Control
        │  codesign --force --sign -
        ▼
M96 Control.app  (arm64, ad-hoc signed)
```

- Local gate: `bash scripts/build-app.sh` + `codesign --verify --deep "M96 Control.app"`.
- CI: `.github/workflows/ci.yml` runs the same script on a macOS runner (push + PR),
  uploads the app artifact, and on `v*` tags creates a release with `M96-Control-macOS.zip`.
- Requires: Xcode command-line tools (swiftc ≥ 6), macOS 14+ target (`-parse-as-library`,
  `onChange(of:initial:_:)` is macOS 14+; `src/Info.plist` `LSMinimumSystemVersion` 14.0).

## Conventions

- App code: English, SwiftUI + IOKit, everything in `src/main.swift` until a second file
  earns its place.
- Protocol facts: only in `agents/HID_PROTOCOL.md`, hardware-verified, experiment-logged.
- Docs: English, real characters, no emoji in UI/docs beyond the rare status marker.
- Commits: one per task, small messages; push collected with user approval.
