extends Area2D

@export var speed: float = 250.0
@export var damage: int = 10
@export var max_lifetime: float = 5.0

var direction: Vector2 = Vector2.ZERO
var ignore_body: Node2D
var lifetime: float = 0.0
var has_hit_something: bool = false  # Prevent multiple hits

func _ready() -> void:
	# Use area_entered instead of body_entered for more reliable detection
	connect("area_entered", Callable(self, "_on_area_entered"))
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	if has_hit_something:
		return
		
	if direction != Vector2.ZERO:
		position += direction * speed * delta
		rotation = direction.angle()
	
	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()
		return

func _on_area_entered(area: Area2D) -> void:
	if has_hit_something:
		return
		
	# Check if it's the player's hitbox area
	if area.is_in_group("player_hitbox") and area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage)
		has_hit_something = true
		queue_free()

func _on_body_entered(body: Node) -> void:
	if has_hit_something:
		return
		
	# Skip if it's the body we should ignore
	if body == ignore_body:
		return
	
	# Use groups instead of name checking
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		has_hit_something = true
		queue_free()
