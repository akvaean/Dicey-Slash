extends CharacterBody2D

const SPEED = 120.0
@export var max_health: int = 100
@export var attack_damages: Array[int] = [5, 8, 12, 15, 20, 25]

var health: int
var direction: Vector2 = Vector2.ZERO
var is_hitting: bool = false
var is_taking_damage: bool = false
var attack_direction: Vector2 = Vector2.ZERO
var hits_left: int = 0
const MAX_HITS_PER_ROLL: int = 5
var current_hit_number: int = 0
var current_attack_type: int = 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_hitbox: Area2D = $attack_hitbox
@onready var health_text: Label = $health
@onready var dice_scene: Control = $dicea
@onready var reroll: Label = $reroll
@onready var roll: Label = $roll
@onready var attack: Label = $attack
@onready var heal_label: Label = $heal
@onready var hits_label: Label = $hits
@onready var goodluck: Label = $goodluck

func _ready():
	health = max_health
	if attack_hitbox:
		attack_hitbox.body_entered.connect(_on_attack_hit)
	await get_tree().create_timer(3).timeout
	roll.hide()
	attack.show()
	await get_tree().create_timer(3).timeout
	attack.hide()
	heal_label.show()
	await get_tree().create_timer(3).timeout
	heal_label.hide()
	goodluck.show()
	await get_tree().create_timer(3).timeout
	goodluck.hide()
	update_hits_label()

func _physics_process(_delta):
	check_dice_state()
	if not (is_hitting or is_taking_damage):
		direction = Input.get_vector("left", "right", "up", "down")
		velocity = direction.normalized() * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	update_animation()

	if Input.is_action_just_pressed("hit") and not is_hitting and Gamemanager.dicea > 0 and hits_left > 0:
		perform_attack()

func check_dice_state():
	if Gamemanager.dicea > 0 and hits_left == 0:
		hits_left = MAX_HITS_PER_ROLL
		current_hit_number = 0
		current_attack_type = Gamemanager.dicea
		update_hits_label()

func perform_attack():
	current_hit_number += 1
	is_hitting = true
	attack_direction = (get_global_mouse_position() - global_position).normalized()
	animation_player.play(get_attack_animation_name())
	if attack_hitbox:
		attack_hitbox.monitoring = true

	await get_tree().create_timer(0.5).timeout
	is_hitting = false
	if attack_hitbox:
		attack_hitbox.monitoring = false

	hits_left -= 1
	update_hits_label()

	if hits_left <= 0:
		Gamemanager.dicea = 0
		if dice_scene:
			dice_scene.can_roll = true
		reroll.show()
		await get_tree().create_timer(2).timeout
		reroll.hide()
		update_hits_label()

# ✅ FIXED: Now allows multiple hits even during damage animation
func take_damage(amount: int) -> void:
	if health <= 0:
		return

	health = max(0, health - amount)
	health_text.text = str(health)

	# Only trigger animation if not already playing one
	if not is_taking_damage:
		is_taking_damage = true
		animation_player.play(get_damage_animation_name())
		await get_tree().create_timer(0.4).timeout
		is_taking_damage = false

	if health <= 0:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/end.tscn")

func heal(amount: int) -> void:
	health = min(max_health, health + amount)
	health_text.text = str(health)

func update_animation():
	if not (is_taking_damage or is_hitting):
		animation_player.play(get_movement_animation_name())

func get_movement_animation_name() -> String:
	return "idle_down" if direction == Vector2.ZERO else get_direction_name()

func get_direction_name() -> String:
	return "left" if abs(direction.x) > abs(direction.y) and direction.x < 0 else \
		   "right" if abs(direction.x) > abs(direction.y) else \
		   "up" if direction.y < 0 else "down"

func get_attack_animation_name() -> String:
	var attack_type = clamp(current_attack_type, 1, 6)
	var base_anim = "hit_left" if abs(attack_direction.x) > abs(attack_direction.y) and attack_direction.x < 0 else \
					"hit_right" if abs(attack_direction.x) > abs(attack_direction.y) else \
					"hit_up" if attack_direction.y < 0 else "hit_down"
	return "%s%d" % [base_anim, attack_type]

func get_damage_animation_name() -> String:
	return "dam_l" if abs(direction.x) > abs(direction.y) and direction.x < 0 else \
		   "dam_r" if abs(direction.x) > abs(direction.y) else \
		   "dam_u" if direction.y < 0 else "dam_d"

func _on_attack_hit(body):
	if body != self and body.has_method("take_damage") and is_hitting:
		var to_enemy = (body.global_position - global_position).normalized()
		if attack_direction.dot(to_enemy) > 0.7:
			var base_damage = attack_damages[current_attack_type - 1]
			body.take_damage(base_damage * current_hit_number)

func update_hits_label():
	if hits_label:
		hits_label.text = str(max(hits_left, 0))


func _on_pause_replacing_by(node: Node) -> void:
	pass # Replace with function body.
