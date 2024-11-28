### Chair.gd

extends Area2D

var player_near = false
var player_body = null
var door_interact = false

@export var messages : Array = []
@export var tess_messages : Array = []
@onready var dialog_popup = $LongerDescPopup
@onready var shelf_right = $"../ShelfRight/CollisionPolygon2D" 
@onready var shelf_right_sprite = $"../ShelfRight/ShelfRight"

var current_message_index : int = 0

func _on_body_entered(body: Node2D):
	if body.is_in_group("active"):
		player_near = true
		player_body = body

func _on_body_exited(body: Node2D):
	if body == player_body:
		player_near = false
		player_body = null

func _process(delta: float):
	if player_body and player_near and Input.is_action_just_pressed("ui_interact"):
		if player_body.name == "Tess":
			if current_message_index < tess_messages.size():
				dialog_popup.message_set(tess_messages[current_message_index])
				dialog_popup.open()
				current_message_index += 1
			else:
				dialog_popup.close()
				current_message_index = 0
				shelf_right.disabled = true
				shelf_right_sprite.modulate.a = 0.5
		elif player_body.name in ["Charlie", "Jay"]:
			if current_message_index < messages.size():
				dialog_popup.message_set(messages[current_message_index])
				dialog_popup.open()
				current_message_index += 1
			else:
				dialog_popup.close()
				current_message_index = 0
