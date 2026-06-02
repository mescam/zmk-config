# ZMK Config — Cradio/Sweep + nice!nano v2

## Build Commands

```bash
# First time: fetch dependencies (~2GB)
nix develop --command west update

# Build firmware
nix run .#build-left     # Build left half → cradio_left.uf2
nix run .#build-right    # Build right half → cradio_right.uf2
nix run .#build-all      # Build both

nix develop              # Enter shell with west, cmake, arm toolchain
```

ZMK revision is pinned in `config/west.yml`. Run `west update` again only when changing the pin.

## Architecture

- `config/cradio.keymap` — keymap (DeviceTree overlay format)
- `config/cradio.conf` — ZMK Kconfig options
- `config/west.yml` — west manifest; points to `zmkfirmware/zmk` main branch
- `flake.nix` — Nix build environment (replaces manual SDK setup)
- `docs/index.html` — static keymap visualization (GitHub Pages)

Fetched at build time (gitignored): `zmk/`, `zephyr/`, `modules/`, `.west/`

## Keymap Syntax Gotchas

**Behaviors with multi-token macros** — `BT_CLR` expands to `BT_CLR_CMD 0` (two tokens). Use `&bt BT_CLR`, NOT `&kp BT_CLR`. Same for `BT_CLR_ALL`, `BT_NXT`, `BT_PRV`. Verify with:
```bash
grep "define BT_CLR " zmk/app/include/dt-bindings/zmk/bt.h
```

**Board identifier** — Newer ZMK/Zephyr uses `nice_nano/nrf52840/zmk`, not `nice_nano_v2`. The build scripts handle this.

**Modifier consistency** — Home row mods mirror across hands:
- Left (pinky→index): Shift, Ctrl, Alt, Gui
- Right (index→pinky): Gui, Alt, Ctrl, Shift

Sticky keys on other layers must match this order.

## CI/CD

GitHub Actions (`.github/workflows/build.yml`):
- Triggers on config/boards/flake changes to master
- Builds both halves in parallel using Nix
- Uploads firmware as artifacts
- Creates draft releases with `.uf2` files

## Keymap Layers

| Layer | Content | Access |
|-------|---------|--------|
| 0 | QWERTY + home row mods | Default |
| 1 | Symbols | Hold right thumb |
| 2 | Nav + Media + BT profiles | Hold left thumb |
| 3 | Numpad + F-keys | Hold from L1 or L2 |

## Flashing

1. Double-tap reset on nice!nano (enters bootloader, mounts as USB drive)
2. Copy `.uf2` file to the drive
3. Repeat for other half

## Common Pitfalls

- `west update` must run before first build (handled by Nix flake automatically in CI)
- ZMK main branch may have breaking changes; pin to a tag in `config/west.yml` if stability needed
- Layer references (`&mo N`) must be updated when removing/adding layers
- The `tapping_term_ms` property in `&mt` block is deprecated in newer ZMK; use per-binding config if needed
