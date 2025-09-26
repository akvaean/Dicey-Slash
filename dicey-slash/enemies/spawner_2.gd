extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_point: Marker2D
@export var base_enemy_count: int = 3               # Enemies in wave 1
@export var enemy_increase_per_wave: int = 2        # Enemies added each new wave
@export var time_between_waves: float = 3.0         # Delay before next wave starts

var current_wave: int = 1
var enemies_to_spawn: int = 0
var enemies_alive: int = 0

signal wave_cleared(wave: int)   # Signal emitted when a wave ends

func _ready():
	start_wave()

func start_wave():
	enemies_to_spawn = base_enemy_count + (current_wave - 1) * enemy_increase_per_wave
	spawn_wave()

func spawn_wave():
	for i in range(enemies_to_spawn):
		spawn_enemy()

func spawn_enemy():
	if not enemy_scene:
		push_warning("No enemy scene assigned to spawner.")
		return

	var enemy = enemy_scene.instantiate()
	call_deferred("add_child", enemy)
	enemy.global_position = spawn_point.global_position
	enemies_alive += 1

	# When enemy exits tree (dies), call _on_enemy_dead
	enemy.connect("tree_exited", Callable(self, "_on_enemy_dead"))

func _on_enemy_dead():
	enemies_alive -= 1
	
	# If all enemies in the current wave are dead…
	if enemies_alive <= 0:
		# Only do this if spawner is still part of the tree
		if is_inside_tree():
			emit_signal("wave_cleared", current_wave)
			await get_tree().create_timer(time_between_waves).timeout
			current_wave += 1
			start_wave()

func _exit_tree():
	enemies_alive = 0
