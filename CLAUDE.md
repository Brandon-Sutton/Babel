# CLAUDE.md: BABEL

BABEL is a 2D side-view action-RPG metroidvania for PC. It is a spiritual successor to *Castlevania: Symphony of the Night*, set in the Tower of Babel. It is built in **Godot 4.6.1 with GDScript only**, and its pixel art is generated with the **PixelLab MCP**, then finished with PixelLab's free workbench tools.

## Where things are

| Path | What it is |
|---|---|
| `docs/GDD.md` | Game design outline: story, world, player kit, systems, rosters. The source of truth for **what** we build. |
| `docs/BACKLOG.md` | Every feature as a tracked task (ID, milestone, priority, status, dependencies), the "Now" queue, and the session log. The source of truth for **what's next**. |
| `docs/ART_BIBLE.md` | Visual spec, palettes, PixelLab recipes and costs, and the **asset registry** of PixelLab IDs. |
| `babel/` | The Godot project (`res://`). This is the folder to open in Godot. |
| `assets/` (repo root) | **Reference art supplied by the user**, such as the main character's design. Use it as the source when recreating sprites with PixelLab. It is not part of the Godot project. |
| `.godot-api/` | XML API reference dumped from the installed engine. Grep it to confirm a class, method or setting exists in 4.6.1 before using it, e.g. `grep -o 'name="[a-z_]*"' .godot-api/doc/classes/TileMapLayer.xml`. |

## Session workflow

