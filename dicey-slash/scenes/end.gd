extends Control

@onready var coins: Label = $coins

func _ready() -> void:
	coins.text = "Coins collected - " + str(Gamemanager.total_coins)

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	Gamemanager.total_coins = 0
	


func _on_quit_pressed() -> void:
	get_tree().quit()
	
