# BABEL: Game Design Outline

**Working title:** BABEL: Requiem of Tongues
**Genre:** 2D side-view action RPG / metroidvania
**Platform:** PC (Windows first; Linux and Steam Deck as targets)
**Engine:** Godot 4.6.1, GDScript
**Art:** pixel art generated with PixelLab, then finished by hand

**Status:** v0.2 outline. v0.1 2026-10-14; **tone set 2026-10-16: grim devotional horror in a twisted religious alternate world** (§1, §2, §4.6–4.7). This is a living document. Items marked ⟨open⟩ are undecided. Build tasks are tracked in [BACKLOG.md](BACKLOG.md), and the visual spec is in [ART_BIBLE.md](ART_BIBLE.md).

---

## 1. Pitch

The Tower of Babel was never destroyed. When the tongues were confounded, the unfinished tower was cursed instead: it cannot fall and it cannot be finished, and everyone who died building it is still inside it. Four thousand years on, it is the cathedral of a world that worships the curse. The **Church of the Sealed Mouth** teaches that speech is the first sin, and its penitents sew their lips and cut out their tongues to be forgiven. The angels who came down to scatter the builders, **the Choir**, never went back: they keep the tower as its jailers and rot in their own holiness. Beneath it, the old gods and demons of the plain gnaw at the foundations.

**Elam** is the scribe who shattered the Tablet of Destinies and brought the Confounding down. He is the last mouth that still speaks the First Tongue, and the curse will not let him die while the tower can still be finished. Now the tower stirs again. He wakes in a buried kiln and climbs it, through the damned, the faithful and the broken Choir, to stop **Nimrod, the Hunter-King**, from speaking the Name that opens heaven.

BABEL is a spiritual successor to *Castlevania: Symphony of the Night* (SotN) in structure: one vast interconnected building explored with elegance, RPG depth (levels, equipment, loot, spells cast by command input, familiars and transformations), and a mid-game reveal that turns the world upside down. Here the reveal is the tower's drowned reflection, which hangs down into the primordial waters of the **Abzu**. Its tone and world take **heavy inspiration from *Blasphemous* 1 and 2 and *Fear & Hunger***: devotional horror, a faith that is itself the monster, grotesque relics and cruel miracles (§4.6–4.7).

## 2. Design pillars

1. **Devotion is the horror (decided 2026-10-16).** The world is religious through and through, and every part of it is twisted: miracles maim, relics are pieces of people, angels are jailers rotting in their own holiness, demons are the old gods of the plain, and the church worships the curse that broke humankind. It is dark and edgy, but made with care: the grotesque is ornate, sad and beautiful, never cheap shock (§4.6–4.7).
2. **One tower, every age of pride.** Every age that dreamed of reaching heaven added a layer to the tower, each in its own architecture and its own heresy: mudbrick at the base, then arches like Bruegel's Babel, Gothic spires, Renaissance clockwork, and iron and wire at the top. Each region is a new age, yet it is all one continuous building. ⟨open: how much late technology the alternate world keeps (§14)⟩
3. **Language is power, and blasphemy.** The First Tongue is the magic system, and in the Church's eyes speaking it is the oldest sin: every Utterance Elam casts is a blasphemy, and the tower hears it.
   - Spells are spoken words entered as "syllables" (command inputs).
   - Doors are sealed by words.
   - NPCs speak confounded languages that you gradually learn.
   - The story's key twist depends on finally understanding what someone is saying.
4. **Exploration always pays.** Every dead end hides something: a breakable wall, a secret room, a rare drop or more map percentage. Relics reopen old spaces. The map itself is a trophy.
5. **Lavish pixels with depth.** The goal is SotN's readable elegance in a grim baroque look (ART_BIBLE §1) at 640×360, using dense parallax, normal-mapped 2D lighting, atmosphere and smooth sprite animation. Sprites are never mixed-resolution and never smoothly scaled.

## 3. SotN DNA: keep, evolve, avoid

