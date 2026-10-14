# BABEL: Backlog

This file is the single source of truth for the work left to do. Every session reads **Now**, works the top unblocked task, and updates this file (statuses, new rows, session log) before it ends. The workflow is described in [../CLAUDE.md](../CLAUDE.md#session-workflow), and the design these tasks implement is in [GDD.md](GDD.md).

## Legend

| Field | Values |
|---|---|
| **Status** | `todo` · `doing` · `done` · `blocked` (put the reason in Notes) · `cut` |
| **Priority** | `P0` must ship in its milestone · `P1` should · `P2` could · `P3` nice to have |
| **Size** | `S` ≤ half a session · `M` about one session · `L` several sessions (**split it into S/M rows before starting**) |
| **Milestone** | `M0` Foundation · `M1` Vertical Slice · `M2` Core Systems · `M3` Act I · `M4` Act II · `M5` Release · `POST` |
| **ID prefixes** | ENG engine/tooling · PIPE art pipeline · ART asset production · PLR player · CBT combat · RPG stats · INV items · SUB relic arms · SPL utterances · FAM familiars · FRM forms · REL relics · WLD world · MAP map · SAV save/travel · AI enemy framework · ENM enemies · BOSS bosses · NPC npcs/dialogue · UI · VFX · AUD audio · LVL level content · NAR narrative · QA · SHIP release · META extras |

Rules:
- **IDs are permanent.** Never renumber them. Cut tasks stay in the table with status `cut`.
- **New tasks** take the next free number in their epic.
- **Acceptance criteria:** a task without any must get some (in [the AC section](#acceptance-criteria)) before work starts.

---

## Now

The current milestone is **M0 Foundation**. Work top to bottom:

1. ~~ENG-001 to ENG-011, VFX-001, LVL-002~~ (done 2026-10-14).
2. **PIPE-001**: Elam style anchor. It costs about 10–30 gens and needs the user to approve a candidate. 145 gens were left on 2026-10-14; the allowance resets on 2026-10-17.
3. **PIPE-004**: sheet packer. It needs no art, so it can be done before PIPE-001.
4. **PIPE-002, PIPE-003, PIPE-006**: palette and importers, built against real PixelLab output.

**M0 exit criteria:**
- ✅ A greybox test room runs with a placeholder capsule player (`tests/visual/greybox_room.tscn`).
- ✅ Headless tests and the project check pass.
- ✅ Movie Maker capture works through the harness.
- ⬜ The Elam anchor is approved and the character and tileset importers work on real PixelLab output.

**M1 exit criteria (vertical slice "The Gate"):**
- The intro run and Namtar scene play.
- The Plain of Shinar and Grand Gate are playable, about 22 rooms.
- Elam has the full base moveset with final animations.
- Five enemies, the Lamassu boss and the double jump are in.
- There is a save room, map screen and HUD.
- Lighting and parallax are in place, with placeholder audio.
- An exported Windows build runs at 60 fps.

---

## Epics

### ENG: Engine, project setup and tooling

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| ENG-001 | Git repository at the repo root, a root `.gitignore`, and a Git LFS decision | M0 | P0 | S | — | done |
| ENG-002 | Apply the display and pixel-perfect settings from CLAUDE.md | M0 | P0 | S | — | done |
| ENG-003 | Physics settings (60 Hz, interpolation) and names for 2D physics layers 1–14 | M0 | P0 | S | — | done |
| ENG-004 | GDScript warnings: `untyped_declaration` set to Error, unsafe warnings on | M0 | P0 | S | — | done |
| ENG-005 | Input map with every action and default keyboard and gamepad bindings | M0 | P0 | S | — | done |
| ENG-006 | Folder skeleton per CLAUDE.md, plus `art_src/.gdignore` | M0 | P0 | S | — | done |
| ENG-007 | The 8 autoload stubs, registered, typed and documented | M0 | P0 | M | ENG-006 | done |
| ENG-008 | Main scene (Main/World/HUD/Menus/Transition/Debug), set as the project's main scene | M0 | P0 | S | ENG-007 | done |
| ENG-009 | Install GUT, add a sample test, and confirm the CLI command works | M0 | P0 | S | ENG-006 | done |
| ENG-010 | `tools/ci/check.gd`: load everything, report failures, exit non-zero on error | M0 | P0 | M | ENG-006 | done |
| ENG-011 | Visual capture harness: `tests/visual/` scenes and a `tools/capture.sh` wrapper | M0 | P0 | S | ENG-008 | done |
| ENG-012 | Debug overlay and cheats (F1): FPS, state, velocity, room, collision toggle, god mode, give item, warp | M1 | P1 | M | ENG-008 | todo |
| ENG-013 | `Logger` subclass writing to `user://logs`, plus an in-game console | M2 | P2 | S | ENG-007 | todo |
| ENG-015 | Windows export preset (shader baker on, icon) and an export smoke test | M1 | P1 | S | ENG-002 | todo |
| ENG-016 | Version stamp from `application/config/version` shown in the title and debug overlay | M2 | P2 | S | ENG-015 | todo |
| ENG-017 | Custom performance monitors: active enemies, projectiles, particles | M2 | P2 | S | ENG-012 | todo |
| ENG-018 | `.claude/settings.json` allow-list for godot and curl commands, to reduce permission prompts | M0 | P2 | S | — | todo |

*ENG-014 was merged into VFX-006.*

### PIPE: Art pipeline (PixelLab to Godot)

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| PIPE-001 | **Style anchor:** generate Elam (side view, facing east) by 2–3 routes, choose one with the user, record it | M0 | P0 | M | — | todo |
| PIPE-002 | Master palette v1 extracted from the anchor: `assets/palettes/master.{png,hex}`, ART_BIBLE §3 updated | M0 | P0 | S | PIPE-001 | todo |
| PIPE-003 | Character importer: PixelLab frames → fixed-canvas sheet anchored at the feet → `AnimationLibrary`/`SpriteFrames` `.tres` | M0 | P0 | M | ENG-006, PIPE-004 | todo |
| PIPE-004 | Sheet packer used by every importer (frames → sheet + JSON regions) | M0 | P0 | S | ENG-006 | todo |
| PIPE-005 | Normal-map pairing: `_n.png` → `CanvasTexture` in the importers | M1 | P1 | S | PIPE-003 | todo |
| PIPE-006 | Tileset importer: sidescroller tileset → `TileSet` `.tres` with physics, terrain set and one-way variants | M0 | P0 | M | LVL-002 | todo |
| PIPE-007 | Parallax importer: layer PNGs + JSON config → a `Parallax2D` preset scene per region | M1 | P1 | S | PIPE-004 | todo |
| PIPE-008 | VFX importer: `vfx_workbench` export → `SpriteFrames` + a one-shot `VfxPlayer` scene | M1 | P1 | S | PIPE-004 | todo |
| PIPE-009 | Icon atlas pipeline: batch icon sheet → one `AtlasTexture` per item id | M2 | P1 | S | PIPE-004 | todo |
| PIPE-010 | Pixel fonts at 8 and 16 px via `create_font`, imported without antialiasing or hinting, set as the Theme default | M1 | P0 | S | — | todo |
| PIPE-011 | UI kit: `create_ui_asset` frames → 9-slice `StyleBoxTexture` theme | M1 | P1 | M | PIPE-001 | todo |
| PIPE-012 | Art validator: flag a non-Nearest filter, mipmaps, lossy imports, non-integer scale, missing normal maps | M2 | P2 | S | ENG-010 | todo |
| PIPE-013 | Registry and budget discipline: an ART_BIBLE registry row per asset, and gens spent in each session log | M0 | P1 | S | — | todo |

### ART: Asset production

Region tilesets, backgrounds and props are tracked in the Level content grid as step 3, "Art".

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| ART-001 | Elam: base sprite and the 24 animations in ART_BIBLE §6.1, palette-locked, with normal maps | M1 | P0 | L | PIPE-001..005 | todo |
| ART-002 | Elam's weapon sprites for the sword and short-sword classes, with attach points | M1 | P0 | S | ART-001 | todo |
| ART-003 | Slice enemies ENM-001, 002, 003, 006 and 007 (sprites and animations) | M1 | P0 | L | PIPE-003 | todo |
| ART-004 | Lamassu boss parts and animation | M1 | P0 | M | PIPE-003 | todo |
| ART-005 | Namtar (intro version): sprite and animations | M1 | P0 | M | PIPE-003 | todo |
| ART-006 | HUD frame, item-get banner, boss bar | M1 | P0 | S | PIPE-011 | todo |
| ART-007 | Item icons, batch 1: slice items plus about 60 general items | M2 | P1 | S | PIPE-009 | todo |
| ART-008 | Elam's forms (Dust, Raven, Lion) with their animation sets | M2 | P0 | L | ART-001 | todo |
| ART-009 | Sera Valcourt: prologue moveset and boss animations | M3 | P0 | L | PIPE-001 | todo |
| ART-010 | NPCs (Nabu, Rask, Siduri, Urshanabi) | M2 | P1 | M | PIPE-001 | todo |
| ART-011 | Portraits: Elam (3 moods), Sera, Rask, Nabu, Siduri, Urshanabi, Namtar, Ashipu, Nimrod | M2 | P1 | M | ART-010 | todo |
| ART-012 | Item icons, batch 2 onward (all of Act I) | M3 | P1 | M | ART-007 | todo |
| ART-013 | Familiar sprites (5) | M3 | P1 | M | FAM-001 | todo |
| ART-014 | Title key art and logo | M5 | P1 | M | — | todo |
| ART-015 | Act II drowned variants: palette plans and new overlay art | M4 | P0 | L | VFX-010 | todo |

### PLR: Player controller

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| PLR-001 | Player scene: `CharacterBody2D`, `Sprite2D`, `AnimationPlayer`, capsule collider, component slots | M1 | P0 | M | ENG-007, PLR-002 | todo |
| PLR-002 | State machine framework (`StateMachine`, `@abstract State`), shared with enemies and bosses | M1 | P0 | M | ENG-006 | todo |
| PLR-003 | Walk, turn and stop with acceleration and deceleration from `PlayerTuning.tres` | M1 | P0 | S | PLR-001 | todo |
| PLR-004 | Jump: variable height, 6-frame coyote time, 6-frame buffer, max fall speed | M1 | P0 | S | PLR-001 | todo |
| PLR-005 | Back-dash (SotN signature): glide distance, cancel windows, optional i-frames flag | M1 | P0 | S | PLR-001 | todo |
| PLR-006 | Crouch (shorter hurtbox); drop through one-way platforms with Down + Jump | M1 | P0 | S | PLR-001, WLD-005 | todo |
| PLR-007 | Per-hand attacks: `attack_right`/`attack_left` call the equipped item's `use()`; `WeaponData` drives animation, hitbox and timing | M1 | P0 | M | CBT-001, INV-001 | todo |
| PLR-008 | Jump-attack and crouch-attack variants; landing cancels | M1 | P0 | S | PLR-007 | todo |
| PLR-009 | Hurt: knockback arc, i-frames with flicker, hit-stop hook | M1 | P0 | S | CBT-002 | todo |
| PLR-010 | Death leads to the game-over flow | M1 | P0 | S | UI-014 | todo |
| PLR-011 | Afterimage trail for back-dash, Lion form and high speed | M1 | P1 | S | PLR-005 | todo |
| PLR-012 | Interact (Up): doors, NPCs, save points, lifts, inscriptions, with a prompt | M1 | P0 | S | PLR-001 | todo |
| PLR-013 | Double jump (Gazelle Anklet) | M1 | P0 | S | REL-002 | todo |
| PLR-014 | Dive kick (Gazelle Anklet; Down + Jump in the air) | M2 | P1 | S | PLR-013 | todo |
| PLR-015 | Guard with a shield: hold to block, chip damage, block VFX | M2 | P0 | S | INV-004 | todo |
| PLR-016 | High jump (Wings of Etana) | M3 | P0 | S | REL-002 | todo |
| PLR-017 | Swimming and drowning (Gills of Oannes) | M3 | P0 | M | WLD-010 | todo |
| PLR-018 | Plumb Line grapple: anchor detection, swing, rappel | M3 | P0 | L | REL-002 | todo |
| PLR-020 | Footstep SFX chosen by the tile's `surface` custom data | M2 | P2 | S | AUD-003 | todo |
| PLR-021 | Movement VFX: landing dust, turn skid, wall bump | M2 | P2 | S | VFX-012 | todo |
| PLR-022 | Walking up and down 45° slopes and stairs, including attacking on slopes | M1 | P0 | S | WLD-005 | todo |
| PLR-023 | Use food and potions from a hand slot | M2 | P1 | S | INV-005 | todo |
| PLR-024 | Corner correction: nudge around ceiling corners and ledge lips | M1 | P1 | S | PLR-004 | todo |

*PLR-019 (item crash) was moved to SUB-010.*

### CBT: Combat

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| CBT-001 | Hitbox and hurtbox components with a `DamageInfo` payload (amount, damage types, element, knockback, source, status chance) | M1 | P0 | M | ENG-003 | todo |
| CBT-002 | `HealthComponent` with `damaged`, `healed` and `died` signals and an invulnerability timer | M1 | P0 | S | — | todo |
| CBT-003 | Damage formula v1: attack vs. defense, resist/weak/absorb/immune, crits from LCK, with unit tests | M1 | P0 | M | CBT-001 | todo |
| CBT-004 | Pooled damage numbers that pop like SotN's (heals green, crits large) | M1 | P1 | S | CBT-001 | todo |
| CBT-005 | Hit-stop and screen-shake service, scaled by the accessibility setting | M1 | P1 | S | — | todo |
| CBT-006 | Enemy hit reactions: flash shader, knockback, stagger threshold (poise) | M1 | P0 | S | VFX-005 | todo |
| CBT-007 | Data-driven status effects: Poison, Burn, Curse, Confounded, Fired, Stun, Slow | M2 | P0 | M | CBT-001 | todo |
| CBT-008 | Projectile base class and `ProjectilePool` | M1 | P0 | M | CBT-001 | todo |
| CBT-009 | Shield interactions: block, and reflect projectiles with certain shields | M2 | P1 | S | PLR-015 | todo |
| CBT-010 | VFX and SFX variants per element | M3 | P2 | S | VFX-012 | todo |
| CBT-011 | Enemy name and HP readout on hit (Codex Scroll) | M2 | P1 | S | REL-001 | todo |
| CBT-012 | Contact damage from enemy bodies, and the player's i-frame rules | M1 | P0 | S | CBT-001 | todo |

### RPG: Stats and progression

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| RPG-001 | `PlayerStats` model (base, derived, modifier stack), recomputed on equip, level-up and status changes | M2 | P0 | M | INV-004 | todo |
| RPG-002 | XP curve for levels 1–99, level-up FX and SFX, stat gains, reduced XP when out-leveled | M2 | P0 | S | RPG-001 | todo |
| RPG-003 | Max-up pickups: Clay Vessel, Reed Pipe, Votive Lamp | M2 | P0 | S | RPG-001 | todo |
| RPG-004 | Breath regeneration scaled by INT | M2 | P0 | S | RPG-001 | todo |
| RPG-005 | Luck: drop rates, crit chance, hidden pity counter | M2 | P1 | S | INV-007 | todo |
| RPG-006 | Balance sheet: `data/balance/*.csv` → importer → `.tres` ⟨open: CSV or edit `.tres` directly⟩ | M3 | P1 | M | INV-009 | todo |
| RPG-007 | Difficulty multipliers for enemy HP and attack | M5 | P2 | S | RPG-001 | todo |

### INV: Items, equipment and loot

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| INV-001 | Item data hierarchy: `@abstract ItemData` → Weapon, Armor, Mantle, Seal, Consumable and KeyItem data | M1 | P0 | M | ENG-006 | todo |
| INV-002 | `Db` autoload: load and index data, validate ids and icons, with tests | M1 | P0 | S | INV-001, ENG-007 | todo |
| INV-003 | Inventory model: stacks, sort keys, signals | M2 | P0 | M | INV-002 | todo |
| INV-004 | Equipment slots (right and left hand, head, body, mantle, two seals), two-handed rules, stat application | M2 | P0 | M | INV-003 | todo |
| INV-005 | Consumables usable from the menu or a hand; effects defined as data | M2 | P0 | S | INV-003 | todo |
| INV-006 | Pickups (shekels, items, max-ups, relic arms) with a magnet and toast | M1 | P0 | S | INV-001 | todo |
| INV-007 | Loot tables: weighted common and rare drops, LCK modifier, pity | M2 | P0 | S | INV-002 | todo |
| INV-008 | Chests and one-time pickups, saved as world flags | M2 | P0 | S | WLD-013 | todo |
| INV-009 | Act I equipment content: about 60 weapons, 30 armor, 12 mantles, 30 seals, 40 consumables (split by region) | M3 | P0 | L | INV-004 | todo |
| INV-010 | Mantle dye: lining color as a shader parameter; dyes sold in shops | M3 | P2 | S | VFX-005 | todo |
| INV-011 | Special weapon behaviors: combos, Scepter of Shamash shield combos, elemental procs | M3 | P2 | M | INV-009 | todo |
| INV-012 | Elam's starting gear and Namtar's gear strip (the Act II recovery is in NAR-013) | M1 | P0 | S | INV-001, NAR-005 | todo |

### SUB: Relic Arms (sub-weapons)

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| SUB-001 | Framework: `SubweaponData`, Embers, Up + Attack and the `relic_arm` button, one equipped at a time | M1 | P1 | M | CBT-008 | todo |
| SUB-002 | Sling Stone | M1 | P1 | S | SUB-001 | todo |
| SUB-003 | Clay Tablet (high arc) | M2 | P0 | S | SUB-001 | todo |
| SUB-004 | Bitumen Flask (fire pool) | M2 | P0 | S | SUB-001 | todo |
| SUB-005 | Hunter's Arrow (piercing) | M3 | P1 | S | SUB-001 | todo |
| SUB-006 | Cylinder Seal (rolls along floors) | M3 | P1 | S | SUB-001 | todo |
| SUB-007 | Lyre of Ur (sound stun) | M3 | P1 | S | SUB-001 | todo |
| SUB-008 | Abzu Water (water pillar) | M3 | P1 | S | SUB-001 | todo |
| SUB-009 | Clepsydra: stop time for enemies and projectiles, not the player | M3 | P0 | M | SUB-001 | todo |
| SUB-010 | Item crashes (super moves) for every Relic Arm | M3 | P2 | M | SUB-002..009 | todo |
| SUB-011 | ⟨open⟩ Decide: owned arsenal or SotN pickup-swap | M2 | P0 | S | — | todo |

### SPL: Utterances (spells)

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| SPL-001 | Command-input recognizer: directional ring buffer counted in 60 Hz frames, notation parser (`"D,DF,F+ATK"`), leniency rules, tests | M2 | P0 | M | ENG-005 | todo |
| SPL-002 | `SpellData`: syllables, Breath cost, cast animation, effect scene, unlock flag | M2 | P0 | S | SPL-001 | todo |
| SPL-003 | Casting flow: cast animation, throat-glyph glow, Breath check, fizzle on failure | M2 | P0 | S | SPL-002, RPG-004 | todo |
| SPL-005 | Quick-cast: bind a learned Utterance to a button (accessibility) | M2 | P1 | S | SPL-003 | todo |
| SPL-006 | The Confounded status blocks casting and scrambles UI text | M2 | P1 | S | CBT-007, NPC-002 | todo |
| SPL-010 | Išātu (fire bolts) | M2 | P0 | S | SPL-003 | todo |
| SPL-011 | Ṣūmu (timed lifesteal) | M3 | P0 | S | SPL-003 | todo |
| SPL-012 | Ḫalāqu (drain HP from everything on screen) | M3 | P1 | S | SPL-003 | todo |
| SPL-013 | Utukku (homing spirit) | M3 | P0 | S | SPL-003 | todo |
| SPL-014 | Erbetti Šārī (four orbiting winds) | M3 | P1 | S | SPL-003 | todo |
| SPL-015 | Ṣalmu (echo blades) | M3 | P1 | M | SPL-003 | todo |
| SPL-016 | Abnu (stone pillars) | M3 | P1 | S | SPL-003 | todo |
| SPL-017 | Šamaš (light beam) | M3 | P1 | S | SPL-003 | todo |
| SPL-018 | Mû (tide wave) | M3 | P2 | S | SPL-003 | todo |
| SPL-019 | Qūlu (silence casters, cure Confounded) | M3 | P1 | S | SPL-003, CBT-007 | todo |

### FAM: Familiars

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| FAM-001 | Framework: follow and steering, behavior states, levels 1–99 earned through use, summoned by relic | M2 | P1 | M | REL-001 | todo |
| FAM-002 | Dove (heals) | M2 | P1 | S | FAM-001 | todo |
| FAM-003 | Clay Homunculus (guards) | M3 | P1 | S | FAM-001 | todo |
| FAM-004 | Tablet Sprite (finds secrets, translates inscriptions) | M3 | P1 | S | FAM-001, NPC-003 | todo |
| FAM-005 | Lamassu Whelp (charge) | M3 | P2 | S | FAM-001 | todo |
| FAM-006 | Utukku Wisp (ranged) | M3 | P2 | S | FAM-001 | todo |
| FAM-007 | Familiar banter lines | M5 | P3 | S | FAM-002..006 | todo |

### FRM: Transformations

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| FRM-001 | Framework: swap controller, collider and animations; drain Breath; transform VFX; forced-revert rules | M2 | P0 | M | PLR-002, RPG-004 | todo |
| FRM-002 | Form of Dust: pass through vents and grates (vent collision layer), immune to physical damage | M2 | P0 | M | FRM-001 | todo |
| FRM-003 | Raven Form: flight | M3 | P0 | M | FRM-001 | todo |
| FRM-004 | Raven upgrades: Cry (sonar reveals breakables), Talon (dive), Eye (dark vision) | M3 | P1 | M | FRM-003 | todo |
| FRM-005 | Lion of Ishtar: run, pounce, charge that breaks weak walls | M3 | P0 | M | FRM-001 | todo |
| FRM-006 | Lion upgrades: Roar, Golden Mane | M3 | P1 | S | FRM-005 | todo |
| FRM-007 | Dust upgrades: Dust Storm, Lasting Dust | M3 | P1 | S | FRM-002 | todo |

### REL: Relics and abilities

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| REL-001 | `RelicData` and on/off toggling in the menu (SotN style) | M2 | P0 | S | INV-001 | todo |
| REL-002 | Ability-gating API (`Game.has_ability()`) plus a debug grant | M1 | P0 | S | ENG-007 | todo |
| REL-003 | Relic and item-get presentation: freeze, banner with name and description, jingle | M1 | P0 | S | UI-004 | todo |
| REL-004 | Word of Opening and Word-sealed doors | M3 | P0 | S | WLD-008 | todo |
| REL-005 | Interpreter's Lens: resolves confounded speech and reveals the Binding Seal | M3 | P0 | S | NPC-002 | todo |
| REL-006 | The five Tongue relics | M3 | P1 | S | NPC-002 | todo |
| REL-007 | Codex Scroll, Wanderer's Cube, Bitumen Plate, Silver and Gold Seals | M3 | P1 | S | REL-001 | todo |

### WLD: World systems

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| WLD-001 | `Room` root script with metadata, plus a `@tool` validator (bounds are whole cells, exits sit on edges) | M1 | P0 | M | ENG-006 | todo |
| WLD-002 | Room transitions: exit → SceneRouter → linked entrance, fade, `reset_physics_interpolation()` | M1 | P0 | M | WLD-001, ENG-007 | todo |
| WLD-003 | Threaded preloading of adjacent rooms, with an unload policy | M2 | P1 | S | WLD-002 | todo |
| WLD-004 | Camera: follow with a deadzone, room limits, look-ahead, vertical bias, shake; camera zones inside rooms | M1 | P0 | M | WLD-001 | todo |
| WLD-005 | One-way platforms and 45° slopes | M1 | P0 | S | LVL-002 | todo |
| WLD-006 | Hidden breakable walls and floors: N hits, saved as a flag | M1 | P0 | S | WLD-013 | todo |
| WLD-007 | Votive lamps: breakable, drop from a loot table, placed as scene tiles | M1 | P0 | S | INV-006 | todo |
| WLD-008 | Doors: normal, boss lock, one-way (Word-sealed doors are in REL-004) | M1 | P0 | S | WLD-002 | todo |
| WLD-009 | Hazards: spikes, pitch pools, crushers, steam vents, live wires | M3 | P0 | M | CBT-001 | todo |
| WLD-010 | Water volumes: swim physics, buoyancy, drowning, hook for the surface shader | M3 | P0 | M | WLD-001 | todo |
| WLD-011 | Dark rooms: darkness from `CanvasModulate`, a light radius, Raven's Eye | M3 | P1 | S | VFX-002 | todo |
| WLD-012 | Moving platforms, lifts (`AnimatableBody2D`), crumbling platforms | M2 | P0 | S | WLD-005 | todo |
| WLD-013 | Switches and persistent world flags (`Game.flags`) | M1 | P0 | S | ENG-007 | todo |
| WLD-014 | **Room inverter** tool for Act II: mirror tile data vertically, flip exits, keep entity anchors | M4 | P0 | L | WLD-001 | todo |
| WLD-015 | Ambient particles per region: dust motes, embers, rain | M3 | P1 | M | VFX-008 | todo |
| WLD-016 | Grand Stair: technology for multi-screen vertical set-piece rooms | M3 | P1 | M | WLD-004 | todo |
| WLD-017 | Orrery: switch-driven room configurations (simplified rotating rooms) | M3 | P2 | L | WLD-013 | todo |
| WLD-018 | Bell-resonance puzzles (Cathedral) | M3 | P2 | M | AUD-003 | todo |
| WLD-019 | Morse-code doors (Wire Spire) | M3 | P2 | S | WLD-008 | todo |
| WLD-020 | Collapsing-floor sequences (Foundation) | M3 | P1 | S | WLD-012 | todo |
| WLD-021 | Room builder: create a new room scene from the template with arguments (region, id, size) | M1 | P0 | S | WLD-001 | todo |
| WLD-022 | Templates for the Quiet Room (save) and the Builders' Lift room | M1 | P0 | S | WLD-021 | todo |

### MAP: Map and completion

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| MAP-001 | World index builder: scan rooms → `data/world_index.json` (cells, exits, icons) | M1 | P0 | M | WLD-001 | todo |
| MAP-002 | Per-cell discovery tracking, saved | M1 | P0 | S | MAP-001 | todo |
| MAP-003 | Full map screen: pan, region colors, icons, player marker, % | M1 | P0 | M | MAP-002, UI-001 | todo |
| MAP-004 | Optional minimap on the HUD | M2 | P1 | S | MAP-003 | todo |
| MAP-005 | Surveyor's Maps sold by region (reveal unvisited outlines) | M3 | P2 | S | NPC-004 | todo |
| MAP-006 | Player-placed map pins | M3 | P2 | S | MAP-003 | todo |
| MAP-007 | Completion %: Act I 100%, Act II 200%, plus the secret bonus | M2 | P0 | S | MAP-002 | todo |
| MAP-008 | Exit consistency validator: exits of adjacent cells must pair up (run in CI) | M1 | P0 | S | MAP-001 | todo |

### SAV: Saving, checkpoints and fast travel

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| SAV-001 | Save schema v1: versioned JSON, migration hook, round-trip tests | M1 | P0 | M | ENG-007 | todo |
| SAV-002 | Quiet Room: full heal, save, mute the Murmur | M1 | P0 | S | SAV-001, WLD-022 | todo |
| SAV-003 | Save slots: three slots, with logic and UI | M2 | P0 | S | SAV-001, UI-001 | todo |
| SAV-004 | Builders' Lifts teleport network | M2 | P0 | M | WLD-002, MAP-003 | todo |
| SAV-005 | Continue and load flow, including returning from game over | M1 | P0 | S | SAV-001 | todo |
| SAV-006 | Safe writes: temp file then rename, keep a `.bak` | M2 | P1 | S | SAV-001 | todo |
| SAV-007 | Steam Cloud compatibility (`user://` path rules) | M5 | P2 | S | SHIP-003 | todo |

### AI: Enemy framework

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| AI-001 | Enemy base scene and `EnemyData` (stats, resistances, drops, XP, Codex text) | M1 | P0 | M | CBT-001, CBT-002, PLR-002 | todo |
| AI-002a | Behaviors A: patrol, chase, sine-wave floater, swoop, spear poke and guard | M1 | P0 | M | AI-001 | todo |
| AI-002b | Behaviors B: thrower, caster, jumper, burrow ambush, ceiling crawler | M2 | P0 | M | AI-001 | todo |
| AI-002c | Behaviors C: tether/binder, phaser, swarm, elite duelist that reacts to the player | M3 | P0 | M | AI-001 | todo |
| AI-003 | Perception: line-of-sight raycasts, aggro and leash ranges, facing | M1 | P0 | S | AI-001 | todo |
| AI-004 | Palette-variant shader and variant data (one sprite, many enemies) | M2 | P1 | S | VFX-005 | todo |
| AI-005 | Spawn rules: respawn on room re-entry, dormant off-screen, maximum active count | M1 | P0 | S | AI-001 | todo |
| AI-006 | Codex data and kill counts | M2 | P1 | S | AI-001 | todo |

### ENM: Enemy roster

Each row covers design, art (PixelLab), `EnemyData`, behavior and the Codex entry. Split a row into ENM-xxx-a (art) and ENM-xxx-b (implementation) when it's pulled into work.

| ID | Enemy | Region | Archetype | Size | MS | Pri | Status |
|---|---|---|---|---|---|---|---|
| ENM-001 | Mud Bat | SHN | Sine-wave flyer that comes in swarms | S | M1 | P0 | todo |
| ENM-002 | Mudborn (a dead builder sealed in clay) | SHN | Slow melee walker | M | M1 | P0 | todo |
| ENM-003 | Pitch Ooze | SHN | Crawler that leaves burning pitch | S | M1 | P0 | todo |
| ENM-004 | Carrion Vulture | SHN | Swoop diver | M | M3 | P1 | todo |
| ENM-005 | Girtablullu (scorpion-man) | SHN | Ranged sting, guards | M | M3 | P1 | todo |
| ENM-006 | Humbaba Mask | GTE | Sine-wave floater (the Medusa-head role) | S | M1 | P0 | todo |
| ENM-007 | Gate Spearman (shade of a Babylonian guard) | GTE | Spear poke, guards | M | M1 | P0 | todo |
| ENM-008 | Glazed Lion (living Ishtar Gate relief) | GTE | Pounces out of the wall | M | M3 | P1 | todo |
| ENM-009 | Sirrush Hatchling | GTE | Hopper that spits fire | S | M3 | P1 | todo |
| ENM-010 | Clay Golemling | FND | Tank that splits into two | M | M3 | P0 | todo |
| ENM-011 | Kiln Imp | FND | Fire thrower | S | M3 | P0 | todo |
| ENM-012 | Taskmaster Shade | FND | Mid-range whip | M | M3 | P0 | todo |
| ENM-013 | Mortar Worm | FND | Burrowing ambusher | M | M3 | P1 | todo |
| ENM-014 | Weeping Builder | FND | Event ghost, harmless until a brick falls | M | M3 | P2 | todo |
| ENM-015 | Strangler Vine | GRD | Stationary grabber | M | M3 | P0 | todo |
| ENM-016 | Cedar Dryad | GRD | Teleporting caster | M | M3 | P0 | todo |
| ENM-017 | Pollen Moth | GRD | Flyer that poisons | S | M3 | P1 | todo |
| ENM-018 | Screw Serpent | GRD | Lunges out of irrigation screws | L | M3 | P1 | todo |
| ENM-019 | Garden Laḫmu | GRD | Heavy brute | L | M3 | P1 | todo |
| ENM-020 | Ink Wraith | ARC | Flyer that phases | M | M3 | P0 | todo |
| ENM-021 | Tablet Swarm | ARC | Swarm | S | M3 | P0 | todo |
| ENM-022 | Living Scroll | ARC | Binds the player | M | M3 | P1 | todo |
| ENM-023 | Scribe Lich | ARC | Caster that inflicts Confounded | M | M3 | P0 | todo |
| ENM-024 | Stylus Sentinel | ARC | Lancer | M | M3 | P1 | todo |
| ENM-025 | Gladiator Shade | COL | Sword-and-shield duelist | M | M3 | P0 | todo |
| ENM-026 | Retiarius | COL | Net (bind) and trident | M | M3 | P0 | todo |
| ENM-027 | Bronze Talos | COL | Tank with a heat aura | L | M3 | P1 | todo |
| ENM-028 | Arena Lion | COL | Charger | M | M3 | P1 | todo |
| ENM-029 | Legion Bones | COL | Skeleton that throws pila | M | M3 | P0 | todo |
| ENM-030 | Kulullû (fish-man) | CIS | Leaps from the water (the merman role) | M | M3 | P0 | todo |
| ENM-031 | Drowned Builder | CIS | Underwater walker | M | M3 | P1 | todo |
| ENM-032 | Weeping Harp | CIS | Sound that stuns | M | M3 | P1 | todo |
| ENM-033 | Cistern Eel | CIS | Lunges from the water | M | M3 | P1 | todo |
| ENM-034 | Apkallu Sage | CIS | Caster with water bolts | M | M3 | P1 | todo |
| ENM-035 | Gargoyle | CAT | Perches, then dives | M | M3 | P0 | todo |
| ENM-036 | Choir Wraith | CAT | Sound waves | M | M3 | P0 | todo |
| ENM-037 | Bell Golem | CAT | Slam that sends a shockwave | L | M3 | P1 | todo |
| ENM-038 | Flagellant | CAT | Erratic melee | M | M3 | P1 | todo |
| ENM-039 | Glass Seraph | CAT | Throws shards of stained glass | M | M3 | P1 | todo |
| ENM-040 | Bone Mason | UND | Skeleton that throws bricks | M | M3 | P0 | todo |
| ENM-041 | Gallû | UND | Fast underworld hound | M | M3 | P0 | todo |
| ENM-042 | Utukku | UND | Phasing ghost that possesses | M | M3 | P1 | todo |
| ENM-043 | Lamashtu's Brood | UND | Dark crawler swarm | S | M3 | P1 | todo |
| ENM-044 | Automaton Knight | ORR | Guards and counters | M | M3 | P0 | todo |
| ENM-045 | Astrolabe Drone | ORR | Orbits and shoots | S | M3 | P0 | todo |
| ENM-046 | Printer's Devil | ORR | Imp that throws movable type | S | M3 | P1 | todo |
| ENM-047 | Gear Spider | ORR | Ceiling crawler | S | M3 | P1 | todo |
| ENM-048 | Cuckoo | ORR | Bursts out of clocks on a timer | S | M3 | P2 | todo |
| ENM-049 | Furnace Brute | FDY | Heavy with a molten slam | L | M3 | P0 | todo |
| ENM-050 | Riveter | FDY | Rapid-fire turret | M | M3 | P0 | todo |
| ENM-051 | Coal Wraith | FDY | Smoke that blinds | M | M3 | P1 | todo |
| ENM-052 | Steam Hound | FDY | Dashes with a steam burst | M | M3 | P1 | todo |
| ENM-053 | Lineman's Ghost | WIR | Electrified hook | M | M3 | P0 | todo |
| ENM-054 | Static Wisp | WIR | Chain lightning between wisps | S | M3 | P0 | todo |
| ENM-055 | Telegraph Mantis | WIR | Strikes in Morse-pattern rhythms | M | M3 | P1 | todo |
| ENM-056 | Switchboard Specter | WIR | Tethers with cables | M | M3 | P1 | todo |
| ENM-057 | Kerub (winged sphinx) | SUM | Elite flyer | L | M3 | P0 | todo |
| ENM-058 | Nimrod's Huntsman | SUM | Elite archer | M | M3 | P0 | todo |
| ENM-059 | Hound of Nimrod | SUM | Pack hunter | M | M3 | P1 | todo |
| ENM-060 | Star Shard | SUM | Falling hazard enemy | S | M3 | P2 | todo |
| ENM-061 | Act II: drowned variants of ENM-001 to 060 (palette and behavior remixes) | All | Variants | — | M4 | P0 | todo |
| ENM-062 | Act II: the Eleven Spawn of Tiamat (Bašmu, Ugallu, Uridimmu, Kusarikku, Storm Demons, Mušmaḫḫū, and others) — design pass | Act II | Mixed | — | M4 | P0 | todo |

### BOSS: Bosses

Every boss row is `L`. When one is pulled into work, split it into: **design sheet** (patterns, phases, telegraphs, arena), **art** (parts), **implementation**, and **polish and tuning**.

| ID | Boss | Region | Concept and mechanics | Reward | MS | Pri | Status |
|---|---|---|---|---|---|---|---|
| BOSS-000 | **Framework**: arena lock, name card, HP bar, phase controller, weighted no-repeat pattern sequencer, death sequence, reward drop, defeated flag | — | — | — | M1 | P0 | todo |
| BOSS-001 | Lamassu, Gate-Warden | GTE | Winged bull with a human head. Charges, wing gusts, stomp shockwaves; flies at low HP | Gazelle Anklet | M1 | P0 | todo |
| BOSS-002 | The Brick-Father | FND | Kiln golem that sheds bricks (new platforms and hazards) as it takes damage | Form of Dust | M3 | P0 | todo |
| BOSS-003 | Humbaba | GRD | Guardian of the cedar forest. Face of entrails, roots grab, seven auras as phases | Lion of Ishtar | M3 | P0 | todo |
| BOSS-004 | The Lexicon | ARC | Swarm of tablets that spells out words; each word changes its element and pattern | Word of Opening | M3 | P0 | todo |
| BOSS-005 | Gilgamesh & Enkidu (shades) | COL | Duo fight, a sword-wielding king and a wild brawler; a tag-team finisher | Plumb Line | M3 | P0 | todo |
| BOSS-006 | Mušḫuššu | CIS | Dragon from the Ishtar Gate; fights partly submerged; water level changes | Gills of Oannes | M3 | P0 | todo |
| BOSS-007 | The Carillon | CAT | Mass of bells and choir mouths; ring the right bells to open its weak points | Raven Form | M3 | P0 | todo |
| BOSS-008 | Namtar, Herald of Fate | UND | Scythe of fate, summons Gallû, inflicts "doom" countdowns | Raven's Eye, gear piece | M3 | P0 | todo |
| BOSS-009 | The Orrery Magus | ORR | Planets orbit as attacks; uses time stop | Clepsydra, Seals | M3 | P0 | todo |
| BOSS-010 | Moloch | FDY | Furnace idol; feed it the wrong fuel; rising heat | Wings of Etana | M3 | P0 | todo |
| BOSS-011 | Wireheart, the Operator | WIR | Switchboard spider; electrifies wires; lines of Morse-code bullets | Unlocks Rask (Lens) | M3 | P0 | todo |
| BOSS-012 | The Echo (doppelgänger) | ARC (Hall of Echoes) | Mirrors the player's equipment and Utterances | Rare equipment | M3 | P2 | todo |
| BOSS-013 | Sera Valcourt, Herald of the Tower | SUM | Uses Sera's moveset with the Measuring Chain. With the Lens, the target is the Binding Seal | Ending fork | M3 | P0 | todo |
| BOSS-014 | Nimrod (prologue version) | SUM, 1889 | Scaled-down Hunter-King for the prologue | — | M3 | P0 | todo |
| BOSS-020 | Gugalanna, Bull of Heaven | Act II | Earthquake stomps, charges that cross the screen | Remnant: Bow | M4 | P0 | todo |
| BOSS-021 | Tiamat's Reflection | Act II | Serpentine sea-mother in the Abzu waters | Remnant: Arrow | M4 | P0 | todo |
| BOSS-022 | Anzû | Act II | Lion-headed eagle that steals equipped items mid-fight | Remnant: Crown | M4 | P0 | todo |
| BOSS-023 | Pazuzu | Act II | King of wind demons; storms, plague swarms | Remnant: Eye | M4 | P0 | todo |
| BOSS-024 | Lamashtu | Act II | Demoness; spawns brood, poison | Remnant: Heart | M4 | P0 | todo |
| BOSS-025 | The Unspoken | Act II | Inverted Lexicon, a being of silence that disables sound-based tells | Remnant: Tongue | M4 | P0 | todo |
| BOSS-026 | Ashipu, the Many-Mouthed | Act II | Mouths cast in every tongue; Confounded storms | — | M4 | P0 | todo |
| BOSS-027 | Nimrod, Hunter-King | Foundation Stone | Giant archer, arrows aimed at heaven rain down | — | M4 | P0 | todo |
| BOSS-028 | Nimrod Confounded | Foundation Stone | True final form, an amalgam speaking every language | Ending | M4 | P0 | todo |
| BOSS-029 | Ereshkigal (superboss) | The Seven Gates | Queen of the Great Below; fought after the gates strip equipment slots | Best seal | M4 | P2 | todo |

### NPC: NPCs and dialogue

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| NPC-001 | Dialogue system: `DialogueData`, typewriter text, speaker and portrait, tongue tag, simple choices, flags | M2 | P0 | M | UI-021 | todo |
| NPC-002 | **Confound `RichTextEffect`:** a glyph set per tongue, a resolve animation, tests | M2 | P0 | M | NPC-001 | todo |
| NPC-003 | Inscriptions: readable wall objects with hint text, gated by Tongue | M3 | P1 | S | NPC-002 | todo |
| NPC-004 | Shop logic: buy, sell, stock unlocked by progress | M2 | P0 | M | INV-003 | todo |
| NPC-005 | Nabu: Codex viewer, map sales, music and lore archive | M3 | P1 | M | NPC-004, AI-006 | todo |
| NPC-006 | Siduri's side quests (5–8) | M3 | P2 | M | NPC-001 | todo |
| NPC-007 | Urshanabi's ferry sequence | M3 | P1 | S | NAR-003 | todo |

### UI: Interface

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| UI-001 | Theme: pixel font, StyleBoxes, gamepad focus visuals | M1 | P0 | M | PIPE-010 | todo |
| UI-002 | HUD: HP and Breath bars, Embers count, Relic Arm icon | M1 | P0 | S | UI-001 | todo |
| UI-003 | Boss HP bar and name card | M1 | P0 | S | UI-001 | todo |
| UI-004 | Item and relic banner, toast stack | M1 | P0 | S | UI-001 | todo |
| UI-005 | Pause menu shell: tabs, gamepad navigation, correct tree pausing | M2 | P0 | M | UI-001 | todo |
| UI-006 | Status screen | M2 | P0 | S | UI-005, RPG-001 | todo |
| UI-007 | Equip screen with stat comparison | M2 | P0 | M | UI-005, INV-004 | todo |
| UI-008 | Items screen (use, sort) | M2 | P0 | S | UI-005 | todo |
| UI-009 | Utterances screen with glyph-syllable inputs | M2 | P1 | S | SPL-002 | todo |
| UI-010 | Relics screen with toggles | M2 | P0 | S | REL-001 | todo |
| UI-011 | Familiars screen | M3 | P1 | S | FAM-001 | todo |
| UI-012 | Title screen and main menu | M1 | P1 | S | UI-001 | todo |
| UI-013 | Settings: video, audio, controls rebinding, accessibility, language | M2 | P0 | L | UI-005 | todo |
| UI-014 | Game-over screen | M1 | P0 | S | UI-001 | todo |
| UI-015 | Credits | M5 | P1 | S | — | todo |
| UI-016 | Screen transitions (fade, flash) | M1 | P0 | S | ENG-008 | todo |
| UI-017 | Controller glyphs that switch automatically (Xbox, PlayStation, keyboard) | M2 | P1 | M | UI-001 | todo |
| UI-018 | Shop UI | M2 | P0 | M | NPC-004 | todo |
| UI-019 | Codex (bestiary) UI | M3 | P1 | S | AI-006 | todo |
| UI-021 | Dialogue box with portraits | M2 | P0 | S | UI-001 | todo |

*UI-020 was merged into SAV-003.*

### VFX: Rendering, lighting, shaders and effects

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| VFX-001 | Pixel-perfect verification scene (integer scaling, no shimmer while the camera moves), captured | M0 | P0 | S | ENG-002, ENG-011 | done |
| VFX-002 | Lighting baseline: `CanvasModulate` per room, lamp lights, a normal-mapped sprite, banded `light()` shader | M1 | P0 | M | PIPE-005 | todo |
| VFX-003 | Tile occluders and shadows | M2 | P1 | S | VFX-002 | todo |
| VFX-004 | Parallax per region with fog tint by depth (ART_BIBLE §5) | M1 | P0 | M | PIPE-007 | todo |
| VFX-005 | Shader library: hit flash, dissolve, palette swap, outline, mantle dye | M1 | P0 | M | ENG-006 | todo |
| VFX-006 | Glow for magic (HDR 2D plus WorldEnvironment) | M1 | P1 | S | ENG-002 | todo |
| VFX-007 | Water: reflection, refraction and caustics | M3 | P0 | M | WLD-010 | todo |
| VFX-008 | Weather and atmosphere: sand, rain, embers, dust motes, god rays, lightning | M3 | P1 | M | — | todo |
| VFX-009 | Heat haze (Foundry) | M3 | P2 | S | — | todo |
| VFX-010 | Abzu post-process shader: ripple and palette shift for Act II | M4 | P0 | M | — | todo |
| VFX-011 | Spell VFX for every Utterance, made in `vfx_workbench` | M3 | P0 | L | PIPE-008 | todo |
| VFX-012 | Hit sparks and impact VFX for each damage type | M1 | P0 | S | PIPE-008 | todo |
| VFX-013 | Optional CRT/scanline filter | M5 | P3 | S | — | todo |
| VFX-014 | Flash-reduction mode | M5 | P1 | S | — | todo |
| VFX-015 | Evaluate a smooth sub-pixel camera (SubViewport offset technique) | M2 | P2 | M | VFX-001 | todo |

### AUD: Audio

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| AUD-001 | Bus layout (Master, Music, SFX, Ambience, Voice, UI), region reverb buses, Area2D overrides | M1 | P0 | S | — | todo |
| AUD-002 | `Audio` autoload: music via `AudioStreamInteractive`, ambience via `AudioStreamSynchronized`, crossfades, ducking | M2 | P0 | M | AUD-001 | todo |
| AUD-003 | SFX: `AudioStreamRandomizer` resources, pooled 2D players, voice limits | M1 | P0 | S | AUD-001 | todo |
| AUD-004 | **The Murmur:** whispering that swells near secrets and goes silent in Quiet Rooms | M3 | P1 | M | AUD-002 | todo |
| AUD-005 | Placeholder SFX and music for the slice (CC0 or generated; licenses recorded) | M1 | P0 | S | AUD-003 | todo |
| AUD-006 | ⟨open⟩ Decide music sourcing, then about 20 region and boss themes | M3 | P0 | L | — | todo |
| AUD-007 | Final SFX pass | M5 | P0 | L | — | todo |
| AUD-008 | Voice for key lines | POST | P3 | L | NAR-002 | todo |

### LVL: Level design and content

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| LVL-000 | Progression graph: critical path, relic gates, optional branches (the Wire Spire stays off the critical path), sequence-break rules, as a Mermaid diagram in `docs/progression.md` | M1 | P0 | M | — | todo |
| LVL-001 | Tower macro map: every Act I region placed on the cell grid (`docs/maps/act1.md`) | M2 | P0 | M | LVL-000 | todo |
| LVL-002 | Greybox `TileSet`: solid, one-way, 45° slopes, hazard, breakable marker, water | M0 | P0 | S | ENG-003 | done |
| LVL-003 | Room metrics guide: jump heights in tiles, door and ceiling clearances, enemy spacing (`docs/level_metrics.md`) | M1 | P0 | S | PLR-004, PLR-013 | todo |
| LVL-004 | Act II derivation plan: which rooms are mirrored, remixed or new | M4 | P0 | M | LVL-001 | todo |

**Level content grid.** Each region goes through five steps:
1. Plan (cell layout and gates)
2. Blockout (greybox rooms)
3. Art (tilesets, backgrounds, props)
4. Encounters and secrets
5. Polish (lighting, ambience, VFX)

Each step's ID is `LVL-<CODE>-<step>`, so the Grand Gate blockout is `LVL-GTE-2`. Put the step's status in its cell.

| Code | Region | Cells (target) | MS | 1 Plan | 2 Blockout | 3 Art | 4 Encounters | 5 Polish |
|---|---|---|---|---|---|---|---|---|
| SHN | Plain of Shinar | 10 | M1 | todo | todo | todo | todo | todo |
| GTE | Grand Gate | 18 (12 in the slice) | M1 | todo | todo | todo | todo | todo |
| FND | The Foundation | 35 | M3 | todo | todo | todo | todo | todo |
| GRD | Hanging Gardens | 35 | M3 | todo | todo | todo | todo | todo |
| ARC | Hall of Tablets (+ Hall of Echoes) | 33 | M3 | todo | todo | todo | todo | todo |
| COL | Colosseum Tiers | 30 | M3 | todo | todo | todo | todo | todo |
| CIS | Cisterns of Babylon | 35 | M3 | todo | todo | todo | todo | todo |
| CAT | Cathedral of Bells | 35 | M3 | todo | todo | todo | todo | todo |
| UND | Underworks | 30 | M3 | todo | todo | todo | todo | todo |
| ORR | Orrery Observatory | 35 | M3 | todo | todo | todo | todo | todo |
| FDY | Iron Foundry | 35 | M3 | todo | todo | todo | todo | todo |
| WIR | Wire Spire | 30 | M3 | todo | todo | todo | todo | todo |
| SUM | Gate of the Gods | 20 | M3 | todo | todo | todo | todo | todo |
| SID | Siduri's Terrace | 4 | M3 | todo | todo | todo | todo | todo |
| A2* | Act II regions (to be added in LVL-004) | ~400 | M4 | todo | todo | todo | todo | todo |

### NAR: Narrative and cutscenes

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| NAR-001 | Story bible and lore pass: verify Akkadian and Sumerian names and terms; tone guide | M2 | P1 | M | — | todo |
| NAR-002 | Full English script, each line tagged by tongue | M3 | P0 | L | NAR-001 | todo |
| NAR-003 | Cutscene system: AnimationPlayer sequences, dialogue, camera moves, letterbox, skip | M1 | P0 | M | WLD-004 | todo |
| NAR-004 | Prologue: Sera vs. Nimrod, 1889 | M3 | P0 | L | ART-009, BOSS-014 | todo |
| NAR-005 | Intro run across the Plain and Namtar's gear-strip scene | M1 | P0 | M | NAR-003, ART-005 | todo |
| NAR-006 | Rask's encounters and the Lens handoff | M3 | P0 | S | NPC-001, REL-005 | todo |
| NAR-007 | Summit confrontation and the fork (Ending A path) | M3 | P0 | M | BOSS-013 | todo |
| NAR-008 | Tower inversion set piece (start of Act II) | M4 | P0 | M | VFX-010 | todo |
| NAR-009 | Ending sequences A to D | M3/M4 | P0 | M | NAR-007 | todo |
| NAR-010 | Lore text for the 72 Glyphs, and where they are placed | M3/M4 | P1 | M | LVL-001 | todo |
| NAR-011 | Flavor text for items and enemies | M3 | P1 | M | INV-009 | todo |
| NAR-012 | Rask rescue quest (Act II) | M4 | P0 | M | NAR-006 | todo |
| NAR-013 | Recovering Elam's lost gear in Act II | M4 | P1 | S | INV-012 | todo |

### QA: Quality and testing

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| QA-001 | Unit test suites for each system (ongoing; every logic task adds tests) | M1+ | P0 | — | ENG-009 | todo |
| QA-002 | Room smoke test: load every room headless, run 60 frames, assert no errors | M2 | P0 | M | MAP-001 | todo |
| QA-003 | Visual regression snapshots of key rooms (Movie Maker) | M3 | P2 | M | ENG-011 | todo |
| QA-004 | Softlock audit: every relic gate has a way back (checked against the progression graph) | M3/M4 | P0 | M | LVL-000 | todo |
| QA-005 | Performance pass: Steam Deck-class target, worst rooms, particle budget | M5 | P0 | M | ENG-017 | todo |
| QA-006 | Playtest protocol and a feedback log section in this file | M1 | P1 | S | — | todo |
| QA-007 | Save fuzzing: load every save version and handle corrupted files | M2 | P1 | S | SAV-006 | todo |

### SHIP: Release

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| SHIP-001 | Windows release export: icon, version, shader baker | M5 | P0 | S | ENG-015 | todo |
| SHIP-002 | Linux and Steam Deck export, with controller verification | M5 | P1 | M | SHIP-001 | todo |
| SHIP-003 | Steam integration (GodotSteam): achievements, cloud saves, rich presence | M5 | P2 | M | SHIP-001 | todo |
| SHIP-004 | Localization pipeline: `tr()` keys, CSV/PO, pseudolocalization test, font glyph coverage | M2 | P1 | M | PIPE-010 | todo |
| SHIP-005 | Translations (languages to be decided) | M5 | P2 | L | SHIP-004 | todo |
| SHIP-006 | Accessibility review: AccessKit labels, remapping, flash and shake, contrast | M5 | P1 | M | UI-013 | todo |
| SHIP-007 | Credits and licenses: Godot MIT notice, fonts, addons, PixelLab Terms of Service check | M5 | P0 | S | — | todo |
| SHIP-008 | Store assets and a trailer captured with Movie Maker | M5 | P1 | M | — | todo |

### META: Extras and replay

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| META-001 | New Game+ | M5 | P2 | M | SAV-001 | todo |
| META-002 | Sera mode: play through as Sera (the Richter-mode analog) | POST | P2 | L | ART-009 | todo |
| META-003 | Boss rush | POST | P3 | M | BOSS-000 | todo |
| META-004 | Achievement list and implementation | M5 | P2 | S | SHIP-003 | todo |
| META-005 | Name-entry secrets | POST | P3 | S | — | todo |
| META-006 | Hard mode | M5 | P2 | S | RPG-007 | todo |
| META-007 | In-game timer for speedruns | M5 | P3 | S | — | todo |

---

## Acceptance criteria

Write the criteria here **before** starting a task. Criteria for M0 and the M1 P0 tasks are pre-filled; later tasks get theirs when they are pulled into work.

### M0

- **ENG-001**
  - `git init` at `C:\Users\bsutt\Git\Babel`.
  - The root `.gitignore` covers `.godot-api/`, `build/` and `babel/.godot/`.
  - The LFS decision is recorded in the session log. If LFS is used, `.gitattributes` tracks `*.png`, `*.wav`, `*.ogg` and `*.zip`.
  - The first commit contains the docs and the Godot project.
- **ENG-002**
  - Every setting from CLAUDE.md is present in `project.godot`.
  - A Movie Maker capture comes out 640×360.
  - The game window opens at 1920×1080 (3×).
- **ENG-003**
  - Physics runs at 60 ticks with interpolation on.
  - All 14 layer names show in the inspector.
- **ENG-004**
  - A test script containing `var x = 1` fails the project check.
  - The same script with `var x: int = 1` passes.
- **ENG-005**
  - Every action in the CLAUDE.md input table exists with keyboard and gamepad bindings.
  - `tests/unit/test_input_map.gd` asserts that they are present.
- **ENG-006**
  - The folder tree matches CLAUDE.md.
  - `art_src/.gdignore` exists, and files in `art_src/` never appear in the FileSystem dock or the import cache.
- **ENG-007**
  - The autoloads are registered in this order: Settings, Events, Db, Game, SaveSystem, WorldMap, Audio, SceneRouter.
  - Each one is statically typed and has `##` docs.
  - The project runs with zero errors.
- **ENG-008**
  - `main.tscn` is the project's main scene and contains the CanvasLayers listed in CLAUDE.md.
  - It runs and shows a placeholder label.
- **ENG-009**
  - GUT is installed in `addons/gut` (a release that supports 4.6) and the plugin is enabled.
  - `tests/unit/test_smoke.gd` passes through the CLI.
  - A deliberately failing test makes the command exit non-zero.
- **ENG-010**
  - The check loads every `.gd`, `.tscn` and `.tres` outside `addons/` and `art_src/`.
  - A deliberately broken script makes it exit 1, naming the file.
  - It runs in under 60 seconds on the current project.
- **ENG-011**
  - `tools/capture.sh <scene> [frames] [outdir]` writes PNGs into the scratchpad, or `build/captures/` by default.
  - The usage is documented in CLAUDE.md.
- **VFX-001**
  - The test scene contains a checkerboard, a sprite and a camera panning at a sub-pixel speed (37 px/s).
  - Captured frames show crisp pixels with no shimmer.
  - Scaling at 1920×1080 is exactly 3×.
- **LVL-002**
  - The greybox TileSet `.tres` contains solid tiles (terrain autotile), one-way tiles (`one_way`), 45° slopes in both directions, and hazard, breakable and water markers (custom data layer `kind`).
  - Physics layers are set to 1 and 2.
- **PIPE-001**
  - 2–3 Elam candidates are generated for no more than 30 gens and shown to the user.
  - One is approved.
  - The ART_BIBLE anchor row and registry row are filled in.
  - The sprite faces east and fits the 128×96 canvas at about 64 px tall.
- **PIPE-002**
  - `assets/palettes/master.png` and `.hex` exist.
  - ART_BIBLE §3.1 is updated with the real values.
- **PIPE-003**
  - Given a downloaded PixelLab character folder, the importer writes:
    - a fixed-cell sheet (128×96, feet anchored)
    - an `AnimationLibrary` `.tres` with one animation per PixelLab animation, using the frame rates in ART_BIBLE §6.1
  - Running it again produces an identical result.
  - It is documented in the file header.
- **PIPE-004**
  - The packer has unit tests covering the frame order and region JSON.
- **PIPE-006**
  - A real PixelLab sidescroller tileset imports into a `TileSet` with collision on its solid tiles and a terrain set that autotiles when painted.
  - A demo room is built with it, captured and reviewed.
- **PIPE-013**
  - It is done when the first PixelLab asset has a registry row and the session log records the gens spent.

### M1 (P0)

- **PLR-001**
  - The player spawned in a greybox room falls, lands and collides correctly.
  - The current state name shows in the debug overlay (or in a print until ENG-012 exists).
- **PLR-002**
  - The `State` API is `enter`, `exit`, `physics_update`, `handle_input`.
  - Unit tests cover transitions and the rejection of unknown states.
- **PLR-003**
  - Acceleration, deceleration and turn values come from `PlayerTuning.tres`.
  - Editing them while the game runs takes effect.
- **PLR-004**
  - Releasing jump early cuts the upward velocity.
  - Coyote time and the jump buffer are counted in frames and unit-tested.
  - The apex height is within ±4 px of the tuning value.
- **PLR-005**
  - Back-dash distance and time come from the tuning resource.
  - Its cooldown is enforced.
  - It can be cancelled into a jump after the configured number of frames.
- **PLR-006**
  - Crouching shortens the hurtbox.
  - Down + Jump drops through one-way platforms only.
- **PLR-007**
  - Swapping the equipped `WeaponData` changes the animation, hitbox and damage with no code change.
  - The hitbox is active only on the active frames, verified in a `--debug-collisions` capture.
- **PLR-008**
  - Jump attacks and crouch attacks use their own animations and hitboxes.
  - Landing cancels a jump attack at the configured frame.
- **PLR-009**
  - Knockback pushes Elam away from the source.
  - The i-frame duration comes from tuning, with flicker.
  - A unit test confirms that hits during i-frames are ignored.
- **PLR-010**
  - At zero HP, the death animation plays, then the game-over screen, then continue goes to the last save.
- **PLR-012**
  - An Up prompt appears near an interactable and triggers its action.
  - Elam can't interact while in the air.
- **PLR-013**
  - The double jump works only with the ability, and resets on landing.
- **PLR-022**
  - Walking up and down 45° slopes has no bounce.
  - Elam stays snapped when walking down slopes.
  - Attacks work on slopes.
- **CBT-001**
  - A hitbox overlapping a hurtbox emits `hit(DamageInfo)`.
  - Each swing hits each target at most once.
  - Collision masks follow the CLAUDE.md layer table.
- **CBT-002**
  - Unit tests cover the `damaged`, `healed` and `died` signals, clamping, and the invulnerability window.
- **CBT-003**
  - Unit tests cover weak, resist, absorb and immune multipliers, crits and the minimum damage of 1.
- **CBT-006**
  - On being hit, an enemy flashes and is knocked back.
  - Poise prevents stun-lock on heavy enemies.
- **CBT-008**
  - The pool reuses instances.
  - Projectiles despawn off-screen or after their lifetime.
  - Instance count stays at its cap under a stress test.
- **CBT-012**
  - Touching an enemy body damages Elam, unless he has i-frames or the enemy data marks it harmless.
- **INV-001**
  - The class hierarchy compiles.
  - Each class has an `id: StringName` and localized name and description keys.
  - A sample `.tres` exists for each class.
- **INV-002**
  - `Db.get_item(&"id")` works.
  - Duplicate ids fail the check with a clear message.
  - Tests cover both.
- **INV-006**
  - Pickups attract toward Elam within a set radius and show a toast.
  - One-time pickups are saved as flags.
- **INV-012**
  - Elam starts with his set.
  - The Namtar scene removes it, and the inventory and HUD reflect that.
- **REL-002**
  - `Game.has_ability()` gates the double jump.
  - The debug grant toggles it.
  - Tests cover it.
- **REL-003**
  - Gameplay pauses, the banner shows the icon, name and description, the jingle plays, and any button dismisses it.
- **WLD-001**
  - The `Room` script exposes `room_id`, `region`, `grid_pos` and `size_cells`.
  - The validator flags bounds that aren't whole cells, exits that aren't on an edge, and missing layers.
- **WLD-002**
  - Crossing an exit loads the linked room and places Elam at the paired entrance with his velocity and state preserved.
  - The fade takes 0.3 s or less.
  - A capture shows no interpolation smear.
- **WLD-004**
  - The camera never shows outside the room's bounds.
  - Deadzone, look-ahead and vertical bias are tunable.
  - Shake goes through CBT-005.
- **WLD-005**
  - One-way and slope tiles from the greybox set behave as in PLR-006 and PLR-022.
- **WLD-006**
  - A hidden wall takes N hits, then shows debris and opens the passage.
  - It stays open after leaving and re-entering the room and after save/load.
- **WLD-007**
  - Lamps placed as scene tiles break and drop from their loot table.
  - They respawn when Elam re-enters the room.
- **WLD-008**
  - Normal doors work.
  - Boss doors lock during the fight and open on the boss's defeat flag.
  - One-way doors work.
- **WLD-013**
  - `Game.set_flag()` and `Game.is_flag()` persist across room reloads and save/load.
  - Tests cover them.
- **WLD-021**
  - `godot --headless --path babel -s res://tools/builders/new_room.gd -- gte 04 2x1` creates a valid room scene that passes the validator.
- **WLD-022**
  - The Quiet Room and Lift templates instantiate through the builder.
- **MAP-001**
  - The headless builder writes `world_index.json` containing the id, region, grid position, size, exits and icons of every room.
- **MAP-002**
  - Entering a room marks its cells as discovered.
  - Discovery is saved.
- **MAP-003**
  - The map screen shows discovered cells, exits, save and lift icons, the player marker and completion %.
  - It can be panned with a gamepad.
- **MAP-008**
  - The validator fails when an exit has no matching exit in the neighboring cell.
  - It is wired into ENG-010.
- **SAV-001**
  - The JSON includes `version`.
  - A round-trip test passes.
  - Unknown keys are ignored.
  - The migration hook is tested with a fake v0 save.
- **SAV-002**
  - Interacting with a Quiet Room heals Elam fully and saves.
  - An "it is quiet" visual cue plays.
- **SAV-005**
  - Title → Continue and game over → Continue both load the last save.
- **AI-001**
  - Enemies are fully data-driven from `EnemyData`.
  - On death they award XP, roll drops and play the dissolve effect.
- **AI-002a**
  - Each behavior is a reusable State.
  - ENM-001, 002, 003, 006 and 007 are built only from these behaviors.
- **AI-003**
  - LOS raycasts are blocked by the world layer.
  - Aggro and leash ranges come from `EnemyData`.
- **AI-005**
  - Enemies respawn on room re-entry.
  - Off-screen enemies go dormant.
  - The maximum active count is respected.
- **BOSS-000**
  - Entering the arena locks it and shows the name card and HP bar.
  - Phases change at HP thresholds.
  - Defeat plays the death sequence, then the reward, then unlocks the arena and sets the flag.
  - A defeated boss does not respawn.
- **BOSS-001** (Lamassu)
  - The design sheet is written first: two phases, at least five telegraphed attacks, and the arena layout.
  - The fight takes 60–120 s for a first-time player at the expected level.
  - It drops the Gazelle Anklet.
- **UI-001**
  - The pixel font is crisp at 1×.
  - Focus is visible on every control.
  - The theme lives in `assets/ui/theme.tres`.
- **UI-002**
  - The bars animate on change.
  - Every label goes through `tr()`.
  - The layout follows GDD §9.
- **UI-003**
  - The boss bar appears with the name card and drains smoothly.
  - The phase markers are visible.
- **UI-004**
  - The banner queues several pickups.
  - Toasts stack and fade.
- **UI-014**
  - The game-over screen offers Continue and Title, with full gamepad navigation.
- **UI-016**
  - Fade and flash transitions are available through `SceneRouter`.
  - Their durations are tunable.
- **VFX-002**
  - The test room shows a dark ambient level, two lamp lights and a normal-mapped Elam lit in bands.
  - Captured and reviewed.
- **VFX-004**
  - GTE has at least 4 Parallax2D layers with fog tint by depth.
  - There are no seams while panning, checked in a capture.
- **VFX-005**
  - The flash, dissolve, palette swap and outline shaders each have a demo in `tests/visual/`.
- **VFX-012**
  - Slash, strike and pierce hits each spawn their own spark.
  - The sparks are pooled.
- **AUD-001**
  - The buses exist, with reverb on the region buses.
  - An Area2D override switches the reverb when Elam enters a room.
- **AUD-003**
  - SFX play through randomizers.
  - The voice limit prevents stacking.
- **AUD-005**
  - Placeholder sounds cover jump, land, attack, hit, enemy death, pickup, door, save and boss.
  - Their sources and licenses are listed in `assets/audio/LICENSES.md`.
- **NAR-003**
  - A cutscene resource can move the camera, show dialogue, play animations, wait and letterbox.
  - Cutscenes can be skipped.
- **NAR-005**
  - The intro runs from the kiln wake-up, across the Plain run, to the gate.
  - Namtar strips Elam's gear (INV-012).
  - The whole sequence takes 3 minutes or less and can be skipped on replay.
- **LVL-000**
  - `docs/progression.md` contains the Mermaid graph of regions, gates and rewards.
  - The Wire Spire is shown as optional.
  - Sequence-break rules are written down.
- **LVL-003**
  - Metrics are measured from the real controller (jump heights in tiles, back-dash distance, and so on) and documented with a diagram.
- **ART-001 to ART-006**
  - Each asset passes the ART_BIBLE §7.3 review gate.
  - It has a registry row.
  - It is imported with the importers.
  - It is checked in a capture.

---

## Session log

Add one entry per session, newest at the bottom, using this shape: **date**, the tasks touched (ID → status), decisions, PixelLab generations spent, and the next step.

- **2026-10-14 (planning session)**
  - Created `CLAUDE.md`, `docs/GDD.md`, `docs/BACKLOG.md` and `docs/ART_BIBLE.md`.
  - Dumped the 4.6.1 API reference to `.godot-api/` and confirmed that the features we rely on exist: `TileMapLayer` physics chunking, `Parallax2D`, `@abstract`, `@export_tool_button`, interactive audio streams, `Logger`/`OS.add_logger`, `FoldableContainer`, AccessKit setting.
  - Verified that Movie Maker capture works on this machine (writes 640×360 PNGs) and that `--check-only` works.
  - Checked PixelLab: Tier 1, 145 gens left, resets 2026-10-17; no PixelLab projects yet.
  - Decisions:
    - 640×360 internal resolution, 16 px tiles, about 64 px hero.
    - GDScript only; JSON saves.
    - The present day is 1893 and the prologue is 1889.
    - The Act II reflection is called the "Abzu Reflection".
  - Gens spent: 0.
  - **Next:** M0, starting with ENG-001 (ask the user about git and LFS).
- **2026-10-14 (git setup)**
  - ENG-001 → done.
  - Initialized the repo at the root on branch `main`, with Git LFS (`git lfs install --local`).
  - Created a root `.gitattributes` with LF normalization and LFS rules for images, audio, video, fonts, zips and `.res`. It replaces Godot's `babel/.gitattributes`.
  - The remote is HTTPS (`https://github.com/Brandon-Sutton/Babel.git`), authenticated with Git Credential Manager through a browser sign-in. The user's SSH key has a passphrase and Windows' ssh-agent is disabled, so SSH can't push from Claude's shell.
  - Gens spent: 0.
  - **Next:** ENG-002 to ENG-006.
- **2026-10-14 (M0 foundation)**
  - ENG-002 to ENG-011, VFX-001 and LVL-002 → done.
  - Project settings are applied by `tools/setup/configure_project.gd`, which is idempotent and is now the way to change settings. It covers the display, physics, warnings, 14 layer names, 14 input actions, 8 autoloads in order, the main scene and the GUT plugin.
  - Autoload stubs are in `autoload/`. The shared `FileScan` util handles `.remap` files in exported builds.
  - The main scene boots with zero errors.
  - GUT **9.6.1** is installed; it's the 4.6 line, while 9.7.x targets Godot 4.7. Tests: 7/7 passing, and a failing test exits 1.
  - `tools/ci/check.gd` uses a custom `Logger` to catch load errors. It exits 1 on syntax errors and on untyped declarations, which confirms the warning-as-error setting (ENG-004).
  - `tools/capture.sh` wraps Movie Maker capture.
  - VFX-001 checks itself and passes: only exact source colors at sub-pixel camera positions, and 3× integer scaling at 1080p.
  - LVL-002: the greybox TileSet (8 tiles) is generated by `tools/builders/build_greybox_tileset.gd`. In `tests/visual/greybox_room.tscn` the capsule climbs the 45° ramps, crosses the spikes and stops at the wall; the scene checks this itself.
  - Decisions:
    - Spike tiles collide as a full tile, flush with the floor. A half-height collider would trap players in an 8 px pit.
    - Visual tests check themselves where possible and log `VISUAL PASS/FAIL`.
  - Gotchas found (added to CLAUDE.md):
    - HDR 2D makes viewport readback linear.
    - Reloading the running `-s` script with `CACHE_MODE_IGNORE` crashes the engine.
    - Headless runs don't print GDScript warnings.
  - Gens spent: 0.
  - **Next:** PIPE-001 (Elam style anchor; needs the user's approval and about 10–30 gens), or PIPE-004 (no gens needed).
