extends CharacterBody2D
class_name Enemy_ranged

# --- Configurable Enemy Stats ---
@export var max_health: int = 50
@export var speed: float = 80.0
@export var wander_speed: float = 40.0
@export var change_direction_time: float = 2.0
@export var chase_range: float = 200.0
@export var stop_distance: float = 60.0
@export var shoot_interval: float = 3.5
@export var projectile_spread_degrees: float = 15.0

# --- Internal State ---
var health: int
var player: Node2D
var wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
var is_taking_damage: bool = false
var shoot_direction: Vector2 = Vector2.ZERO
var shoot_cooldown: float = 0.0

# --- Node References ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle: Marker2D = $muzzle
@onready var health_bar: Label = $health
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var default_projectile = preload("res://enemies/projectile.tscn")

func _ready():
	health = max_health
	player = get_tree().get_first_node_in_group("player")
	_set_random_direction()
	shoot_cooldown = randf_range(0.0, shoot_interval)  # randomize cooldown

func _physics_process(delta: float):
	if health <= 0:
		return

	if shoot_cooldown > 0:
		shoot_cooldown -= delta

	if is_taking_damage:
		velocity = Vector2.ZERO
	else:
		if player and is_instance_valid(player):
			var distance_to_player = global_position.distance_to(player.global_position)
			if distance_to_player < chase_range:
				_chase_player(distance_to_player)
				_try_shoot()
			else:
				_wander(delta)
		else:
			player = get_tree().get_first_node_in_group("player")
			_wander(delta)

	if velocity != Vector2.ZERO:
		move_and_slide()

	_update_animation()

# --- Movement ---
func _chase_player(distance_to_player: float):
	if distance_to_player > stop_distance:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO

func _wander(delta: float):
	wander_timer -= delta
	if wander_timer <= 0:
		_set_random_direction()
	velocity = wander_direction * wander_speed

func _set_random_direction():
	wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_timer = change_direction_time

# --- Combat ---
func take_damage(amount: int):
	if is_taking_damage or health <= 0:
		return

	health = max(0, health - amount)
	if health_bar:
		health_bar.text = str(health)

	is_taking_damage = true
	animation_player.play(_get_damage_animation_name())

	await get_tree().create_timer(0.4).timeout
	is_taking_damage = false

	if health <= 0:
		die()

func die():
	_spawn_drop()
	queue_free()

func _try_shoot():
	if shoot_cooldown > 0 or not player or not is_instance_valid(player):
		return

	shoot_cooldown = shoot_interval + randf_range(-0.5, 0.5)

	# Compute vector from muzzle to player
	var muzzle_to_player = (player.global_position - muzzle.global_position)
	var distance = muzzle_to_player.length()
	var direction = muzzle_to_player.normalized()

	# Optional: reduce spread for long distances
	var spread = projectile_spread_degrees
	if distance > 150:
		spread *= 0.5

	direction = direction.rotated(deg_to_rad(randf_range(-spread, spread)))

	# Spawn projectile at muzzle
	var proj = default_projectile.instantiate()
	get_parent().add_child(proj)
	proj.global_position = muzzle.global_position
	proj.direction = direction
	proj.ignore_body = self

	# Update shoot_direction for animations
	shoot_direction = direction
	animation_player.play(_get_shoot_animation_name())

# --- Animation ---
func _update_animation():
	if is_taking_damage:
		return
	var anim_name = _get_movement_animation_name()
	animation_player.play(anim_name)

func _get_movement_animation_name() -> String:
	if velocity == Vector2.ZERO:
		return "idle_down"
	else:
		return _get_direction_name()

func _get_direction_name() -> String:
	if abs(velocity.x) > abs(velocity.y):
		return "left" if velocity.x < 0 else "right"
	else:
		return "up" if velocity.y < 0 else "down"

func _get_shoot_animation_name() -> String:
	if abs(shoot_direction.x) > abs(shoot_direction.y):
		return "hit_left" if shoot_direction.x < 0 else "hit_right"
	else:
		return "hit_up" if shoot_direction.y < 0 else "hit_down"

func _get_damage_animation_name() -> String:
	if abs(velocity.x) > abs(velocity.y):
		return "dam_l" if velocity.x < 0 else "dam_r"
	else:
		return "dam_u" if velocity.y < 0 else "dam_d"

# --- Drops ---
func _spawn_drop():
	var drop_chance = randi() % 3
	var drop_scene: PackedScene
	if drop_chance == 0:
		drop_scene = preload("res://objects/heal.tscn")
	else:
		drop_scene = preload("res://objects/coin.tscn")

	var drop = drop_scene.instantiate()
	get_parent().add_child(drop)
	drop.global_position = global_position
