### LongerDescPopup.gd

extends CanvasLayer

var message: String = ""
@onready var animation_player = $"../AnimationPlayer"

func message_set(new_value: String) -> void:
	$Dialog/Message.text = new_value

func _ready():
	self.visible = false

func open():
	self.visible = true
	animation_player.play("typewriter")

func close():
	self.visible = false