1. Read `docs/BACKLOG.md`: the **Now** section and the latest session log entry.
2. Take the top unblocked task, or whatever the user asks for, and set its status to `doing`.
3. If the task has no acceptance criteria, write 3–6 checkable bullets into the backlog **before** coding.
4. Implement only that task. New ideas become new backlog rows, not scope creep.
5. Verify it (see [Verification](#verification)). A task is not `done` until its checks pass.
6. Update the backlog: change the status, add any tasks you discovered, and append a session log entry (date, tasks, decisions, next step).
7. Decisions that change the game go into `GDD.md`; art decisions and new PixelLab IDs go into `ART_BIBLE.md`.

Ask the user before changing the design pillars, story beats, scale targets, or anything spending more than 25 PixelLab generations at once.

## Engine and commands

The `godot` command is on PATH (`C:\Users\bsutt\bin\godot.exe`, **4.6.1.stable, standard build: no .NET, so no C#**). The Bash tool is Git Bash. Run the commands below from the repo root `C:\Users\bsutt\Git\Babel`.

| Purpose | Command |
|---|---|
| Import assets and refresh the class cache (after creating files outside the editor) | `godot --headless --path babel --import` |
| Parse-check one script | `godot --headless --path babel --check-only -s res://path/to/file.gd` |
| Project-wide load check: loads every script, scene and resource; exits 1 on any error | `godot --headless --path babel -s res://tools/ci/check.gd` |
| Run the GUT unit tests (`tests/unit/`, configured in `babel/.gutconfig.json`; exits 1 on failure) | `godot --headless --path babel -s res://addons/gut/gut_cmdln.gd` |
| Apply or re-apply project settings (display, physics, warnings, layers, input map, autoloads, plugins). **Change settings here, not by hand.** | `godot --headless --path babel -s res://tools/setup/configure_project.gd` |
| Run the game or one scene | `godot --path babel [--scene res://scenes/...tscn] [--debug-collisions]` |
| **Capture frames to look at** | `babel/tools/capture.sh res://tests/visual/<scene>.tscn [frames] [outdir]`. Writes 640×360 PNGs to `build/captures/<scene>/`, prints any `VISUAL PASS/FAIL` lines the scene logs, and prints the last frame's path for you to Read. It opens a window, so it can't run headless. |
| Art review sheet: images at N× above, 1× below, with drawn sizes printed. Save sheets the user approves to `docs/art_reviews/`. | `godot --headless --path babel -s res://tools/import/contact_sheet.gd -- <out.png> <scale> <img>...` (OS paths) |
| Palettes: extract a character's exact colors, or convert the curated `master.gpl` | `godot --headless --path babel -s res://tools/import/palette_tool.gd -- extract <out_base> <img>...` or `-- gpl <in.gpl> <out_base>` |
| **Import a PixelLab character** (recipe: `art_src/pixellab/characters/<slug>/import.json`; export unzipped in `export/`) → `assets/sprites/.../<slug>.png`, `.json`, `_anims.tres` | `godot --headless --path babel -s res://tools/import/import_character.gd -- res://art_src/pixellab/characters/<slug>/import.json`, then `--import`, then preview with `babel/tools/capture.sh res://tests/visual/character_preview.tscn 100` |
| **Import a PixelLab sidescroller tileset** (recipe: `art_src/pixellab/tilesets/<slug>/import.json`, with `tileset.png` + `metadata.json` beside it) → `assets/tilesets/<region>/<slug>.png` + `.tres` | `godot --headless --path babel -s res://tools/import/import_tileset.gd -- res://art_src/pixellab/tilesets/<slug>/import.json`, then `--import` and run it again if it asks; preview with `babel/tools/capture.sh res://tests/visual/tileset_room.tscn 440` |
| **Gameplay regression checks** (scripted input on the real player and the real game; every line must be VISUAL PASS) | `babel/tools/capture.sh res://tests/visual/gameplay_test.tscn 660`, `babel/tools/capture.sh res://tests/visual/sandbox_tour.tscn 720`, `babel/tools/capture.sh res://tests/visual/systems_test.tscn 540`, `babel/tools/capture.sh res://tests/visual/spearman_test.tscn 1560`, `babel/tools/capture.sh res://tests/visual/equipment_test.tscn 2400`, `babel/tools/capture.sh res://tests/visual/wall_block_test.tscn 700` `babel/tools/capture.sh res://tests/visual/specials_test.tscn 2400` (running, Relic Arms, Utterances, weapon arts, equipment passives) and `babel/tools/capture.sh res://tests/visual/loot_test.tscn 1500` (enemy drops) |
| **Visible equipment** (GDD §6.7, ART_BIBLE §6.3): review the hero's attach points; rebuild the worn-item sprites and link them to the items | `godot --headless --path babel -s res://tools/import/anchor_review.gd -- res://assets/sprites/player/hero hero <out.png> 2` and `godot --headless --path babel -s res://tools/builders/build_worn_art.gd` (run `--import` and run it again if it asks) |
| Review helpers (Python, in the `.gdignore`'d `babel/art_src/`): raw guide-prop frames before import, and grids or zooms of capture frames | `python babel/art_src/pixellab/characters/hero/rig/review_rod.py <frames_dir> <out.png>`, `python babel/art_src/tools/capture_grid.py <capture_dir> <out.png> <cols> <frame>...`, `python babel/art_src/tools/capture_zoom.py <capture_dir> <out.png> x0,y0,x1,y1 <frame>...` |
| Rebuild the greybox TileSet | `godot --headless --path babel -s res://tools/builders/build_greybox_tileset.gd`, then `--import` if it asks, then run it again |
| Measure FPS | add `--print-fps` |
| Debug keys in a running debug build (ENG-012) | F1 overlay (state, speeds, resources, recent directional inputs), F2 give every item and spell, F3 refill HP/Breath/Embers, F4 god mode, F5 cycle the Relic Arm |
| Export a Windows build (once ENG-015 exists) | `godot --headless --path babel --export-release "Windows Desktop" ../build/windows/Babel.exe` |
| Regenerate the API reference | `godot --headless --doctool .godot-api` |
| Generate docs from `##` comments | `godot --headless --path babel --doctool <out> --gdscript-docs res://scripts` |

Other notes:
- The user may have the Godot editor open. It will offer to reload files changed on disk, but if it saves its in-memory copy first, external `.tscn` edits get overwritten. Before large scene edits, ask whether the editor is open, or tell the user to reload.
- A script-only `--check-only` cannot resolve other scripts' `class_name`s until `--import` has run once.

## Git

- The repository root is `C:\Users\bsutt\Git\Babel`. The remote `origin` is `https://github.com/Brandon-Sutton/Babel.git` and the branch is `main`.
- Pushes use HTTPS through Git Credential Manager, whose sign-in is stored in Windows, so `git push` works non-interactively. The SSH key has a passphrase and no agent, so **don't switch the remote back to SSH**.
- **Git LFS** stores binary assets (images, audio, video, fonts, zips, `.res`) according to the root `.gitattributes`. Text files are normalized to LF.
  - Before committing the first file of a new binary type, add an LFS rule for it.
  - Check with `git check-attr filter -- <path>`.
- **Auto-commit and push** (standing permission from the user, 2026-10-14). After each finished task, or group of small tasks, has passed verification, commit and `git push`.
  - Put the backlog IDs first in the message, e.g. `ENG-002: apply display settings`.
  - Include the backlog and session-log update in the same commit.
  - Never commit work that fails the check or the tests.
- Never commit `.godot-api/`, `babel/.godot/`, `build/`, secrets, or signed PixelLab download URLs.

## Project layout (`res://`)

```
babel/
├─ project.godot
├─ addons/                   third-party plugins (gut, …)
├─ art_src/                  .gdignore'd raw PixelLab downloads: art_src/pixellab/<kind>/<slug>/
├─ assets/
│  ├─ sprites/{player,enemies,bosses,npcs,props,items,vfx}/<slug>/   sheet .png, _n.png normals, .tres
│  ├─ tilesets/<region>/     TileSet .tres + atlases
│  ├─ backgrounds/<region>/  parallax layers
│  ├─ ui/  fonts/  portraits/  palettes/  shaders/
│  └─ audio/{music,sfx,ambience,voice}/
├─ data/                     .tres instances: items/ weapons/ armor/ seals/ consumables/ enemies/
│                            spells/ subweapons/ relics/ familiars/ loot/ dialogue/ + world_index.json
├─ scenes/
│  ├─ main/                  main.tscn (boot), game_root
│  ├─ actors/{player,enemies/<slug>,bosses/<slug>,npcs/<slug>,familiars/<slug>}/
│  ├─ components/            hitbox, hurtbox, health, loot_dropper, status_effects, …
│  ├─ world/rooms/<region>/<region>_<nn>.tscn   e.g. gte_03.tscn
│  ├─ world/{props,doors,pickups,hazards}/
│  ├─ ui/{hud,menus,map,dialogue}/
│  └─ vfx/
├─ scripts/                  shared code not owned by one scene: core/ data_types/ systems/ util/
├─ autoload/                 singleton scripts (see table)
├─ localization/             translation CSV/PO files
├─ tests/                    unit/ (GUT), visual/ (capture scenes)
└─ tools/                    @tool and EditorScript utilities: ci/ import/ builders/ world/
```

Rules:
- A scene's script sits next to its `.tscn`. Shared classes go in `scripts/`.
- File and folder names are `snake_case`. Rooms are `<region code>_<two digits>`, with region codes as in GDD §5.2 (`shn`, `gte`, `fnd`…).
- Docs belong at the repo root (`docs/`), never inside `babel/`.

## Display and pixel-perfect settings (ENG-002 applies these)

```ini
[display]
window/size/viewport_width=640
window/size/viewport_height=360
window/size/window_width_override=1920
window/size/window_height_override=1080
window/stretch/mode="viewport"
window/stretch/scale_mode="integer"

[rendering]
textures/canvas_textures/default_texture_filter=0   ; Nearest
2d/snap/snap_2d_transforms_to_pixel=true
viewport/hdr_2d=true                                ; glow for magic (Forward+)

[physics]
common/physics_ticks_per_second=60
common/physics_interpolation=true
```

The project already uses Forward+ on D3D12 and Jolt for 3D. **Jolt is 3D-only**, so 2D uses Godot Physics 2D, which is what we want.

## Architecture

### Runtime tree

```
Main (Node)                         scenes/main/main.tscn
├─ World (Node2D)
│  ├─ <Room>                        swapped by SceneRouter; freed on exit
│  │  ├─ Parallax (Node2D)          Parallax2D layers
│  │  ├─ BackWall · Solid · Platforms · FgDeco   (TileMapLayer)
│  │  ├─ Entities (Node2D)          enemies, props, lamps, pickups, NPCs
│  │  ├─ Exits (Node2D)             RoomExit (Area2D) ×n
│  │  └─ Lighting (Node2D)          CanvasModulate + lights
│  ├─ Player                        persists across rooms
│  └─ GameCamera (Camera2D)         follows the player; limits come from Room bounds
├─ HUD (CanvasLayer 10)
├─ Menus (CanvasLayer 20)
├─ Transition (CanvasLayer 30)
└─ Debug (CanvasLayer 99)
```

### Autoloads (keep to this list; add one only with a backlog row that justifies it)

| Name | Responsibility |
|---|---|
| `Events` | Typed signal bus for *cross-system* notices only: `room_entered`, `enemy_killed`, `item_acquired`, `boss_defeated`, `flag_set`… Signals inside one scene connect directly. |
| `Game` | Run state: act, abilities and relics owned (`has_ability(&"double_jump")`), world flags, play time, player stats reference |
| `Db` | Loads every `data/**/*.tres` at boot and indexes it by `id: StringName`; validates that ids are unique |
| `SaveSystem` | Versioned JSON saves in `user://saves/slot_N.json`; collects `save_data()` from systems and restores with `load_data()` |
| `WorldMap` | Room index (`data/world_index.json`), per-cell discovery, completion % |
| `SceneRouter` | Room loading and transitions, threaded preloading of neighbors, player placement, fades |
| `Audio` | Music (`AudioStreamInteractive`), ambience layers, pooled SFX, bus control |
| `Settings` | `user://settings.cfg` (`ConfigFile`): video, audio, input remaps, accessibility, language |

### Core patterns

- **Composition over inheritance.** Behavior lives in component nodes such as `HealthComponent`, `HitboxComponent`, `HurtboxComponent`, `LootDropper`, `StatusEffects` and `Knockback`. The parent wires them together with signals.
- **State machines.** A `StateMachine` node with `State` children (`@abstract class_name State`) is shared by the player, enemies and bosses. A state transitions with `machine.transition_to(&"Jump")`.
- **Data in Resources.** Each data type is a custom `Resource` class in `scripts/data_types/` (`ItemData`, `WeaponData`, `EnemyData`, `SpellData`, `LootTable`, `PlayerTuning`…), with instances as `.tres` files in `data/`. Never hardcode stats or tuning in scripts.
- **Frame data in AnimationPlayer.** Property tracks toggle hitbox `monitoring` and shape `disabled`; method tracks spawn VFX and SFX and open cancel windows. Use `Sprite2D` + `AnimationPlayer` for anything that fights. Use `AnimatedSprite2D` only for simple looping props.
- **Persistence keys.** One-time world objects (chests, breakable walls, bosses) save under `"<room_id>/<node_name>"` in `Game.flags`.
- **Saves are JSON, never Resources.** Loading a `.tres`/`.res` from `user://` can execute embedded scripts.

### Collision layers (names go in `layer_names/2d_physics/*`)

| # | Name | Used by |
|---|---|---|
| 1 | `world` | Solid tiles, walls, doors |
| 2 | `platform` | One-way tiles (`TileData.one_way`) and moving platforms |
| 3 | `player` | Player body |
| 4 | `enemy` | Enemy bodies |
| 5 | `player_hurtbox` | Areas that receive damage on the player |
| 6 | `enemy_hurtbox` | Areas that receive damage on enemies |
| 7 | `player_hitbox` | Player attacks and projectiles (they mask layer 6) |
| 8 | `enemy_hitbox` | Enemy attacks and projectiles (they mask layer 5) |
| 9 | `pickup` | Items and currency |
| 10 | `interact` | NPCs, save points, lifts, inscriptions |
| 11 | `trigger` | Room exits, camera zones, cutscene triggers |
| 12 | `breakable` | Breakable walls and lamps |
| 13 | `water` | Water volumes |
| 14 | `hazard` | Spikes, pitch, crushers |

### Rendering order

| Range | Content |
|---|---|
| `z_index` −100 to −10 | Parallax2D background layers |
| −5 | BackWall tiles |
| 0 | Solid and Platforms tiles, props |
| 10 | Enemies and NPCs |
| 20 | Player |
| 30 | Player-side projectiles and VFX |
| 50 | FgDeco and foreground Parallax2D |
| 60 | Atmosphere particles |
| CanvasLayers | HUD 10, Menus 20, Transition 30, Debug 99 |

### Input actions (defaults; all rebindable)

| Action | Keyboard | Gamepad (Xbox layout) |
|---|---|---|
| `move_left` / `move_right` / `move_up` / `move_down` | Arrow keys | D-pad / left stick |
| `jump` | Z | A |
| `attack_right` (right-hand item) | X | X |
| `attack_left` (left-hand item) | C | B |
| `backdash` | Shift | Y |
| `relic_arm` (also Up + Attack) | V | LT |
| `form_dust` / `form_raven` / `form_lion` | A / S / D | RT / RB / LB |
| `map` | Tab | Back/View |
| `pause` | Esc | Start/Menu |
| `ui_*` | Godot defaults | Godot defaults |

Utterances are read from a buffer of directional inputs (SPL-001). Express input windows in **frames at 60 Hz** in data.

## GDScript conventions

- **Static typing everywhere.** `debug/gdscript/warnings/untyped_declaration` is set to Error. Use typed collections such as `Array[EnemyData]` and `Dictionary[StringName, int]` (typed dictionaries arrived in 4.4).
- **Naming:**

  | Kind | Style | Example |
  |---|---|---|
  | Classes and nodes | `PascalCase` | `HealthComponent` |
  | Files, functions, variables | `snake_case` | `health_component.gd` |
  | Constants | `UPPER_SNAKE` | `MAX_FALL_SPEED` |
  | Private members | `_leading_underscore` | `_buffer` |
  | Signals | past tense | `damaged`, `died`, `room_entered` |
  | Booleans | `is_`, `has_`, `can_` | `is_grounded` |

- **IDs** for actions, states, items and flags are `StringName` literals (`&"jump"`).
- **References:**
  - Use `%UniqueName` for nodes inside the same scene, and `@export var target: Node2D` across scenes.
  - Never use long `get_node("../../X")` chains.
  - Give `@onready` variables explicit types.
- **`class_name`** goes on reusable types only. Use **`@abstract`** (4.5+) on base classes such as `State`, `ItemData` and `EnemyBehavior`.
- **Editor tooling:**
  - Use `@tool` with `Engine.is_editor_hint()` guards for editor-side helpers (room validator, previews).
  - Use `@export_tool_button("Label")` (4.4+) for inspector buttons such as "Rebuild exits" or "Validate room".
  - Use `EditorScript` for one-off batch operations.
- **Physics callbacks:** when changing `monitoring` or shape `disabled` inside a physics callback, use `set_deferred()`.
- **Documentation:** write `##` doc comments on public APIs; `--gdscript-docs` consumes them.
- **Text:** every user-facing string goes through `tr()`, from the first commit.

## Editing Godot files from outside the editor

- `.tscn` and `.tres` are text, so small edits by hand are fine. Copy the header format from an editor-saved file.
- **Never invent UIDs.** When adding an `[ext_resource]`, give the `path=` and omit `uid=`; the editor adds it on the next save. Commit the `*.uid` files Godot creates next to scripts and shaders (4.4+), and move or rename them together with their file.
- **Never hand-edit `tile_map_data`** (a binary PackedByteArray). Build rooms in the editor, or with tool scripts that call `TileMapLayer.set_cell()`.
- **Complex scenes:** generate them with a builder script in `tools/builders/` that extends `SceneTree`. It constructs the nodes, sets `owner` on every descendant, then calls `PackedScene.pack()` and `ResourceSaver.save()`. Run it with `godot --headless --path babel -s res://tools/builders/<x>.gd`.
- After writing files outside the editor, run `--import`, then the check script.
- `babel/.godot/` is a cache: never edit it or commit it.

## Godot 4.6 feature playbook

Verify uncertain APIs in `.godot-api/` first.

| Need | Use | Notes |
|---|---|---|
| Room tiles | **`TileMapLayer`**, one node per layer (`TileMap` is deprecated) | Physics is chunked by `physics_quadrant_size`, which keeps the number of collision bodies low. One-way tiles use `TileData.one_way`. Custom data layers: `surface` (footstep SFX) and `breakable`. Use an occlusion layer for shadows. |
| Lamps and breakables painted like tiles | `TileSetScenesCollectionSource` (scene tiles) | |
| Parallax | **`Parallax2D`** (`scroll_scale`, `repeat_size`, `repeat_times`, `autoscroll`) | `ParallaxBackground`/`ParallaxLayer` are legacy; don't use them. |
| Smooth motion on high-refresh displays | Physics interpolation (a project setting) | Call `reset_physics_interpolation()` on the player and camera after any teleport or room change. |
| Character movement | `CharacterBody2D.move_and_slide()` with custom gravity from `PlayerTuning` | Use `AnimatableBody2D` for moving platforms and lifts. |
| Hit detection | `Area2D` hitboxes and hurtboxes on dedicated layers | Toggle them from AnimationPlayer tracks. |
| Animation with frame data | `Sprite2D` + `AnimationPlayer` + `AnimationLibrary` | `AnimationTree` is optional. The code state machine calls `play()`. |
| Large bosses | `Skeleton2D`/`Bone2D`, or a Node2D part hierarchy + AnimationPlayer | Part-based bosses are cheaper art and smoother animation. |
| Lighting and depth | `CanvasModulate`, `PointLight2D`, `DirectionalLight2D`, `LightOccluder2D`, `CanvasTexture` (diffuse + PixelLab normal map) | A `light()` shader quantizes light into bands. |
| Bloom | `rendering/viewport/hdr_2d` + `WorldEnvironment` (`background_mode = BG_CANVAS`, glow on) | Use only for magic and embers. |
| Shaders | `canvas_item` shaders in `assets/shaders/` | Hit flash, palette swap, dissolve, outline, mantle dye, water (`hint_screen_texture`), heat haze. |
| Particles | `GPUParticles2D` (`CPUParticles2D` as fallback) | Pre-warm ambient emitters. |
| Adaptive music | `AudioStreamInteractive` (clips and transitions), `AudioStreamSynchronized` (stems), `AudioStreamPlaylist` | |
| SFX variety | `AudioStreamRandomizer` (random pitch and volume) | |
| Region reverb | `Area2D.audio_bus_override` / `audio_bus_name` + per-region buses | |
| Confounded text | `RichTextLabel` + a custom `RichTextEffect` (`[confound tongue=akk]…[/confound]`) | |
| Room streaming | `ResourceLoader.load_threaded_request()` / `load_threaded_get()` | Preload adjacent rooms. |
| Editor helpers | `@tool`, `EditorScript`, `@export_tool_button`, `EditorUndoRedoManager` | |
| Collapsible debug and menus | `FoldableContainer` (4.5+) | |
| Logging | Subclass `Logger` and register it with `OS.add_logger()` (4.5+) | |
| Screen readers | AccessKit (`accessibility/general/accessibility_support`, 4.5+) | |
| Localization | `tr()`, CSV/PO translations, pseudolocalization | The pixel font must cover every shipped language. |
| Profiling | Debugger tabs (Profiler, Visual Profiler, Monitors) and `Performance.add_custom_monitor()` | |
| Visual checks and trailer capture | Movie Maker (`--write-movie`) | |
| Shipping | Export presets with the **shader baker** turned on (desktop export option, 4.5+) | Removes first-run shader stutter. |
| Live editing | The editor's Game tab embeds the running game; select nodes in it | |

## PixelLab art pipeline

The full recipes, budget and registry are in `docs/ART_BIBLE.md`.

- PixelLab tools are **deferred**: load each schema with ToolSearch (`select:mcp__pixellab__<tool>`) before calling it.
- **Side view only:**

  | Tool | Setting |
  |---|---|
  | Characters and objects | `view:"side"` |
  | 1-direction objects | `view:"sidescroller"` |
  | Tilesets | `create_sidescroller_tileset` |
  | Animations | `directions:["east"]` (flip for west) |

- **Costs:** run `get_balance` before batches. Announce estimates, and get the user's OK for anything over 25 generations. Prefer free tools first: `pixelart_workbench`, `vfx_workbench` and `save_to_asset`.
- **Waiting:** use `wait_for_jobs`, never sleep or poll loops.
- **Images:** pass URLs, or `upload:<id>`, rather than large base64.
- **Downloads:** go to `babel/art_src/pixellab/<kind>/<slug>/`. Record IDs, never signed URLs.
- **Review before import:** Read the PNG and check it at 4×. Lock frame palettes with `reduce_colors`. Generate normal maps with `create_normal_map`.
- **Registry:** every asset gets a row in the ART_BIBLE registry.

## Verification

- **Every change:**
  1. Parse-check the touched scripts.
  2. Run the project check (ENG-010).
  3. Run the tests related to the change.
- **Logic** (damage formulas, stats, inventory, input recognizer, save migration): add or extend GUT unit tests.
- **Anything visual** (rendering, art import, UI, VFX, room layout): capture frames with Movie Maker and *look at them* before calling the change done. Check pixel crispness, alignment and layering.
- **Game feel** (movement, combat timing): Claude cannot feel controls. Implement the change with its tuning exposed in data, describe exactly what the user should test, and log their feedback in the backlog.
- **Performance:** never claim performance without measuring it (`--print-fps`, Monitors). The target is 60 fps locked on a Steam Deck-class machine.

## Gotchas

- Blurry pixels mean something is overriding the Nearest texture filter, a texture has mipmaps, or an import uses lossy compression. Keep sprite imports `Lossless` with mipmaps off.
- Sprite or camera jitter usually comes from an un-snapped camera combined with smoothing, or a teleport without `reset_physics_interpolation()`. Inspect it with a 4× capture.
- Movie Maker cannot render with `--headless`.
- **Scripted input in tests:** `Input.action_press()` registers on the next physics frame. Hold a press for 2 frames, and keep modifiers such as Up held past it. Wait about 30 frames after the window opens, because a focus change releases every held action.
- **HDR 2D is on, so frames read back from a viewport (`get_texture().get_image()`) are linear floats.** Convert them with `Color.linear_to_srgb()` before comparing against palette colors (see `tests/visual/pixel_perfect.gd`). The final on-screen and Movie Maker output is sRGB as usual.
- **Never `ResourceLoader.load(…, CACHE_MODE_IGNORE)` the script that is currently running** (for example, a `-s` tool reloading itself). It crashes the engine with signal 11.
- `--check-only` and headless runs **don't print GDScript warnings**; only the editor shows them. Warnings set to Error (like `untyped_declaration`) still fail to load, so the check script catches those.
- Visual test scenes in `tests/visual/` check themselves where possible: they log `VISUAL PASS`/`VISUAL FAIL` from in-engine measurements, so you don't rely on eyeballing alone.
- Area2D overlap signals fire inside physics callbacks, so defer any state changes.
- Pool projectiles and damage numbers (CBT-008); don't `instantiate()` and `queue_free()` hundreds of them per second.
- `.gitattributes` forces LF line endings, so leave line endings alone.
- **In a `canvas_item` `fragment()`, `COLOR` already holds the texture colour times modulate.** Multiplying `texture(TEXTURE, UV)` into it again squares every colour and darkens the sprite (this hid the enemies' real colours until 2026-10-15). To get modulate on its own, pass `COLOR` from `vertex()` in a varying.
- **Sprites created or placed outside `_physics_process`** (projectiles, the equipment rig) need `reset_physics_interpolation()` after placement, or `physics_interpolation_mode = OFF`. Otherwise their first frame is drawn at the origin.
- **Every item Elam equips must be visible on him** (GDD §6.7). New Elam animations are made with the guide prop (ART_BIBLE §6.3) by animating the stored character, never a loose image, and are marked `"guide_prop": true` in `import.json`. New equipment needs a `WornArt` or a dye ramp. Every weapon type has its own full animation set, named `<stance>_<move>` (`mace_walk`, `scythe_jump`), chosen by `WeaponData.stance`; the sword uses the shared set. A new weapon type needs its own start-frame hold and full set (ART_BIBLE §6.3). Never name the weapon in the prompt (ART_BIBLE §6.3).
- **Attacks are blocked by walls** (CBT-013): `Hitbox` only hits a hurtbox with a clear ray through world tiles (layer 1) from the attacker's centre line. New hitboxes get this for free; set `blocked_by_walls = false` only for something meant to pass through walls.
- In Git Bash, paths look like `/c/Users/...`; in GDScript use `res://` and `user://`, and convert with `ProjectSettings.globalize_path()` when a tool needs an OS path.
