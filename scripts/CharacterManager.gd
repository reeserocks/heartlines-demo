### CharacterManager.gd
extends Node2D

# STATE MACHINE
enum CharacterState { TESS, JAY, CHARLIE }
var current_state: CharacterState = CharacterState.TESS

# NODE REFERENCES
@onready var tess = $Tess
@onready var jay = $Jay
@onready var charlie = $Charlie

# PARAMETERS
@export var speed = 175

# AI PARAMETERS
@export var ai_speed = 30
@export var ai_move_chance = 0.5  # 50% chance to move
@export var ai_decision_interval = 2.0  # Decide every 2 seconds
@export var min_separation_radius = 10.0  # Minimum distance between characters
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

	if event.is_action_pressed("ui_ability"):
		active_character.use_ability()
		print("you used the ability")

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

# SWITCHING CHARACTERS
func _switch_to_character(character):
	if character == active_character:
		return  # Ignore if already active
	active_character = character
	inactive_characters = [tess, jay, charlie].filter(func(c): return c != active_character)
	_update_active_character()

func _update_active_character():
	for character in [tess, jay, charlie]:
		var is_active = character == active_character
		character.set_process(character == active_character)
		character.set_visible(true)
		
		# Update Camera2D for  active character
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
	var random_offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	var target_position = active_character.global_position + random_offset
	
	# Ensure character doesn't move too close to others
	for other_character in [tess, jay, charlie]:
		if other_character != character and character.global_position.distance_to(other_character.global_position) < min_separation_radius:
			return  # Skip movement to avoid clustering
	
	# Move the character towards the calculated position
	var direction = (target_position - character.global_position).normalized()
	character.move_and_animate(direction, ai_speed * delta)

# AI MOVE CONDITION 
func _can_move(character):
	# AI can move only if it is not too close to the player
	return active_character.global_position.distance_to(character.global_position) > max_ai_distance_from_player
