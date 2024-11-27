### Tiger.gd

extends StaticBody2D

var player_near = false
var player_body = null
var wires_collected = false
var gears_collected = false
var electrical_collected = false

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
		if wires_collected != true and gears_collected != true and electrical_collected != true:
			if current_message_index < messages.size():
				dialog_popup.message_set(messages[current_message_index])
				dialog_popup.open()
				current_message_index += 1
			else:
				dialog_popup.close()
				current_message_index = 0
		else: 
			dialog_popup.message_set("The TIGER wakes up.")
			dialog_popup.open()
			_delete_all_after_delay()

func _delete_all_after_delay():
	var delete_timer = Timer.new()
	add_child(delete_timer)
	delete_timer.wait_time = 1.0
	delete_timer.one_shot = true 
	delete_timer.autostart = false
	delete_timer.start()
	
	await delete_timer.timeout
	queue_free()
