# Incremental Survivors 3D (billboard / 2.5D rebuild)

Copied from [`kamilch1k/incremental-survivors`](https://github.com/kamilch1k/incremental-survivors)
(`2d-original.html` in this folder is the untouched 2D original) and rebuilt as **straight-up 3D**
with the exact look you asked for:

- **Pixel-art map as a plane** — each realm bakes a chunky pixel tile canvas
  (dungeon stone / greenwood grass / heaven marble / inferno ash) and stretches it over
  ONE `THREE.PlaneGeometry` ground slab with rim + under-box so it reads as a floating
  diorama. No 3D terrain sculpting — just the flat pixel map.
- **All characters as flat vertical sheets** — hero, every enemy, boss, prop
  (tree / pillar / torch / crystal / chest / beacon) is a `PlaneGeometry` standing
  upright on the plane, Y-billboarded every frame (`rotation.y` yaws to the camera,
  never tips over). Blob shadows ground them.
- True 3D where it helps game feel: perspective follow camera, fog + hemisphere/
  directional lighting per realm, 3D XP/gold gems (octahedrons), expanding nova rings
  and boss telegraph rings lying on the plane, HTML damage numbers projected from 3D.

## Play

Open **`index.html`** in a modern browser (internet needed once for the Three.js CDN
+ Google Fonts), or serve the folder:

```powershell
cd incremental-survivors-3d
python3 -m http.server 8123
# → http://localhost:8123/index.html
```

- Pick a **champion** (8, same roster/mods as 2D) and a **realm plane** (4, same
  unlock requirements), hit **▶ Start Run**.
- The hero auto-moves and auto-fights; WASD is an optional nudge. Wheel zooms the
  3D camera, P/Esc pauses.
- Same loop as the original: waves scale with time, boss every 5 waves with
  telegraphed slam + summons, XP gems → level-up choices (orbs / bolts / nova /
  chain / aura / wraiths / axes…), beacons/chests (cache / surge / arsenal / heal),
  victory at level 50, gold Forge + soul Ascend persisted in `localStorage`
  (`is3d_save_v1`, separate from the 2D save).
- `index.html?wallpaper=1` starts a hands-free Dungeon run with the side panel
  hidden (use in Lively Wallpaper or similar).

## Files

| file | what |
|---|---|
| `index.html` | the whole 3D game (Three.js via CDN, no build step) |
| `2d-original.html` | untouched copy of the 2D original for reference |
| `revenant_assets.zip`, `sprite_preview.png` | carried over from the original repo copy |
| `Start/Stop-DesktopBackground.ps1` | original 2D wallpaper scripts (kept; use `?wallpaper=1` on `index.html` for the 3D one) |

## Tech notes

- `three@0.160.0` via importmap (`unpkg`), `NearestFilter` canvas textures for
  crisp pixels, shared unit-plane geometry with feet origin.
- Prop pixel art (`tree`, `pillar`, `torch`, `crystal`, `bones`, …) reuses the
  2D original's `PAL` + `bakeArt` rows; hero/enemy sheets are small procedural
  pixel painters with 2-frame walk animation.
- Enemy cap (~90, 150 in nightmare), pooled HTML damage numbers, cached
  projectile textures — fine on integrated graphics.

## Credits

- Base game + pixel art concept: 2D original (CC0 tiles by 0x72, OFL fonts,
  procedural Web Audio). 3D rebuild: same systems, new renderer.
