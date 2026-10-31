# HID Protocol — M96BT2

Single source of truth for the M96BT2 HID interface. **Facts only — hardware-observed.
Hypotheses are marked and never treated as fact.**

## Device identity

| Field | Value | Source |
|---|---|---|
| Vendor ID | `0x32C2` | observed — IOKit match in `src/main.swift` |
| Product ID | `0x6621` | observed — IOKit match in `src/main.swift` |
| Product name | `M96BT2` | observed — `kIOHIDProductKey` property |
| Transport | Bluetooth | user-verified pairing |

## Output report 2 (known)

Single-byte payload, the **only** output report observed on this device.

| Value | Meaning | Source |
|---|---|---|
| `0x00` | Backlight off | observed — app "Off" button |
| `0x01 … 0xFE` | Brightness scale | observed — slider sends `UInt8(brightness * 255)` |
| `0xFF` | Full brightness | observed — pulse test step 1 |
| `0xCC` (204) | Pulse-test resting value | observed — pulse test step 3; effect on device unconfirmed |
| `0x02` | Caps LED probe | observed — app "Caps LED" button; effect on device unconfirmed |

Send path: `IOHIDDeviceSetReport(device, kIOHIDReportTypeOutput, 2, bytes, 1)`.
Success = `kIOReturnSuccess` (0), reported in the app status line.

## What the hardware does NOT support

- **No software lighting interface beyond report 2.** No color, no per-key control.
- **Fixed rainbow LED layer.** Red is not available; effects are keyboard-side only.
- Anything else the UI previews (breathing etc.) is a **preview**, reachable only via
  hardware shortcuts — not via HID.

## Hardware-only shortcuts (no HID equivalent observed)

| Function | Shortcut | Source |
|---|---|---|
| Power / mode | `Fn + Del` | keyboard manual |
| Brightness | `Fn + ↑ / ↓` | keyboard manual |
| Effect speed | `Fn + ← / →` | keyboard manual |
| Volume | Turn knob | keyboard manual |
| Backlight mode | Hold knob 5 s | keyboard manual |
| Windows / Mac mode | `Fn + Tab` | keyboard manual |
| Bluetooth pairing | `Esc + Q` (3–5 s) | keyboard manual |

## Open questions

- [ ] **Input reports** — keystrokes, battery level: never captured. Need an input callback +
      `IOHIDManagerScheduleWithRunLoop` experiment; document IDs + byte layout.
- [ ] **Byte → mode mapping** — do report-2 values beyond the brightness range switch modes?
      Unobserved; test `0x02`/`0xCC` responses first.
- [ ] **Other output report IDs** — descriptors not captured; any ID beyond 2 is unknown.
- [ ] **Pulse test semantics** — `255 → 0 → 204` sequence was designed as a visibility test,
      not a documented protocol feature. Does `204` mean something specific? Unknown.

## Experiment log (template)

```
Date · setup · sent: report 2 = <hex> · observed: <effect> · notes
```

No entry = no fact. Update this file in the same commit as any new finding.
