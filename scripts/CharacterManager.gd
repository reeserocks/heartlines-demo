### CharacterManager.gd
extends Node2D

# STATE MACHINE
enum CharacterState { TESS, JAY, CHARLIE }
var current_state: CharacterState = CharacterState.TESS

# NODE REFERENCES
@onready var tess = $Tess
@onready var jay = $Jay
@onready var charlie = $Charlie

@onready var raycast_tess = tess.get_node("RayCast2D")
@onready var raycast_jay = jay.get_node("RayCast2D")
@onready var raycast_charlie = charlie.get_node("RayCast2D")

@onready var navigation_agent_tess = tess.get_node("NavigationAgent2D")
@onready var navigation_agent_jay = jay.get_node("NavigationAgent2D")
@onready var navigation_agent_charlie = charlie.get_node("NavigationAgent2D")

# PARAMETERS
@export var speed = 175

# AI PARAMETERS
@export var ai_speed = 30
@export var ai_move_chance = 0.5  # 50% chance to move
@export var ai_decision_interval = 2.0  # Decide every 2 seconds
@export var min_separation_radius = 175.0  # Minimum distance between characters
@export var max_ai_distance_from_player = 200.0  # Max distance the AI can be from the active player

# ACTIVE AND INACTIVE CHARACTERS
var active_character
var inactive_characters = []
var ai_states = {}

#COMBAT
var gun_cooldown = true
var bullet = preload("res://scenes/combat/Bullet.tscn")
var ability_active = false
var mouse_loc_from_player = null

# UPDATE CHARACTER
func _ready():
	active_character = tess
	inactive_characters = [jay, charlie]
	_initialize_ai_states()
	
	for character in [tess, jay, charlie]:
		character.set_process(true)
	
	_update_active_character()

func _physics_process(delta):
	_process_active_character(delta)
	_process_inactive_ai(delta)
	
	var mouse_pos = get_global_mouse_position()
	$Charlie/Marker2D.look_at(mouse_pos)
	mouse_loc_from_player = get_global_mouse_position() - active_character.position 
	
	if active_character == charlie:
		if Input.is_action_just_pressed("ui_ability"):
			if ability_active == false:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				ability_active = true
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				ability_active = false
	
		if Input.is_action_just_pressed("ui_shoot") and ability_active and gun_cooldown:
			gun_cooldown = false
			var bullet_instance = bullet.instantiate()
			bullet_instance.rotation = $Charlie/Marker2D.rotation
			bullet_instance.global_position = $Charlie/Marker2D.global_position
			add_child(bullet_instance)
			
			await get_tree().create_timer(0.4).timeout
			gun_cooldown = true
	

# INITIALIZE AI STATES
func _initialize_ai_states():
	for character in [tess, jay, charlie]:
		ai_states[character] = { 
			"moving": randf() < ai_move_chance,  # Randomly decide if moving at start
			"next_decision_time": randf_range(0.1, ai_decision_interval)  # Immediate or staggered decision
			}

# INPUT EVENTS
func _input(event):
	# Switch character based on number keys
	if event.is_action_pressed("ui_switch_tess"):  # Key 1
		_switch_to_character(tess)
	elif event.is_action_pressed("ui_switch_jay"):  # Key 2
		_switch_to_character(jay)
	elif event.is_action_pressed("ui_switch_charlie"):  # Key 3	
		_switch_to_character(charlie)
	
	#ability
	elif event.is_action_pressed("ui_ability"):
			active_character.use_ability()
	
	#interact with world
	elif event.is_action_pressed("ui_interact"):
		var target = _get_active_character_raycast().get_collider()
		if target != null:
			print("Raycast hit: " + target.name)
			if target.is_in_group("npc") and target != active_character:
				print("Interacted with NPC: " + target.name)
				
				target.set_dialogue(active_character)
				
				$CanvasLayer/DialogPopup.npc = target
				$CanvasLayer/DialogPopup.npc_name_set(target.name)
				$CanvasLayer/DialogPopup.message_set(target.get_current_dialogue())
				$CanvasLayer/DialogPopup.open()
	
	elif event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

