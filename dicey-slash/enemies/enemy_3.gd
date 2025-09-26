extends Enemy_m


func _ready():
	max_health = 40
	speed = 120.0
	wander_speed = 60.0
	melee_damage = 4
	attack_interval = 0.8

	super._ready()  

func _spawn_drop():
	var drop_scene: PackedScene = preload("res://objects/coin.tscn")
	var drop = drop_scene.instantiate()
	get_parent().add_child(drop)
	drop.global_position = global_position
