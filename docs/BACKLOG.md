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

**M0 is complete (2026-10-14).** The current milestone is **M1 Vertical Slice**.

**Playable core is in (2026-10-14), plus the SotN systems pass (2026-10-15).**
- Movement, sword attacks, stats and leveling all work.
- The three enemies now have real sprites.
- Afterimages, hit sparks and screen shake are in.
- Votive lamps drop embers, shekels and items; the save altar saves, and death returns you to the last save.
- The pause menu has the status sheet and the SotN equipment screen.
- Crouch holds while Down is held, with its own crouching slash; the Gate Spearman has five attacks (2026-10-15).
- **Everything Elam equips is visible on him** (2026-10-15): weapon in hand, shield, circlet, seals, relic anklet, bronze plates and the mantle lining. The swing smear takes the weapon's colour.
- **Map** (2026-10-15, MAP-001..003, MAP-009, REL-008): Tab opens the Builder's Plan: explored cells blue, unexplored dim, secret rooms once found, Elam blinking, % explored. The plan is a relic (carried from the start for now). After changing a room, rebuild `data/world_index.json`.
- **Secrets** (2026-10-15, WLD-006): hidden breakable walls and floors (look like the wall, 3 hits) and cracked bricks (2 hits), with secret rooms off camera behind them. In the sandbox: a cracked block in the middle stretch, a hidden floor just past the double-jump wall over a cellar, and a hidden stretch of the far right wall into a secret room. F1 outlines them.
- **Enemies drop gear** (2026-10-15, INV-013): each enemy has a loot table with a common and a rare piece of gear found only as drops (Potsherd Seal, Riverclay Mail, Gate Guard's Helm, Watchman's Mantle, Seal of Humbaba). Dropped gear stays on the floor.
- **SotN specials pass** (2026-10-15, logic only; art waits for the refill, ART-018): running (double-tap and hold), Relic Arms paid in Embers (Sling Stone, Clay Tablet; V or Up + Attack), Utterances by command input (Išātu: ↓↘→ + Attack), a Breath-paid weapon art per weapon type (←→ + Attack), and equipment that grants abilities and passives. Debug keys F1–F5.

**Playtest wanted (game feel, log the verdict here):** the map's readability (cell size 24×14 px, colours, the blinking marker); breakable walls (3 hits for hidden ones, 2 for cracked bricks; the crack, rubble and camera pan into a secret room); how often gear drops (common about 1 in 10 kills, rare about 1 in 25); running (is a 14-frame double-tap window right, is 290 px/s too fast?), the feel of entering ↓↘→ and ←→ commands, the Breath and Ember costs, the weapon arts' reach and recovery, the Clay Tablet's arc; the Scythe of Ninurta's reach and slow reap (12-frame wind-up, 38 frames in all); the Spearman's wind-up lengths and ranges, the anti-air reach, how often it throws fireballs or leaps, and the crouching-slash timing.

The user's priority is the game: keep building gameplay ahead of the art pipeline.

Next, in suggested order:
0. **Playtest kit:** training dummy (CBT-014) and feature gym (QA-008), then shield guard (PLR-015) and potions in a hand (PLR-023, INV-005).
1. **Visible equipment (EQV):** after the 2026-10-17 refill, regenerate the rest of Elam's set with the guide prop (EQV-009): jump attack, death, guard, cast, throw, double jump, landing and more. Then PixelLab worn art (EQV-012).
2. **Relics:** `RelicData` for every relic with a worn spot, plus menu toggling (EQV-010, REL-001).
3. **Per-weapon animations:** every weapon type has its own full set (EQV-017). Next: split the sheet per type (EQV-018), and new types such as the spear, each with its own set.
4. **Systems:**
   - game-over screen (UI-014, completes PLR-010)
   - title screen with continue (UI-012, SAV-005)
5. **World:** room transitions (WLD-001/002), then dual-grid tile art (WLD-023) once the user has decided on the GTE tileset style.
6. **Art polish:** weapon-specific swings (ART-016), item icons (INV-014), palette locks for the hero and enemy animations.

**M0 exit criteria:**
- ✅ A greybox test room runs with a placeholder capsule player (`tests/visual/greybox_room.tscn`).
- ✅ Headless tests and the project check pass.
- ✅ Movie Maker capture works through the harness.
- ✅ The Elam anchor is approved (2026-10-14).
- ✅ The character and tileset importers work on real PixelLab output (2026-10-14).

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
| ENG-012 | Debug overlay and cheats (F1): FPS, state, velocity, room, collision toggle, god mode, give item, warp. First pass done 2026-10-15: F1 overlay, F2 give everything, F3 refill, F4 god mode, F5 cycle Relic Arm; the rest is ENG-019 | M1 | P1 | M | ENG-008 | done |
| ENG-013 | `Logger` subclass writing to `user://logs`, plus an in-game console | M2 | P2 | S | ENG-007 | todo |
| ENG-015 | Windows export preset (shader baker on, icon) and an export smoke test | M1 | P1 | S | ENG-002 | todo |
| ENG-016 | Version stamp from `application/config/version` shown in the title and debug overlay | M2 | P2 | S | ENG-015 | todo |
| ENG-017 | Custom performance monitors: active enemies, projectiles, particles | M2 | P2 | S | ENG-012 | todo |
| ENG-018 | `.claude/settings.json` allow-list for godot and curl commands, to reduce permission prompts | M0 | P2 | S | — | todo |
| ENG-019 | Debug tools, second pass: room readout, collision toggle, give one chosen item, warp to a room, spawn an enemy at the cursor, slow motion and frame advance | M1 | P1 | S | ENG-012 | todo |

*ENG-014 was merged into VFX-006.*

### PIPE: Art pipeline (PixelLab to Godot)

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| PIPE-001 | **Style anchor:** generate Elam (side view, facing east) by 2–3 routes, choose one with the user, record it | M0 | P0 | M | — | done |
| PIPE-002 | Master palette v1 extracted from the anchor: `assets/palettes/master.{png,hex}`, ART_BIBLE §3 updated | M0 | P0 | S | PIPE-001 | done |
| PIPE-003 | Character importer: PixelLab frames → fixed-canvas sheet anchored at the feet → `AnimationLibrary`/`SpriteFrames` `.tres` | M0 | P0 | M | ENG-006, PIPE-004 | done |
| PIPE-004 | Sheet packer used by every importer (frames → sheet + JSON regions) | M0 | P0 | S | ENG-006 | done |
| PIPE-005 | Normal-map pairing: `_n.png` → `CanvasTexture` in the importers | M1 | P1 | S | PIPE-003 | todo |
| PIPE-006 | Tileset importer: sidescroller tileset → `TileSet` `.tres` with physics, terrain set and one-way variants | M0 | P0 | M | LVL-002 | done |
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
| ART-001 | Elam: base sprite and the 24 animations in ART_BIBLE §6.1, palette-locked, with normal maps | M1 | P0 | L | PIPE-001..005 | doing |
| ART-002 | Elam's weapon sprites for the sword and short-sword classes, with attach points | M1 | P0 | S | ART-001 | todo |
| ART-003 | Slice enemies ENM-001, 002, 003, 006 and 007 (sprites and animations) | M1 | P0 | L | PIPE-003 | doing |
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
| ART-016 | Weapon-specific swing art: the Sappara and Bronze Mace reuse the sword slash (stretched to their timing). The mechanism exists now (EQV-015); this is the art, see EQV-017 | M2 | P2 | M | ART-001 | todo |
| ART-017 | A lower crouch pose for Elam, so high attacks can be ducked visibly. The current crouch is 59 px tall and the Spearman's stab (46–53 px) crosses the head, so a crouch does not dodge it. | M2 | P2 | S | ART-001 | todo |
| ART-018 | Specials art pass after the refill (ART_BIBLE §8.1): run, throw and cast per weapon type, art-specific attacks, Relic Arm sprites, spell and art effects, worn art for the new mantles and seals. About 25 gens: ask first | M1 | P0 | M | PLR-025, SUB-001, SPL-020 | todo |

