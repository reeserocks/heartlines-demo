### Aberration.gd

extends CharacterBody2D

@export var speed = 30

var health = 100
var dead = false
var player_near = false
var player_body = null

func _ready():
	dead = false

func _physics_process(_delta):
	if !dead:
		$DetectionArea/CollisionShape2D.disabled = false
		if player_body and player_near and !GameManager.cutscene_playing: 
			await get_tree().create_timer(1).timeout
			position += (player_body.position - position) / speed
			$AnimatedSprite2D.play("move")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		$DetectionArea/CollisionShape2D.disabled = true
		queue_free()


func _on_detection_area_body_entered(body: Node2D):
	if body.is_in_group("active"):
		player_near = true
		player_body = body
		if !GameManager.cutscene_triggered:
			GameManager.trigger_cutscene()

func _on_detection_area_body_exited(body: Node2D):
	if body == player_body:
		player_near = false
		player_body = null

func _on_hitbox_area_entered(area: Area2D):
	var damage
	if area.has_method("bullet_deal_damage"):
		damage = 50
		take_damage(damage)

func take_damage(damage):
	health = health - damage
	if health <= 0 and !dead:
		death()

func death():
	dead = true
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(1).timeout
	queue_free()
