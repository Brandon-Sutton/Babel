# BABEL: Art Bible and PixelLab Pipeline

This document defines how BABEL looks and how its art is made. It is the source of truth for visual specs, palettes, PixelLab recipes and costs, and the **asset registry** (every generated asset and its PixelLab ID).

**Status:** v0.1. The palette and recipes are provisional until the style anchor is approved (PIPE-001 and PIPE-002 in [BACKLOG.md](BACKLOG.md)).

---

## 1. Target look: "grim baroque: Symphony of the Night's readability, devotional horror's soul"

- **Devotional horror, readable first (decided 2026-10-16).** Heavy inspiration from *Blasphemous* 1 and 2 and *Fear & Hunger* (GDD §4.6–4.7): ornate religious architecture and iconography (gold leaf, reliquaries, votive candles, sewn mouths, wings nailed to brick), gore and body horror drawn with care, deep shadows lit by candle, ember and kiln light, and a desaturated base with crimson, tarnished gold and bone accents.
- **Dark never means muddy.** The silhouettes stay tall and readable, with flowing mantles and big bosses, and every enemy, hazard and pickup reads at a glance against its background. The grotesque is ornate and sad, never shapeless.
- **More pixels per thing:**
  - Elam is about 90 px tall, versus about 48 px for Alucard. That gives roughly 3.5× the pixel area per character.
  - The screen is 640×360, about 4× SotN's pixel count, so rooms can carry far more architectural detail.
- **More depth:**
  - 4–7 parallax layers per room.
  - Atmospheric tinting by distance.
  - Normal-mapped sprites lit by 2D lights.
  - Sparse dark foreground silhouettes.
  - Particles: dust motes, embers, rain and bubbles.
  - HDR glow on magic only.
- **Never break the grid.** No rotation, non-integer scaling or sub-pixel blending of sprites. Effects that need rotation (some boss parts, spinning projectiles) use frames drawn rotated, or rotate in exact 90° steps. The one exception is large boss parts deliberately rotated on bones; that is allowed and reviewed case by case.

## 2. Resolution, grid and size classes

| Spec | Value |
|---|---|
| Internal resolution | **640×360** |
| Display scaling | Integer only: 2× (1280×720), 3× (1920×1080), 4× (2560×1440), 6× (3840×2160). Other resolutions are letterboxed. |
| Tile size | **16×16** |
| Map cell (one screen) | 640×360 = 40 × 22.5 tiles. Room bounds are measured in pixels in whole cells. In odd-height rooms the bottom half-row is solid fill beneath the floor. |
| Hero | About **90 px** tall standing (the approved anchor is 91 px on a 96×96 PixelLab canvas), about 25% of screen height. Fixed frame canvas **128×128**, anchored at bottom-center (feet). The user chose this size on 2026-10-14 for more pixel detail. |
| Small enemy | ≤ 40 px (bats, masks, wisps) |
| Medium enemy | 64–112 px (soldiers, ghouls) |
| Large enemy | 128–176 px (brutes, golems) |
| Boss | 192–256 px single sprite, or **part-based** (recommended above 192 px) |
| Item icon | 16×16 (inventory), 32×32 (item-get banner) |
| Portrait | 64×64 (dialogue), 128×128 (key scenes) |
| Pixel font | 8 px (HUD and body text), 16 px (titles) |

## 3. Palette

### 3.1 Master ramps (v1, PIPE-002, 2026-10-14)

- **Source of truth:** `babel/assets/palettes/master.gpl`, a GIMP palette with ramps named `<ramp>_<n>`. Regenerate `master.png` (one row per ramp) and `master.hex` with `palette_tool.gd gpl`.
- **Where the colors come from:** the approved Elam anchor, plus the region ramps from v0.
- **Review sheet:** `docs/art_reviews/2026-10-14_master_palette_v1.png`.

| Ramp | Dark → light (hex) | Use |
|---|---|---|
| Bitumen | `#020202` `#111011` `#161616` `#242022` `#29292a` `#3b3534` `#464342` `#6c6765` | Cape, boots, outlines, dark stone |
| Indigo | `#16131f` `#2e2939` `#4b3d6e` `#8b7fb8` `#d4cdf0` | Elam's coat; night sky; deep shadows |
| Gold | `#614224` `#82633f` `#9f7345` `#ac864b` `#c59c5c` `#d4b06e` `#fbe69b` | Braid, trim, relics; **shared with olive skin** |
| Crimson | `#380611` `#671120` `#c0263c` `#ef6a6a` | Cape lining, blood, crimson magic |
| Silver | `#8a7e71` `#948984` `#a8a196` `#adb2b5` `#c2c3c3` `#d8d8d7` `#f3eeec` | Hair, steel, moonlight |
| Lapis | `#1b2a5c` `#2c4a9a` `#3d64b5` `#4f7fd1` `#9cc3f0` | Glyph glow, glazed brick, water magic |
| Bone | `#6f6553` `#b3a684` `#e8dfc4` `#fff8e6` | Parchment, bone, UI text |
| Terracotta | `#4a1f17` `#7c3524` `#b45a37` `#df9161` | Mudbrick, kilns |
| Verdigris | `#183a33` `#2f6b55` `#5fa37c` `#a8d8a0` | Gardens, oxidized bronze |

**Per-character palettes:** `babel/assets/palettes/<character>.png`/`.hex` hold the character's exact colors, extracted with `palette_tool.gd extract`. `elam.png` has 32 colors.
- Lock every new animation's frames to it: `reduce_colors` with `palette_image_url` pointing at that file (upload it with `get_upload_url`).
- The anchor itself was reduced from 75 AI colors to 32 with `reduce_colors` (job `6a0442be`). Visually it's identical.