### PLR: Player controller

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| PLR-001 | Player scene: `CharacterBody2D`, `Sprite2D`, `AnimationPlayer`, capsule collider, component slots | M1 | P0 | M | ENG-007, PLR-002 | done |
| PLR-002 | State machine framework (`StateMachine`, `@abstract State`), shared with enemies and bosses | M1 | P0 | M | ENG-006 | done |
| PLR-003 | Walk, turn and stop with acceleration and deceleration from `PlayerTuning.tres` | M1 | P0 | S | PLR-001 | done |
| PLR-004 | Jump: variable height, 6-frame coyote time, 6-frame buffer, max fall speed | M1 | P0 | S | PLR-001 | done |
| PLR-005 | Back-dash (SotN signature): glide distance, cancel windows, optional i-frames flag | M1 | P0 | S | PLR-001 | done |
| PLR-006 | Crouch (shorter hurtbox); drop through one-way platforms with Down + Jump | M1 | P0 | S | PLR-001, WLD-005 | done |
| PLR-007 | Per-hand attacks: `attack_right`/`attack_left` call the equipped item's `use()`; `WeaponData` drives animation, hitbox and timing | M1 | P0 | M | CBT-001, INV-001 | done |
| PLR-008 | Jump-attack and crouch-attack variants; landing cancels | M1 | P0 | S | PLR-007 | done |
| PLR-009 | Hurt: knockback arc, i-frames with flicker, hit-stop hook | M1 | P0 | S | CBT-002 | done |
| PLR-010 | Death leads to the game-over flow | M1 | P0 | S | UI-014 | doing |
| PLR-011 | Afterimage trail for back-dash, Lion form and high speed | M1 | P1 | S | PLR-005 | done |
| PLR-012 | Interact (Up): doors, NPCs, save points, lifts, inscriptions, with a prompt | M1 | P0 | S | PLR-001 | todo |
| PLR-013 | Double jump (Gazelle Anklet) | M1 | P0 | S | REL-002 | done |
| PLR-014 | Dive kick (Gazelle Anklet; Down + Jump in the air) | M2 | P1 | S | PLR-013 | todo |
| PLR-015 | Guard with a shield: hold to block, chip damage, block VFX | M2 | P0 | S | INV-004 | todo |
| PLR-016 | High jump (Wings of Etana) | M3 | P0 | S | REL-002 | todo |
| PLR-017 | Swimming and drowning (Gills of Oannes) | M3 | P0 | M | WLD-010 | todo |
| PLR-018 | Plumb Line grapple: anchor detection, swing, rappel | M3 | P0 | L | REL-002 | todo |
| PLR-020 | Footstep SFX chosen by the tile's `surface` custom data | M2 | P2 | S | AUD-003 | todo |
| PLR-021 | Movement VFX: landing dust, turn skid, wall bump | M2 | P2 | S | VFX-012 | todo |
| PLR-022 | Walking up and down 45° slopes and stairs, including attacking on slopes | M1 | P0 | S | WLD-005 | doing |
| PLR-023 | Use food and potions from a hand slot | M2 | P1 | S | INV-005 | todo |
| PLR-024 | Corner correction: nudge around ceiling corners and ledge lips | M1 | P1 | S | PLR-004 | todo |
| PLR-025 | Running: double-tap a direction and hold it to run; jumping out of a run keeps the speed. Run animation per weapon type comes with the art pass (until then the walk plays faster) | M1 | P0 | S | PLR-003 | done |

*PLR-019 (item crash) was moved to SUB-010.*

### CBT: Combat

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| CBT-001 | Hitbox and hurtbox components with a `DamageInfo` payload (amount, damage types, element, knockback, source, status chance) | M1 | P0 | M | ENG-003 | done |
| CBT-002 | `HealthComponent` with `damaged`, `healed` and `died` signals and an invulnerability timer | M1 | P0 | S | — | done |
| CBT-003 | Damage formula v1: attack vs. defense, resist/weak/absorb/immune, crits from LCK, with unit tests | M1 | P0 | M | CBT-001 | doing |
| CBT-004 | Pooled damage numbers that pop like SotN's (heals green, crits large) | M1 | P1 | S | CBT-001 | done |
| CBT-005 | Hit-stop and screen-shake service, scaled by the accessibility setting | M1 | P1 | S | — | done |
| CBT-006 | Enemy hit reactions: flash shader, knockback, stagger threshold (poise) | M1 | P0 | S | VFX-005 | done |
| CBT-007 | Data-driven status effects: Poison, Burn, Curse, Confounded, Fired, Stun, Slow | M2 | P0 | M | CBT-001 | todo |
| CBT-008 | Projectile base class and `ProjectilePool` | M1 | P0 | M | CBT-001 | todo |
| CBT-009 | Shield interactions: block, and reflect projectiles with certain shields | M2 | P1 | S | PLR-015 | todo |
| CBT-010 | VFX and SFX variants per element | M3 | P2 | S | VFX-012 | todo |
| CBT-011 | Enemy name and HP readout on hit (Codex Scroll) | M2 | P1 | S | REL-001 | todo |
| CBT-013 | Attacks are blocked by level geometry: a hit only lands with a clear line through world tiles from the attacker to the target, for the player and enemies alike; a blocked swing sparks where it meets the wall | M1 | P0 | S | CBT-001 | done |
| CBT-014 | Training dummy: cannot die, shows damage per hit, hit count, DPS over the last 5 s and the move that dealt it; resets on a key. For comparing weapons, arts and Relic Arms in playtests | M1 | P0 | S | CBT-003 | todo |
| CBT-012 | Contact damage from enemy bodies, and the player's i-frame rules | M1 | P0 | S | CBT-001 | done |

### RPG: Stats and progression

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| RPG-001 | `PlayerStats` model (base, derived, modifier stack), recomputed on equip, level-up and status changes | M2 | P0 | M | INV-004 | done |
| RPG-002 | XP curve for levels 1–99, level-up FX and SFX, stat gains, reduced XP when out-leveled | M2 | P0 | S | RPG-001 | done |
| RPG-003 | Max-up pickups: Clay Vessel, Reed Pipe, Votive Lamp | M2 | P0 | S | RPG-001 | todo |
| RPG-004 | Breath regeneration scaled by INT | M2 | P0 | S | RPG-001 | todo |
| RPG-005 | Luck: drop rates, crit chance, hidden pity counter | M2 | P1 | S | INV-007 | todo |
| RPG-006 | Balance sheet: `data/balance/*.csv` → importer → `.tres` ⟨open: CSV or edit `.tres` directly⟩ | M3 | P1 | M | INV-009 | todo |
| RPG-007 | Difficulty multipliers for enemy HP and attack | M5 | P2 | S | RPG-001 | todo |

### INV: Items, equipment and loot

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| INV-001 | Item data hierarchy: `@abstract ItemData` → Weapon, Armor, Mantle, Seal, Consumable and KeyItem data | M1 | P0 | M | ENG-006 | done |
| INV-002 | `Db` autoload: load and index data, validate ids and icons, with tests | M1 | P0 | S | INV-001, ENG-007 | todo |
| INV-003 | Inventory model: stacks, sort keys, signals | M2 | P0 | M | INV-002 | done |
| INV-004 | Equipment slots (right and left hand, head, body, mantle, two seals), two-handed rules, stat application | M2 | P0 | M | INV-003 | done |
| INV-005 | Consumables usable from the menu or a hand; effects defined as data | M2 | P0 | S | INV-003 | todo |
| INV-006 | Pickups (shekels, items, max-ups, relic arms) with a magnet and toast | M1 | P0 | S | INV-001 | done |
| INV-007 | Loot tables: weighted common and rare drops, LCK modifier (the pity counter was not built; it is in RPG-005) | M2 | P0 | S | INV-002 | done |
| INV-008 | Chests and one-time pickups, saved as world flags | M2 | P0 | S | WLD-013 | todo |
| INV-009 | Act I equipment content: about 60 weapons, 30 armor, 12 mantles, 30 seals, 40 consumables (split by region) | M3 | P0 | L | INV-004 | todo |
| INV-010 | Mantle dye: lining color as a shader parameter; dyes sold in shops | M3 | P2 | S | VFX-005 | todo |
| INV-011 | Special weapon behaviors: combos, Scepter of Shamash shield combos, elemental procs | M3 | P2 | M | INV-009 | todo |
| INV-012 | Elam's starting gear and Namtar's gear strip (the Act II recovery is in NAR-013) | M1 | P0 | S | INV-001, NAR-005 | doing |
| INV-013 | Enemy loot tables (`EnemyData.loot`), rolled on death, with gear found only as drops so the equipment loop works in play | M1 | P0 | S | INV-007 | done |
| INV-014 | Item icons in the equip menu and pickups (needs PIPE-009) | M2 | P2 | S | PIPE-009 | todo |
| INV-016 | Equipment that grants abilities and passive effects: `EquipmentData.abilities` (e.g. double jump while worn) and `passives` (Breath regen, HP regen, lifesteal, Ember saver, run speed), with first items to test them | M1 | P0 | M | INV-004 | done |
| INV-015 | Two-handed weapons: a two-handed weapon empties the left hand, and equipping the left hand removes it. The menu and stat preview follow the rule. First weapon: the Scythe of Ninurta | M1 | P0 | S | INV-004 | done |

### EQV: Visible equipment (paper doll)

