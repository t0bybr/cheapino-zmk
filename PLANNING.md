# Cheapino ZMK - Cleanup & Restructure

+doc:planning +project:cheapino-zmk

## Status

- Branch: `feat/cleanup` (von `feat/qmk-parity` abgezweigt)
- Bereits erledigt (commit `358d51a`):
  - urob/zmk-leader-key, urob/zmk-unicode, BlueDrink9/zmk-poor-mans-led-indicator aus `west.yml` entfernt
  - Leader-Behaviour, `del_td`/`del_td_mac` Tap-Dance, `lt_leader` Hold-Tap raus
  - Hex-Input-Macros raus (tm, ½, ¼, ¾, ≈, ➜ + `_mac`-Pendants)
  - LED-Indicator-Configs + `&blue_led` aus Overlay raus
  - R3-Thumb temporär auf `&lt_t CMD DEL` gesetzt
- Build von `feat/cleanup` ist grün (commit `358d51a`).

## Ziel: Aufgeräumte Layer-Struktur

Dramatische Reduktion: aus 9+ Layern werden 4 (BASE, L1, L2, CMD) plus Mac-Sentinel.
Die seltenen Layer (MOUSE, MEDIA, EXTRA, FKEY) verschwinden als eigene Layer und
leben als Mod-Morph-Variationen innerhalb L1 und L2 (geschaltet über MOD = LSHFT).

## Layer-Indizes

```c
#define BASE     0
#define L1       1   // NAV / MEDIA / EXTRA combined
#define L2       2   // NUM / F-Keys / SYM combined
#define CMD      3   // Umlaute (NUR Umlaute - kein Clipboard mehr)
#define MAC      4   // Sentinel-Layer, getoggelt via BT-Slot 2
#define MAC_L2   5   // Mac-Symbole überlagern L2 (Option statt AltGr)
```

## BASE

- **HRMs entfernen**: Reihe 2 wird plain `&kp A R S T D | H N E I O`. Toby will sich
  davon trennen, weil sonst aus Muskelgedächtnis weiter genutzt wird.
- **Top-Reihe**: `Q W F P G | J L U Y lit_quot` (mod-morph `lit_quot` für `'`/`"` behalten)
- **Bot-Reihe**: `Z X C V B | K M comma_lt dot_gt lit_slsh` (mod-morphs behalten)
- **Thumbs**:

| Pos | Thumb    | Tap  | Hold  | Behavior                                                        |
| --- | -------- | ---- | ----- | --------------------------------------------------------------- |
| 30  | L1 außen | Esc  | LALT  | `&mt LALT ESC`                                                  |
| 31  | L2 mitte | Spc  | LSHFT | `&mt LSHFT SPACE`                                               |
| 32  | L3 innen | Tab  | LCTRL | `&mt LCTRL TAB` (Linux) / `&mt LGUI TAB` (Mac via MAC-Sentinel) |
| 33  | R3 innen | Ret  | L1    | `&lt L1 RET`                                                    |
| 34  | R2 mitte | Bspc | L2    | `&lt L2 BSPC`                                                   |
| 35  | R1 außen | Del  | CMD   | `&lt CMD DEL`                                                   |

- **Mod-Morphs auf BASE behalten**: `comma_lt`, `dot_gt`,
  `lit_quot`, `lit_slsh`, `ae_m`, `oe_m`, `ue_m`, `ss_m`.
- **Hold-Tap-Behaviors**: `&mt` und `&lt` von ZMK direkt nutzen, mit `tapping-term-ms = <200>`,
  `quick-tap-ms = <150>`, `flavor = "balanced"`. Tuning später.

## Combos auf BASE

| Tasten              | Pos   | Output       | Notes                          |
| ------------------- | ----- | ------------ | ------------------------------ |
| Z + X               | 20+21 | `&kp LC(X)`  | Cut                            |
| X + C               | 21+22 | `&kp LC(C)`  | Copy                           |
| C + V               | 22+23 | `&kp LC(V)`  | Paste                          |
| Spc + Bspc          | 31+34 | `&caps_word` | Caps-Word (Doppel-Shift)       |
| L2-Thumb + L3-Thumb | 31+32 | `&kp LGUI`   | META = Cmd/GUI, `slow-release` |

- Mac-Variante: das `LC(X)`/`LC(C)`/`LC(V)`-Combo wird auf `LG(X)`/`LG(C)`/`LG(V)` umgeschrieben
  via separate Combo-Definitionen mit `layers = <MAC>` (oder per mod-morph). Konkretes
  Vorgehen: zwei parallele Combos mit `layers`-Filter — einmal für BASE (LC), einmal mit
  `layers = <MAC>` (LG). Das META-Combo wird `LCTRL` auf Mac.

