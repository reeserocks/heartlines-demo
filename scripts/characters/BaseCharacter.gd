### BaseCharacter.gd
extends CharacterBody2D

class_name NPC

# NODE REFERENCES
@onready var animation_sprite = $AnimatedSprite2D

# VARIABLE EXPORT
@export var character_name: String = "base"
@export var inv: Inv

# UPDATED THROUGHOUT GAME STATE
var new_direction = Vector2(0,1) #only move one space
var animation

# DIALOGUE
var dialogues : Dictionary = {}
var current_dialogue: String = ""

# APPLY MOVEMENT
func move_and_animate(direction: Vector2, movement: float):
	if direction != Vector2.ZERO:
		move_and_collide(direction * movement)
		player_animations(direction)
	else:
		player_animations(Vector2.ZERO)

# ANIMATION DIRECTION
func returned_direction(direction: Vector2):
	var normalized_direction = direction.normalized()
	var default_return = "side"
	
	if normalized_direction.y > 0:
		return "down"
	elif normalized_direction.y < 0:
		return "up"
	elif normalized_direction.x > 0:
		# RIGHT
		$AnimatedSprite2D.flip_h = false
		return "side"
	elif normalized_direction.x < 0:
		# LEFT
		$AnimatedSprite2D.flip_h = true
		return "side"
		
	# DEFAULT VALUE IS EMPTY
	return default_return

# PLAY ANIMATIONS
func player_animations(direction: Vector2):
	if direction != Vector2.ZERO:
		new_direction = direction
		animation = "walk_" + character_name + "_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	else:
		animation = "idle_" + character_name + "_" + returned_direction(new_direction)
		animation_sprite.play(animation)

func use_ability():
	# base implementation does nothing; to be overridden by child classes
	pass

func collect(item):
	inv.insert(item)

func set_dialogue(active_character):
	current_dialogue = dialogues[active_character][randi() % dialogues[active_character].size()]

func get_current_dialogue() -> String: 
	return current_dialogue
