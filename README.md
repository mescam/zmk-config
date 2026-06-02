# Ferris Sweep ZMK Config

ZMK firmware configuration for Ferris Sweep with nice!nano v2 controllers.

## Build

```bash
# Fetch dependencies (first time only)
nix develop --command west update

# Build both halves
nix run .#build-all
```

Output: `cradio_left.uf2`, `cradio_right.uf2`

## Flash

1. Double-tap reset on nice!nano (enters bootloader)
2. Copy `.uf2` to mounted USB drive
3. Repeat for other half

## Keymap

4 layers with home row mods (tap-preferred, 285ms).

| Layer | Content | Access |
|-------|---------|--------|
| 0 | QWERTY + mods | Default |
| 1 | Symbols | Hold right thumb |
| 2 | Nav + Media + BT | Hold left thumb |
| 3 | Numpad + F-keys | Hold from L1 or L2 |

**Layer 0 — QWERTY**
```
╭─────────────────────────────────╮╭─────────────────────────────────╮
│  Q    W    E    R    T          ││          Y    U    I    O    P  │
│ Sft  Ctl  Alt  Gui    G        ││        H  Gui  Alt  Ctl  Sft   │
│  Z    X    C    V    B          ││          N    M    ,    .    /  │
╰──────────────╮ L2   Spc        ││       Bspc   L1 ╭──────────────╯
               ╰──────────────────╯╰─────────────────╯
```

**Layer 2 — Nav + Media + Bluetooth**
```
╭─────────────────────────────────╮╭─────────────────────────────────╮
│ Esc  Mute Vol↓ Vol↑ Bri↑       ││       PgUp Home   ↑  End   Del │
│ Sft  Ctl  Alt  Gui  Bri↓       ││       Tab    ←    ↓    →  Enter│
│ Caps Stop  Rwd  FF   Play      ││       PgDn  BT0  BT1  BT2  CLR │
╰──────────────╮ ___   Spc       ││       Bspc   L3 ╭──────────────╯
               ╰──────────────────╯╰─────────────────╯
```

Full visualization: [jakubwozniak.me/zmk-config](https://jakubwozniak.me/zmk-config/)

## Bluetooth

- `BT0` / `BT1` / `BT2` — select profile
- `CLR` — clear current profile pairing
- Default: profile 0 active after flash

To pair: select profile → pair from computer's Bluetooth settings.

## Home Row Mods

Mods mirror across hands:

| Position | Left | Right |
|----------|------|-------|
| Pinky | Shift | Shift |
| Ring | Ctrl | Ctrl |
| Middle | Alt | Alt |
| Index | Gui | Gui |

Hold for modifier, tap for key. Use opposite hand for combos (e.g., Ctrl+Shift+S = hold right L+', tap left S).

## Tech Stack

- **Board**: nice!nano v2 (nRF52840)
- **Shield**: Ferris Sweep (Cradio)
- **Firmware**: ZMK (pinned commit)
- **Build**: Nix flake + west + Zephyr RTOS
- **CI**: GitHub Actions (Nix-based)

## Repository Structure

```
├── config/
│   ├── cradio.keymap    # Keymap (DeviceTree overlay)
│   ├── cradio.conf      # ZMK Kconfig options
│   └── west.yml         # West manifest (ZMK pinned)
├── docs/
│   └── index.html       # Keymap visualization
├── flake.nix            # Nix build environment
└── .github/workflows/
    └── build.yml        # CI/CD pipeline
```

## License

MIT