## L1 (NAV/MEDIA/EXTRA combined)

**Linke Hand: System + BT**

|         | Spalte 0    | Spalte 1         | Spalte 2    | Spalte 3       | Spalte 4                                                          |
| ------- | ----------- | ---------------- | ----------- | -------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Reihe 1 | `&soft_off` | `&studio_unlock` | `&none`     | `&bootloader`  | `&sys_reset`                                                      |
| Reihe 2 | `&bt_lin`   | `&bt_and`        | `&bt_mac`   | `&bt BT_SEL 3` | `&bt BT_SEL 4`                                                    | (Alle Profiles bekommen eine Combo in einem mod-morph, die das jeweilige Profile cleart, also `MOD + &bt BT_SEL 4` = `&bt BT_CLR 4`) |
| Reihe 3 | `&none`     | `&none`          | `&kp PSCRN` | `&none`        | `&out_tog` (mod-morph: ohne MOD = `OUT_BLE`, mit MOD = `OUT_USB`) |

**Rechte Hand: Pfeile/Vol mit MOD-Variante = Maus/Media**

Mod-Morphs (alle reagieren auf `MOD_LSFT`):

| Pos | ohne MOD   | mit MOD (Shift) |
| --- | ---------- | --------------- |
| 5   | `&none`    | `&none`         |
| 6   | `PG_UP`    | `SCRL_UP`       |
| 7   | `UP`       | `MMV_UP`        |
| 8   | `PG_DN`    | `SCRL_DN`       |
| 9   | `&none`    | `&none`         |
| 15  | `HOME`     | `SCRL_LEFT`     |
| 16  | `LEFT`     | `MMV_LEFT`      |
| 17  | `DOWN`     | `MMV_DOWN`      |
| 18  | `RIGHT`    | `MMV_RIGHT`     |
| 19  | `END`      | `SCRL_RIGHT`    |
| 25  | `C_PREV`   | `&none`         |
| 26  | `C_VOL_DN` | `&none`         |
| 27  | `C_MUTE`   | `&none`         |
| 28  | `C_VOL_UP` | `&none`         |
| 29  | `C_NEXT`   | `&none`         |

**Maus-Klicks via Combos in L1** (statt Mod-Morph-Variante):

| Tasten | Pos   | Output         | Notes                     |
| ------ | ----- | -------------- | ------------------------- |
| N + E  | 16+17 | `&mkp LCLK`    | Linksklick, `layers = <L1>` |
| E + I  | 17+18 | `&mkp RCLK`    | Rechtsklick, `layers = <L1>` |
| M + ,  | 26+27 | `&mkp MCLK`    | Mittelklick, `layers = <L1>` |

**MOD-Mechanik (vereinfacht)**: MOD ist einfach Shift, gehalten via **L2-Thumb (Pos 31)**.
Da alle Thumbs in L1/L2 `&trans` sind, fällt Pos 31 auf BASE = `&mt LSHFT SPACE` durch.
Hält Toby den L2-Thumb gleichzeitig zum Layer-Aktivator (R3-Thumb), ist Shift aktiv und
die Mod-Morphs auf den L1-Tasten triggern.

**L1-Thumbs**: alle `&trans`. Keine Spezial-Definition für Pos 32 mehr.

## L2 (NUM/F/SYM combined)

Aus Tobys Skizze (`Thumb Tap Hold Hold Mod.txt`, Z. 27-37). Mod-Morphs reagieren auf
`MOD_LSFT`. MOD = Shift via **L2-Thumb (Pos 31)** wie auf L1 — also kein Spezial-Override
auf Pos 32 nötig.

**Linke Hand**:

|         | Spalte 0       | Spalte 1     | Spalte 2 | Spalte 3 | Spalte 4 |
| ------- | -------------- | ------------ | -------- | -------- | -------- |
| Reihe 1 | `none / F11`   | `none / F12` | `; / :`  | `*`      | `„ / "`  |
| Reihe 2 | `1 / F1`       | `2 / F2`     | `3 / F3` | `4 / F4` | `5 / F5` |
| Reihe 3 | `` ` `` ` / ~` | `$ / €`      | `@ / !`  | `# / ^`  | `– / —`  |

**Rechte Hand**:

