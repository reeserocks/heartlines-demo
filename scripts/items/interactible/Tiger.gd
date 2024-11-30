### Tiger.gd

extends StaticBody2D

var player_near = false
var player_body = null
var wires_collected = false
var gears_collected = false
var electrical_collected = false

@export var messages : Array = []
@export var jay_messages : Array = []
@export var tess_charlie_messages : Array = []
@onready var dialog_popup = $LongerDescPopup
@onready var animation_player = $AnimationPlayer

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
		if wires_collected != true or gears_collected != true or electrical_collected != true:
			if current_message_index < messages.size():
				dialog_popup.message_set(messages[current_message_index])
				dialog_popup.open()
				current_message_index += 1
			else:
				dialog_popup.close()
				current_message_index = 0
		else:
			if player_body.name == "Jay": 
				if current_message_index < jay_messages.size():
					dialog_popup.message_set(jay_messages[current_message_index])
					dialog_popup.open()
					current_message_index += 1
				else:
					dialog_popup.close()
					current_message_index = 0
					animation_player.play("fade_out")
			elif player_body.name in ["Charlie", "Tess"]:
				if current_message_index < tess_charlie_messages.size():
					dialog_popup.message_set(tess_charlie_messages[current_message_index])
					dialog_popup.open()
					current_message_index += 1
				else:
					dialog_popup.close()
					current_message_index = 0


func _on_animation_player_animation_finished(anim_name: StringName):
	if anim_name == "fade_out":
		get_tree().change_scene_to_file("res://scenes/cutscenes/End.tscn")