The user's rule (2026-10-15): every weapon, shield, armor piece, mantle, seal and relic is visible on Elam in every animation. Design: GDD §6.7 "Visible equipment". Pipeline: ART_BIBLE §6.3.

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| EQV-001 | Design: slot-by-slot display rules, layer order and the attach-point set (GDD §6.7) | M1 | P0 | S | — | done |
| EQV-002 | Guide-prop rig: a key-green rod painted into Elam's hand before animating. The importer finds the rod in every frame, records the grip and angle (`hand_r`), keeps any key-green swing smear as a recolorable mask, and erases both from the body art | M1 | P0 | M | PIPE-003 | done |
| EQV-003 | Body attach points per frame (head, neck, chest, belt, ankles; `hand_l` from the chest), with a review sheet that draws every point on every frame | M1 | P0 | M | EQV-002 | done |
| EQV-004 | `WornArt` data: sprite, pivot pixel, attach point, layer (behind or in front), follows the hand angle. Used by `EquipmentData` and `RelicData` | M1 | P0 | S | INV-001 | done |
| EQV-005 | `EquipmentRig` on the player: one sprite per slot and relic, placed from the current frame's attach points every frame, mirrored with facing, ordered behind or in front of the body | M1 | P0 | M | EQV-003, EQV-004 | done |
| EQV-006 | Material recolor: Elam's sheet palette-locked to an indexed palette with material ramps (plates, trim, lining…); body armor and mantles supply replacement ramps through a palette-swap shader. v1 classes pixels by colour (plates below the neck, crimson lining) instead of an indexed palette | M1 | P0 | M | EQV-005 | done |
| EQV-007 | Clean rotated weapon art: pre-rendered angle steps (RotSprite-style) so weapons following the hand angle stay crisp | M1 | P1 | S | EQV-005 | todo |
| EQV-008 | Worn art, batch 1: the nine current items plus the Gazelle Anklet (placeholder art drawn in code) | M1 | P0 | S | EQV-004 | done |
| EQV-009 | Regenerate Elam's animation set with the guide prop. The core nine are done (11 gens on 2026-10-15). The rest of ART_BIBLE §6.1 follows after the 2026-10-17 refill (approved: ~75 gens in total) | M1 | P0 | L | EQV-002 | doing |
| EQV-010 | `RelicData` with a worn spot for every relic; relics toggled off are hidden (with REL-001). `RelicData` and the Gazelle Anklet are in | M2 | P0 | S | EQV-004, REL-001 | doing |
| EQV-011 | Visual test: equip each item in turn and check it is drawn at its attach point in every frame of every animation | M1 | P0 | S | EQV-005 | done |
| EQV-012 | Worn art, PixelLab pass: replace the code-drawn batch 1 sprites with generated ones (same pivots) | M2 | P1 | S | EQV-008 | todo |
| EQV-013 | Per-frame weapon layer: put the weapon behind the body on frames where the near hand passes behind it (detected from how much of the guide rod is hidden) | M2 | P2 | S | EQV-002 | todo |
| EQV-014 | Afterimage ghosts also copy the worn items and the dye | M2 | P2 | S | EQV-005 | todo |
| EQV-015 | Per-weapon animations: `WeaponData.animations` maps any of Elam's animations (attack, idle, walk…) to that weapon's own version, falling back to the shared one. First user: the scythe (idle, walk, attack) | M1 | P0 | S | EQV-002 | done |
| EQV-016 | Two-handed stance set: every move (idle, walk, jump, fall, crouch, crouching slash, back-dash, hurt, attack) has a `two_handed_*` version, and every two-handed weapon uses it unless it names its own stance | M1 | P0 | M | EQV-015 | done |
| EQV-017 | Every weapon type has its own full animation set, because each is held differently: sword (lowered forward), sickle-sword (level, ready to hook), mace (hanging, overhead smash), great sword (two-handed raised guard, cleave), scythe (upright reaper hold). `WeaponData.stance` names the type's set. Adds the two-handed Lion-Hilt Greatsword | M1 | P0 | L | EQV-016 | done |
| EQV-018 | Split Elam's sheet per weapon type (one sheet per stance, loaded when that weapon is equipped). The single sheet is now 1664x6120 with 45 animations and grows by about 1,200 px of height per type | M2 | P1 | M | EQV-017 | todo |
| EQV-019 | Great-sword crouch is only a half crouch (he keeps the guard up), so the art stands taller than the crouch hurtbox. Regenerate a lower crouch and crouching cut after the refill | M2 | P2 | S | EQV-017 | todo |
| EQV-020 | Mace overhead wind-up: the model turns Elam's back to the camera when he lifts a one-handed weapon overhead, so the mace attack uses frames 1, 5-8 (raise forward, smash). Retry the full wind-up with an end-frame pin after the refill | M2 | P2 | S | EQV-017 | todo |

### SUB: Relic Arms (sub-weapons)

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| SUB-001 | Framework: `RelicArmData`, Embers, Up + Attack and the `relic_arm` button, one carried at a time | M1 | P0 | M | CBT-008 | done |
| SUB-002 | Sling Stone | M1 | P0 | S | SUB-001 | done |
| SUB-003 | Clay Tablet (high arc) | M1 | P0 | S | SUB-001 | done |
| SUB-004 | Bitumen Flask (fire pool) | M2 | P0 | S | SUB-001 | todo |
| SUB-005 | Hunter's Arrow (piercing) | M3 | P1 | S | SUB-001 | todo |
| SUB-006 | Cylinder Seal (rolls along floors) | M3 | P1 | S | SUB-001 | todo |
| SUB-007 | Lyre of Ur (sound stun) | M3 | P1 | S | SUB-001 | todo |
| SUB-008 | Abzu Water (water pillar) | M3 | P1 | S | SUB-001 | todo |
| SUB-009 | Clepsydra: stop time for enemies and projectiles, not the player | M3 | P0 | M | SUB-001 | todo |
| SUB-010 | Item crashes (super moves) for every Relic Arm | M3 | P2 | M | SUB-002..009 | todo |
| SUB-011 | Decided 2026-10-15: SotN pickup-swap. One Relic Arm is carried; picking up another drops the old one where you stand | M1 | P0 | S | — | done |

### SPL: Utterances (spells)

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| SPL-001 | Command-input recognizer: directional ring buffer counted in 60 Hz frames, notation parser (`"D,DF,F+ATK"`), leniency rules, tests | M1 | P0 | M | ENG-005 | done |
| SPL-002 | `SpellData`: syllables, Breath cost, cast animation, effect scene, unlock flag | M1 | P0 | S | SPL-001 | done |
| SPL-003 | Casting flow: cast animation, throat-glyph glow, Breath check, fizzle on failure | M1 | P0 | S | SPL-002, RPG-004 | done |
| SPL-005 | Quick-cast: bind a learned Utterance to a button (accessibility) | M2 | P1 | S | SPL-003 | todo |
| SPL-006 | The Confounded status blocks casting and scrambles UI text | M2 | P1 | S | CBT-007, NPC-002 | todo |
| SPL-010 | Išātu (fire bolts) | M1 | P0 | S | SPL-003 | done |
| SPL-020 | Weapon arts: every weapon type has a special attack (Back, Forward + Attack) that costs Breath: Swift Thrust (sword), Hooking Lunge (sickle-sword), Earthshaker (mace), Lion's Cleave (great sword), Reaping Whirl (scythe) | M1 | P0 | M | SPL-003 | done |
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
| REL-002 | Ability-gating API (`Game.has_ability()`) plus a debug grant | M1 | P0 | S | ENG-007 | done |
| REL-003 | Relic and item-get presentation: freeze, banner with name and description, jingle | M1 | P0 | S | UI-004 | doing |
| REL-004 | Word of Opening and Word-sealed doors | M3 | P0 | S | WLD-008 | todo |
| REL-005 | Interpreter's Lens: resolves confounded speech and reveals the Binding Seal | M3 | P0 | S | NPC-002 | todo |
| REL-006 | The five Tongue relics | M3 | P1 | S | NPC-002 | todo |
| REL-007 | Codex Scroll, Wanderer's Cube, Bitumen Plate, Silver and Gold Seals | M3 | P1 | S | REL-001 | todo |
| REL-008 | The Builder's Plan: the relic that unlocks the map (MAP-003), worn as a clay tablet on the belt. Carried from the start for now; placed in the world with the level pass | M1 | P0 | S | MAP-003 | done |

### WLD: World systems

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| WLD-001 | `Room` root script with metadata, plus a `@tool` validator (bounds are whole cells, exits sit on edges) | M1 | P0 | M | ENG-006 | todo |
| WLD-002 | Room transitions: exit → SceneRouter → linked entrance, fade, `reset_physics_interpolation()` | M1 | P0 | M | WLD-001, ENG-007 | todo |
| WLD-003 | Threaded preloading of adjacent rooms, with an unload policy | M2 | P1 | S | WLD-002 | todo |
| WLD-004 | Camera: follow with a deadzone, room limits, look-ahead, vertical bias, shake; camera zones inside rooms | M1 | P0 | M | WLD-001 | todo |
| WLD-005 | One-way platforms and 45° slopes | M1 | P0 | S | LVL-002 | todo |
| WLD-006 | Hidden breakable walls and floors: N hits, saved as a flag, hiding secret rooms off the camera (and later the map), as in SotN | M1 | P0 | M | WLD-013 | done |
| WLD-007 | Votive lamps: breakable, drop from a loot table, placed as scene tiles | M1 | P0 | S | INV-006 | done |
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
| WLD-024 | Breakable variants for imported PixelLab tilesets: `import_tileset.gd` adds an alternative of each solid tile with `breakable` data (hidden walls) and a cracked-brick tile per region | M1 | P1 | S | WLD-006, PIPE-006 | todo |
| WLD-023 | **Dual-grid art layer:** derive PixelLab corner tiles from the room's logic and collision cells (greybox) on a layer offset by half a tile, so art and collision line up with the 16 px grid and each room's tile art is automatic | M1 | P0 | M | PIPE-006, LVL-002 | todo |

### MAP: Map and completion

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| MAP-001 | World index builder: scan rooms → `data/world_index.json` (cells, exits, icons). First pass: cells, secret rooms and openings from the rooms' tiles; icons in MAP-010 | M1 | P0 | M | WLD-001 | done |
| MAP-002 | Per-cell discovery tracking, saved | M1 | P0 | S | MAP-001 | done |
| MAP-003 | Full map screen: pan, region colors, icons, player marker, %. First pass without icons (MAP-010) | M1 | P0 | M | MAP-002, UI-001 | done |
| MAP-010 | Map icons: save altars, lifts, bosses, uncollected items; doors drawn from room exits once WLD-002 exists | M1 | P1 | S | MAP-003, WLD-002 | todo |
| MAP-004 | Optional minimap on the HUD | M2 | P1 | S | MAP-003 | todo |
| MAP-005 | Surveyor's Maps sold by region (reveal unvisited outlines). Revisit: the Builder's Plan (REL-008) already shows unvisited rooms | M3 | P2 | S | NPC-004 | todo |
| MAP-006 | Player-placed map pins | M3 | P2 | S | MAP-003 | todo |
| MAP-007 | Completion %: Act I 100%, Act II 200%, plus the secret bonus | M2 | P0 | S | MAP-002 | todo |
| MAP-009 | Secret areas (WLD-006 `SecretArea`) are hidden on the map until entered; finding one counts toward the secret bonus (MAP-007) | M2 | P0 | S | MAP-002, WLD-006 | done |
| MAP-008 | Exit consistency validator: exits of adjacent cells must pair up (run in CI) | M1 | P0 | S | MAP-001 | todo |