|         | Spalte 5 | Spalte 6 | Spalte 7 | Spalte 8 | Spalte 9  |
| ------- | -------- | -------- | -------- | -------- | --------- |
| Reihe 1 | `‚ / '`  | `& / %`  | `- / _`  | `= / +`  | `&none`   |
| Reihe 2 | `6 / F6` | `7 / F7` | `8 / F8` | `9 / F9` | `0 / F10` |
| Reihe 3 | `… / °`  | `( / )`  | `[ / ]`  | `{ / }`  | `\ / \|`  |

**L2-Thumbs**: alle `&trans`. MOD = Shift kommt automatisch via Pos 31 BASE-Mod-Tap.

**Wichtige DE-Layout-Mappings für die Symbole**:

- `;` = `LS(COMMA)`, `:` = `LS(DOT)`
- `*` = `LS(RBKT)` (DE-Layout)
- `"` = `LS(N2)` (oder Macro `dquote` für typografisch korrekt)
- `„` = Macro `dqlo`
- `'` = Macro `rsquote` (typografisch) oder `LS(NON_US_HASH)`
- `‚` = Macro `dqhi`
- `&` = `LS(N6)`, `%` = `LS(N5)`
- `-` = `MINUS`, `_` = `LS(MINUS)`
- `=` = `LS(N0)` (Linux-DE), `+` = `LS(RBKT)` — Achtung: `+` und `*` kollidieren auf
  RBKT-Position. `*` ist `LS(RBKT)`, `+` einfacher als direkter Keycode `RBKT`. Prüfen
  beim Implementieren.
- `(` = `LS(N8)`, `)` = `LS(N9)`
- `[` = `RA(N8)` = `DE_LBRC`, `]` = `RA(N9)` = `DE_RBRC`
- `{` = `RA(N7)` = `DE_LCBR`, `}` = `RA(N0)` = `DE_RCBR`
- `\` = `RA(MINUS)` = `DE_BSLS`, `\|` = `RA(NON_US_BACKSLASH)` = `DE_PIPE`
- `–` = Macro `ndash`, `—` = Macro `mdash`
- `…` = Macro `ellip`, `°` = Macro `degree`
- `^` = Macro `de_circ`, `~` = `RA(RIGHT_BRACKET)` = `DE_TILD`
- `` ` `` = Macro `de_grv`
- `$` = `LS(N4)`, `€` = `RA(E)` = `DE_EURO`
- `@` = `RA(Q)` = `DE_AT`, `!` = `LS(N1)`
- `#` = `NON_US_HASH`

## CMD (L3) - nur Umlaute

|         | Spalte 0 | Spalte 1 | Spalte 2 | Spalte 3 | Spalte 4 |
| ------- | -------- | -------- | -------- | -------- | -------- |
| Reihe 1 | `&none`  | `&none`  | `&none`  | `&none`  | `&none`  |
| Reihe 2 | `&ae_m`  | `&none`  | `&ss_m`  | `&none`  | `&none`  |
| Reihe 3 | `&none`  | `&none`  | `&none`  | `&none`  | `&none`  |

|         | Spalte 5 | Spalte 6 | Spalte 7 | Spalte 8 | Spalte 9 |
| ------- | -------- | -------- | -------- | -------- | -------- |
| Reihe 1 | `&none`  | `&none`  | `&ue_m`  | `&none`  | `&none`  |
| Reihe 2 | `&none`  | `&none`  | `&none`  | `&none`  | `&oe_m`  |
| Reihe 3 | `&none`  | `&none`  | `&none`  | `&none`  | `&none`  |

CMD-Thumbs: alle `&trans`. Kein Clipboard mehr (das ist auf den Combos).

## MAC Sentinel (Layer 4)

Toggle-Layer, getoggelt via BT-Slot-Macros:

```dts
bt_lin: bt_lin {  // BT 0 = Linux
    compatible = "zmk,behavior-macro";
    bindings = <&macro_tap &bt BT_SEL 0>;
    /* MAC bleibt aus */
};

bt_and: bt_and {  // BT 1 = Android (gleich wie Linux)
    compatible = "zmk,behavior-macro";
    bindings = <&macro_tap &bt BT_SEL 1>;
};

bt_mac: bt_mac {  // BT 2 = Mac (toggelt MAC sentinel an)
    compatible = "zmk,behavior-macro";
    bindings = <&macro_tap &bt BT_SEL 2 &tog MAC>;
};
```

