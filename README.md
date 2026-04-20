# Cheapino v2 - Toby Keymap (ZMK Port)

+doc:readme +project:cheapino-toby

ZMK-Port meiner QMK-Keymap fuer das Cheapino v2. Single-MCU (Nice Nano v2), beide
Haelften ueber RJ45 verbunden. Shield-Files uebernommen von tompi's
`cheapino-zmk-config-single-nicenano`.

## Struktur

- `boards/shields/cheapinov2/` -- Shield-Definition (Matrix, Physical Layout, Keymap)
- `config/cheapinov2.conf` -- Build-Config (Studio, Pointing, Smooth Scroll)
- `build.yaml` -- GitHub-Actions-Ziel: `nice_nano_v2` + Shield `cheapinov2`
- `.github/workflows/build.yml` -- CI-Build via zmkfirmware

## Build

```bash
# Via GitHub Actions: Push triggert Build, Artifact als UF2
# Lokal (West):
west init -l config
west update
west build -s zmk/app -b nice_nano_v2 -- -DSHIELD=cheapinov2
```

UF2 im `build/zephyr/zmk.uf2`. Flash: Nice Nano per Doppel-Reset in Bootloader,
UF2 auf den erscheinenden Massenspeicher kopieren.

## Layout

Colemak (klassisch, kein DH), Home Row Mods auf A/R/S/T (links GACS) und N/E/I/O
(rechts GACS gespiegelt). Sechs Thumb-Tasten mit Layer-Taps.

### Layer

| # | Name | Zweck |
|---|------|-------|
| 0 | BASE | Colemak + HRMs + Thumb-LTs |
| 1 | MEDIA | Volume, Play/Pause, Prev/Next |
| 2 | NAV | Pfeile, Home/End, PgUp/PgDn, GUI+Tab |
| 3 | MOUSE | Cursor, Scroll, Klicks |
| 4 | SYM_R | Rechte Symbol-Hand (DE-Layout) |
| 5 | NUM | Zahlen + Klammerreihe (DE-Layout) |
| 6 | FKEY | F1-F12, TTY-Switch (Linux), System |
| 7 | EXTRA | BT-Profile, Output-Switch, Studio-Unlock |
| 8 | CMD | Clipboard + Umlaute (Hold auf DEL-Thumb) |

**Tri-Layer**: SYM_R + NUM gleichzeitig gehalten -> FKEY (via `conditional_layers`).

### Thumb-Cluster

```
 MEDIA   NAV   MOUSE  |  SYM_R   NUM    CMD
  ESC   SPACE   TAB   |  ENTER   BSPC   DEL
```

### Home Row Mods

HRMs sind Chordal-Hold-Aequivalent via `hold-trigger-key-positions` -- das Hold
triggert nur, wenn eine Taste der gegenueberliegenden Hand gedrueckt wird.
GUI-HRMs (A und O) haben ein leicht laengeres `tapping-term-ms` (280 vs 250),
analog zu QMKs `TAPPING_TERM + 30`.

### Mod-Morphs

- Shift+Backspace -> Delete
- Shift+Escape -> Tilde (`~`)
- Shift+Komma -> `<` (DE: NON_US_BACKSLASH)
- Shift+Punkt -> `>`
- `'/"` auf der Pinky-Position (lit_quot)
- `/?` auf der rechten Unten-Position (lit_slsh)

### Combos

- X+C -> Copy (Ctrl+C)
- C+V -> Paste (Ctrl+V)
- Z+X -> Cut (Ctrl+X)

50ms Timeout, nur auf BASE aktiv.

### Dead-Key-Aufloesungen

Macros `de_circ` und `de_grv` senden Dead-Key + Space, um literales `^` und
Backtick `\`` zu erhalten.

## Was fehlt gegenueber QMK

Diese Features existieren in ZMK 0.3.0 nicht (oder nicht in dieser Form):

- **OS-Detection + OS-aware Shortcuts** -- alle Shortcuts sind fix Linux/Ctrl.
- **Leader Key (QMK-Stil)** -- kein Aequivalent in Upstream. Community-Modul
  (`zmk-leader-key`) waere moeglich, ist aber nicht in Phase 1.
- **BSPC-State-Machine** (Triple-Tap+Hold = Auto-Repeat, Word-Delete, Shift=DEL
  held) -- vereinfacht zu `&lt NUM BSPC` + Shift-Morph fuer DEL.
- **DEL_FKY Hybrid** (tap=Leader, hold=CMD, double-tap=App-Leader) -- vereinfacht
  zu `&lt_t CMD DEL` (tap=DEL, hold=CMD).
- **RGB-Layer-Overlays** (HRM-Overlay, Leader-Overlay, Boot-OS-Flash) -- das
  Cheapino hat nur 1 Status-LED, und ZMK kann nicht per-Event overlayen wie
  QMKs rgblight_layers.
- **Kinetic Mouse** -- ZMK hat einen anderen Mouse-Stack ohne Inertia-Mode.
- **Autocorrect Dictionary** -- kein Aequivalent.
- **App-Switcher mit Timer-Release** -- vereinfacht zu festem GUI+Tab.
- **Compose-basierte Typografie** (Gedankenstriche, Anfuehrungszeichen, `EUR`) --
  weg. Koennte als Macros nachgeruestet werden.

## Matrix-Positionen (fuer Combos / hold-trigger)

```
 0  1  2  3  4        5  6  7  8  9
10 11 12 13 14       15 16 17 18 19
20 21 22 23 24       25 26 27 28 29
        30 31 32      33 34 35
```

## TODO / Nacharbeit

- Testen: HRMs tunen (`tapping-term-ms`, `quick-tap-ms` je nach Tippgefuehl).
- Pruefen: AltGr-Symbole auf dem Host-DE-Layout (`{}[]\\|~@EUR`) wirklich korrekt.
- Ggf. Caps-Word als Combo (z.B. Position 20 + 29) hinzufuegen.
- macOS-Profil ueberlegen: ggf. zweites Layer, das per `&to MAC_BASE` die
  AltGr-Kombis auf macOS-Option-Kombis umleitet.
