### BaseInteractibleObj.gd

extends StaticBody2D

var player_near = false
var player_body = null

@export var messages : Array = []
@onready var dialog_popup = $LongerDescPopup

var current_message_index : int = 0

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("active"):
		player_near = true
		player_body = body

func _on_area_2d_body_exited(body: Node2D):
	if body == player_body:
		player_near = false
		player_body = null

func _process(delta: float):
	if player_body and player_near and Input.is_action_just_pressed("ui_interact"):
		if current_message_index < messages.size():
			dialog_popup.message_set(messages[current_message_index])
			dialog_popup.open()
			current_message_index += 1
		else:
			dialog_popup.close()
			current_message_index = 0
