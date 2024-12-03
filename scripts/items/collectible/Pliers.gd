### Pliers.gd

extends Area2D

var player_near = false
var player_body = null

@export var item: InvItem
@onready var locked_door = $"../LockedDoor"

func _ready():
	add_to_group("collectible")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("active"):
		player_near = true
		player_body = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_body:
		player_near = false
		player_body = null

func _process(delta: float):
	if player_body and player_near and Input.is_action_just_pressed("ui_interact") and !locked_door.pliers_collected:
		player_body.collect(item)
		locked_door.pliers_collected = true
		queue_free()
