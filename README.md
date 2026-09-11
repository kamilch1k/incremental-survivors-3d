# Incremental Survivors — isometric

### ▶ Play it now: **https://kamilch1k.github.io/incremental-survivors-3d/**

The **complete original game** — same maps, tiles, sprites, champions, realms,
abilities, bosses, Forge, Ascend, audio and UI as
[`kamilch1k/incremental-survivors`](https://github.com/kamilch1k/incremental-survivors)
— rendered in **true isometric 2:1**. No gameplay, balance, asset or logic was
touched; only the paint path changed.

## What "isometric" means here

- **Diamond tilemap, full screen** — the realm floor (baked once per run from the
  original `drawRooms()` output, flat decor included) is drawn in a single
  isometric transform, so every pixel is world: no sky, no void, no gaps.
- **Standing billboards** — hero, enemies, bosses, allies, beacons and props are
  vertical sheets with feet planted and shadows, at exact original proportions.
- **Iso wall boxes** — every wall segment is a raised box (two shaded faces +
  top face + highlight lip), depth-sorted back-to-front by ground depth with
  everything else, so you walk behind trees and in front of walls.
- **Iso ground decals** — auras, novas, pools, mines, boss telegraphs project as
  floor ellipses; bolts, beams, damage numbers and particles all live in the same
  isometric space; flyers float at real heights.
- Minimap, HUD, boss bar, menus and `?wallpaper=1` background mode unchanged.

## Play

Open **`index.html`** (no build step, works offline except Google Fonts), or:

```powershell
python3 -m http.server 8123
# → http://localhost:8123/index.html
```

Same game as the original: hero fights automatically, you steer Forge/Ascend;
WASD/arrows nudge the hero relative to the isometric view (W = screen-up);
wheel zooms, P/Esc pauses. The camera smoothly follows the hero's body-center;
hero base speed is +18% with snappier acceleration versus the 2D original.

## Files

| file | what |
|---|---|
| `index.html` | the full game, 3D perspective renderer (this is what Pages hosts) |
| `2d-original.html` | untouched 2D original, for diffing |
| `threejs-3d.html` | earlier experimental Three.js rebuild, kept for reference |
| `revenant_assets.zip`, `sprite_preview.png` | carried over from the original repo |
| `Start/Stop-DesktopBackground.ps1` | original wallpaper scripts (work with `index.html`) |

## Patch anatomy (all in `index.html`)

`bakeFloor3D()` (called from `startRun()` / `applyRealFloors()`, renders the realm
into `floorCv` at 0.5× via a temporary `ctx` swap + `FULL_FLOOR` viewport +
`COLLECT_WALLS` box capture in `drawWallSeg`), `isoSetup()` / `iproj()` 2:1
projection, `isoBb()` billboards, `isoEll()` / `ring3()` / `burst3()` /
`glow3()` / `fill3()` / `isoQuad()` screen-space effects, `isoBox()`, per-type
painters (`isoEnemy`, `isoHero`, `isoBeacon`, `isoProp`, `isoFlyby`, `isoAlly`,
`isoDecal`, `isoAir`) dispatched depth-sorted back-to-front in `render()`.
Verified headless (real-time): 40 s run → wave 4, 86 kills, level 6, zero
console errors; screenshots confirm diamond floor, wall boxes, sorting.

## Credits

- Game, pixel art (*DungeonTileset II* by **0x72**, CC0), fonts (OFL), procedural
  Web Audio: the 2D original and its authors. 3D perspective conversion:
  render path only.
