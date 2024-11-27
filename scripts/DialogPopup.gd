### DialogPopup.gd

extends CanvasLayer

#node refs
@onready var animation_player = $"../../AnimationPlayer"
@onready var character_face = $CharacterFace

var npc_name : String = ""
var message: String = ""
var npc : Node = null

var character_faces = {
	"Tess": preload("res://assets/MyAssets/Faces/tess_face.png"),
	"Jay": preload("res://assets/MyAssets/Faces/jay_face.jpg"),
	"Charlie": preload("res://assets/MyAssets/Faces/charlie_face.PNG")
}

func npc_name_set(new_value: String):
	npc_name = new_value
	$Dialog/NPC.text = new_value

func message_set(new_value):
	npc_name = new_value
	$Dialog/Message.text = new_value

func face_set(character_name: String):
	if character_faces.has(character_name):
		$CharacterFace.texture = character_faces[character_name]
	else:
		$CharacterFace.texture = null

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
