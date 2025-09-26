extends Area2D

@export var heal_amount: int = 20  # how much health it restores

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("heal"):
			body.heal(heal_amount)  # call player's heal function
		queue_free()  # remove health kit from the scene
