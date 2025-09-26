extends Control

var rng := RandomNumberGenerator.new()
var faces := []
@onready var animated_dice = $animated_dice
var is_rolling := false
@onready var player = get_tree().get_first_node_in_group("player")
var can_roll: bool = true  # Track if dice can be rolled
var cooldown_time: float = 10.0  # 10 second cooldown
var cooldown_timer: Timer  # Timer for cooldown
@onready var cooldown_label: Label = $"../cooldown"

func _ready():
	rng.randomize()
	
	# Create cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	add_child(cooldown_timer)
	
	# Collect all dice sprites
	for i in range(1, 7):
		var face_node = get_node("dice%d" % i)
		if face_node is Sprite2D:
			faces.append(face_node)
		else:
			push_warning("dice%d sprite missing!" % i)
	
	# Show first face and hide others
	for f in faces:
		f.visible = false
	if faces:
		faces[0].visible = true
	animated_dice.visible = false
	
	# Find the player node if not already set
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	# Initialize cooldown label if it exists
	if cooldown_label:
		cooldown_label.visible = false

func _input(event):
	if event.is_action_pressed("diceh") and can_roll and not is_rolling:
		start_roll()

func _process(_delta):
	# Update cooldown display if label exists and timer is running
	if cooldown_label and not can_roll:
		var time_left = cooldown_timer.time_left
		cooldown_label.text =  str(ceil(time_left)) 
		cooldown_label.visible = true

func start_roll():
	if not can_roll:
		return
		
	is_rolling = true
	can_roll = false  # Start cooldown
	
	# Hide all static faces and show rolling animation
	for f in faces:
		f.visible = false
	animated_dice.visible = true
	animated_dice.animation = "rollh"
	animated_dice.play()
	animated_dice.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished():
	animated_dice.visible = false
	animated_dice.stop()
	animated_dice.disconnect("animation_finished", Callable(self, "_on_animation_finished"))
	show_random_face()
	is_rolling = false
	
	# Start cooldown timer
	cooldown_timer.start()

func _on_cooldown_finished():
	can_roll = true
	if cooldown_label:
		cooldown_label.visible = false
	print("Dice cooldown finished! You can roll again.")

func show_random_face():
	if faces.is_empty():
		return
	var idx = rng.randi_range(0, faces.size() - 1)
	for i in range(faces.size()):
		faces[i].visible = (i == idx)
	
	# Health increase feature
	increase_health_based_on_dice(idx + 1)  # +1 because idx is 0-5 but dice values are 1-6

func increase_health_based_on_dice(dice_value: int):
	# Calculate how much health to add
	var health_to_add = dice_value * 3  # Example: dice 1 = +5 health, dice 6 = +30 health
	
	# Use the player's heal function instead of modifying Gamemanager directly
	if player and player.has_method("heal"):
		player.heal(health_to_add)
		print("Healed for ", health_to_add, " health! (Dice roll: ", dice_value, ")")
