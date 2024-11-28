### ShelfRight.gd

extends StaticBody2D

@onready var shelf_right = $CollisionPolygon2D
@onready var shelf_right_sprite = $ShelfRight

func _on_area_2d_body_exited(body: Node2D) -> void:
	shelf_right.disabled = false
	shelf_right_sprite.modulate.a = 1
