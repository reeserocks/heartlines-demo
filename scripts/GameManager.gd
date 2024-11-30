### GameManager.gd

extends Node

var cutscene_playing = false
var disable_input = false
var cutscene_triggered = false

# Pause the game and trigger the cutscene
func trigger_cutscene():
	if !cutscene_playing:
		cutscene_playing = true
		disable_input = true
		var cutscene = preload("res://scenes/cutscenes/AberrationEncounter.tscn").instantiate()
		get_tree().current_scene.add_child(cutscene)
		cutscene.connect("cutscene_finished", Callable(self, "_on_cutscene_finished"))

func _on_cutscene_finished():
	cutscene_playing = false
	disable_input = false
	cutscene_triggered = true
	get_tree().current_scene.get_node("AberrationEncounter").queue_free()

func trigger_controls_menu():
	disable_input = true
	var menu = preload("res://scenes/menus/Controls.tscn").instantiate()
	get_tree().current_scene.add_child(menu)