### SAV: Saving, checkpoints and fast travel

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| SAV-001 | Save schema v1: versioned JSON, migration hook, round-trip tests | M1 | P0 | M | ENG-007 | done |
| SAV-002 | Quiet Room: full heal, save, mute the Murmur | M1 | P0 | S | SAV-001, WLD-022 | done |
| SAV-003 | Save slots: three slots, with logic and UI | M2 | P0 | S | SAV-001, UI-001 | todo |
| SAV-004 | Builders' Lifts teleport network | M2 | P0 | M | WLD-002, MAP-003 | todo |
| SAV-005 | Continue and load flow, including returning from game over | M1 | P0 | S | SAV-001 | doing |
| SAV-006 | Safe writes: temp file then rename, keep a `.bak` | M2 | P1 | S | SAV-001 | done |
| SAV-007 | Steam Cloud compatibility (`user://` path rules) | M5 | P2 | S | SHIP-003 | todo |

### AI: Enemy framework

| ID | Task | MS | Pri | Size | Deps | Status |
|---|---|---|---|---|---|---|
| AI-001 | Enemy base scene and `EnemyData` (stats, resistances, drops, XP, Codex text) | M1 | P0 | M | CBT-001, CBT-002, PLR-002 | done |
| AI-002a | Behaviors A: patrol, chase, sine-wave floater, swoop, spear poke and guard | M1 | P0 | M | AI-001 | doing |
| AI-002b | Behaviors B: thrower, caster, jumper, burrow ambush, ceiling crawler | M2 | P0 | M | AI-001 | todo |
| AI-002c | Behaviors C: tether/binder, phaser, swarm, elite duelist that reacts to the player | M3 | P0 | M | AI-001 | todo |
| AI-003 | Perception: line-of-sight raycasts, aggro and leash ranges, facing | M1 | P0 | S | AI-001 | doing |
| AI-004 | Palette-variant shader and variant data (one sprite, many enemies) | M2 | P1 | S | VFX-005 | todo |
| AI-005 | Spawn rules: respawn on room re-entry, dormant off-screen, maximum active count | M1 | P0 | S | AI-001 | doing |
| AI-006 | Codex data and kill counts | M2 | P1 | S | AI-001 | todo |
| AI-007 | Ceiling check before leaping attacks: the Spearman's leap rises 125 px, so skip it under a low ceiling (raycast) | M1 | P1 | S | AI-003 | todo |

### ENM: Enemy roster

Each row covers design, art (PixelLab), `EnemyData`, behavior and the Codex entry. Split a row into ENM-xxx-a (art) and ENM-xxx-b (implementation) when it's pulled into work.

| ID | Enemy | Region | Archetype | Size | MS | Pri | Status |
|---|---|---|---|---|---|---|---|
| ENM-001 | Mud Bat | SHN | Sine-wave flyer that comes in swarms | S | M1 | P0 | todo |
| ENM-002 | Mudborn (a dead builder sealed in clay) | SHN | Slow melee walker | M | M1 | P0 | done |
| ENM-003 | Pitch Ooze | SHN | Crawler that leaves burning pitch | S | M1 | P0 | todo |
| ENM-004 | Carrion Vulture | SHN | Swoop diver | M | M3 | P1 | todo |
| ENM-005 | Girtablullu (scorpion-man) | SHN | Ranged sting, guards | M | M3 | P1 | todo |
| ENM-006 | Humbaba Mask | GTE | Sine-wave floater (the Medusa-head role) | S | M1 | P0 | done |
| ENM-007 | Gate Spearman (shade of a Babylonian guard) | GTE | Stab, floor sweep, anti-air thrust, fireball, leap-plunge | M | M1 | P0 | done |
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
| UI-002 | HUD: HP and Breath bars, Embers count, Relic Arm icon | M1 | P0 | S | UI-001 | done |
| UI-003 | Boss HP bar and name card | M1 | P0 | S | UI-001 | todo |
| UI-004 | Item and relic banner, toast stack | M1 | P0 | S | UI-001 | todo |
| UI-005 | Pause menu shell: tabs, gamepad navigation, correct tree pausing | M2 | P0 | M | UI-001 | done |
| UI-006 | Status screen | M2 | P0 | S | UI-005, RPG-001 | done |
| UI-007 | Equip screen with stat comparison | M2 | P0 | M | UI-005, INV-004 | done |
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
| VFX-005 | Shader library: hit flash, dissolve, palette swap, outline, mantle dye | M1 | P0 | M | ENG-006 | doing |
| VFX-006 | Glow for magic (HDR 2D plus WorldEnvironment) | M1 | P1 | S | ENG-002 | todo |
| VFX-007 | Water: reflection, refraction and caustics | M3 | P0 | M | WLD-010 | todo |
| VFX-008 | Weather and atmosphere: sand, rain, embers, dust motes, god rays, lightning | M3 | P1 | M | — | todo |
| VFX-009 | Heat haze (Foundry) | M3 | P2 | S | — | todo |
| VFX-010 | Abzu post-process shader: ripple and palette shift for Act II | M4 | P0 | M | — | todo |
| VFX-011 | Spell VFX for every Utterance, made in `vfx_workbench` | M3 | P0 | L | PIPE-008 | todo |
| VFX-012 | Hit sparks and impact VFX for each damage type | M1 | P0 | S | PIPE-008 | done |
| VFX-013 | Optional CRT/scanline filter | M5 | P3 | S | — | todo |
| VFX-014 | Flash-reduction mode | M5 | P1 | S | — | todo |
| VFX-015 | Evaluate a smooth sub-pixel camera (SubViewport offset technique) | M2 | P2 | M | VFX-001 | todo |
| VFX-016 | Enemy readability: a subtle rim or outline shader so dark sprites (Gate Spearman) stand out from dark back walls. **Root cause found and fixed 2026-10-15:** the hit-flash shader multiplied the texture in twice, which squared every colour. Enemies now show their true colours. Add an outline only if a playtest still asks for one. | M1 | P1 | S | VFX-005 | done |

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
| QA-008 | Feature gym: one test room with a station per feature (training dummies at set distances, a wall, a platform ladder for jumps, a row of lamps, Relic Arm pickups, an item chest, enemy pens), reachable from the debug tools, so every playtest is repeatable | M1 | P0 | M | CBT-014, ENG-019 | todo |

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
  - Holding Down keeps the crouch: the pose settles once and holds instead of restarting.
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
- **EQV-002**
  - The importer reads the guide-prop frames and writes `hand_r` (grip x, y relative to the feet, and angle) for every frame into the sheet JSON.
  - No key-green pixels remain in the imported body sheet. Pixels the rod covered over the body are filled; pixels outside the body become transparent.
  - Key-green swing smears are saved as a separate mask sheet.
  - A review sheet marks the grip and angle on every frame, and it has been checked by eye.
- **INV-015**
  - Equipping a two-handed weapon returns the left-hand item to the inventory.
  - Equipping anything in the left hand while a two-handed weapon is held returns that weapon to the inventory.
  - The stat preview shows the result of both rules, and the menu shows the left hand as taken by the two-handed weapon.
  - Unit tests cover each rule, and a save round trip keeps the two-handed weapon equipped.
- **EQV-015**
  - With the scythe equipped, Elam plays the scythe's idle, walk and attack. Moves the scythe has no version of fall back to the shared ones.
  - Swapping weapons changes the animation set immediately, even mid-idle.
  - The scythe is drawn in his hands in every frame of its own animations, and the attack's smear shows in its slash colour.
