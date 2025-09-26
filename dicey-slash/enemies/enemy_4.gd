extends Enemy_ranged
class_name Enemy_ranged_fast

func _ready():
	# Customize before calling parent
	max_health = 35
	speed = 120.0
	wander_speed = 60.0
	shoot_interval = 2.0
	projectile_spread_degrees = 10.0
	chase_range = 250.0
	super._ready() 
