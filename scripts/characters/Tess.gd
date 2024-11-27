extends "res://scripts/characters/BaseCharacter.gd"

func _ready():
	remove_from_group("npc")
	add_to_group("active")

func use_ability():
	animation_sprite.play("ability_tess")

func set_dialogue(active_character):
	dialogues = {
		"Jay": [
			"You don't think they left me on purpose, right?",
			"You worked with my dad, so he would probably tell you if he left, wouldn't he?",
			"Thanks for taking me here, by the way. I hope we find them."
		],
		"Charlie": [
			"Hey, when's it my turn to use the shotgun? Pleeasee!!",
			"Uncle Charlie... you'll make sure everything turns out okay, right?",
			"Thanks for taking me here, by the way. I hope we find them."
		]
	}
	super.set_dialogue(active_character.name)
