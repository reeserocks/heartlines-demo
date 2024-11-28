### DialogPopup.gd

extends CanvasLayer

#node refs
@onready var animation_player = $"../../AnimationPlayer"

var npc_name : String = ""
var message: String = ""
var npc : Node = null

func npc_name_set(new_value: String):
	npc_name = new_value
	$Dialog/NPC.text = new_value

func message_set(new_value):
	npc_name = new_value
	$Dialog/Message.text = new_value

func _ready():
	self.visible = false
	set_process_input(false)

func open():
	self.visible = true
	animation_player.play("typewriter")

func close():
	self.visible = false
	npc = null

func _on_animation_player_animation_finished(anim_name: StringName):
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		close()