| Keep | Evolve | Avoid |
|---|---|---|
| One interconnected building, with completion % on the map | Quick-cast option for spells (accessibility) | Rare drops that require grinding (we add a hidden pity counter) |
| RPG stats, XP and levels | Equipment comparison and a sort/filter inventory | Picking up a sub-weapon that silently replaces your current one ⟨open: owned arsenal vs. pickup-swap⟩ |
| Two-hand equipment (each button uses one hand's item) | Input buffering, coyote time and fully rebindable controls | Softlocks and one-way traps with no exit |
| Sub-weapons with their own resource | Map pins and region names on the map | Long Act II backtracking without fast travel (we add more lifts) |
| Spells cast by command input | Adaptive music (explore, combat and boss layers) | Unreadable dark rooms without an option to brighten them |
| Familiars that level up through use | Boss rush and time trials after release | |
| Three transformations | Accessibility: hold-or-toggle forms, less flashing, less screen shake | |
| Relics that gate progress and can be toggled | | |
| Librarian-style shop and bestiary | | |
| Damage numbers, back-dash and secret walls | | |
| An inverted second half and multiple endings | | |
| Save rooms and teleport rooms | | |

## 4. Setting and story

### 4.1 Mythic backstory

- Before the Confusion, everyone spoke one language: **the First Tongue**, the language in which the world was named, and in which a name has power over what it names.
- **Nimrod**, Hunter-King of Shinar, built **Etemenanki** ("House of the Foundation of Heaven and Earth") to storm heaven. He shot an arrow at the sky, and it came back bloodied. Then he set out to inscribe the **Tablet of Destinies** in the First Tongue and speak the Name from the summit, to make himself a god.
- The tower was raised from mudbrick tempered with the bodies of the builders who fell. Their ghosts are still in the brick.
- **Elam**, his royal scribe and master mason, understood what the Name would do and shattered the Tablet at the summit. In that moment **the Choir** descended and confounded the tongues. The builders could no longer understand each other; many tore at their own mouths. The work stopped.
- The Choir could not unmake the tower, so they cursed it: **it cannot fall and it cannot be finished.** They stayed to guard it, and have kept their watch so long that their holiness has curdled: wings nailed to the brickwork, eyes multiplied, faces worn smooth by the one note of the Confounding they still sing.
- Elam alone kept the First Tongue, and it binds him: **he cannot die while the tower can still be finished.** He sleeps whenever the tower sleeps. He knows the Confounding was his doing, and carries it as penance.
- From the ruin grew the **Church of the Sealed Mouth**. It teaches that speech was humankind's first sin and the Confounding its just punishment. The faithful sew their mouths to be forgiven, its priests speak only in signs, and its saints are those who cut out their own tongues; its relics are what is left of them. ⟨open: final name of the faith⟩
- The **old gods and demons of the plain** (Lamashtu, Pazuzu, Humbaba, Namtar, the spawn of Tiamat) were here before the tower, and feed on it from below.
- The tower sank beneath the plain, and it rises whenever enough voices are raised as one. Every age that rose with it left its architecture on it.
- The 72 shards of the Tablet (one for each tongue of the nations) are scattered through the tower. They are the **Glyphs**, the game's lore collectibles.

### 4.2 The present (proposal, 2026-10-16; to be settled in NAR-001)

- The game is set in an **alternate world** shaped by the Confounding, not in our history. ⟨open: the v0.1 frame (the year 1893, the Eiffel Tower, telegraph cables, Ottoman Mesopotamia, a Danish philologist) is to be reworked into it⟩
- **The Jubilee of One Voice:** the Church gathers its pilgrims for a great silent liturgy at the tower's foot, the first time in an age that so many have been of one mind. It is enough. The tower stirs. Ashipu, the Church's high priest, arranged it.
- **Prologue (a generation ago):** Sera Valcourt of the **Measurers**, an order that breaks the tower whenever it rises, climbs during the last Stirring and puts Nimrod back to sleep at the summit. Then she vanishes.
- **Now:** the tower rises again, faster. Elam wakes.

### 4.3 Characters

| Character | Role (SotN analog) | Notes |
|---|---|---|
| **Elam** | Protagonist (Alucard) | Ageless scribe-mason of Nimrod's court and keeper of the First Tongue; the man who brought the Confounding down, carrying it as penance. **His look follows the user's reference art in `assets/` at the repo root (2026-10-14):** a tall, lean man with short swept silver-grey hair and a stern face. He wears a long dark charcoal frock coat with purple-and-silver plate armor on the shoulders, chest and forearms, a crimson vest, tall laced boots with silver buckles, and a long dark cape lined in crimson. Calm, sorrowful and dryly bitter. He speaks rarely. The sprite is in ART_BIBLE §10.1. |
| **Sera Valcourt** | Richter | A tower-breaker of the Measurers, who won the last rising. Elam finds her at the summit as the "Herald of the Tower," her mouth sewn by Ashipu, speaking only a confounded tongue. Her weapon, the Measuring Chain, is a surveyor's chain used like a whip, its links stamped with the names of the fallen. |
| **Adela Rask** | Maria | ⟨open, NAR-001⟩ A scholar of the forbidden tongues, hunted by the Church as a heretic. She is searching for Sera, who is her friend. She gives Elam the **Interpreter's Lens**. In Act II she can be lost or rescued, which affects the ending. |
| **Nimrod, the Hunter-King** | Dracula | Builder of the tower: a giant archer who shot an arrow at heaven that came back bloodied. Half-ascended, he sleeps in the tower's reflected foundation, crowned with the wings of the angels he brought down. |
| **Ashipu, the Many-Mouthed** | Shaft | High priest of the Church of the Sealed Mouth, once Nimrod's exorcist. He wears a golden mask with a sewn-shut mouth, and his robes are covered in mouths that speak every language. He engineers the rising and controls Sera. |
| **Namtar, Herald of Fate** | Death | The death-herald of the old gods, who carries plague and fate. He strips Elam's gear at the Grand Gate and returns as a recurring threat and later a boss. |
| **Archivist Nabu** | Librarian | A ghost scribe of the forbidden archive in the Hall of Tablets, who sells what the Church burned. He runs the shop, the bestiary (Codex), the map sales and the lore archive. |
| **Urshanabi** | Ferryman | Ferryman of the waters of death in the *Epic of Gilgamesh*, who asks a fare no living person should pay. He ferries Elam across the Cisterns. |
| **Siduri** | (new) | The tavern-keeper at the edge of the world, from Gilgamesh, pouring wine for the damned on the terraces. She gives hints, side quests and rest. |

### 4.4 Act structure

- **Prologue** (playable, about 5 minutes). Sera fights Nimrod at the Gate of the Gods in 1889. It teaches the basics with Sera's moveset and ends with Nimrod falling and Sera vanishing.
- **Act I: The Ascent.** Elam wakes and runs across the Plain of Shinar. At the Grand Gate, Namtar strips his equipment (Elam's starting gear is lost and recovered later in Act II). Elam then explores the ascending tower, collects relics and forms, meets Rask, and finally confronts Sera at the Gate of the Gods.
  - **Without the Lens:** Sera speaks only confounded glyphs. Defeating her leads to **Ending A**.
  - **With the Lens:** her words resolve, and she is begging to be freed. Elam sees Ashipu's **Binding Seal** above her and destroys it. Ashipu flees into the tower's reflection, the sky folds, and the **Abzu Reflection** opens beneath the foundation.
- **Act II: The Descent.** The inverted tower is the tower's reflection hanging down into the primordial waters, so going downward is progress. *Pride ascends; humility descends.* Elam collects the **six Remnants of Nimrod** (Bow, Arrow, Crown, Eye, Heart and Tongue) from six bosses to unseal the **Foundation Stone**. Rescuing Rask is optional. Then he defeats Ashipu and finally Nimrod.

### 4.5 Endings

| Ending | Condition |
|---|---|
| **A: The Silent King** | Elam kills Sera in Act I. He takes the summit throne and the credits roll. |
| **B: The Scattering** | Elam defeats Nimrod without rescuing Rask. |
| **C: One Speech** | Elam defeats Nimrod after rescuing Rask. |
| **D: The First Word** (secret epilogue) | Ending C plus all 72 Glyphs. |

### 4.6 Angels, demons and the damned

Every enemy and most characters belong to one of four families, which set their look and the voice of their Codex entries.

| Family | What they are | Examples |
|---|---|---|
| **The Choir** (angels) | The host that confounded the tongues and stayed as the tower's jailers. Holy, beautiful and rotten: wings nailed to brick, eyes multiplied, faces worn smooth by singing the one note of the Confounding. They strike at anything that speaks. | Choir Warden, Ophan (a burning wheel of eyes), Censer-Seraph, the Lamassu bound at the Gate ⟨proposals⟩ |
| **The Old Ones** (demons) | The gods and demons of the plain, older than the tower, feeding on it from below. Hungry and sly, and sometimes the only ones who tell the truth. | Lamashtu, Pazuzu, Humbaba, Namtar, the Spawn of Tiamat |
| **The Damned** (monsters) | The builders and pilgrims the tower kept: bodies baked into brick, penitents who climbed until nothing human was left. | Mudborn, Mud Bats, Pitch Ooze, flagellants, the Brick-Father |
| **The Faithful** (the Church) | The Church of the Sealed Mouth's guards, priests and zealots, mouths sewn, who kill to keep the silence. | Gate Spearman, sewn-mouth priests, Ashipu |

### 4.7 Tone, voice and content (decided 2026-10-16)

- **Influences:** *Blasphemous* 1 and 2 (devotional grotesque art, penance and guilt, cryptic liturgical lore told in item and NPC fragments, bosses that are beautiful and cruel) and *Fear & Hunger* (grimdark cruelty, dread, desperate ascension, a world where hope is a trap), with SotN for structure.
- **Voice:** item, enemy and lore text is short, solemn and oblique, in the register of a liturgy or a confession, with the occasional plain, cruel sentence. Lore comes in fragments for the player to piece together; nothing is explained outright. No jokes in lore text. Characters speak in plain, elevated English.
- **Motifs:** mouths and tongues (sewn, cut out, multiplied); bricks made of people; gold leaf over rot; votive candles and kiln fire; nails, cords and wax seals; wings nailed down; the unfinished (scaffolds, broken stairs, half-built rooms); the one note of the Confounding; penance and guilt.
- **In scope:** gore, body horror, desecration, cruelty and despair, shown with craft and meaning: ornate, devotional and sad, never shock for its own sake.
- **Limits:** no sexual violence or sexualised gore. The faith is invented: it draws on Abrahamic and Mesopotamian imagery (angels, saints, relics, demons, the Tower) but does not depict or mock real-world religions' sacred figures. The Most High is never shown: the horror is in His servants, His silence, and what people made of His curse. Whether the Confounding was justice or cruelty is left to the player.
- **Applies everywhere:** names, item and enemy descriptions, NPC lines, PixelLab prompts (ART_BIBLE §7.2) and art. The existing item text was rewritten in this voice on 2026-10-16.

## 5. World

### 5.1 Structure

- **One interconnected map.** A map cell is one screen (640×360 px). Act I targets roughly 400 cells. Act II mirrors Act I's layout, flipped vertically and with remixed content, for about 800 cells in total. That gives 200% completion, with a secret bit of percentage beyond it.
- **Vertical spine with horizontal terraces.** The **Grand Stair** spirals up through the core and connects the regions. Each region branches sideways along its terraces.
- **Three kinds of gate:**
  - Movement relics gate physical spaces.
  - **Words** gate sealed doors.
  - **Tongues** gate optional NPC content and inscriptions.
- **Fast travel and saving:** about one **Builders' Lift** (teleport) per region plus one at key junctions, and a **Quiet Room** (save) every 8–12 cells along the critical path.
- **The map (decided 2026-10-15, MAP-001..003, MAP-005).** The map is a relic, the **Builder's Plan**, found later in the game. With it, Tab shows the tower one screen per cell: the cells Elam has explored in their region's colour, walls around each room with gaps where rooms connect, Elam's position blinking, and the share explored (secrets count past 100%). Cells are discovered as Elam walks them, whether or not he has the plan yet.
  - **Surveyor's Maps** add sections. Archivist Nabu sells one per section; owning it shows that section's unvisited rooms dim (where Elam has yet to go), while the rooms he has already explored there stay highlighted. Without a section's map, its unvisited rooms don't show at all.
  - Secret rooms never appear until found, map or not.
- **Secrets behind breakable walls (decided 2026-10-15, WLD-006).** As in SotN, walls, floors and ceilings can hide secret rooms.
  - A **hidden** breakable tile looks exactly like the wall around it and takes 3 hits; a **cracked brick** shows it can be broken and takes 2. Touching breakable tiles crack together and crumble together.
  - Elam's weapons, weapon arts and Relic Arms break them; a crouching strike breaks floors. Enemies can't.
  - A broken wall stays broken (a world flag, kept by saving).
  - The secret room behind lies **outside the room's camera bounds**, so it can't be seen until Elam steps in; then the camera pans to show it. It is also kept **off the map** until found (MAP-009), and finding it counts toward the secret percentage.

### 5.2 Act I regions

Regions are listed in ascending order. Progression order is set in backlog task LVL-000.

| # | Code | Region | Era / architecture | Palette and mood | Mechanic focus | Boss | Key reward |
|---|---|---|---|---|---|---|---|
| 1 | SHN | **Plain of Shinar** (exterior) | Night desert, brick kilns, bitumen pits | Moonlit indigo, ember orange | Intro run; Namtar strips gear | (scripted Namtar) | none |
| 2 | GTE | **Grand Gate** | Neo-Babylonian glazed brick (Ishtar Gate) | Lapis blue, gold, lion reliefs | First save room, first secrets | **Lamassu, Gate-Warden** | Gazelle Anklet (double jump) |
| 3 | FND | **The Foundation** | Sumerian mudbrick, scaffolds, kilns | Terracotta, soot, kiln red | Collapsing floors, heat | **The Brick-Father** | Form of Dust |
| 4 | GRD | **Hanging Gardens** | Terraces, irrigation screws, cedars | Verdigris, jade, gold | Water-screw lifts, vines | **Humbaba** | Lion of Ishtar (form) |
| 5 | ARC | **Hall of Tablets** | Assyrian library of clay tablets | Parchment, lamp gold, ink black | Word-sealed doors; the shop (Nabu) | **The Lexicon** | Word of Opening, Codex Scroll |
| 6 | COL | **Colosseum Tiers** | Bruegel's Roman arches | Sandstone, sunset crimson | Arena challenge waves | **Gilgamesh & Enkidu** (shades) | Plumb Line (grapple) |
| 7 | CIS | **Cisterns of Babylon** | Persian qanats, willows hung with harps | Teal, drowned blue | Swimming, the ferry | **Mušḫuššu** | Gills of Oannes |
| 8 | CAT | **Cathedral of Bells** | Gothic and Byzantine | Stained glass, candle amber, violet | Bell-resonance puzzles | **The Carillon** | Raven Form |
| 9 | UND | **Underworks** (catacombs below the foundation) | Builders' graves | Bone, ash grey, sickly green | Dark rooms with a light radius | **Namtar, Herald of Fate** | Raven's Eye; part of Elam's lost gear |
| 10 | ORR | **Orrery Observatory** | Renaissance clockwork, astrolabes, printing presses | Brass, starlight, navy | Time mechanisms, Silver and Gold Seals | **The Orrery Magus** | Clepsydra (time stop) |
| 11 | FDY | **Iron Foundry** | Industrial girders, cranes, furnaces | Rust, coal, molten orange | Crushers, steam, Bitumen Plate | **Moloch** | Wings of Etana (high jump) |
| 12 | WIR | **Wire Spire** (optional branch) | Victorian telegraph and early electricity | Slate, sodium yellow, electric cyan | Live wires, Morse-code doors | **Wireheart, the Operator** | Rask hands over the **Interpreter's Lens** |
| 13 | SUM | **Gate of the Gods** (summit) | Unfinished scaffolding into a starry dome | Gold, white, deep night | Set-piece ascent | **Sera Valcourt** | The ending fork |

**Optional spaces:**
- **Siduri's Terrace:** a rest hub with side quests.
- **Hall of Echoes:** a sealed room in the Archive containing **The Echo**, a doppelgänger boss.
- **The Seven Gates:** an Act II challenge based on the *Descent of Inanna*. Each gate strips one equipment slot, and the superboss **Ereshkigal** waits at the bottom.

**Critical-path rule:** the Wire Spire must stay *off* the critical path, so that a player can reach Sera without the Lens and get Ending A, as in SotN.

### 5.3 Act II: the Abzu Reflection

- The Act I layout is mirrored vertically and drowned:
  - Drowned Gate
  - Roots of the Gardens
  - Unwritten Archive
  - Sunken Arena
  - Abzu Springs
  - Silent Cathedral (the bells are mute)
  - Ossuary of Kur
  - Unwound Orrery
  - Cold Foundry
  - Dead Wire
  - **Foundation Stone** (the final area)
- **Look:** a cold teal and violet palette shift, water-caustic overlays and rising bubbles. Gravity is normal: you are descending through a reflection.
- **New enemy family:** the **Eleven Spawn of Tiamat** from the *Enūma Eliš*, including Bašmu, Ugallu, Uridimmu, Kusarikku, the Storm Demons and the Seven-Headed Serpent, plus drowned variants of Act I enemies.
- **Remnant bosses:**

  | Remnant | Boss |
  |---|---|
  | Bow | Gugalanna, the Bull of Heaven |
  | Arrow | Tiamat's Reflection |
  | Crown | Anzû, the thief-bird |
  | Eye | Pazuzu |
  | Heart | Lamashtu |
  | Tongue | The Unspoken |

- **Finale:** Ashipu, the Many-Mouthed, then **Nimrod, Hunter-King**, then **Nimrod Confounded**.

## 6. Elam: the player kit

### 6.1 Base moveset

- Walk, and **run** (decided 2026-10-15): double-tap a direction and hold it. Jumping out of a run keeps the run speed until landing. The Lion form is still the fastest mover.
- Back-dash
- Variable-height jump
- Crouch, and dropping through one-way platforms
- Attack with each hand (the item in that hand determines the move)
- Jump attack and crouch attack
- Guard (when holding a shield)
- Interact (press Up)
- Use a Relic Arm (Up + Attack, or a dedicated button)

Starting tuning values are listed below. They live in `PlayerTuning.tres` and will be tuned in playtests.

| Parameter | Start value | Notes |
|---|---|---|
| Elam standing height | ~90 px (the approved sprite is 91 px) | About 25% of screen height (SotN is about 21%); chosen for pixel detail |
| Walk speed | 180 px/s | Crosses a screen in about 3.5 s (SotN: about 2.8 s) |
| Run speed | 290 px/s | Double-tap within 14 frames (`run_tap_frames`), then hold |
| Back-dash | ~100 px over 0.25 s | Cancellable after 0.15 s |
| Jump height | ~144 px (9 tiles, about 1.6 body heights) | Time to apex 0.42 s |
| Jump velocity | 686 px/s | Derived from height and time to apex (2h/t) |
| Gravity | 1633 px/s² | Derived from height and time to apex (2h/t²) |
| Max fall speed | 800 px/s | |
| Coyote time / jump buffer | 6 frames each | |

### 6.2 Relics (movement and keys)

| Relic | Effect | SotN analog |
|---|---|---|
| Gazelle Anklet | Double jump; unlocks the dive kick | Leap Stone |
| Wings of Etana | High jump | Gravity Boots |
| Gills of Oannes | Swim and breathe in deep water | Holy Snorkel |
| Plumb Line | Grapple and rappel from anchor points | (new) |
| Word of Opening | Opens Word-sealed doors | Jewel of Open |
| Bitumen Plate | Walk over burning pitch and spikes | Spike Breaker |
| Silver Seal, Gold Seal | Open the Orrery's inner chamber | Silver/Gold Ring |
| Codex Scroll | Shows enemy names and HP | Faerie Scroll |
| **Builder's Plan** | The map: where Elam has been and where he is (Tab); Surveyor's Maps add the unvisited rooms of their sections. Carried from the start until the level pass places it | (new: in SotN the map is always available, and the Castle Map reveals unexplored rooms) |
| Wanderer's Cube | Lamps drop items twice as often (sold by Nabu for now) | Cube of Zoe |
| **Interpreter's Lens** | Understand any spoken tongue; reveals the Binding Seal | Holy Glasses |
| Tongues (Akkadian, Latin, Liturgical, Mechanist, Telegraphic) | Read the matching inscriptions and NPC speech | (new) |

### 6.3 Transformations

All forms drain **Breath** (MP) over time.

| Form | Core ability | Upgrade relics |
|---|---|---|
| **Form of Dust** | Become drifting sand. Pass through vents and grates; immune to physical damage; slow | Dust Storm (deals damage), Lasting Dust (longer duration) |
| **Raven Form** | Free flight | Raven's Cry (sonar that reveals secrets), Raven's Talon (dive attack), Raven's Eye (see in the dark) |
| **Lion of Ishtar** | Fast run, pounce, and a charge that breaks weak walls | Lion's Roar (stun), Golden Mane (fireball while charging) |

### 6.4 Utterances (spells)

Spells are words of the First Tongue. Each one is entered as a sequence of syllables (directional inputs) followed by Attack, and costs Breath. A **Quick-cast** setting can bind any learned Utterance to a button.

**How commands are read (SPL-001).** Directions are read relative to where Elam faces when Attack is pressed, so ↓↘→ facing right is ↓↙← facing left. Each command has a window in 60 Hz frames for the whole sequence, and the last direction may have been let go up to 8 frames before Attack. Inputs between the steps are ignored. When two commands match, the longer one wins. Without enough Breath the Utterance fizzles, nothing is spent, and the press makes a normal attack.

For the playtest, Išātu is known from the start; in the game it is learned.

The names below are Akkadian-flavored placeholders and will be checked in a lore pass (NAR-001).

| Utterance | Meaning | Input (placeholder) | Effect | SotN analog |
|---|---|---|---|---|
| Išātu | Fire | ↓↘→ + Atk | Fire bolts | Hellfire |
| Ṣūmu | Thirst | ←↙↓↘→ + Atk | Timed lifesteal | Dark Metamorphosis |
| Ḫalāqu | Unmaking | ←↖↑↗→↘↓ + Atk | Drains HP from everything on screen | Soul Steal |
| Utukku | Spirit | ↑↓ + Atk | Homing spirit | Summon Spirit |
| Erbetti Šārī | The Four Winds | →↘↓↙← + Atk | Four orbiting wind spirits | Tetra Spirit |
| Ṣalmu | Image | ↓↓↑ + Atk | Echo blades that copy your attacks | Sword Brothers |
| Abnu | Stone | ↓↓ + Atk | Pillars rise from the floor | (new) |
| Šamaš | The Sun's Gaze | ↑↑ + Atk | Light beam | (new) |
| Mû | Tide | ←→↓ + Atk | Water wave that pushes enemies | (new) |
| Qūlu | Silence | hold ↓ + Atk | Silences casters and cancels the Confounded status | (new) |

### 6.5 Relic Arms (sub-weapons)

Relic Arms cost **Embers**, which drop from votive lamps (the game's breakable candles). Each one also has a super move, called an **item crash** in SotN, triggered by Up + Attack while guarding.

- Thrown with the Relic Arm button, or Up + Attack.
- One is carried at a time, as in SotN: picking up another drops the old one where Elam stands.
- Each has an Ember cost and an on-screen limit (the Sling Stone: 1 Ember, 3 at once; the Clay Tablet: 2 Embers, 2 at once).
- Arcing Relic Arms pass over walls; straight ones stop at them.

| Relic Arm | Behavior | SotN analog |
|---|---|---|
| Sling Stone | Straight, fast shot | Dagger |
| Clay Tablet | High arc | Axe |
| Bitumen Flask | Fire pool on impact | Holy Water |
| Hunter's Arrow | Piercing arrow | (new) |
| Cylinder Seal | Rolls along the floor | (new) |
| Lyre of Ur | Sound wave that stuns | (new) |
| Abzu Water | Rising water pillar | (new) |
| Clepsydra | Stops time | Stopwatch |

### 6.6 Familiars

Familiars level from 1 to 99 through use.

| Familiar | Role | SotN analog |
|---|---|---|
| Dove | Heals | Faerie |
| Clay Homunculus | Blocks attacks and guards | (new) |
| Tablet Sprite | Finds secrets and translates inscriptions | (new) |
| Lamassu Whelp | Charge attack; presses switches | Demon |
| Utukku Wisp | Ranged magic | Ghost |

### 6.7 Stats, equipment and status effects

**Stats:**
- **STR:** physical attack.
- **CON:** defense and HP growth.
- **INT:** spell power, Breath growth and Breath regeneration.
- **LCK:** drop rates and critical hits.
- **Derived:** HP, Breath (MP), Embers, attack per hand, and defense.
- Elam can reach level 99.
- Enemies give less XP once Elam out-levels them.

**Equipment slots:** Right Hand, Left Hand, Head, Body, Mantle, and two Seals. Seals are accessories: cylinder seals, rings and amulets.

**Visible equipment (core rule, decided 2026-10-15).** Everything Elam equips or carries is visible on his sprite in every animation. This goes beyond SotN, where only the cape color and the swung weapon show.

| Slot | How it shows |
|---|---|
| Right Hand | The weapon is always held in the hand, including while idling, walking, jumping and crouching. It follows the hand's position and angle in every frame. A swing's smear takes the weapon's color. |
| Left Hand | A shield or second weapon on the far arm. It is drawn behind the body, so its rim shows past his silhouette, and comes forward when guarding. |
| Head | A helm, circlet or hood sprite placed on the head. |
| Body | Recolors the coat, plates and trim. Heavier armor adds rigid pieces such as pauldrons, a gorget or greaves. |
| Mantle | The cape is always worn, as in SotN. The mantle sets its outer color, lining and trim. |
| Seals (×2) | Each seal says where it is worn: a ring on the hand, an amulet at the neck, or a cylinder seal on the belt. |
| Relics | Each relic is a small worn trinket at a fixed spot. Examples: the Gazelle Anklet at the ankle, the Interpreter's Lens as a monocle, the Tongues as tablets on the belt, the Plumb Line coiled at the hip. Relics toggled off are hidden. |

**How it works.**
- Elam's body animations carry per-frame attach points: the right hand (with angle), head, neck, chest, belt and ankles. The left hand is derived from the right.
- Rigid items are separate sprites placed on those points.
- Soft items (body armor and mantles) recolor the body through a material palette.
- This keeps every new item cheap: one small sprite, or a palette, instead of a redraw of Elam's whole animation set.
- The attach points come from a key-green guide rod painted into his hand before animating (ART_BIBLE §6.3).

**Weapon classes:**
- Short swords, swords and great swords
- Sickle-swords (khopesh and sappara)
- Maces, spears and knuckles
- Scythes, two-handed (the Scythe of Ninurta)
- Great swords, two-handed (the Lion-Hilt Greatsword)
- Throwing weapons
- Shields, including a shield-rod analog called the Scepter of Shamash
- Bows (late game)
- Food and potions, which can be used directly from a hand slot

**Two-handed weapons** (great swords, scythes) take both hands. Equipping one returns the left-hand item to the bag, and equipping anything in the left hand takes the two-handed weapon off, as in SotN.

**Each weapon type has its own animation set**, because each is held differently. Every move changes with the type: idle, walk, jump, fall, crouch, crouching attack, back-dash, hurt and attack.

| Type | Hold and attack |
|---|---|
| Sword (one-handed) | Lowered forward; quick slash |
| Sickle-sword (one-handed) | Held level, ready to hook; wide hooking slash |
| Mace (one-handed) | Hanging at his side; raise and smash |
| Great sword (two-handed) | Raised two-handed guard; heavy overhead cleave |
| Scythe (two-handed) | Upright reaper hold; slow two-handed reap |

New weapon types (spears, knuckles, bows…) each get their own set. A single weapon can also replace individual moves of its type.

**Weapon arts (decided 2026-10-15).** Every weapon type has a special attack entered as ←→ + Attack (Back, Forward) that costs Breath, so special attacks use resources like SotN's sword techniques:

| Type | Art | Effect | Breath |
|---|---|---|---|
| Sword | Swift Thrust | Short lunge | 4 |
| Sickle-sword | Hooking Lunge | Long lunge | 6 |
| Mace | Earthshaker | Two shockwaves along the floor, one each way | 8 |
| Great sword | Lion's Cleave | Wide, heavy forward cleave | 10 |
| Scythe | Reaping Whirl | A full spin that hits on both sides, twice | 10 |

**Equipment can grant abilities and passive effects (decided 2026-10-15).** An item can grant a movement ability for as long as it is worn (the Feather Mantle grants the double jump). It can also carry passives that add up across everything worn: Breath regeneration, HP regeneration, lifesteal, a chance for Relic Arms to cost no Embers, and run speed. The equip screen lists them. First test items: Feather Mantle (double jump), Courier's Mantle (+25% run speed), Lamp of Ea (+2 Breath/s), Fang of Lamashtu (15% lifesteal) and Ember Censer (half of throws are free).

**Walls block attacks.** A hit only lands if nothing solid stands between the attacker and the target. This applies to Elam's weapons and to enemy spears alike. A swing that meets a wall strikes sparks off it. One-way platforms don't block.

**Content targets:** about 60 weapons, 30 head and body pieces, 12 mantles, 30 seals and 40 consumables. The mantle lining can be dyed.

**Damage types:**
- Physical: Slash, Strike, Pierce.
- Elemental: Fire, Water, Earth (clay), Wind, Light (Shamaš), Dark.

**Status effects:**

| Status | Effect |
|---|---|
| Poison | Damage over time |
| Burn | Damage over time from burning bitumen |
| Curse | Can't use Relic Arms |
| **Confounded** (signature) | Utterances fail, and HUD and menu text scrambles into glyphs |
| **Fired** | Turned into brick (petrify). Mash buttons to break free |
| Stun | Can't act for a moment |
| Slow | Reduced speed |

### 6.8 Economy and loot

- **Currency:** shekels of silver.
- **Ways to spend shekels:** Nabu's shop, Siduri's tavern, the Surveyor's Maps for each region, and dyes.
  - **Nabu's shop (decided 2026-10-16, NPC-004).** Talk to Archivist Nabu (Up) to buy gear, relics and Surveyor's Maps. Gear can be bought again; relics and maps once. A relic works the moment it is bought. The shop shows the price, Elam's shekels, and what each entry gives, including how much of a map's section he has already explored. Selling and stock that grows with progress come later (NPC-008).
  - Elam starts with 600 shekels for the playtest.
- **Drops:** each enemy has a common and a rare drop, both modified by LCK, plus a hidden pity counter so rare drops don't require endless grinding. Votive lamps drop Embers, shekels, Relic Arms or occasionally items.
  - An enemy rolls its loot table once when it dies, and the drop pops out where it fell (INV-013).
  - Gear and Relic Arms stay on the floor until Elam leaves the room; Embers and shekels blink out after 10 s.
  - Some gear is found only as drops. Starting rates for tuning: common gear about 1 kill in 10, rare about 1 in 25.

  | Enemy | Common gear | Rare gear |
  |---|---|---|
  | Mudborn | Potsherd Seal (DEF +1, CON +2) | Riverclay Mail (DEF +6, CON +1) |
  | Gate Spearman | Gate Guard's Helm (DEF +3) | Watchman's Mantle (DEF +1, HP regenerates) |
  | Humbaba Mask | — | Seal of Humbaba (LCK +4) |
- **Max-ups:** Clay Vessel (+HP), Reed Pipe (+Breath), Votive Lamp (+Embers).
- **Healing:** food and drink (date wine, honey cakes and so on) and potions. Quiet Rooms fully heal.

## 7. Enemies and bosses

The full roster with IDs is in [BACKLOG.md](BACKLOG.md#enm-enemy-roster). Act I has about 60 enemies, and palette-swapped variants push the Codex toward 100 or more entries. Every enemy belongs to one of the four families in §4.6 (the Choir, the Old Ones, the Damned, the Faithful).

**Behavior archetypes:**
- Walker, charger and jumper
- Sine-wave floater (the Medusa-head role, played here by **Humbaba Masks**)
- Swooper and swarm
- Turret, thrower and caster
- Guard/counter and burrower/ambusher
- Ceiling crawler and phaser
- Tether/binder
- Elite duelist

**Every attack has a readable answer.** An attack winds up with a visible telegraph, its hitbox matches the painted weapon, and the player has a counter: crouch, jump, back-dash, cut the projectile, or stagger it during the wind-up. Any reach beyond the art is drawn as an effect, such as a spear-light streak. The **Gate Spearman** sets the pattern:

| Attack | When | Answer |
|---|---|---|
| Stab | close | jump it or back-dash out; a crouch does not dodge it |
| Floor sweep | close, alternating with the stab | jump it |
| Anti-air thrust (short wind-up) | the player jumps in close or over it | don't jump at it |
| Fireball | 150 px or more away | crouch, jump, or cut it with a weapon |
| Leap-plunge | 100–220 px away | step out from under the landing |

**Boss rules:**
- The arena locks when the fight begins.
- A title card shows the boss's name, SotN style.
- Each boss has two or three phases, and its attack patterns are readable and telegraphed.
- No boss can be cheesed into a softlock.
- Each boss drops a guaranteed key item plus a stat or HP reward.

**Large bosses** are built from parts (Skeleton2D or a Node2D hierarchy driven by AnimationPlayer) instead of full-frame giant sprites. This makes them both cheaper to generate and smoother to animate.

## 8. NPCs, dialogue and confounded speech

- Every line of dialogue and every inscription carries a **tongue tag**: First, Akkadian, Latin, Liturgical, Mechanist or Telegraphic.
- Without the matching Tongue relic (or the Lens, for spoken lines), the text renders as that tongue's scrambled glyph script using a custom `RichTextEffect`. Once Elam understands the tongue, the text resolves letter by letter.
- Inscriptions on walls hint at secrets, so learning Tongues pays off in exploration as well as story.
- Sera's summit dialogue is the payoff: the player hears a pleading voice they cannot understand until they have the Lens.

## 9. UI and UX

- **HUD:** top-left ornate frame showing the HP and Breath bars, Embers count and Relic Arm icon. Damage numbers pop off enemies. Pickups appear as a toast stack. Bosses get an HP bar. An optional minimap sits top-right.
- **Pause menu tabs:** Status, Equip, Items, Utterances (each shown with its glyph syllables), Relics (toggleable), Familiars, Codex, Map and System.
- **Front end:** title screen, three save slots, game-over screen and credits.
- **Settings:**

  | Category | Options |
  |---|---|
  | Video | Window or fullscreen, integer scale, vsync, optional CRT filter, brightness |
  | Audio | Volume per bus |
  | Controls | Full rebinding for keyboard and gamepad, with controller glyphs that switch automatically |
  | Accessibility | Quick-cast, hold or toggle for forms, flash reduction, screen-shake slider, text speed, high-contrast HUD, screen-reader labels in menus (AccessKit) |
  | Language | Interface language |

## 10. Art direction (summary)

The look is **grim baroque**: SotN's readable elegance with devotional horror in the spirit of *Blasphemous* (ornate religious architecture and iconography, gore and body horror drawn with care, deep shadows lit by candles and kiln fire), at 640×360 with 16 px tiles and an approximately 90 px hero. Depth comes from 4–7 parallax layers per region, atmospheric tinting by depth, normal-mapped sprites under 2D lights with banded (quantized) lighting, and HDR glow for magic. Each region has its own era palette built on a shared master ramp of bitumen black, lapis, gold, terracotta, bone and crimson. The full specification is in [ART_BIBLE.md](ART_BIBLE.md).

## 11. Audio direction

- **Music:** dark liturgical baroque with Mesopotamian lament: lyre, oud, frame drums, ney flute, and choir. The Choir's one sustained note of the Confounding is a recurring motif. Each region has its own theme, and an `AudioStreamInteractive` switches between exploration, combat and boss sections.
- **The Murmur:** the tower constantly whispers in many languages. The whispering swells near secrets and goes silent in Quiet Rooms, which is how the save rooms feel safe.
- **SFX:** punchy and crunchy, in the spirit of 32-bit-era games.
- **Voice:** voiced key story lines only ⟨open; stretch goal⟩.
- **Sourcing** ⟨open⟩: commissioned composer, licensed music or generated music. PixelLab does not make audio.

## 12. Technical summary

- Godot 4.6.1, GDScript only.
- 640×360 viewport, `viewport` stretch mode with integer scaling, 60 Hz physics with physics interpolation.
- Forward+ renderer on D3D12.
- Saves are versioned JSON.
- All user-facing text goes through `tr()` from day one.

Conventions and commands are in [../CLAUDE.md](../CLAUDE.md).

## 13. Scope and milestones

| Milestone | Goal | Exit criteria (summary) |
|---|---|---|
| **M0 Foundation** | The project can be built and tested | Project configured, folder structure and autoloads in place, test runner and screenshot capture working, greybox tiles, Elam style anchor approved |
| **M1 Vertical Slice: "The Gate"** | 15–20 minutes of representative play | Intro run, Namtar scene, Plain of Shinar plus Grand Gate (about 20 rooms), full base moveset, 5 enemies, Lamassu boss, double jump, save room, map, HUD, lighting and parallax, exported build runs at 60 fps |
| **M2 Core Systems** | Every system exists at least once | Stats and leveling, inventory and equipment, Utterances, Relic Arms, one form, one familiar, shop, Codex, lifts, settings, save slots, dialogue with confounded text |
| **M3 Act I** | Act I complete | All 13 regions and bosses, Endings A and normal path into Act II, prologue |
| **M4 Act II** | Game complete | Inverted tower, Remnant bosses, Ashipu, Nimrod, Endings B–D |
| **M5 Release** | Shippable | Audio final, localization, accessibility, performance pass, Steam build |
| **POST** | Extras | Sera mode, boss rush, NG+ variants |

**Scope risk:** SotN-scale content is very large. If time runs short, the order of cuts is:
1. Seven Gates and the Hall of Echoes.
2. Familiars 4–5.
3. Tongues beyond the Lens.
4. Act II new regions (keep the mirrored remix only).

Act I must never be cut below the quality of the slice.

## 14. Open questions

- Final title and subtitle.
- Sub-weapons: owned arsenal or SotN-style pickup-swap?
- Music sourcing and voice-over budget.
- Should Sera mode ship at launch?
- Map size: confirm the 400-cell Act I after the M1 slice reveals the real cost per room.
- The alternate world's framing (§4.2): rework the v0.1 1893 frame, its real-world places and the Danish philologist (NAR-001); decide how much late technology (iron, wire) the world keeps.
- Final names of the faith (working: the Church of the Sealed Mouth) and of the angels (working: the Choir).
- *Fear & Hunger*-style mechanics (hunger, sanity, lasting injuries) are not planned: the inspiration is tone only, unless the user asks for them.
