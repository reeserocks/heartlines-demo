### DescPopup.gd

extends CanvasLayer

var message: String = ""

func message_set(new_value):
	$Dialog/Message.text = new_value

func _ready():
	self.visible = false

func open():
	self.visible = true

func close():
	self.visible = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		close()
