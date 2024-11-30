extends Node

@export var animation_player : AnimationPlayer
@export var autoplay : bool = false
@export var next_scene : PackedScene
@export var camera : Camera2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _input(event):
	if event.is_action_pressed("ui_accept") and not animation_player.is_playing():
		animation_player.play()

func pause():
	if autoplay == false:
		animation_player.pause()

func change_scene():
	get_tree().change_scene_to_packed(next_scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