### 3.2 Region accents (each region adds 2–3 ramps to the master)

| Code | Region | Accent ramps | Fog / ambient tint |
|---|---|---|---|
| SHN | Plain of Shinar | Night sky, ember orange | Indigo |
| GTE | Grand Gate | Lapis, gold | Deep blue |
| FND | Foundation | Terracotta, soot, kiln red | Smoky brown |
| GRD | Hanging Gardens | Verdigris, jade, gold | Green-teal haze |
| ARC | Hall of Tablets | Parchment, lamp gold, ink | Warm sepia |
| COL | Colosseum Tiers | Sandstone, sunset crimson | Dusky orange |
| CIS | Cisterns | Teal, drowned blue | Blue-green |
| CAT | Cathedral of Bells | Stained-glass jewel tones, candle amber, violet | Violet |
| UND | Underworks | Bone, ash, sickly green | Near-black green |
| ORR | Orrery | Brass, starlight, navy | Navy |
| FDY | Iron Foundry | Rust, coal, molten orange | Red-brown smog |
| WIR | Wire Spire | Slate, sodium yellow, electric cyan | Grey-blue |
| SUM | Gate of the Gods | Gold, white, deep night | Starlit black |
| Act II | Abzu Reflection | Shift every region toward teal and violet; lower saturation | Water-caustic overlay |

### 3.3 Palette rules

- **Hue-shift every ramp:** shadows move toward violet or blue, highlights toward warm yellow. Never darken with pure black or lighten with pure white.
- **Color limits:** at most 32 colors per hero-size character (about 24 for smaller sprites) and about 48 per region tileset. All of a character's frames share **one** palette, locked with `reduce_colors` and the character's palette file (§3.1).
- **Readability by layer:** the gameplay layer (anything you can stand on or that can hurt you) has the strongest contrast and a lit top edge. Background layers are darker and lower in saturation. Enemies separate from the background through warm/cool contrast.
- **Palette swaps:** enemy variants use a palette-swap shader on one sprite (AI-004), not regenerated art.

## 4. Light, shading and outline

- **Authored light** comes from the **upper left**. Generate sprites with *medium* shading so that dynamic 2D lights do not double up on the baked shading.
- **Outlines:** characters and enemies use a **selective outline** (dark outline that lightens where the light hits). Tiles use selective or none. Backgrounds have none.
- **Dynamic light:**
  - `CanvasModulate` sets each room's ambient level, from 0.35 (dark) to 0.8 (exterior).
  - Lamps and magic are `PointLight2D`s.
  - Sprites carry normal maps through `CanvasTexture`.
  - A canvas `light()` shader quantizes light into **3–4 bands**, so lighting looks hand-shaded instead of airbrushed.
- **Glow** (HDR 2D plus a WorldEnvironment) is reserved for magic, embers, molten metal and holy light. Exceeding 1.0 brightness is an intentional effect, never the default.

## 5. Depth layers

