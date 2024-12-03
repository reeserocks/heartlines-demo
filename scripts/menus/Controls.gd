### Controls.gd

extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_quit_button_pressed():
	GameManager.disable_input = false
	queue_free()

func _on_quit_button_real_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
