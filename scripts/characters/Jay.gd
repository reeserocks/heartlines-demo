extends "res://scripts/characters/BaseCharacter.gd"

func use_ability():
	animation_sprite.play("ability_jay")

func set_dialogue(active_character):
	dialogues = {
		"Tess": [
			"Hey, we'll find your parents, don't worry.",
			"I knew your dad very well, and he'd be taking care of your Momma here.",
			"Your mom and dad love you very much. They wouldn't leave you."
		],
		"Charlie": [
			"It's not like them to dissapear like this. I hope they're okay.",
			"I'd never been to Tobenna's workplace. I'm kinda excited to see it... if only under different circumstances.",
			"You holding up ok, love?"
		]
	}
	super.set_dialogue(active_character.name)
