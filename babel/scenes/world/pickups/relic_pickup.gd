class_name RelicPickup
extends Area2D
## A relic floating over the floor (REL-003, placeholder look): touching it grants
## [member ability] and shows its name and use. Relics already owned remove themselves.

@export var ability: StringName = &"double_jump"
@export var title: String = "Gazelle Anklet"
@export var detail: String = "Double jump: press jump in midair"

var _time: float = 0.0


func _ready() -> void:
	if Game.has_ability(ability):
		queue_free()
		return
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	Game.grant_ability(ability)
	Events.item_acquired.emit(ability, 1)
	Events.notice.emit(title, detail)
	queue_free()


func _draw() -> void:
	var bob: float = roundf(sin(_time * 3.0) * 2.0)
	var glow: float = 0.5 + 0.5 * sin(_time * 6.0)
	var centre: Vector2 = Vector2(0, -18 + bob)
	draw_rect(Rect2(centre + Vector2(-6, -6), Vector2(12, 12)), Color("fbe69b", 0.15 + 0.2 * glow))
	for i: int in 5:
		draw_rect(Rect2(centre + Vector2(-i, -4 + i), Vector2(i * 2 + 1, 1)), Color("d4b06e"))
		draw_rect(Rect2(centre + Vector2(-i, 4 - i), Vector2(i * 2 + 1, 1)), Color("c59c5c"))
	draw_rect(Rect2(centre + Vector2(-1, -1), Vector2(2, 2)), Color("fbe69b"))
