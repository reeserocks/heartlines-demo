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
@export var min_separation_radius = 20.0  # Minimum distance between characters
@export var max_ai_distance_from_player = 100.0  # Max distance the AI can be from the active player

# ACTIVE AND INACTIVE CHARACTERS
var active_character
var inactive_characters = []
var ai_states = {}

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
		print("you used the ability")
	
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
				$CanvasLayer/DialogPopup.face_set(target.name)
				$CanvasLayer/DialogPopup.open()

# ACTIVE CHARACTER MOVEMENT
func _process_active_character(delta):
	# GET PLAYER INPUT
	var direction: Vector2
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# NORMALIZE DIAGONAL MOVEMENT
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	active_character.move_and_animate(direction, speed * delta)
	
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
			_move_character(character, delta)
		else:
			character.move_and_animate(Vector2.ZERO, 0)

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
