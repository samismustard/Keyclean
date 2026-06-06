# KeyClean — Mac Keyboard Tool Design

**Date:** 2026-06-06

## Overview

A native macOS utility with two core features:
1. **Keyboard lock** — disables all keyboard (and optionally mouse click) input so the user can physically clean their keyboard without triggering actions.
2. **Input simulator** — records and replays keyboard/mouse macros, and runs JavaScript automation scripts.

Delivered as a menu bar app with an optional full main window.

---

## Architecture

Three layers:

```
┌─────────────────────────────────────┐
│  UI Layer (SwiftUI)                 │
│  Menu bar  │  Main window (3 tabs)  │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│  Core Services                      │
│  InputSimulator  │  InputRecorder   │
│  ScriptEngine    │  KeyboardLocker  │
│  MacroStore                         │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│  macOS APIs                         │
│  CGEvent  │  JavaScriptCore         │
│  NSStatusItem  │  Accessibility API │
└─────────────────────────────────────┘
```

### Core Services

| Service | Responsibility |
|---------|---------------|
| `InputSimulator` | Posts `CGEvent`s for keystrokes, mouse clicks, and mouse moves |
| `InputRecorder` | Installs a `CGEvent` tap, captures input events with timestamps |
| `ScriptEngine` | `JSContext` wrapper exposing `keyboard`, `mouse`, `sleep` JS APIs |
| `KeyboardLocker` | `CGEvent` tap that swallows all input events (returns nil) |
| `MacroStore` | Persists macros and scripts as JSON to `~/Library/Application Support/KeyClean/` |

**Required permission:** Accessibility (Input Monitoring) — prompted on first launch via `AXIsProcessTrusted()`.

---

## UI

### Menu Bar (always visible)
- Lock/unlock keyboard toggle with icon change (lock icon when active)
- Run recent macros (last 5)
- Open main window

### Main Window — 3 tabs

**Macros tab**
- List of recorded macros
- Record button (starts/stops `InputRecorder`)
- Assign global hotkey per macro
- Rename and delete actions

**Scripts tab**
- Syntax-highlighted code editor
- Run button
- Output console below editor (JS `console.log` + runtime errors with line numbers)

**Settings tab**
- Global hotkeys configuration
- Launch at login toggle
- Accessibility permission status indicator with re-prompt button

---

## Data Model

```swift
struct Macro: Codable, Identifiable {
    var id: UUID
    var name: String
    var events: [InputEvent]   // ordered, with per-event timing
    var hotkey: KeyCombo?
}

struct InputEvent: Codable {
    var type: EventType        // keyDown/keyUp/mouseDown/mouseUp/mouseMoved
    var keyCode: Int?
    var position: CGPoint?
    var delayMs: Int           // delay since previous event
}

struct Script: Codable, Identifiable {
    var id: UUID
    var name: String
    var source: String         // JavaScript
    var hotkey: KeyCombo?
}
```

Macros and scripts persisted as JSON in `~/Library/Application Support/KeyClean/`.

---

## JavaScript API

```js
keyboard.type("hello world")   // types a string
keyboard.press("cmd+c")        // presses a key combo
mouse.click(500, 300)          // left click at screen coords
mouse.moveTo(200, 400)         // move cursor
sleep(500)                     // wait ms
```

Errors bubble to the Scripts tab console with line numbers. Scripts run on a background thread; UI remains responsive.

---

## Keyboard Lock

- Installs `CGEvent` tap at `kCGSessionEventTap` level
- Swallows all key events and mouse clicks; mouse movement allowed so user can reach menu bar to unlock
- Unlock: global hotkey set before locking (default `⌘⌥L`), or click menu bar icon
- Visual feedback: menu bar icon changes to lock icon; optional fullscreen overlay ("Keyboard locked — clean away")

---

## Permissions & Error Handling

**Permissions flow:**
1. First launch checks `AXIsProcessTrusted()`
2. If denied, shows onboarding screen with direct link to System Settings > Privacy & Security > Accessibility
3. If permission revoked mid-session, `CGEvent` tap creation fails gracefully → alert user

**Error handling:**
- Script runtime errors: caught in `JSContext`, displayed in console with line number
- Macro playback failure: non-fatal toast notification
- Keyboard lock install failure: alert with troubleshooting steps
- Corrupt JSON on disk: reset to empty store, no crash

---

## Testing

| Area | Approach |
|------|----------|
| `InputSimulator` | Unit tests with mock event poster; verify correct `CGEvent` types and keycodes |
| `ScriptEngine` | Unit tests running JS snippets against mock simulator; verify call dispatch |
| `MacroStore` | Encode/decode round-trip tests; corrupt JSON recovery |
| `KeyboardLocker` | Manual only (CGEvent taps require Accessibility permission unavailable in CI) |
| UI | SwiftUI previews per tab; no XCUITest |
| Integration | Manual checklist: lock/unlock cycle, record+replay macro, run script end-to-end |

---

## Out of Scope

- Network features of any kind
- Cloud sync
- Plugin system
- Windows/Linux support
