extends Area2D

@export var coin_value: int = 1

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):  # make sure your player is in group "player"
		Gamemanager.add_coins(coin_value)
		queue_free()
