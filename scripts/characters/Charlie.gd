extends "res://scripts/characters/BaseCharacter.gd"

func set_dialogue(active_character):
	dialogues = {
		"Jay": [
			"We need to find Tobenna and Katherine.",
			"Did you turn off the stove before we left?",
			"I find it strange that Katherine just ran off without telling us.",
			"Do you think Tobenna is really still out here? You know him better than anyone.",
		],
		"Tess": [
			"Hey, kid. We're gonna find your parents.",
			"Your dad's gotta be around here somewhere, and your mom's sure to be with him.",
			"Keep your head up, Tess. We'll find them.",
			"Your parents are smart people. They've gotta be here."
		]
	}
	super.set_dialogue(active_character.name)
