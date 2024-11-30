### MainMenu.gd

extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cutscenes/Start.tscn")

func _on_controls_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Controls.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
