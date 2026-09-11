# Incremental Survivors 2.5D

### ▶ Play it now: **https://kamilch1k.github.io/incremental-survivors-3d/**

This is the **complete original game** — same file, same maps, same tiles, same
sprites, same background vistas, same champions, realms, abilities, bosses, Forge,
Ascend, audio and UI as
[`kamilch1k/incremental-survivors`](https://github.com/kamilch1k/incremental-survivors)
— with **only the renderer converted to 2.5D oblique**. No gameplay, balance,
asset or logic file was touched; every change is inside the paint path.

## What "2.5D" means here

- **Ground plane squashed** (`TILT = 0.84`): floors, room tiles, carpets, rings,
  auras, boss telegraphs and glows all render on a tilted plane, so circles read
  as floor ellipses.
- **Characters stand upright**: hero, enemies, bosses, allies, beacons and props
  are foot-planted vertical standees whose height is divided back out of the tilt,
  keeping exact original pixel proportions with feet on their shadows.
- **Extruded walls**: every wall segment grows a shaded vertical face + top lip.
- **Painter-sorted depth**: props, beacons, creatures and hero draw back-to-front
  by ground-Y, so you walk *behind* trees and *in front of* walls correctly.
- **Sky stays level**: backdrops, vistas and clouds render tilt-free, exactly as
  in 2D; camera, culling, minimap and target arrow account for the taller view.

All world coordinates, collision, AI, waves, drops, saves (`localStorage`) and
`?wallpaper=1` background mode behave byte-identically to the 2D original.

## Play

Open **`index.html`** (no build step, works offline except Google Fonts), or:

```powershell
python3 -m http.server 8123
# → http://localhost:8123/index.html
```

Same controls and meta game as the original: hero fights automatically, you steer
the Forge/Ascend; wheel zooms, P/Esc pauses.

## Files

| file | what |
|---|---|
| `index.html` | the full game, 2.5D renderer (this is what Pages hosts) |
| `2d-original.html` | untouched 2D original, for diffing |
| `threejs-3d.html` | earlier experimental Three.js rebuild, kept for reference |
| `revenant_assets.zip`, `sprite_preview.png` | carried over from the original repo |
| `Start/Stop-DesktopBackground.ps1` | original wallpaper scripts (work with `index.html`) |

## Patch anatomy (all in `index.html`, search `2.5D`)

`TILT`/`TILT_INV`/`viewHT()` + tilted camera transform in `render()` (backdrop
split into an untilted pass via `drawBackdrop()`), `drawSpriteV()` /
`drawSpriteTintedV()` foot-planted painters, wall faces in `drawWallSeg()`,
flat/stand split in `drawProp()`, standee extractors (`drawBeaconFull`,
`drawFlybyFull`, `drawEnemyFull`, `drawAllyFull`, `drawHeroFull`) dispatched
Y-sorted, enemy HP bar re-anchored above heads. Verified headless: 44 s run →
wave 4, 129 kills, level 8, zero console errors.

## Credits

- Game, pixel art (*DungeonTileset II* by **0x72**, CC0), fonts (OFL), procedural
  Web Audio: the 2D original and its authors. 2.5D conversion: render-path only.