- **EQV-016**
  - With a two-handed weapon, every move Elam makes plays its two-handed version; with a one-handed weapon, none of them do.
  - A two-handed weapon without its own stance uses the two-handed set; one can still override single moves.
  - The weapon sits in his hands in every frame of the two-handed set (equipment_test's per-frame check).
- **CBT-013**
  - A sword or scythe swing does not hurt an enemy on the far side of a wall, even when the hitbox reaches it; the same swing hits once the wall is gone.
  - An enemy's spear does not hit the player through a wall.
  - One-way platforms do not block attacks.
  - A swing stopped by a wall shows a spark at the wall.
- **EQV-017**
  - Each weapon type plays its own idle, walk, jump, fall, crouch, crouching attack, back-dash, hurt and attack. No two types share a hold.
  - The weapon sits in his hands in every frame of every set (equipment_test's per-frame check).
  - equipment_test equips each weapon in turn and checks every move plays that type's set.
- **PLR-025**
  - Double-tapping a direction within `run_tap_frames` and holding it moves at `run_speed`; a single press walks.
  - Releasing or reversing the direction stops the run; jumping out of a run keeps run speed in the air until landing.
  - Run speed and the tap window live in PlayerTuning; equipment can raise run speed (INV-016).
- **INV-016**
  - An ability on an equipped item (e.g. `double_jump`) works only while it is worn.
  - Passives add up across equipped items and apply in play: Breath and HP regeneration, lifesteal on hits, Ember saver, run speed.
  - The equip menu lists an item's abilities and passives.
  - Unit tests cover granting, removal and stacking.
- **SUB-001..003**
  - `relic_arm` (or Up + Attack) throws the carried Relic Arm and spends its Ember cost; without enough Embers nothing is thrown.
  - The Sling Stone flies straight; the Clay Tablet flies in a high arc. Both hit enemies, break lamps and stop at walls.
  - Each Relic Arm has an on-screen limit.
  - Picking up another Relic Arm swaps it, dropping the old one; the HUD shows the carried one.
- **SPL-001..003, SPL-010, SPL-020**
  - The recognizer matches commands in the notation (`D,DF,F+ATK`) within their frame windows, mirrored for facing; unit tests cover hits, misses and leniency.
  - A matched spell or weapon art with enough Breath starts a short cast, spends the Breath and runs its effect; without enough Breath it fizzles and nothing is spent.
  - Išātu throws three fire bolts. Each weapon type's art has its own effect and cost.
  - A plain attack press still attacks normally.
- **ENG-012 (first pass)**
  - Debug builds only: F1 toggles an overlay (state, velocity, HP/Breath/Embers, abilities, recent inputs), F2 gives every item, Relic Arm and spell, F3 refills HP, Breath and Embers, F4 toggles god mode, F5 cycles the carried Relic Arm.
- **MAP-001..003, MAP-009, REL-008 (map, first pass)**
  - `tools/world/build_world_index.gd` instantiates every room scene and writes `data/world_index.json`: each room's map cells (640×360 px each, placed by the room's `map_cell`), its region, its secret areas as their own hidden rooms, and the openings between neighbouring cells read from the Solid tiles (breakable tiles count as open).
  - `WorldMap` marks the cell Elam stands in as discovered, saves the discovered cells with the game and restores them on load; it reports % explored (secret cells add a bonus beyond 100%).
  - The Builder's Plan (relic, ability `map`) is carried from the start for now and shows on Elam's belt. Without it, Tab only says there is no map.
  - Tab opens the map and pauses: explored cells filled in the region's colour, unexplored cells dim, secret rooms hidden until entered, room walls with gaps where rooms connect, Elam's position blinking, % explored. Arrow keys pan; Tab, Esc or Back closes. The pause menu and the map don't open over each other.
  - Unit tests: index contents, cell maths, % explored, the save round trip. A visual test walks Elam through the sandbox in the real game, opens the map and checks what it draws, including a found secret room.
- **WLD-006**
  - Breakable tiles are painted like any other tile: a hidden variant of the solid tile that looks identical (3 hits) and the cracked brick (2 hits). The hit count is the tile's `breakable` custom data; touching breakable cells break together.
  - Player weapons, weapon arts and Relic Arms break them; enemy attacks don't. Each hit cracks and flashes the tiles; the last one crumbles them into rubble with a shake.
  - A broken group is saved as a world flag (`<room_id>/<layer>@x,y`) and stays broken when the room reloads.
  - A `SecretArea` marks a hidden room outside the room's camera bounds: it can't be seen until Elam enters it, then the camera pans to show it, and back when he leaves. The first entry sets a flag and emits `Events.secret_found` for the map (MAP-009).
  - The sandbox has a hidden wall into a secret room, a hidden floor over a cellar, and a cracked-brick block.
  - Unit tests cover grouping, hit counts and persistence; a visual test breaks a wall and a floor with real attacks and a block with a Relic Arm, enters both secrets and checks the camera.
- **INV-013**
  - `EnemyData.loot` is a `LootTable` rolled once when the enemy dies, with the player's luck; the drop pops out where it died.
  - Every enemy has a table with a common and a rare piece of gear that is found only as a drop (new items), and each new item is visible on Elam (worn sprite or dye).
  - Dropped gear and Relic Arms stay until the room is left; Embers and shekels still blink out.
  - Unit tests: every loot table names real items and has matching entries; every enemy can drop gear; every equipment item is visible.
  - A visual test kills each enemy with a fixed roll, collects the gear, equips it and sees it on Elam.
- **CBT-014**
  - A dummy takes hits without dying and shows each hit's damage, the hit count and DPS over the last 5 s.
  - It names the move that dealt the last hit (weapon, art, Utterance or Relic Arm).
  - A key resets the readout.
- **QA-008**
  - One room has a station for each feature: dummies at 40/80/150 px, a wall, a platform ladder, lamps, Relic Arm pickups, an item chest and enemy pens.
  - It loads from the debug tools and returns the player to where they were.
  - A visual test walks through it and every station logs PASS.
- **EQV-005**
  - Equipping a weapon, shield, helm, seal or relic shows its sprite at the right attach point in every animation frame, mirrored correctly when facing left.
  - Changing equipment in the pause menu updates Elam immediately.
  - Items on the far side (left hand) draw behind the body, near-side items in front.
- **EQV-006**
  - Equipping a different body armor or mantle recolors only that material's pixels.
  - Hit flash and other sprite effects still work on top of the recolor.
- **AI-005**
  - Enemies respawn on room re-entry.
  - Off-screen enemies go dormant.
  - The maximum active count is respected.
- **ENM-007** (Gate Spearman)
  - Five telegraphed attacks, each with an answer: stab (jump it or back-dash), floor sweep (jump it), anti-air (drawn by jumping in close), fireball (crouch, jump or cut it with a weapon), leap-plunge (step out from under).
  - A staggering hit during any wind-up cancels the attack.
  - Hitboxes match the painted spear. The anti-air reach past the painted tip is shown by a spear-light streak.
  - `tests/visual/spearman_test.tscn` checks each answer, and every check passes.
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
- **2026-10-14 (PIPE-001, Elam style anchor)**
  - PIPE-001 → done. The approved anchor is PixelLab character `a6fa2f9e-2d8f-435c-b6c3-c89e08dceec1` (v3, side view, 4 directions, 91 px tall on a 96×96 canvas). The full recipe is in ART_BIBLE §7.4.
  - **Round 1:** standard, v3 and Pro Flash routes. The user preferred v3's quality but said it read as an elf, and asked for a regeneration using their reference image as the style guide.
  - **Round 2:**
    - The reference was unzoomed and used as `style_image` for `create_image_pro`, giving 4 candidates.
    - The straight-on candidate was rotated with v3 and approved.
    - Hand-placed details (workbench, free): gold hair rings, cylinder-seal clasp, lapis throat glyph. Saved to the east and south rotations.
    - Review sheets: `docs/art_reviews/2026-10-14_elam_anchor*.png`.
  - Decisions:
    - **Hero is about 90 px tall** (the user's choice, for detail). ART_BIBLE size classes and the GDD tuning values are scaled to match.
    - The reference image stays local and gitignored because it's third-party art.
    - Characters must not read as copies of the reference's character.
  - New tool: `tools/import/contact_sheet.gd` (review sheets that print drawn sizes).
  - Gens spent: 23.1 (round 1: 11; round 2: 12.1). About 122 left; the allowance resets 2026-10-17.
  - **Next:** PIPE-002 (palette from the anchor), PIPE-004 (sheet packer), then PIPE-003 with a first idle animation.
- **2026-10-14 (PIPE-002, palettes)**
  - PIPE-002 → done.
  - The Elam anchor was reduced from 75 colors (AI noise, many near-duplicate blacks) to 32 with `reduce_colors` across all 4 rotations together, then saved back with `save_to_asset`. It looks identical.
  - `assets/palettes/elam.{png,hex}` holds Elam's 32 colors, used to lock future animation frames.
  - `assets/palettes/master.gpl` is the curated source: 9 ramps, 48 colors. `master.{png,hex}` are generated from it. ART_BIBLE §3.1 and §3.3 are updated.
  - New tool: `tools/import/palette_tool.gd` (`extract`, `gpl`).
  - Gens spent: 0.1.
  - **Next:** PIPE-004 (sheet packer), then PIPE-003 with a first idle animation (about 1–3 gens).
- **2026-10-14 (PIPE-004, sheet packer)**
  - PIPE-004 → done. `scripts/util/sheet_packer.gd` (`SheetPacker`):
    - One row per animation, fixed cell size.
    - Each frame's source pivot (the feet) lands on the shared cell pivot, so PixelLab canvases of different sizes line up.
    - Frames whose opaque pixels get clipped are reported.
    - Writes a JSON layout sidecar.
    - Sprite2D plays it with `frame_coords = (frame, row)`.
  - 5 unit tests; 12/12 tests pass.
  - Gens spent: 0.
  - **Next:** PIPE-003 (character importer). Needs a first Elam animation (`breathing-idle` or a v3 idle, about 1–3 gens).
- **2026-10-14 (PIPE-003, character importer; first Elam animation)**
  - PIPE-003 → done. ART-001 → doing (idle done).
  - **Elam's idle:** v3 animation, east, 8 frames (3 gens).
    - It came back with 62 colors.
    - It was palette-locked to `elam.png` (`reduce_colors` with `palette_image_url`, 0.1 gen) down to 30 colors, all in Elam's palette, and saved back to the animation.
  - **PixelLab's export format:** `metadata.json` maps each animation and direction to its frame files. Animation canvases (132) grow evenly around the rotation canvas (96), so pivots can be derived from the rotation.
  - **Importer:** `tools/import/import_character.gd`, driven by `art_src/.../elam/import.json`. It outputs `assets/sprites/player/elam/elam.{png,json}` and `elam_anims.tres`. Re-running gives byte-identical files, and the idle's feet sit exactly on the ground line.
  - **Preview:** `tests/visual/character_preview.tscn` → `VISUAL PASS elam/idle: 8 of 8 frames shown`. The mirrored copy keeps its feet in place. The frame is saved as `docs/art_reviews/2026-10-14_elam_ingame_idle.png`.
  - Gens spent: 3.1. About 118.7 left; the allowance resets 2026-10-17.
  - **Next:** PIPE-006 (tileset importer; needs a GTE tileset, about 3 gens), then M1 (PLR-002/001).
- **2026-10-14 (PIPE-006, tileset importer: M0 complete)**
  - PIPE-006 → done. **M0 is complete.**
  - **GTE tileset:** generated with `create_sidescroller_tileset`; 16 corner-based Wang tiles, 2.6 gens.
    - The image endpoint redirects, so download it with `curl -L`.
    - `metadata.json` gives each tile's corner flags (lower = solid, upper = air) and its position in the sheet.
  - **Importer:** `tools/import/import_tileset.gd` with an `import.json` recipe.
    - Produces a MATCH_CORNERS terrain set; corner bits come from the metadata, and the all-air tile is skipped.
    - Collision comes from solid corner quadrants merged with `BitMap.opaque_to_polygons` (L-shapes and diagonals handled).
    - Output: `assets/tilesets/gte/gte_solid.{png,tres}`.
  - **Demo room:** `tests/visual/tileset_room.tscn` paints with `set_cells_terrain_connect` → VISUAL PASS (0 holes in 256 cells; the capsule lands and stops at the wall).
  - **Finding:** with corner tiles, the solid edge sits half a tile inside the painted cells. Added WLD-023 (dual-grid art layer) to line the art up with the 16 px grid.
  - Gens spent: 2.6. **115.7 left**; the allowance resets 2026-10-17.
  - **Next:** the user's verdict on the GTE tileset style, then WLD-023, then M1 player work (PLR-002/001/003/004).
- **2026-10-14 (playable core: movement, combat, stats, enemies)**
  - **New main character:** the user's reference image (`assets/e99196a6-….jpg` at the repo root, a folder for user-supplied reference art) replaces the previous Elam look.
    - Pipeline: flood-fill the baked checkerboard to white, then unzoom.
    - Then `create_image_pro` with the reference as both design reference and style image. Candidate 1 was picked, then rotated with v3 into character `aa0091a3-fdf9-4ffa-a82e-207c905c5126`.
    - Animations: idle, walk, jump (split into jump and fall), crouch, back-dash and hurt with v3. The v3 "attack" had no swing, so it was rejected and replaced by a PixMiniMax sword slash (`attack_sword`, 1 gen) with a baked smear arc.
    - Imported with 160×128 cells, widened for the sword slash.
  - **Player** (`scenes/actors/player/`): seven states (Ground, Air, Crouch, Backdash, Attack, Hurt, Dead) on a `StateMachine` with an `@abstract` State. It covers:
    - SotN-style instant walk and facing; variable jump, coyote time and jump buffer; dropping through one-way platforms.
    - Back-dash that cancels into an attack or jump; ground, crouch and air attacks timed by `WeaponData`.
    - Knockback, invulnerability with flicker, death and respawn, and a "LEVEL UP" popup.
    - Tuning is in `data/player/player_tuning.tres`. Jump speed is solved for the 60 Hz step, so the apex is exactly 144 px.
  - **Combat:** `Hitbox`, `Hurtbox`, `HealthComponent`, `DamageInfo`, `Combat.damage` (attack − defense/2, crit ×1.5 from LCK), hit-stop, a hit-flash shader, and pixel-font damage numbers.
  - **Stats:** `PlayerStats` on `Game.stats` (LV, XP curve, STR/CON/INT/LCK, HP/MP, ATK/DEF), with the HUD and a status screen on Esc/Start.
  - **Enemies:** an `@abstract Enemy` base plus three behaviors, Mudborn, Gate Spearman and Humbaba Mask (with spawner). Their art is still placeholder.
  - **Room:** the sandbox room (3 screens wide) holds the Gazelle Anklet relic (double jump) and a wall that needs it. The main scene loads it and respawns everything on death.
  - **Tests:**
    - Unit tests: 34/34 pass.
    - `tests/visual/gameplay_test.tscn`: 8/8 checks pass (walk 180 px/s, apex 144.1 px, back-dash 100 px, crouch, sword kill +12 XP, contact damage, i-frames, level-up).
    - `tests/visual/sandbox_tour.tscn`: 4/4 pass (camera keeps the floor in view, relic pickup and banner, double jump over the 160 px wall, Spearman thrust).
  - **Bugs found and fixed by the tests:**
    - `PlayerStats` redeclared Resource's built-in `changed` signal.
    - Damage numbers spawned at the world origin.
    - The camera `offset` ignored the room limits.
    - The mask spawner's typed lambda broke on freed masks.
    - Jump apex overshoot and back-dash short by one frame.
  - Gens spent: about 31 (hero candidates 10, rotation 2, 7 animations 18, attack 1, unzoom 0.1). **84.6 left** until the 2026-10-17 reset.
  - **Next:** see **Now**.
- **2026-10-15 (enemy sprites, SotN polish, lamps, drops, save room, equipment menu)**
  - **Enemy art** (24 gens in total):
    - Mudborn and Gate Spearman: Pro Flash characters (7 each), using the hero's front rotation as a style-only reference.
    - Mudborn walk and Spearman walk: v3 (3 each).
    - Spearman thrust: PixMiniMax (1), split into windup, thrust and recover in the importer.
    - Humbaba Mask, votive lamp and save altar: Pixen (1 each).
    - The `Enemy` base builds a Sprite2D and AnimationPlayer from the imported sheet. The placeholder `_draw()` remains as a fallback.
  - **Polish:**
    - `AfterimageTrail` adds violet fading ghosts while back-dashing.
    - `HitSpark` adds a pixel starburst on every hit.
    - `GameCamera.shake` shakes by whole pixels, scaled by the accessibility setting `screen_shake`. It fires when the player is hit, on kills and on critical hits.
  - **Items:**
    - `ItemData` (abstract) → `EquipmentData` (Kind WEAPON, SHIELD, HEAD, BODY, MANTLE, SEAL) → `WeaponData`.
    - Nine items in `data/`.
    - `Inventory` (counts) on `Game.inventory`.
    - `PlayerStats` gained seven SotN slots, `total()`, `preview()`, `summary()`, embers and shekels.
    - `Game.equip()` swaps items between the inventory and the slots.
    - Starting kit: Short Sword, Mason's Mail and Crimson Mantle equipped; Sappara, Lapis Shield, Scribe's Circlet and Seal of Shamash carried.
  - **World:**
    - `VotiveLamp` breaks on one hit and rolls a `LootTable` (luck raises item weight).
    - `Pickup` drops pop out, fall, are pulled to the player and blink out.
    - `SaveAltar`: press Up to restore HP/MP and save.
    - Saves (SAV-001/006) are versioned JSON, written to a temp file then renamed, with a `.bak` kept.
    - Main resumes from the save at boot and returns to the last save on death.
  - **UI:** a pause menu with the status sheet and the EQUIP page. It shows the seven slots, stats with a green/red before→after preview, and wrapped descriptions. The HUD shows embers and hides while paused. The pixel font gained punctuation glyphs.
  - **Tests:**
    - Unit tests: 46/46 (loot, inventory, equipment math, Game.equip, save round trip, corrupt save).
    - Visual checks: 21/21 (`gameplay_test` 8, `sandbox_tour` 4, new `systems_test` 9).
  - **Bugs fixed:**
    - The afterimage trail read the player's sprite before the player had initialized.
    - `JSON.parse_string` printed an extra engine error on corrupt saves.
  - Gens spent: 24. **60.6 left** until the 2026-10-17 reset.
  - **Next:** see **Now**.
- **2026-10-15 (constant crouch, crouching slash, Gate Spearman moveset)**
  - **Crouch "not constant" fixed:** after a non-looping animation finished, `AnimationPlayer.current_animation` went empty, so `play_animation` restarted the crouch every frame (the jump pose had the same bug). `Player` and `Enemy` now compare `assigned_animation`, so a finished animation holds its last frame; `restart` replays on purpose. Leaving a crouching slash with Down held goes straight to the held crouch pose.
  - **Crouching slash:** a new PixMiniMax animation (`crouch_attack`, group 780ffc93, 1 gen), frames 0–5. Frames 6–7 stand up, so they are dropped. The low hitbox is unchanged.
  - **Gate Spearman (ENM-007)**, rewritten as one attack table, `Spec` (wind-up, active and recover frames; hitbox; power; lunge; animations):
    - **Stab:** close, chest height. The painted spear crosses a crouching head, so the hitbox is honest and a crouch does not dodge it. Jump it or back-dash out. ART-017 tracks a lower crouch.
    - **Sweep:** close, alternating with the stab. It scrapes the floor front to back; jump it.
    - **Anti-air:** chosen whenever the player is airborne and above within 110 px. The wind-up is only 12 frames. The hitbox reaches past the painted tip, and a gold spear-light streak is drawn over that reach.
    - **Fireball:** at 150 px or more, on a 160-frame cooldown. The cast frame holds the painted fireball, then the real `Fireball` (`scenes/actors/enemies/projectiles/`) replaces it at the same spot. It climbs 9 px so it clears a crouch, flies 170 px/s, bursts on walls, and can be cut by a sword stroke (it has a Hurtbox on enemy_hurtbox).
    - **Leap:** at 100–220 px, on a 200-frame cooldown. It rises so the apex is over the player, then plunges spear-down at 620 px/s. Contact damage is off while airborne, so the plunge lands the hit. It lands with a shake and a spark.
    - A staggering hit in any wind-up cancels the attack. Aggro range is raised to 340. Tests can set `forced_attack`.
  - **Art:** four PixMiniMax animations on 34128d92 (sweep 50b04977, anti_air 7f951b80, cast 88715c3d, leap 7ad06154; 1 gen each), split into wind-up, active and recover in `import.json`. The fireball sprite is cropped from cast frame 5 (no generation).
  - **Importer:** a new per-animation `lift` re-seats airborne frames that PixelLab painted above the feet line (leap rise 13 px, plunge 18 px). The Spearman cell grew to 192×132, so the sweep's spear tip no longer clips.
  - **Tests:** new `tests/visual/spearman_test.tscn`, 12/12. It covers constant crouch, crouching slash, stab vs crouch, standing and jumping, sweep vs standing and jumping, anti-air chosen and connecting, fireball vs standing and crouching, sword cuts fireball, and leap plunge. Regression: gameplay 8/8, sandbox tour 4/4, systems 9/9, unit 46/46.
  - **Bugs found by looking at captures:**
    - The fireball blinked out for one frame at the hand-off. It needed `reset_physics_interpolation()` after placement.
    - Contact damage stole the plunge's hit.
    - The stab's painted spear crossed a crouching head the hitbox missed. The hitbox was made honest.
  - **Design choice to confirm:** the user named three attacks (upward thrust, fireball, jumping-down attack); the fourth, the floor sweep, is Claude's pick and is easy to swap.
  - Gens spent: 5. **About 55.6 left** until the 2026-10-17 reset.
  - **Next:** the user's playtest of the Spearman and the crouch, then **Now** item 1 (jump attack and death art).
- **2026-10-15 (visible equipment: EQV-001..008, EQV-011)**
  - **The user's rule:** every relic, equipment item, weapon and accessory slot must appear on the character.
  - **The user's choices** (all recommended options):
    - Body armor and mantles recolor, with add-on pieces where needed.
    - The cape is always worn.
    - Weapons and shields are held in hand at all times.
    - Attach points come from regenerating Elam's animations with a guide prop (~75 gens approved).
    - Recorded in GDD §6.7 "Visible equipment" and ART_BIBLE §6.3.
  - **Guide prop:**
    - A key-green rod painted into Elam's fist, then the stored character animated with PixMiniMax from that start frame.
    - Animating a loose image turned his back to the camera on both slash attempts, so attacks must use the stored character.
    - The importer (`GuideProp`) finds grip and angle in every frame, erases the rod, cuts the key-green swing smear into `hero_smear.png`, and measures head, neck, chest, belt, far hand and ankles from the silhouette.
    - The core nine animations were regenerated: idle, walk, jump/fall, crouch, back-dash, hurt, attack and crouching slash. Hero cell is now 208x136.
  - **Data:**
    - New `WornArt` (texture, pivot, points, layer, follows_angle).
    - `EquipmentData` gains `worn`, `dye_material` and `dye_ramp`.
    - New `RelicData` (ability + worn). `data/relics/gazelle_anklet.tres`.
  - **Rig (`EquipmentRig` on the player):**
    - One sprite per item, placed on the current frame's points every rendered frame, mirrored with facing.
    - The shield sits behind the body on the far arm. Seal slot 1 hangs at the chest and slot 2 at the belt; the anklet goes on both ankles.
    - The weapon hides on smear frames while the smear shows in the weapon's `slash_color`.
    - `equipment_dye.gdshader` turns Mason's Mail plates bronze and colours the mantle lining.
    - Rig sprites opt out of physics interpolation: like the fireball earlier, a new sprite was drawn at the feet for one frame.
  - **Bug fixed:** `hit_flash.gdshader` sampled the texture and multiplied it into `COLOR`, which already holds it, so every enemy colour was squared. That is why the Spearman looked black and orange. Enemies now show their art's colours, which closes VFX-016.
  - **Worn art batch 1:** eight sprites drawn in code (`tools/builders/build_worn_art.gd`). PixelLab versions are EQV-012.
  - **Tests:**
    - New `tests/visual/equipment_test.tscn`, 7/7: every item worn; hand points on the fist and head points on the head in all 50 frames; 347 placements exact; mirroring; weapon swap; smear tint; bronze dye measured in the rendered frame.
    - Regression: gameplay 8/8, sandbox 4/4, systems 9/9, spearman 12/12, unit 46/46. No key-green pixels remain in `hero.png`.
  - Gens spent: 12 (8 guide-prop animations, 3 loose-image experiments, 1 crouching slash). **About 43.6 left** until the 2026-10-17 reset.
  - **Next:** the user looks at Elam in his gear. After the refill, finish EQV-009 (the rest of the animation set), then EQV-012 worn art and EQV-010 relics.
- **2026-10-15 (two-handed scythe and per-weapon animations: INV-015, EQV-015)**
  - **The user's request:** a two-handed weapon (scythe) that empties the left hand and changes the attack animation, with custom animations per weapon in future.
  - **Two-handed rule:**
    - `PlayerStats.equip()` now returns everything it takes off.
    - A two-handed weapon empties the left hand, and anything put in the left hand takes a two-handed weapon off (as in SotN).
    - `preview()` runs the same rule on a copy, so the menu's before/after numbers always match.
    - The menu shows the left hand as `(TWO-HANDED)` and tags the weapon.
  - **Per-weapon animations:**
    - `WeaponData.animations` maps any of Elam's animation names to the weapon's own version.
    - `Player.resolve_animation()` applies it everywhere (`play_animation`, `hold_last_frame`, the attack state), falling back to the shared animation.
    - Swapping weapons changes the stance at once.
    - Swings whose art has no smear get the procedural `SlashFX` arc in the weapon's colour.
  - **Scythe of Ninurta:** `data/weapons/scythe_of_ninurta.tres`. ATK 14, 12/8/18 frames, reach 74, height 56, pale violet slash. Worn sprite (64x32) drawn by `build_worn_art.gd`.
  - **Art:**
    - New start frame `rig/start_standing_pole.png`: an upright green pole, so the stance is a reaper's.
    - Guide-prop `scythe_idle`, `scythe_walk` and `scythe_attack`.
    - The first attack prompt said "scythe reap", and the model painted its own scythe blade and a dark arc that the key can't remove. It was deleted and redone with neutral wording ("swing of the plain green pole"). Lesson in ART_BIBLE §6.3.
  - **Tests:**
    - Unit 51/51 (5 new: two-handed empties the left hand, the left hand removes the two-handed weapon, one-handed keeps the shield, preview follows the rule, Game.equip returns both, and the save round trip keeps the scythe).
    - `equipment_test` 11/11 (4 new: both hands taken, own animations, arc and scythe in hand through the reap, instant swap back).
    - Regression 33/33.
  - Gens spent: 4 (idle, walk, attack twice). **About 40.6 left** until the 2026-10-17 reset.
  - **Next:** the user tries the scythe. Then EQV-017 class sets and EQV-016 for the scythe's other moves after the refill.
- **2026-10-15 (two-handed stance set and walls block attacks: EQV-016, CBT-013)**
  - **The user's request:** a different idle, attack and movement pose with a two-handed weapon than with a one-handed one, and attacks blocked by the environment instead of passing through.
  - **Stance set:**
    - `WeaponData.stance` names the animation set a weapon uses: Elam plays `<stance>_<move>` where the sheet has one. Two-handed weapons default to `two_handed`, so any future two-handed weapon gets the poses for free.
    - Single moves can still be overridden with `WeaponData.animations`.
    - The scythe's idle, walk and attack were renamed to `two_handed_*`.
    - New guide-prop animations: two_handed jump/fall, crouch, back-dash, hurt and crouching slash.
  - **Art lessons:**
    - The first crouching slash reaped backward. The redo was pinned with an **end frame**: the crouched start with its rod erased and repainted forward-down by `rig/repaint_rod.py`; the end frame is kept at `rig/end_crouched_pole_chop.png`.
    - That redo painted its smear in **magenta**. The importer now treats saturated magenta as smear: always cut out, never part of the rod.
    - The crouched poses sat 2 px below the ground line, fixed with `lift: -2`.
    - A grey anti-aliased pixel at the rod's tip survived the erase. The importer now removes tiny detached clusters next to the rod.
  - **Walls (CBT-013):**
    - `Hitbox.has_clear_line()` rays from the attacker's centre line, at the hitbox height, to the target's hurtbox (centre or nearest point) through world tiles (layer 1). Blocked targets aren't marked as hit, so they can still be struck if they step clear.
    - Applies to every hitbox (player weapons, spears, plunge, contact). One-way platforms don't block.
    - The player's swing sparks where it meets a wall within reach.
  - **Fixed along the way:** HitSpark, DamageNumber and the afterimage ghosts were placed after entering the tree, so their first frame was interpolated from the origin. All three now call `reset_physics_interpolation()`.
  - **Tests:**
    - New `tests/visual/wall_block_test.tscn`, 6/6: sword and scythe blocked by a wall and hitting without one; a one-way platform doesn't block; sparks on the wall; spear blocked.
    - `equipment_test` 11/11: all seven moves checked play the two-handed set; 696 placements exact over 100 frames.
    - Regression 33/33, unit 51/51.
  - Gens spent: 7 (6 two-handed animations + 1 crouching-slash redo). **About 33.6 left** until the 2026-10-17 reset.
  - **Next:** the user tries the scythe's full stance and the wall blocking. Then EQV-017 class sets after the refill.
- **2026-10-15 (one animation set per weapon type: EQV-017)**
  - **The user's report:** no difference between two-handed and one-handed swords; each weapon needs its own animations for the character and its attacks, because each type is held differently.
  - **Why it looked the same:** the Short Sword, Sappara and Bronze Mace (all one-handed) shared the sword set, and there was no two-handed sword.
  - **Change:** every weapon type now has its own full set (idle, walk, jump, fall, crouch, crouching attack, back-dash, hurt, attack):

    | Type | Weapon | Hold |
    |---|---|---|
    | sword | Short Sword | shared set, lowered forward |
    | sickle_sword | Sappara | level, ready to hook; slash with a wide smear |
    | mace | Bronze Mace | hanging; raise and smash |
    | greatsword | Lion-Hilt Greatsword (new, two-handed, ATK 16) | raised two-handed guard; overhead cleave |
    | scythe | Scythe of Ninurta | upright reaper hold (renamed from `two_handed_*`) |

  - **Code:**
    - `WeaponData.stance` names the type's set, and the implicit two-handed default is gone.
    - The importer anchors a wide two-handed grip on the rear fist, and the great sword pivots at its pommel end.
    - The mace and great sword are in the starting bag.
  - **Art:**
    - 24 guide-prop animations plus 1 redo (the mace attack turned Elam's back twice, so frames 2-4 are dropped; see EQV-020).
    - Crouching attacks pinned with painted end frames.
    - Lifts: -1 to -4 for the crouched poses.
    - PixelLab runs at most 8 jobs at once.
  - **Tests:**
    - `equipment_test` 11/11: 35 weapon moves each play their own type's set; 247 frames with the hand on the fist; 1,720 placements exact.
    - Regression 39/39, unit 51/51.
  - Gens spent: 25. **About 8.6 left** until the 2026-10-17 reset.
  - **Next:** the user compares the five holds in game. After the refill: EQV-018 sheet split, EQV-019 and EQV-020.
- **2026-10-15 (SotN specials pass, logic only: PLR-025, INV-016, SUB-001..003, SPL-001..003, SPL-010, SPL-020, ENG-012)**
  - **The user's request:** focus on logic while PixelLab is low; add the missing SotN features (running, equipment that grants abilities, special attacks that spend resources); suggest features for the playtest. World and story come last.
  - **Running (PLR-025):** double-tap and hold; walk 180, run 290 px/s (`PlayerTuning.run_speed`, `run_tap_frames` 14). Air control uses the run speed, so a jump out of a run keeps it. Until the run art exists, the walk plays at 1.6×.
  - **Command input (SPL-001):** `CommandInput` records direction changes per physics frame and matches notation like `D,DF,F` relative to the facing at the press, with a per-move window and an 8-frame release grace. The longest matching command wins.
  - **Specials (SPL-002/003/010/020):** `SpellData` drives Utterances and weapon arts through one `Cast` state (wind-up, effect, recovery). Effects: bolts, lunge, shockwave, cleave, whirl. Not enough Breath fizzles and the press attacks normally. Išātu is known at the start for the playtest.
  - **Relic Arms (SUB-001..003):** `RelicArmData` (cost, flight, damage, on-screen limit). `PlayerShot` is the shared projectile (also used by spells). Pickups swap the carried arm and drop the old one. The HUD shows the carried arm.
  - **Equipment (INV-016):** `EquipmentData.abilities` and `passives`; `Game.has_ability` also checks what is worn; `PlayerStats.passive()` sums across items. Five test items in the starting bag. The equip screen lists the effects.
  - **Debug (ENG-012 first pass):** F1 overlay with recent inputs, F2 everything, F3 refill, F4 god mode, F5 cycle Relic Arm. Debug builds only.
  - **Test lessons:** a scripted `Input.action_press` registers on the next physics frame, so test presses last 2 frames and modifiers (Up) stay held past the press. A focus change while the capture window opens releases held actions, so the test waits 30 frames first. Breath regen needed an epsilon (2/s × 2 s summed to 3.9999).
  - **Tests:** new `tests/visual/specials_test.tscn` 16/16; unit 68/68 (17 new: command input and specials); regression 50/50 (gameplay, sandbox, systems, spearman, wall block, equipment).
  - Gens spent: 0. **About 8.6 left** until the 2026-10-17 reset.
  - **Next:** the user playtests the specials (see Now). After the refill: ART-018 (ask first). Suggested logic next: CBT-014 training dummy, QA-008 feature gym, PLR-015 guard, PLR-023 potions.
- **2026-10-15 (enemy loot tables: INV-013)**
  - **The user's request:** enemies drop gear, so the equipment loop works in play.
  - **Loot:** `EnemyData.loot` is a `LootTable` rolled once in `Enemy._on_died` with the player's luck; the drop pops out at mid-height where the enemy died. One shared generator (`Enemy.seed_loot` / `loot_rng`) makes drops repeatable in tests.
  - **Drop-only gear** (not in the starting bag), with code-drawn worn art and dyes:

    | Enemy | Common (weight /100) | Rare (weight /100) |
    |---|---|---|
    | Mudborn | Potsherd Seal (10) | Riverclay Mail (4) |
    | Gate Spearman | Gate Guard's Helm (16) | Watchman's Mantle (8, HP regen 0.5/s) |
    | Humbaba Mask | — | Seal of Humbaba (5) |

  - **Pickups:** gear and Relic Arms no longer blink out; Embers and shekels still do after 10 s.
  - **Found along the way:** INV-007 was marked done with a pity counter that doesn't exist; the row now points to RPG-005, which still owns it. In tests, a freed object compares equal to null, so record results before collecting a pickup.
  - **Tests:** new `tests/visual/loot_test.tscn` 8/8 (kill drop, gear stays while Embers blink out, collect and wear, each enemy's gear dropped, worn and visible, mantle regen); unit 74/74 (6 new in `test_enemy_loot.gd`: tables well formed, every enemy drops gear, drop-only gear not given, rates, every equipment item visible, seeded rolls repeat); regression 66/66.
  - Gens spent: 0. **About 8.6 left** until the 2026-10-17 reset.
  - **Next:** the user plays the sandbox and judges the drop rates. Suggested: RPG-005 pity counter, CBT-014 training dummy, QA-008 feature gym.
- **2026-10-15 (breakable walls and secret rooms: WLD-006)**
  - **The user's request:** special tiles that can be destroyed, used as in SotN to hide secret rooms off the map.
  - **Breakable tiles:** the greybox TileSet has a `breakable` custom data layer (hits to break) and a hidden variant of the solid tile as alternative 1 (identical art, 3 hits); the cracked brick takes 2. A `BreakableTiles` child of a TileMapLayer groups touching breakable cells, gives each group a hurtbox on the breakable layer (12 px margin, so a crouching strike reaches floors), cracks and flashes it per hit, crumbles it into rubble cut from the tile's own art, and saves `<room_id>/<layer>@x,y`. `Hurtbox.terrain_rects` lets the wall check (CBT-013) count a ray that stops on the wall itself.
  - **Secret areas:** `SecretArea` (a `@tool` node with an `area` and a camera `view`) sits outside the room's camera bounds. When Elam's feet enter it, the camera limits pan to its view (0.35 s) and pan back when he leaves; the first entry sets `<room_id>/secret/<name>` and emits `Events.secret_found` for the map (MAP-009, new row).
  - **Sandbox:** cracked block at tiles 64-65; hidden floor at 98-100 over a cellar dug into rock (ledge to climb out, 2 lamps); hidden stretch of the right wall at rows 14-19 into an east room (3 lamps). F1 outlines breakables and secret areas.
  - **Helpers:** `WorldKeys` builds `<room_id>/<name>` flags; `Rubble` VFX.
  - **Test reliability:** the capture window loses focus about 1.3 s after opening (the editor takes it back), which released held keys mid-test. New `tests/visual/window_settle.gd` waits for that before scripted input; specials, loot, secrets and gameplay tests use it (gameplay now needs 800 frames).
  - **Tests:** new `tests/visual/secrets_test.tscn` 6/6 (hidden wall pixel-identical to the plain wall, sword breaks it in 3, secret room shown only once entered and the camera pans back, crouching strikes break a hidden floor into the cellar, Sling Stones break a cracked block, broken tiles stay broken on rebuild); unit 79/79 (5 new in `test_breakable_tiles.gd`); regression 74/74.
  - Gens spent: 0. **About 8.6 left** until the 2026-10-17 reset.
  - **Next:** the user tries the sandbox secrets. Later: WLD-024 breakable variants for the PixelLab tilesets, MAP-009 when the map exists.
- **2026-10-15 (the map: MAP-001..003, MAP-009, REL-008)**
  - **The user's request:** a map system that shows the map, where Elam is, where he has been and where he has yet to go, gated by a relic found later in the game but given for now.
  - **World index (MAP-001):** `tools/world/build_world_index.gd` instantiates each room under `scenes/world/rooms/`, reads its `bounds`, `map_cell` and `region`, records its cells (640×360 px each), each `SecretArea` as its own secret room, and the openings between cells of different rooms from the Solid tiles (breakable tiles count as open). The sandbox gives 3 room cells, 2 secret cells (east room, cellar) and 2 openings.
  - **Discovery (MAP-002):** `WorldMap` marks the cell under Elam's feet every physics frame, reports % explored (secret cells add past 100%), and saves the discovered cells in the save file (`"map"`).
  - **Map screen (MAP-003, MAP-009):** `scenes/ui/map/map_screen.gd` on the Menus layer. Tab opens it and pauses; explored cells in the region's colour, unexplored dim with dim walls, secret rooms hidden until entered, double walls between rooms with a gap at openings, a blinking marker kept inside Elam's cell, % explored. Arrows pan; Tab, Esc or Back close, and the same Esc press doesn't open the pause menu.
  - **Builder's Plan (REL-008):** relic with ability `map`, granted at start by `Game.STARTING_RELICS` for now; worn as a clay tablet at the back of the belt. Without it Tab shows "NO MAP".
  - **Lessons:** a `-s` tool script compiles before the autoloads exist, so it can't reach classes that use them (duck typing by group instead), and nodes added in `_initialize()` aren't in the tree until the first frame. Added to CLAUDE.md.
  - **Tests:** new `tests/visual/map_test.tscn` 5/5 in the real game (discovery, the drawn cell colours, Esc closes without the pause menu, no plan no map, a found secret room with its door); unit 86/86 (7 new in `test_world_map.gd`); regression 80/80 (equipment_test counts the plan on the belt).
  - Gens spent: 0. **About 8.6 left** until the 2026-10-17 reset.
  - **Next:** the user tries the map. Later: MAP-010 icons, MAP-004 minimap, MAP-007 full completion rules, MAP-008 exit validator once rooms connect (WLD-002).