(Die Logik "toggle MAC nur einmal" ist hier vereinfacht. Sauberer wäre ein Macro
das den MAC-State explizit setzt, aber `&tog` reicht wenn man konsequent zwischen
`bt_lin`/`bt_and` und `bt_mac` wechselt. Wenn der State driftet, manueller `&tog MAC`
auf einer EXTRA-artigen Position.)

**MAC-Layer-Bindings**: nur OS-spezifisches überschreiben.

| Pos                  | Mac-Override   | Erklärung                      |
| -------------------- | -------------- | ------------------------------ |
| 32                   | `&mt LGUI TAB` | L3-Thumb wird Cmd statt Ctrl   |
| (Combo) L2+L3 thumbs | `&kp LCTRL`    | META-combo wird Ctrl statt GUI |
| 21+22                | `&kp LG(C)`    | Copy-combo (Cmd statt Ctrl)    |
| 22+23                | `&kp LG(V)`    | Paste-combo                    |
| 20+21                | `&kp LG(X)`    | Cut-combo                      |

Alle anderen MAC-Positionen: `&trans` (fall-through auf BASE).

## MAC_L2 (Layer 5) - Mac-Symbole

Conditional-Layer-Aktivierung:

```dts
conditional_layers {
    mac_l2_overlay {
        if-layers = <L2 MAC>;
        then-layer = <MAC_L2>;
    };
};
```

MAC_L2 überschreibt nur die Klammern und Zeichen, die auf macOS-DE per Option
statt AltGr erreicht werden:

