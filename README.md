# Incremental Survivors 3D — top-down perspective

### ▶ Play it now: **https://kamilch1k.github.io/incremental-survivors-3d/**

The **complete original game** — same maps, tiles, sprites, background vistas,
champions, realms, abilities, bosses, Forge, Ascend, audio and UI as
[`kamilch1k/incremental-survivors`](https://github.com/kamilch1k/incremental-survivors)
— rendered with a **true top-down 3D perspective camera**. No gameplay, balance,
asset or logic file was touched; only the paint path changed.

## What "3D" means here

A real pinhole camera sits behind + above the hero, looking down-forward:

- **Perspective floor** — the realm plane (baked once per run from the original
  `drawRooms()` output, flat decor included) is reprojected every frame in
  scanline strips, so tiles shrink toward a **horizon with sky + realm vista**
  (crypt arches, green hills, heaven temple, inferno spires) above it.
- **Depth attenuation** — near enemies tower, far ones shrink; flyers (birds,
  wisps, wraiths, clouds) float at real heights above the ground.
- **Standing billboards** — hero, enemies, bosses, allies, beacons and props are
  camera-facing vertical sheets with feet planted and shadows.
- **3D wall boxes** — every wall segment is a raised box with front face + top
  face + highlight lip, correctly occluded back-to-front with everything else.
- **Ground decals in perspective** — auras, novas, pools, mines, boss telegraphs
  project as floor ellipses; bolts, beams, damage numbers and particles all live
  in the same 3D space.
- Minimap, HUD, boss bar, menus and `?wallpaper=1` background mode unchanged.

## Play

Open **`index.html`** (no build step, works offline except Google Fonts), or:

```powershell
python3 -m http.server 8123
# → http://localhost:8123/index.html
```

Same game as the original: hero fights automatically, you steer Forge/Ascend;
wheel zooms the camera (closer/lower when zoomed in), P/Esc pauses.

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
`COLLECT_WALLS` box capture in `drawWallSeg`), `camSetup()` / `proj()` pinhole
model, `bbDraw()` billboards, `gEll()` / `ring3()` / `burst3()` / `glow3()` /
`fill3()` / `quadImg()` screen-space ground effects, `wallBox()`, per-type
painters (`enemy3`, `hero3`, `beacon3`, `prop3`, `flyby3`, `ally3`, `decal3`,
`air3`) dispatched depth-sorted far-to-near in `render()`.
Verified headless (real-time): 40 s run → wave 4, 83 kills, level 6, zero
console errors; screenshots confirm perspective floor, horizon, wall boxes.

## Credits

- Game, pixel art (*DungeonTileset II* by **0x72**, CC0), fonts (OFL), procedural
  Web Audio: the 2D original and its authors. 3D perspective conversion:
  render path only.
