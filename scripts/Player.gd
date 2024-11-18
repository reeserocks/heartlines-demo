### Player.gd
extends CharacterBody2D

# NODE REFERENCES
@onready var animation_sprite = $AnimatedSprite2D

# PLAYER STATES
@export var speed = 50
var is_attacking = false

#UPDATED THROUGHOUT GAME STATE
var new_direction = Vector2(0,1) #only move one space
var animation

func _physics_process(delta):
	# GET PLAYER INPUT
	var direction: Vector2
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# NORMALIZE DIAGONAL MOVEMENT
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# APPLY MOVEMENT
	var movement = speed * direction * delta
	if is_attacking == false:
		move_and_collide(movement)
		player_animations(direction)
	if !Input.is_anything_pressed():
		if is_attacking == false:
			animation = "idle_" + returned_direction(new_direction)

func _input(event):
	if event.is_action_pressed("ui_attack"):
		is_attacking = true 
		var animation = "attack_" + returned_direction(new_direction)
		animation_sprite.play(animation)

# ANIMATION DIRECTION
func returned_direction(direction : Vector2):
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
func player_animations(direction : Vector2):
	if direction != Vector2.ZERO:
		new_direction = direction
		animation = "walk_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	else:
		animation = "idle_" + returned_direction(new_direction)
		animation_sprite.play(animation)

# RESET STATE
func _on_animated_sprite_2d_animation_finished() -> void:
	is_attacking = false
