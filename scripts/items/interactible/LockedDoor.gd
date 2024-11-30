### LockedDoor.gd

extends StaticBody2D

var player_near = false
var player_body = null
var pliers_collected = false

var health = 50

@export var messages : Array = []
@onready var dialog_popup = $LongerDescPopup
@onready var lights_off = $"../Room1_Lights"

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
		if pliers_collected != true:
			if current_message_index < messages.size():
				dialog_popup.message_set(messages[current_message_index])
				dialog_popup.open()
				current_message_index += 1
			else:
				dialog_popup.close()
				current_message_index = 0
		else: 
			dialog_popup.message_set("You used the pliers on the padlock.")
			dialog_popup.open()
			lights_off.visible = false
			_delete_all_after_delay()

func _on_hitbox_area_entered(area: Area2D):
	var damage
	if area.has_method("bullet_deal_damage"):
		damage = 50
		take_damage(damage)

func take_damage(damage):
	health = health - damage
	if health <= 0:
		dialog_popup.message_set("You shot the lock off of the door!")
		dialog_popup.open()
		lights_off.visible = false
		_delete_all_after_delay()

func _delete_all_after_delay():
	var delete_timer = Timer.new()
	add_child(delete_timer)
	delete_timer.wait_time = 1.4
	delete_timer.one_shot = true 
	delete_timer.autostart = false
	delete_timer.start()
	
	await delete_timer.timeout
	queue_free()