# ACTIVE CHARACTER MOVEMENT
func _process_active_character(delta):
	# GET PLAYER INPUT
	var direction: Vector2
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# NORMALIZE DIAGONAL MOVEMENT
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# MOVE IF ABILITY IS NOT ACTIVE
	if !ability_active:
		if !GameManager.disable_input:
			active_character.move_and_animate(direction, speed * delta)
	# FREEZE IF ABILITY IS ACTIVE
	else:
		if mouse_loc_from_player.x >= -25 and mouse_loc_from_player.x <= 25 and mouse_loc_from_player.y < 0:
				$Charlie/AnimatedSprite2D.play("attack_up")
		if mouse_loc_from_player.y >= -25 and mouse_loc_from_player.y <= 25 and mouse_loc_from_player.x > 0:
				$Charlie/AnimatedSprite2D.flip_h = false
				$Charlie/AnimatedSprite2D.play("attack_side")
		if mouse_loc_from_player.x >= -25 and mouse_loc_from_player.x <= 25 and mouse_loc_from_player.y > 0:
				$Charlie/AnimatedSprite2D.play("attack_down")
		if mouse_loc_from_player.y >= -25 and mouse_loc_from_player.y <= 25 and mouse_loc_from_player.x < 0:
				$Charlie/AnimatedSprite2D.flip_h = true
				$Charlie/AnimatedSprite2D.play("attack_side")

	#TURN RAYCAST2D TOWARD MOVEMENT DIRECTION
	if direction != Vector2.ZERO:
		_get_active_character_raycast().target_position = direction.normalized() * 50

# SWITCHING CHARACTERS
func _switch_to_character(character):
	if character == active_character:
		return  # Ignore if already active
	
	active_character.remove_from_group("active")
	active_character.add_to_group("npc")
	
	active_character = character
	
	#NPC interaction groups
	active_character.remove_from_group("npc")
	active_character.add_to_group("active")
	
	inactive_characters = [tess, jay, charlie].filter(func(c): return c != active_character)
	
	_update_active_character()

func _update_active_character():
	for character in [tess, jay, charlie]:
		var is_active = character == active_character
		character.set_process(character == active_character)
		character.set_visible(true)
		
		# Update Camera2D for active character
		var camera = character.get_node("Camera2D")
		if camera:
			camera.enabled = is_active

# PROCESS INACTIVE AI
func _process_inactive_ai(delta):
	for character in inactive_characters:
		var state = ai_states[character]
		
		# Countdown for AI decision
		state["next_decision_time"] -= delta
		if state["next_decision_time"] <= 0:
			state["moving"] = randf() < ai_move_chance  # Random decision to move
			state["next_decision_time"] = ai_decision_interval

		# Check if AI should move
		if state["moving"] and _can_move(character):
			if _is_active_character_nearby(character):
				# If active character is too close, move away
				_move_away_from_active_character(character, delta)
			else:
				_move_character(character, delta)
		else:
			character.move_and_animate(Vector2.ZERO, 0)

# CHECK IF THE ACTIVE CHARACTER IS TOO CLOSE
func _is_active_character_nearby(character) -> bool:
	var distance = active_character.global_position.distance_to(character.global_position)
	return distance < min_separation_radius  # If closer than the minimum separation radius


# MOVE THE NPC AWAY FROM THE ACTIVE CHARACTER
func _move_away_from_active_character(character, delta):
	# Calculate direction away from the active character
	var direction_to_player = character.global_position - active_character.global_position
	var move_direction = direction_to_player.normalized()
	
	# Move the NPC in the opposite direction
	var navigation_agent = _get_navigation_agent(character)
	navigation_agent.target_position = character.global_position + move_direction * 50  # Move away by 50 units

	# Move the character to the new position
	if not navigation_agent.is_navigation_finished():
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - character.global_position).normalized()
		character.move_and_animate(direction, ai_speed * delta)

# AI MOVEMENT LOGIC
func _move_character(character, delta):
	var target_position = active_character.global_position
	
	# Use the NavigationAgent2D to set the movement target
	var navigation_agent = _get_navigation_agent(character)
	navigation_agent.target_position = target_position
	# Make the character move towards the target position
	if not navigation_agent.is_navigation_finished():
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - character.global_position).normalized()
		character.move_and_animate(direction, ai_speed * delta)

# AI MOVE CONDITION 
func _can_move(character):
	# AI can move only if it is not too close to the player
	return active_character.global_position.distance_to(character.global_position) > max_ai_distance_from_player

# GET THE ACTIVE CHARACTER'S RAYCAST
func _get_active_character_raycast() -> RayCast2D:
	if active_character == tess:
		return raycast_tess
	elif active_character == jay:
		return raycast_jay
	else:
		return raycast_charlie

# GET THE CHARACTER'S NAVIGATION AGENT
func _get_navigation_agent(character) -> NavigationAgent2D:
	if character == tess:
		return navigation_agent_tess
	elif character == jay:
		return navigation_agent_jay
	else:
		return navigation_agent_charlie
