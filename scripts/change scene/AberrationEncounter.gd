### AberrationEncounter.gd

extends Node2D

signal cutscene_finished

@export var animation_player : AnimationPlayer
@export var autoplay : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event):
	if event.is_action_pressed("ui_accept") and not animation_player.is_playing():
		animation_player.play()

func pause():
	if autoplay == false:
		animation_player.pause()

func cutscene_end():
	emit_signal("cutscene_finished")
