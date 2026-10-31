# M96 — Backlight Control

macOS control app + interactive web preview for the **M96BT2** Bluetooth mechanical keyboard.

The M96BT2 exposes exactly **one** HID output report (report ID 2, single byte) and ships with a
**fixed rainbow LED layer**. This project controls what the firmware actually lets us control
(power, brightness via that byte), documents everything we know about the protocol, and previews
the keyboard states that are only reachable through hardware shortcuts.

## What's in this repo

| Path | What it is |
|---|---|
| `src/main.swift` | macOS SwiftUI app — connects to the M96BT2 over IOKit HID and sends report 2 |
| `src/Info.plist` | App bundle metadata (`local.m96.control`) |
| `index.html` | Zero-dependency web preview of the backlight UI + hardware shortcut reference |
| `scripts/build-app.sh` | Reproducible build: `swiftc` → `M96 Control.app` → ad-hoc codesign |
| `.opencode/agents/` | Agent packs (see [AGENTS.md](AGENTS.md)) |
| `agents/` | Reference docs: HID protocol, project structure |
| `.github/workflows/ci.yml` | CI build on every push, release artifact on tags (macOS runner — public repo keeps it free) |

## The hardware truth

The M96 has **no software lighting interface** beyond a single-byte output report.
If the backlight doesn't change when the app sends values, that is expected — the LED layer
is fixed rainbow and color/effects are only reachable via the keyboard shortcuts below.
**Red is not available on this board.** The HTML preview reflects this honestly.

### HID interface (known)

- Vendor `0x32C2` · Product `0x6621` · Device name `M96BT2`
- Output report **2**, payload **1 byte**
  - `0x00` — backlight off
  - `0x01 … 0xFE` — brightness scale (UI sends `UInt8(brightness * 255)`)
  - `0xFF` — full on
  - `0x02` — caps LED probe
- Full notes + open questions: [`agents/HID_PROTOCOL.md`](agents/HID_PROTOCOL.md)

### Hardware shortcuts

| Function | Shortcut |
|---|---|
| Power / mode | `Fn + Del` |
| Brightness | `Fn + ↑ / ↓` |
| Effect speed | `Fn + ← / →` |
| Volume | Turn the knob |
| Backlight mode | Hold the knob 5 s |
| Windows / Mac mode | `Fn + Tab` |
| Bluetooth pairing | `Esc + Q` (hold 3–5 s) |

## macOS app

The app scans IOKit for the M96BT2, opens it, and sends output report 2 from a small
control surface (toggle, brightness slider, pulse test, caps LED probe, rescan).

### Build

```bash
bash scripts/build-app.sh
open "M96 Control.app"
```

Requires Xcode command-line tools (`swiftc`) on macOS 14+ (the app uses the macOS 14
`onChange(of:initial:_:)` API). Output: `M96 Control.app` (arm64, ad-hoc signed).
The bundle is a build artifact and stays out of git.

### Usage

1. Pair the M96BT2 over Bluetooth.
2. Open `M96 Control.app` — it connects on launch; use **Rescan** after pairing.
3. Toggle/brightness send report 2 immediately; the status line shows the exact
   `IOReturn` for every send.

## Web preview

Open `index.html` in any browser — no server, no dependencies. It previews the on/off/
breathing states, brightness, and documents the hardware shortcuts. Everything the preview
cannot change on real hardware is marked as such.

## Development & agents

Agent work in this repo is routed through [`AGENTS.md`](AGENTS.md): task → agent pack →
max. 3 context files. Session history lives in [`context.md`](context.md).

Ground rules:

- **Verify, don't claim** — a build (`bash scripts/build-app.sh`) or a browser check proves a change, not a guess.
- **Never invent HID reports** — values in [`agents/HID_PROTOCOL.md`](agents/HID_PROTOCOL.md) are only added after they're observed on hardware.
- **One commit per task**, push collected with user approval.
- The `.app` bundle is generated, not edited.

## Legal disclaimer

**Use this software entirely at your own risk.** By downloading, building, or using any part of
this project, you agree to the following:

1. **No affiliation.** This project is not affiliated with, endorsed by, or sponsored by the
   manufacturer of the M96BT2 keyboard. All product names, trademarks, logos, and brand names
   are the property of their respective owners and are used solely for identification and
   interoperability purposes.
2. **Hardware risk.** This software sends HID output reports directly to a physical device.
   Incorrect or unexpected report values can alter device behavior, corrupt configuration,
   void your warranty, or damage the keyboard. The authors have tested only the values
   documented in [`agents/HID_PROTOCOL.md`](agents/HID_PROTOCOL.md). You are solely
   responsible for anything you send to your hardware.
3. **No fitness for purpose.** The M96BT2's firmware exposes no software lighting interface
   beyond the documented report. There is no guarantee the backlight will respond, or that any
   build will work with your unit, firmware version, or OS version.
4. **Software warranty disclaimer.** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
   KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION
   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR
   THE USE OR OTHER DEALINGS IN THE SOFTWARE.
5. **Third-party use.** This repository is public. The authors accept no liability for how
   others copy, modify, redistribute, or use this code or the documentation it contains.
6. **macOS Gatekeeper.** The app is ad-hoc signed, not notarized. macOS may show a security
   warning on first launch — that is expected. Run only builds you trust.
7. **No advice.** Nothing in this repository constitutes professional, legal, or technical
   advice about Bluetooth, HID, or any third-party hardware.
