### CorrodedDoor.gd

extends StaticBody2D

var player_near = false
var player_body = null
var key_collected = false

@export var messages : Array = []
@export var tess_messages : Array = []
@onready var dialog_popup = $LongerDescPopup
@onready var lights_off = $"../Room2_Lights"

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
		if key_collected != true:
			if player_body.name == "Tess":
				if current_message_index < tess_messages.size():
					dialog_popup.message_set(tess_messages[current_message_index])
					dialog_popup.open()
					current_message_index += 1
				else:
					dialog_popup.close()
					current_message_index = 0
					$CorrodedDoor.modulate.a = 0.3
					$CollisionShape2D.disabled = true
					lights_off.visible = false
					_crawl_through_door()
			elif player_body.name in ["Charlie", "Jay"]:
				if current_message_index < messages.size():
					dialog_popup.message_set(messages[current_message_index])
					dialog_popup.open()
					current_message_index += 1
				else:
					dialog_popup.close()
					current_message_index = 0
		else:
			dialog_popup.message_set("You unlock the door for the others.")
			dialog_popup.open()
			_delete_all_after_delay()

func _crawl_through_door():
	var countdown = Timer.new()
	add_child(countdown)
	countdown.wait_time = 3.0
	countdown.one_shot = true 
	countdown.autostart = false
	countdown.start()
	
	await countdown.timeout
	$CorrodedDoor.modulate.a = 1
	$CollisionShape2D.disabled = false

func _delete_all_after_delay():
	var delete_timer = Timer.new()
	add_child(delete_timer)
	delete_timer.wait_time = 1.0
	delete_timer.one_shot = true 
	delete_timer.autostart = false
	delete_timer.start()
	
	await delete_timer.timeout
	queue_free()
