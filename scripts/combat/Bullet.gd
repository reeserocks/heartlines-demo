### Bullet.gd

extends Area2D

@export var speed = 1000

func _ready():
	set_as_top_level(true)
	$AnimatedSprite2D.rotation = rotation

func _process(delta):
	position += (Vector2.RIGHT*speed).rotated(rotation) * delta

func bullet_deal_damage():
	pass

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body):
	if body.name == "Aberration":
		$AnimatedSprite2D.play("impact")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "impact":
		queue_free()
