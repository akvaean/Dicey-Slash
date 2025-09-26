extends Label

func _ready():
	text = str(Gamemanager.total_coins)
	Gamemanager.coins_changed.connect(_on_coins_changed)

func _on_coins_changed(new_total: int):
	text = str(new_total)
