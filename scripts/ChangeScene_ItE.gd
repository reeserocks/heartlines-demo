### ChangeScene_ItE.gd

extends Area2D

var player_near = false
var player_body = null

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("active"):
		player_near = true
		player_body = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_body:
		player_near = false
		player_body = null

func _process(delta: float):
	if player_body and player_near and Input.is_action_just_pressed("ui_interact"):
		get_tree().change_scene_to_file("res://scenes/LIMERICK_Exterior.tscn")
