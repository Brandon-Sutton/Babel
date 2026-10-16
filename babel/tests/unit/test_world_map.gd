extends GutTest
## MAP-001..003, MAP-009, REL-008: the world index built from the sandbox, discovery by
## position, % explored, the save round trip, the Builder's Plan, and what the map draws
## for each cell and edge.

const SANDBOX: String = "res://scenes/world/rooms/test/sandbox_room.tscn"
const TEST_SLOT: int = 6


func before_each() -> void:
	Game.reset()
	WorldMap.reset()


func after_all() -> void:
	SaveSystem.delete_save(TEST_SLOT)
	Game.reset()
	WorldMap.reset()


## A stand-in for the sandbox room, so WorldMap finds its place in the index.
func _room() -> Node2D:
	var room: Node2D = Node2D.new()
	room.scene_file_path = SANDBOX
	add_child_autofree(room)
	room.add_to_group(&"room")
	return room


func test_index_lists_the_sandbox_and_its_secrets() -> void:
	assert_eq(WorldMap.cells.size(), 5, "3 room cells and 2 secret cells")
	for cell: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]:
		assert_eq(WorldMap.entry_at(cell).get("id"), "sandbox_room")
		assert_false(WorldMap.entry_at(cell).get("secret"))
	assert_eq(WorldMap.entry_at(Vector2i(3, 0)).get("id"), "sandbox_room/secret/EastRoom")
	assert_true(WorldMap.entry_at(Vector2i(3, 0)).get("secret"))
	assert_eq(WorldMap.entry_at(Vector2i(2, 1)).get("id"), "sandbox_room/secret/Cellar")
	assert_true(WorldMap.has_opening(Vector2i(2, 0), Vector2i(3, 0)), "the hidden wall")
	assert_true(WorldMap.has_opening(Vector2i(2, 1), Vector2i(2, 0)), "the hidden floor, either order")
	assert_false(WorldMap.has_opening(Vector2i(1, 0), Vector2i(1, 1)), "no passage there")


func test_standing_in_a_cell_discovers_it() -> void:
	var room: Node2D = _room()
	WorldMap.locate(room, Vector2(1000, 320))
	assert_eq(WorldMap.player_cell, Vector2i(1, 0), "feet on the floor of the second screen")
	assert_true(WorldMap.is_discovered(Vector2i(1, 0)))
	assert_almost_eq(WorldMap.player_offset.x, 1000.0 / 640.0 - 1.0, 0.001)
	assert_false(WorldMap.is_discovered(Vector2i(0, 0)))
	WorldMap.locate(room, Vector2(1600, 480))
	assert_eq(WorldMap.player_cell, Vector2i(2, 1), "the cellar floor")


func test_explored_percent_counts_secrets_as_a_bonus() -> void:
	assert_eq(WorldMap.explored_percent(), 0.0)
	WorldMap.discover_cell(Vector2i(0, 0))
	assert_almost_eq(WorldMap.explored_percent(), 100.0 / 3.0, 0.01)
	WorldMap.discover_cell(Vector2i(1, 0))
	WorldMap.discover_cell(Vector2i(2, 0))
	assert_almost_eq(WorldMap.explored_percent(), 100.0, 0.01)
	WorldMap.discover_cell(Vector2i(3, 0))
	assert_almost_eq(WorldMap.explored_percent(), 400.0 / 3.0, 0.01, "a secret goes past 100%")
	WorldMap.discover_cell(Vector2i(9, 9))
	assert_almost_eq(WorldMap.explored_percent(), 400.0 / 3.0, 0.01, "cells outside the index don't count")


func test_discovery_is_saved() -> void:
	WorldMap.discover_cell(Vector2i(0, 0))
	WorldMap.discover_cell(Vector2i(3, 0))
	assert_eq(SaveSystem.save_game(TEST_SLOT, SANDBOX, Vector2.ZERO), OK)
	WorldMap.reset()
	assert_false(WorldMap.is_discovered(Vector2i(0, 0)))
	SaveSystem.apply_save(SaveSystem.load_game(TEST_SLOT))
	assert_true(WorldMap.is_discovered(Vector2i(0, 0)))
	assert_true(WorldMap.is_discovered(Vector2i(3, 0)))
	assert_eq(WorldMap.discovered.size(), 2)


func test_the_builders_plan_grants_the_map() -> void:
	var plan: RelicData = Game.item(&"builders_plan") as RelicData
	assert_not_null(plan)
	assert_eq(plan.ability, &"map")
	assert_not_null(plan.worn, "worn on the belt")
	assert_true(Game.has_ability(&"map"), "carried from the start for now")


func test_map_cell_states() -> void:
	WorldMap.discover_cell(Vector2i(0, 0))
	assert_eq(MapScreen.cell_state(Vector2i(0, 0)), &"explored")
	assert_eq(MapScreen.cell_state(Vector2i(1, 0)), &"unknown", "not visited, on no map he owns")
	Game.inventory.add(&"surveyor_map_west")
	assert_eq(MapScreen.cell_state(Vector2i(1, 0)), &"unexplored", "shown dim by the Surveyor's Map")
	assert_eq(MapScreen.cell_state(Vector2i(3, 0)), &"hidden", "secret until found")
	assert_eq(MapScreen.cell_state(Vector2i(2, 1)), &"hidden")
	assert_eq(MapScreen.cell_state(Vector2i(7, 7)), &"none")
	WorldMap.discover_cell(Vector2i(3, 0))
	assert_eq(MapScreen.cell_state(Vector2i(3, 0)), &"explored")


func test_map_walls_and_doors() -> void:
	Game.inventory.add(&"surveyor_map_west")
	Game.inventory.add(&"surveyor_map_east")
	assert_eq(MapScreen.edge_kind(Vector2i(0, 0), Vector2i.RIGHT), &"none", "inside one room")
	assert_eq(MapScreen.edge_kind(Vector2i(0, 0), Vector2i.LEFT), &"wall", "the world's edge")
	assert_eq(MapScreen.edge_kind(Vector2i(2, 0), Vector2i.RIGHT), &"wall", "the secret room isn't shown yet")
	WorldMap.discover_cell(Vector2i(3, 0))
	assert_eq(MapScreen.edge_kind(Vector2i(2, 0), Vector2i.RIGHT), &"door", "found: the passage shows")
	assert_eq(MapScreen.edge_kind(Vector2i(3, 0), Vector2i.LEFT), &"door")
	assert_eq(MapScreen.edge_kind(Vector2i(2, 0), Vector2i.DOWN), &"wall", "the cellar is still hidden")