| Symbol | Linux-DE (RA)          | Mac-DE (LA)         |
| ------ | ---------------------- | ------------------- |
| `{`    | `RA(N7)`               | `LA(N8)`            |
| `}`    | `RA(N0)`               | `LA(N9)`            |
| `[`    | `RA(N8)`               | `LA(N5)`            |
| `]`    | `RA(N9)`               | `LA(N6)`            |
| `\`    | `RA(MINUS)`            | `LA(LS(N7))`        |
| `\|`   | `RA(NON_US_BACKSLASH)` | `LA(N7)`            |
| `@`    | `RA(Q)`                | `LA(L)`             |
| `~`    | `RA(RIGHT_BRACKET)`    | Macro `de_tild_mac` |

Restliche Tasten: `&trans` (fall-through auf L2).

## Conditional Layers Übersicht

```dts
conditional_layers {
    compatible = "zmk,conditional-layers";
    mac_l2_overlay {
        if-layers = <L2 MAC>;
        then-layer = <MAC_L2>;
    };
};
```

## Implementierungs-Reihenfolge

1. **Header umbauen**: Layer-Defines auf BASE/L1/L2/CMD/MAC/MAC_L2 umstellen,
   alte Layer-Defines (MEDIA/NAV/MOUSE/SYM_R/NUM/FKEY/EXTRA/MAC_BASE/MAC_SYM/MAC_NUM/MAC_CMD)
   raus.
2. **Behaviors aufräumen**: HRMs (`hrm_l`, `hrm_r`, `hrm_lg`, `hrm_rg`) komplett raus.
   Layer-Tap-Behaviors (`lt_t`, `lt_spc`, `lt_bspc`, `lt_esc`) auf das Nötige reduzieren
   oder durch ZMK-builtin `&mt`/`&lt` ersetzen. `&mmv`/`&msc` Tuning bleibt.
3. **Mod-Morphs**: `bspc_del`, `esc_tilde`, `comma_lt`, `dot_gt`, `lit_quot`, `lit_slsh`,
   `ae_m`, `oe_m`, `ue_m`, `ss_m` behalten. Neue Mod-Morphs für L1 (PG_UP↔SCRL_UP usw.)
   und L2 (1↔F1 usw.) hinzufügen.
4. **Macros**: Behalten: `de_circ`, `de_grv`, `mdash`, `ndash`, `ellip`, `dqlo`, `dqhi`,
   `dquote`, `rsquote`, `degree` + `_mac`-Pendants + `de_tild_mac`. Anpassen: `bt_lin`,
   `bt_and` (neu), `bt_mac` mit `&tog MAC`.
5. **Conditional Layers**: nur `mac_l2_overlay`. Alte tri-layer (`fkey_tri`) raus.
6. **Combos**:
   - `combo_copy` (X+C), `combo_paste` (C+V), `combo_cut` (Z+X) — Linux mit `LC(...)`
   - `combo_caps` umbau auf Spc+Bspc (Pos 31+34) statt T+N
   - Neu: `combo_meta` (Pos 31+32, slow-release) für LGUI
   - Neu: `combo_lclk` (N+E, layers = `<L1>`), `combo_rclk` (E+I, layers = `<L1>`),
     `combo_mclk` (M+,, layers = `<L1>`)
   - Mac-Varianten der Clipboard-Combos mit `layers = <MAC>` filtern (LG statt LC).
7. **Layer BASE neu**: HRMs raus, neue Thumbs (`&mt LALT ESC`, `&mt LSHFT SPACE`,
   `&mt LCTRL TAB`, `&lt L1 RET`, `&lt_bspc L2 0`, `&lt CMD DEL`).
8. **Layer L1 neu**: System+BT links, Pfeile+Vol rechts mit Mod-Morphs für MOD-Variante.
9. **Layer L2 neu**: Symbole+Ziffern nach Tobys Skizze.
10. **Layer CMD neu**: Nur Umlaute, sonst `&none`/`&trans`.
11. **Layer MAC neu**: Sentinel, fast nur `&trans`, nur Pos 32 + Clipboard-Combos überschrieben.
12. **Layer MAC_L2 neu**: Mac-Klammern überlagern L2.
13. **`config/cheapinov2.conf` prüfen**: `CONFIG_ZMK_KEYMAP_LAYERS=` ggf. anpassen
    (default ist 8, wir haben 6). Sollte automatisch passen.
14. **Build**: `git push origin feat/cleanup`, GitHub Action prüft Build. Bei Fehler
    iterieren.
15. **Flash & Test**: UF2 holen, flashen, Toby testet.

## Edge Cases / Offene Punkte

- **MOD = Shift via L2-Thumb (Pos 31)**: Alle Thumbs in L1/L2/CMD sind `&trans`,
  d.h. Pos 31 fällt auf BASE = `&mt LSHFT SPACE` zurück. Linke Hand hält L2-Thumb für
  Shift, rechte Hand hält R3-Thumb für L1 (oder R2-Thumb für L2). Mod-Morphs auf den
  L1/L2-Tasten reagieren auf Shift. Keine Spezial-Override auf Pos 32 nötig.
- **R2-Thumb in L1/L2/CMD = `&trans`**: fällt auf BASE = `&lt_bspc L2 0` zurück. Wenn
  Toby in L1 ist und R2 antippt, kommt Bspc raus (= das BASE-Tap-Verhalten). OK so.
- **Caps-Word continue-list**: muss umlaut-tauglich bleiben (ae_m/oe_m/ue_m/ss_m
  Mod-Morphs). Liste: `<UNDERSCORE MINUS BACKSPACE DELETE KP_MINUS SLASH SQT SEMI LBKT>`.
- **Display-Modul**: bleibt vorerst aus `feat/cleanup` raus (Display-Code aus
  feat/qmk-parity holen wir später wieder rein wenn Layout sitzt).
- **`bt_mac` mit `&tog MAC`**: wenn Toby zweimal hintereinander auf `bt_mac` drückt,
  wird MAC zweimal getoggelt → State driftet. Workaround: feste `&to` Sequenz oder
  Toby weiß was er tut. Erstmal `&tog`, später ggf. robuster.

## Test-Plan

- [ ] BASE: Esc/Spc/Tab tap funktionieren, Alt/Shift/Ctrl hold funktionieren
- [ ] BASE: Ret tap, L1 hold (rechte Hand)
- [ ] BASE: Bspc tap, Shift+Bspc = Del, L2 hold
- [ ] BASE: Del tap (R1), CMD hold
- [ ] BASE: Cut/Copy/Paste-Combos (Z+X, X+C, C+V)
- [ ] BASE: Caps-Word via Spc+Bspc (Pos 31+34)
- [ ] BASE: META-Combo (L2+L3 thumbs)
- [ ] L1: Pfeile + System-Tasten
- [ ] L1: MOD-Variante (L2-Thumb = Shift halten) → Scroll/MMV
- [ ] L1: Maus-Klicks via Combos N+E (LCLK), E+I (RCLK), M+, (MCLK)
- [ ] L2: Ziffern auf der mittleren Reihe
- [ ] L2: F-Keys via MOD (L2-Thumb halten)
- [ ] L2: Symbole rechts
- [ ] CMD: ä/ö/ü/ß (mit Caps-Word: Ä/Ö/Ü/SS)
- [ ] BT-Profile-Switch via L1
- [ ] Mac-Test: BT_SEL 2 aktiviert MAC, Cmd-Thumb funktioniert, Cmd+C/V/X klappen
- [ ] Mac-Test: Mac-Klammern via Option auf L2