The z-index and CanvasLayer numbers are defined in [CLAUDE.md](../CLAUDE.md#rendering-order).

| Layer | Node | `scroll_scale` | Content | Treatment |
|---|---|---|---|---|
| Sky / far | `Parallax2D` | 0.0–0.1 | Sky, moon, distant tower silhouettes | Lowest saturation; 70% toward the fog color |
| Far architecture | `Parallax2D` | 0.2–0.35 | Distant arches and terraces | 50% toward fog |
| Mid architecture | `Parallax2D` | 0.5–0.65 | Columns, windows | 30% toward fog |
| Near background | `Parallax2D` | 0.8–0.9 | Pillars, chains, banners | 15% toward fog |
| Back wall | `TileMapLayer` "BackWall" | 1.0 | Wall the player walks in front of | Darkened about 30%; no collision |
| **Gameplay** | `TileMapLayer` "Solid" and "Platforms", plus actors | 1.0 | Floors, walls, platforms, everything interactive | Full contrast |
| Foreground | `Parallax2D` 1.15–1.3, or `TileMapLayer` "FgDeco" | >1.0 | Silhouetted pillars, vines, chains | Nearly black and sparse. **Never hides a hazard or pickup.** |
| Atmosphere | `GPUParticles2D`, light shafts | — | Dust, embers, rain, bubbles | Additive or mix blending, low alpha |

## 6. Animation guidelines

### 6.1 Elam's animation set (all facing east; mirrored for west with `flip_h`)

| Animation | Frames | FPS | Notes |
|---|---|---|---|
| `idle` | 8 | 8 | Breathing and mantle sway |
| `walk` | 8–10 | 12 | |
| `run` | 8 | 14 | Per weapon type (`<stance>_run`). Until it exists the walk plays at 1.6× (`run_anim_scale`) |
| `turn` | 3 | 15 | |
| `jump_up` / `jump_apex` / `fall` | 2 / 2 / 2 | 10 | Loop the last frame |
| `land` | 3 | 15 | |
| `crouch` / `stand_up` | 2 / 2 | 15 | |
| `back_dash` | 4 | 15 | Low and gliding, like SotN |
| `attack_slash` | 6–8 | 20 | 1–2 anticipation frames, 2 active, 3 recovery |
| `attack_stab` | 6 | 20 | Short swords and spears |
| `attack_heavy` | 8–10 | 16 | Great swords and maces |
| `crouch_attack` | 6 | 20 | |
| `jump_attack` | 6 | 20 | |
| `guard` | 3 | 15 | Shield raised; hold the last frame |
| `hurt` | 3 | 12 | |
| `death` | 10 | 10 | |
| `cast` | 8 | 14 | Throat glyphs glow (lit through an emission mask) |
| `throw` | 6 | 18 | Relic Arms |
| `double_jump` | 6–8 | 18 | Somersault |
| `dive_kick` | 3 | 15 | |
| `swim` | 8 | 10 | |
| `transform` | 8 | 16 | Shared start of all form changes |
| `item_get` | 4 | 10 | Relic pickup pose |
| `interact` | 2 | 10 | Reading or looking up |

That is about 24 animations at roughly 2.5 generations each.

### 6.2 Animation rules

- **Anchor:** feet at bottom-center, identical in every frame and every animation. The importer pads all frames to the character's fixed canvas.
- **Weapons are separate sprites** attached to a hand bone or offset track. One set of attack animations then serves every weapon in a class, which is a big generation saving.
- **Frame data lives in the AnimationPlayer** (hitbox on and off, SFX, VFX), not in the art.
- **Smears:** fast attacks get one or two smear frames, either generated or painted with `pixelart_workbench`.
- **Severable boss parts (GDD §7, BOSS-030):** each severable part is drawn twice on the same canvas and pivot: the part itself, and the layer beneath it (stump, bone, wet flesh, or what hides under it, such as eyes under an angel's face). The torn-off piece that falls away is the part sprite itself. Generate the beneath layer from the part image (inpaint or edit) so the two line up exactly.

### 6.3 Guide-prop rig: attach points for visible equipment (EQV-002, 2026-10-15)

Every item Elam equips is drawn on him (GDD §6.7), so each body frame needs to know where his hand, head, chest, belt and ankles are. PixelLab draws flat frames, so the attach points come from a **guide prop**.

**Recipe:**
1. Paint a key-green rod (`#00ff00`, 2 px, with a darker edge) into the right fist of a start frame. Use `art_src/pixellab/characters/hero/rig/paint_guide_rod.py`.
   - Standing: `rig/start_standing.png`.
   - Crouched: `rig/start_crouched.png`, which is the last frame of `rig_crouch`.
2. Upload it with `get_upload_url`.
3. Animate the **stored character** with `animate_character(mode:"pixminimax", directions:["east"], custom_start_frame_url:"upload:<id>")`. In `action_description`, say that the right hand keeps gripping the bright green rod. About 1 gen per animation.
   - **Don't use `animate_image_pixminimax` on a loose image for attacks.** Twice it turned Elam's back to the camera mid-swing. The stored character keeps him in profile.
4. Mark the animation `"guide_prop": true` in `import.json`.
   - The importer (`GuideProp`) fits the rod's axis, finds the grip where the fist covers it, and stores `hand_r` (x, y, angle) per frame.
   - It erases the rod. Pixels over the body are filled from neighbours; the rest become transparent.
   - It moves a key-green **swing smear**, with its white core, to `<slug>_smear.png`. The rig tints the smear with the weapon's `slash_color`.
   - Body points are measured from the silhouette for every animation: `head`, `neck`, `chest`, `belt`, `hand_l` (chest + (4, 10)), `ankle_f` and `ankle_b`.
5. Review with `tools/import/anchor_review.gd`. `tests/visual/equipment_test.tscn` checks every frame automatically.

**Per-weapon animations (EQV-015):**
- Name them `<weapon>_<animation>` (`scythe_attack`) and list them in the weapon's `WeaponData.animations`.
- Give the start frame the weapon's own hold. The scythe uses `rig/start_standing_pole.png`: a long pole held upright, made with `paint_guide_rod.py ... 51,68 41,6`.
- **Never name the weapon in the prompt.** "Scythe reap" made the model paint its own scythe blade and a dark arc that the key can't remove. Describe a "plain bright green pole" and only the motion.
- A swing drawn without a smear gets the procedural arc in the weapon's colour.
- **One set per weapon type (EQV-017):** each type has its own start frame with its own hold, painted with `paint_guide_rod.py <east.png> <out> <preview> butt tip`:
  - `start_sickle.png` (44,55 → 80,52), level forward.
  - `start_mace.png` (48,48 → 50,82), hanging.
  - `start_greatsword.png` (42,61 → 84,19), raised guard.
  - `start_standing_pole.png`, the scythe.
  - Crouching attacks start from the set's own crouch end frame (`start_crouched_<type>.png`) and are pinned with an end frame (`end_crouched_<type>.png`, made by `repaint_rod.py`).
  - PixelLab runs at most 8 jobs at once.
  - **Operational limits:**
    - The character export ZIP returns an error ("still being generated", HTTP 423) until every queued job finishes, so download after the whole batch.
    - `get_upload_url` links last 15 minutes; uploads are kept for 3 days.
    - Frame links from `get_character` only work with their `?t=` query.
    - Generations refill around the 17th of each month (Tier 1: 2,000).
  - **Before importing,** check raw frames with `art_src/pixellab/characters/hero/rig/review_rod.py <frames_dir> <out.png>`. It prints each frame's grip and angle and draws them.
  - A wide two-handed grip is anchored on the rear fist.
- **Two-handed stance set (EQV-016, now the `scythe_*` set):** `two_handed_*` animations from the upright-pole start frame, and `rig/start_crouched_pole.png` for the crouching slash. Every two-handed weapon uses this set unless it names its own `stance`.
- **When the model swings the wrong way, pin the end pose.** Pass `end_frame_url` with a copy of the start frame whose rod is erased and repainted in the target direction, as was done for `rig/end_crouched_pole_chop.png`.
- The model may paint a smear in **magenta** instead of key green; the importer treats saturated magenta as smear too.
- Crouched poses can sit 2 px under the ground line. Fix them with `"lift": -2`.

**Worn art (EQV-008):**
- Hand items are drawn pointing right with the grip at `WornArt.pivot`, and turn with the hand.
- Everything else stays upright on its point.
- Batch 1 is drawn in code by `tools/builders/build_worn_art.gd`, as placeholder quality. A PixelLab PNG can replace any of them without data changes.

**Body armor and mantles** don't need art. `equipment_dye.gdshader` recolors the steel **plates** below the neck, and the crimson cape **lining**, onto the item's three-color ramp.

## 7. PixelLab recipes

Before calling any PixelLab tool, load its schema with ToolSearch (`select:mcp__pixellab__<tool>`), because the tools are deferred. Costs come from the tool schemas as of 2026-10-14. The response's cost line is authoritative, so record it in the registry.

### 7.1 Recipe table

| Asset class | Tool | Key parameters | Cost (gens) | Notes |
|---|---|---|---|---|
| Hero, NPC or humanoid enemy (rigged) | `create_character` | `view:"side"`, `mode:"v3"` (best) or `"standard"` (cheap tests), `size` 64–96, `outline:"selective outline"`, `detail:"high detail"` | standard 1 · v3 2–9 · pro 10–25 | Use the **east** facing; mirror for west. v3 without a reference image always makes 8 directions. |
| New character in an approved style | `create_character_pro_flash` with `style_image` set to the anchor, or `create_character` with `mode:"pro"` and `style_character_id` | `view:"side"`, width/height in multiples of 4 | Check with `get_pro_flash_capabilities` (free) | `style_character_id` requires an 8-direction anchor |
| Character animation | `animate_character` | `directions:["east"]`, `mode:"v3"` with `action_description`, or `"template"` with `template_animation_id` (walk, run, idle), `keep_first_frame:false` | template 1 per direction; v3 `ceil(w·h·frames/65536)` per direction (64 px at 8 frames = 1; 96–128 px = 2–3) | Use v3 first, then pixminimax for long clips (up to 40 frames). `delete_animation` before re-rolling. |
| Non-humanoid enemy or creature | `create_object_pro_flash` (`n_directions:1`, `view:"side"`), then `animate_object` (`mode:"v3"`) | Up to 256 px | Image cost plus v3 animation | Quadrupeds such as Lion form and hounds can use `create_character` with `body_type:"quadruped"` and `template` lion or dog for rigged animation |
| Boss (part-based) | `create_object_pro_flash` or `create_image_pro` for each part (head, torso, arms…) | Transparent background | ~10–40 per boss | Assemble with `Skeleton2D` or Node2D plus AnimationPlayer |
| Sidescroller tileset | `create_sidescroller_tileset` | `tile_size:16`, `lower_description` (body material), `transition_description` (top surface), `transition_size` 0–0.5, chain `base_tile_id` within a region | **2–3** | Inspect the returned layout once, then map it into a Godot terrain set (PIPE-006) |
| Back-wall texture / seamless fill | `create_image_pixen` | 64–128 px square, multiple of 4, prompt "seamless tileable" | **1** | Check seams by tiling 3×3 in a test scene; fix with `pixelart_workbench` |
| Background layer | `create_image_pixen` | Up to 680×384 (area ≤ 512²), `no_background:false` for opaque far layers, `true` for cutouts | **1** | Cheapest high-res option. For a forced palette, use `create_image_pixflux` with `color_image_url` (≤ 400 px) or run `reduce_colors` afterwards |
| Hero-quality background or key art | `create_image_pro` | Up to 688×384, `palette` as hex list, `reference_images` | 10–25 | Use sparingly (title screen, boss arenas) |
| Props and decor (batch) | `create_1_direction_object` | `view:"sidescroller"`, `size` (≤ 42 → 64 candidates, ≤ 85 → 16, ≤ 170 → 4), `item_descriptions` for distinct items | 10–25 per call | One call can fill a region's prop list. Finalize with `select_object_frames`. |
| Prop matched to a background | `create_map_object` | `view:"side"`, `background_image` for style matching | See response | |
| Item icons (batch) | `create_1_direction_object` with `size` ≤ 32 and up to 64 `item_descriptions`; or `create_image_pro` at 16–32 px | 64 per call | 10–25 per call | Pack into an atlas (PIPE-009) |
| Normal map | `create_normal_map` | `image:"character:<id>:east:<animation>"` returns a strip, `convention:"opengl"` | **0.5** | Pair it with the diffuse sheet in a `CanvasTexture` |
| Palette lock | `reduce_colors` | All frames of an animation **together**, `palette_image_url` set to the character's palette strip | **0.1** | Prevents palette drift between frames |
| Dialogue portrait | `create_portrait_character` | `direction:"character_to_portrait"`, `view:"side"`, `result_size` 64 or 128 | 10 (≤ 64 px) / 15 (128 px) | |
| UI panels and frames | `create_ui_asset` | `style_image_base64` set to the anchor screenshot, `elements` | 10–25 | Slice into 9-patch `StyleBoxTexture` |
| Pixel font | `create_font` | `glyph_px` 8 or 16 | 15 | Returns a TTF and an atlas. There is no space glyph, so set the space advance in Godot. |
| VFX (hits, spells, auras) | `vfx_workbench` | `start [--sprite …]`, `add_part`, `render`, `export --game-pack` | **Free** | Exports a spritesheet with JSON |
| Cleanup and polish | `pixelart_workbench` | `lint`, `repair`, `selout`, `shade`, `clean-lines`, `score` | **Free** | Keep fixes with `save_to_asset` (free) |
| Fix one region of an image | `inpaint_image` | Rectangle or mask | 10–25 | **Images over 256 px need Tier 2.** We are on Tier 1. |

### 7.2 Prompt templates

- **Style suffix** (append to every sprite prompt):
  `side view, 2D action RPG sprite, grim devotional dark fantasy, ornate religious horror, ancient Mesopotamian and baroque, decayed and grotesque, 32-bit console era pixel art, rich hue-shifted shading, selective dark outline, light from upper left`
  (Tone set 2026-10-16. Keep franchise names such as *Blasphemous* out of prompts; describe the look instead.)
- **Character:**
  `<who>, <silhouette and costume>, <2-3 palette words>, full body, facing right, <style suffix>`
- **Enemy:** as for a character, plus `<threatening pose>` and `<how it attacks>` (this gives the animation stage something to work from).
- **Background layer:**
  `<scene>, side-scrolling game background, <distant|mid|near> layer, <palette words>, atmospheric depth, no characters, no text, 32-bit console era pixel art`
- **Tileset:** `lower_description` names the solid body material and `transition_description` names the surface (moss, sand, glazed tiles, rust).

**Avoid in prompts:**
- Franchise or trademark names. We want our own identity, and the models don't need them.
- `isometric` and `top-down` in side-view prompts.
- Words like "blurry", "photo" or "3D render".

### 7.3 Consistency workflow

1. **Style anchors.** Approve one anchor per asset class and record it in §10:
   - Elam (characters)
   - GTE solid tileset (tiles)
   - GTE mid-background layer (backgrounds)
   - HUD frame (UI)
2. **Characters:** pass the anchor as `style_image` or `style_character_id`.
3. **Tilesets:** chain `base_tile_id` within a region. Carry one tile over between neighboring regions so their edges match.
4. **Backgrounds:** force the region palette (pixflux `color_image_url`, or `reduce_colors` with `palette_image_url`).
5. **Animations:** run `reduce_colors` over every frame together, using the character's palette strip.
6. **Review gate:** view every asset at 1× and 4× (Read the PNG) before import. Reject it for any of:
   - mixed-resolution pixels or anti-aliased halos on transparent edges
   - colors outside the palette
   - wrong facing or inconsistent feet anchor
   - anatomy that breaks between frames
   - silhouettes that don't read at 1×

### 7.4 Proven recipe: the Elam anchor (2026-10-14)

This is the route the user approved. Reuse it for every major character (Sera, NPCs, bosses' humanoid forms).

1. **Style reference.** The user's style reference is a pixel-art gothic-aristocrat piece, kept locally at `docs/art_reviews/reference_image.png` and gitignored because it's third-party art.
   - Crop it to the figure and upload it with `get_upload_url`.
   - Run `unzoom_image` (`quantize:-1`) to recover the native pixel grid. That job is `6e98c25d-991a-4672-9303-e3295ae2493b`; pass `https://api.pixellab.ai/mcp/images/6e98c25d-991a-4672-9303-e3295ae2493b/download` as the `style_image_url`. Uploads expire after 3 days; the unzoom job output is kept in the gallery as asset `e638b8a1`.
2. **Front-facing candidates:** `create_image_pro` at 96×96, `no_background:true`, with `style_image_url` set to the unzoomed reference and all four `style_copy` aspects. It costs 10 gens for 4 candidates.
   - The prompt must state a **human** (rounded ears; "not an elf") and "front view facing the viewer".
   - Pick a candidate that is **straight-on**: a 3/4 view mislabels every direction in the next step.
3. **Rotate:** `create_character` with `mode:"v3"`, `view:"side"`, `n_directions:4` and `reference_image_url` set to the chosen candidate. It costs 2 gens and gives a rigged character, so template and v3 animations work.
4. **Identity details:** add them by hand with `pixelart_workbench edit` (`patch_pixels`, free), then `save_to_asset` back to each rotation.
5. **Review:** use `tools/import/contact_sheet.gd`, write the sheet to `docs/art_reviews/`, and get the user's approval.

**Avoid:** anything that reads as a copy of the reference's character. Each design needs its own identifying details (for Elam: olive-brown skin, gold hair rings, cylinder-seal clasp, lapis throat glyph, cuneiform-like gold cuffs).

### 7.5 Working rules for Claude sessions

- **Budget:**
  - Run `get_balance` before any batch.
  - State the estimated cost before any action over 25 generations, or any batch over 50, and get the user's OK.
  - Keep about 10% of the monthly allowance in reserve for fixes.
- **Waiting:** use `wait_for_jobs` (free) instead of sleep or poll loops.
- **Passing images:** prefer URLs, or `upload:<id>` via `get_upload_url`, over inline base64. MCP clients truncate large base64 arguments.
- **Downloading:** fetch results with `curl` into `babel/art_src/pixellab/<kind>/<slug>/`, and unzip ZIPs there. **Never copy signed download URLs into docs or code**; record only PixelLab IDs.
- **Sizing:** never rescale generated art by a non-integer factor. If the size is wrong, regenerate at the right size or use `unzoom_image` for upscaled pixel art.
- **Registry:** after each asset, update §10 with its ID, tool, cost and status.

## 8. Generation budget

The Tier 1 subscription gives **2,000 generations per month**, refilling on about the 17th. Check `get_balance`; on 2026-10-14 there were 145 left before the reset. There is also a small daily bonus once the allowance is used up.

| Asset group | Volume | Estimated gens |
|---|---|---|
| Elam: base and about 24 animations | 25 assets | ~65 |
| Elam forms: 3 forms × about 8 animations | 27 | ~70 |
| Sera: prologue moveset and boss | ~19 | ~50 |
| NPCs (5) and portraits (~15) | 20 | ~180 |
| Act I enemies: 60 × (create plus ~4 animations) | 60 | ~480 |
| Act I bosses, part-based | 14 | ~490 |
| Sidescroller tilesets: 13 regions × 3 | 39 | ~100 |
| Back-wall and fill textures (pixen) | ~40 | ~40 |
| Backgrounds: 13 × 6 layers × about 3 attempts (pixen) | 78 | ~235 |
| Props: about 20 batch calls | ~20 | ~360 |
| Item icons: about 250 in batches of 64 | ~5 | ~100 |
| UI kit and fonts | ~6 | ~90 |
| Normal maps (~350 strips) | 350 | ~175 |
| Palette locks (~400) | 400 | ~40 |
| VFX | — | 0 (free) |
| Act II content | — | ~900 |
| Rework reserve (about 15%) | — | ~500 |
| **Total** | | **~3,900** (about 2 months of allowance, spread over the schedule) |

### 8.1 Queued for the 2026-10-17 refill: the specials pass (ART-018)

The logic for running, Relic Arms, Utterances and weapon arts is in and tested with placeholder visuals (2026-10-15). Art to make, all with the guide prop (§6.3) so the weapon stays in hand:

| Art | Count | Est. gens | Placeholder today |
|---|---|---|---|
| `<stance>_run` for sword, sickle_sword, mace, greatsword, scythe | 5 | ~5 | Walk at 1.6× |
| `<stance>_throw` (Relic Arm throw) | 5 | ~5 | The stance's attack, sped up |
| `<stance>_cast` (Utterance and weapon-art wind-up, throat glyphs) | 5 | ~5 | Attack pose tinted with the spell colour |
| Art-specific attacks: thrust lunge, hooking lunge, ground smash, overhead cleave, spin | 5 | ~5 | The stance's attack plus a code-drawn arc or ring |
| Relic Arm sprites: Sling Stone, Clay Tablet (in flight and as pickups) | 2 | 0 (`pixelart_workbench`) | Code-drawn |
| Effects: Išātu bolt, Earthshaker wave, cleave and whirl smears, Relic Arm impact | 5 | 0 (`vfx_workbench`) | Code-drawn |
| Worn art for the new mantles and seals (EQV-012) | 5 | ~5 | Code-drawn |

About 25 generations in all. Ask the user before starting, since it is at the 25-generation limit.

## 9. Import pipeline (implemented in PIPE-003 to PIPE-008)

**Characters (PIPE-003, done).** Each character has a recipe at `babel/art_src/pixellab/characters/<slug>/import.json`, with the PixelLab ZIP export unzipped beside it in `export/`. The recipe lists the animations, the source names from `metadata.json`, fps or `frame_ms`, loop and grounded flags, the cell and its pivot, and the output folder. The importer (`tools/import/import_character.gd`):

- **Pivot:** takes the feet pivot from the rotation (lowest opaque row plus the boots' center). Each animation's pivot is that plus half its canvas growth, because PixelLab grows canvases evenly: a 96 rotation becomes a 132 animation, +18/+18.
- **Lift:** PixelLab paints airborne poses (a leap) above the feet line inside the canvas. A per-animation `"lift": <px>` moves those frames down so the art sits on the body that physically jumps. Measure the lowest opaque row of the frames first.
- **Packing:** packs everything with `SheetPacker`.
- **Validation:** fails on clipped frames, and on feet in `grounded` animations drifting more than 1 px off the ground line.
- **Output:** writes `<slug>.png`, `<slug>.json` and `<slug>_anims.tres`. The AnimationLibrary's tracks drive `Sprite2D:frame_coords`.

**In the scene:** `Sprite2D.centered = false`, `offset = -pivot`, with `hframes`/`vframes` from the JSON. Keep `cell_pivot.x` at the horizontal center of the cell (64 for 128) so `flip_h` (facing left) keeps the feet in place.

**Updating an animation:** re-download the export ZIP after every PixelLab change. That includes `save_to_asset` fixes and palette locks.

**Breakable tiles (WLD-006).** A hidden breakable wall reuses the plain tile's art as an alternative tile, so it costs no art; each region also wants one cracked-brick tile that shows it can be broken (WLD-024).

**Tilesets (PIPE-006, done).** Download PixelLab's `image` (use `curl -L`; it redirects) and `metadata` into `babel/art_src/pixellab/tilesets/<slug>/` next to an `import.json`. The importer (`tools/import/import_tileset.gd`):
- **Terrain:** PixelLab's 16 corner-based "Wang" tiles become a MATCH_CORNERS terrain set. Each tile's "lower" corners are terrain 0, so the terrain brush and `set_cells_terrain_connect` autotile.
- **Collision:** built from the solid corner quadrants, merged with `BitMap.opaque_to_polygons`, so floors are flat and grid-aligned.
- **Output:** `<slug>.png` + `<slug>.tres` in the region folder.

**Corner-tile caveat:** the solid edge (art and collision) sits **half a tile inside** the painted cells. WLD-023 (dual grid) will line the art up with the 16 px logic grid used by greybox rooms.

**Before saving an animation, lock its palette:**
1. Upload the frames and `assets/palettes/<slug>.png` with `get_upload_url`.
2. Run `reduce_colors` with `palette_image_url` over all the frames together.
3. Check with `palette_tool.gd extract` that every color is in the character's `.hex`.
4. `save_to_asset` to `character:<id>:east:<animation group id>`.

```
PixelLab job ─▶ wait_for_jobs ─▶ get_* (status, URLs)
  ─▶ curl ─▶ babel/art_src/pixellab/<kind>/<slug>/        (raw files; Godot ignores this folder via .gdignore)
  ─▶ review (Read PNG) ─▶ fix (pixelart_workbench ─▶ save_to_asset) ─▶ re-download
  ─▶ importer (godot --headless -s res://tools/import/<importer>.gd -- <args>)
  ─▶ babel/assets/<kind>/<slug>/<slug>.png (+ _n.png normal map) + .tres (SpriteFrames / AnimationLibrary / TileSet)
  ─▶ registry row (§10)
```

## 10. Asset registry

### 10.1 Style anchors

| Class | Slug | PixelLab ID | Approved | Notes |
|---|---|---|---|---|
| Character | `hero` | `aa0091a3-fdf9-4ffa-a82e-207c905c5126` | 2026-10-14 | **Current main character.** Made from the user's reference `assets/e99196a6-….jpg`. Route: flood-fill the checkerboard, unzoom, `create_image_pro` with the reference as design and style, candidate 1, then a v3 rotation. Side view, 88 px tall; sheet cells 160×128 with pivot (80,124). |
| Character (superseded) | `elam` | `a6fa2f9e-2d8f-435c-b6c3-c89e08dceec1` | 2026-10-14 | The earlier look, replaced by `hero` the same day. Kept for reference. |
| Tileset | `gte_solid` | `187ea0fe-4e3f-4d6f-b9e4-6cf18fb1b195` (base tile `144c7114-b7b4-49f3-b6f1-4004d3ca1beb` for chaining) | **pending the user's review** | Lapis glazed brick with a gold-gem cap, 16 px. Review: `docs/art_reviews/2026-10-14_gte_tileset*.png` |
| Background | `gte_bg_mid` | — | — | |
| UI | `hud_frame` | — | — | |

### 10.2 Assets

Status values: `concept`, `approved`, `imported`, `final`, `rejected`.

| Slug | Kind | Tool / mode | PixelLab ID(s) | Size | Gens | Status | Godot path | Notes |
|---|---|---|---|---|---|---|---|---|
| `elam` | character | `create_character` v3 with reference (from `create_image_pro` with style_image) | `a6fa2f9e-2d8f-435c-b6c3-c89e08dceec1` | 96×96 | 2 (+10 for candidates, 0.1 unzoom) | approved | `art_src/pixellab/characters/elam/` (not yet imported) | **Style anchor.** Front source: image job `663ab2ea` index 3. East and south edited with the workbench (hair rings, clasp, throat glyph). |
| `mudborn` | enemy character | Pro Flash, style ref = hero south rotation; walk with v3 | `459332da-68b7-4dd5-a1fc-c021ed3a9e87` (walk group `91afbb0f`) | 96×96 → 128×128 cells | 10 | imported | `assets/sprites/enemies/mudborn/` | Clay golem with brick chunks and ember eyes. Idle = walk frame 0. |
| `gate_spearman` | enemy character | Pro Flash, style ref = hero; walk with v3; thrust, sweep, anti_air, cast and leap with **PixMiniMax** | `34128d92-d7bb-4210-b36f-d66d7112add1` (walk `45d3d164`, thrust `c1e106eb`, sweep `50b04977`, anti_air `7f951b80`, cast `88715c3d`, leap `7ad06154`) | 192×132 cells | 15 | imported | `assets/sprites/enemies/gate_spearman/` | Each attack is split into wind-up, active and recover: thrust 0-2 / 3-5 / 6-7, sweep 0-2 / 3-4 / 5-7, anti_air 0-1 / 2-4 / 5-7, cast 0-4 / 5 / 6-7, leap 0-1 / rise 2-4 (lift 13) / plunge 5 (lift 18) / land 6-7. Painted spear positions, relative to the feet: thrust y −53..−46 reaching x 65; anti-air tip (58, −87); plunge tip about (32, −18) before lift. Dark against dark walls; see VFX-016. |
| `spearman_fireball` | VFX sprite | cropped from `gate_spearman` cast frame 5 (no generation); hand and gauntlet pixels keyed out | — | 33×20, core at (25, 9) | 0 | imported | `assets/sprites/vfx/spearman_fireball/` | Used by `Fireball`, so the hand-off from the cast frame is seamless. It flickers by flipping vertically every 4 frames. |
| `humbaba_mask` | enemy sprite | `create_image_pixen` 40×40 | job `3b96cc79` | 40×40 | 1 | imported | `assets/sprites/enemies/humbaba_mask/` | Static sprite; bob and sine motion in code. |
| `votive_lamp` | prop | `create_image_pixen` 32×48 | job `c357e6d1` | 32×48 | 1 | imported | `assets/sprites/props/votive_lamp.png` | Halo flicker drawn in code. |
| `save_altar` | prop | `create_image_pixen` 64×64 | job `1ec16471` | 64×64 | 1 | imported | `assets/sprites/props/save_altar.png` | |
| `hero` animations (superseded 2026-10-15) | idle, walk, jump (→ jump and fall), crouch, back-dash, hurt (v3); attack and crouch_attack (**PixMiniMax**, 1 gen each; the v3 attack had no swing and was rejected) | groups idle `9ab4d829`, walk `6204fe3a`, jump `cc9591a2`, crouch `c691c600`, backdash `2c85c53e`, hurt `23c740a6`, attack_sword `f6ea6ebc`, crouch_attack `780ffc93` (frames 0-5; 6-7 stand up and are dropped) | 132×132 | ~20 | imported | `assets/sprites/player/hero/` | **Lesson:** use `mode:"pixminimax"` for weapon actions; v3 doesn't render swings. Palette lock still to do. |
| `hero` guide-prop animations | idle, walk, jump (→ jump [2-4] and fall [5-7]), crouch, back-dash, hurt, attack and crouch_attack, with the key-green rod (**PixMiniMax** on the stored character, custom start frame) | groups rig_idle `1f4bb90d`, rig_walk `e6784974`, rig_jump `450d9eca`, rig_crouch `1e8a47ef`, rig_backdash `9b1b959c`, rig_hurt `bae328b9`, rig_attack `88fe0fd5`, rig_crouch_attack `71dcf536` | 132–204 px canvases → 208×136 cells, pivot (104,124) | 8 (+3 for the loose-image experiments) | imported | `assets/sprites/player/hero/` (+ `hero_smear.png`) | Frame 0 of each group is the start frame and is skipped. The attack's smear is frames 4–5 and the crouching slash's is frame 2. Every frame carries attach points. |
| `hero` scythe animations | scythe_idle, scythe_walk, scythe_attack (guide prop, upright-pole start frame) | groups rig_scythe_idle `1fe6d8c7`, rig_scythe_walk `ab61ffcc`, rig_scythe_attack `b92272f0` (first attempt `7d2284c7` deleted: painted blade) | 132-184 px → 208x136 cells | 4 | imported | `assets/sprites/player/hero/` | The reap has no smear, so the SlashFX arc stands in. |
| `hero` two-handed set | two_handed_jump/fall, crouch, crouch_attack, backdash, hurt (+ idle, walk, attack from the scythe groups) | groups rig_2h_jump `66209a8b`, rig_2h_crouch `b4e93086`, rig_2h_backdash `148d4f63`, rig_2h_hurt `b2fd43a1`, rig_2h_crouch_attack `c257a8a7` (end-frame pinned; first attempt `d57a2bdf` deleted: reaped backward) | 132-188 px → 208x136 cells | 7 | imported | `assets/sprites/player/hero/` | The crouch and crouching slash use `lift: -2`. The slash's smear came out magenta. |
| `hero` weapon-type sets | sickle_sword_*, mace_*, greatsword_* (idle, walk, jump/fall, crouch, crouch_attack, backdash, hurt, attack) | rig_sickle_* (idle `4b9afd6d`, walk `00d58c55`, jump `1c53318e`, crouch `650949c5`, crouch_attack `9c573707`, backdash `a16d211a`, hurt `cd347713`, attack `2deb864b`); rig_mace_* (idle `4bb710d5`, walk `32c5e4ed`, jump `60dbcd80`, crouch `3f838528`, crouch_attack `2324ea41`, backdash `af4cc7a5`, hurt `e010461e`, attack `66689a32`, first attempt `aa96826f` deleted); rig_greatsword_* (idle `dc929a84`, walk `7da75917`, jump `3e9d5a0d`, crouch `8a8c0950`, crouch_attack `ec2b11f9`, backdash `99f36a7a`, hurt `4f964631`, attack `8483238d`) | 132-188 px → 208x136 cells | 25 | imported | `assets/sprites/player/hero/` | The mace attack uses frames 1, 5-8 (the wind-up turned his back). The great-sword crouch is a half crouch. |
| worn art batch 1 | short_sword, sappara, bronze_mace, lapis_shield, scribes_circlet, seal_of_shamash, seal_of_nergal, gazelle_anklet, scythe_of_ninurta, lion_greatsword; then lamp_of_ea, fang_of_lamashtu, ember_censer (2026-10-15) and the drop-only gear potsherd_seal, seal_of_humbaba, gate_guard_helm (conical bronze helm, 18×13, pivot at the brow band) (INV-013); builders_plan (clay map tablet hung at the back of the belt, REL-008); wanderers_cube (bone die on a cord at the neck, REL-009). Dye: saffron_mantle lining. Dyes: riverclay_mail plates, watchmans_mantle lining | drawn in code (`build_worn_art.gd`) | — | 8×6 to 38×9 px | 0 | imported (placeholder) | `assets/sprites/items/worn/` | Hand items point right, grip at the pivot. |
| `elam/idle` | animation (east) | `animate_character` v3, 8 frames, `keep_first_frame:false`, then palette-locked (`reduce_colors` job `c1adef4a`) | group `55a12780-566f-4524-8195-f712a25c80ac` | 132×132 | 3.1 | imported | `assets/sprites/player/elam/` (row 0) | 30 of Elam's colors; feet on the ground line in all frames. In-game check: `docs/art_reviews/2026-10-14_elam_ingame_idle.png` |
| `gte_solid` | sidescroller tileset | `create_sidescroller_tileset` (lower: lapis glazed brick with gold mortar; transition: gold-glazed cap with rosettes; transition_size 0.25; highly detailed, detailed shading, selective outline) | `187ea0fe-4e3f-4d6f-b9e4-6cf18fb1b195` | 16 px ×16 tiles | 2.6 | imported (style pending review) | `assets/tilesets/gte/gte_solid.{png,tres}` | Demo room PASS (0 holes in 256 cells). The cap's gems read bright, like lamps. |
| `elam_cand_standard` | character | `create_character` standard | `031e2437-edd4-4a81-99d1-615bc68591d4` | 92×92 | 1 | rejected | — | Too simple, pale. Sheet: `docs/art_reviews/2026-10-14_elam_anchor.png` |
| `elam_cand_v3` | character | `create_character` v3 | `09a2d9a3-bf4a-440d-b2d6-30601191f763` | 96×96 | 3 | rejected | — | Best of round 1, but read as an elf |
| `elam_cand_proflash` | character | `create_character_pro_flash` | `3f796778-f13d-4939-9cc6-c0176c3ff321` | 96×96 | 7 | rejected | — | Robed, softer |
