extends Control

var rng := RandomNumberGenerator.new()
var faces := []
@onready var animated_dice = $animated_dice
var is_rolling := false
var can_roll := true  # Only true after last attack finishes

func _ready():
	rng.randomize()
	
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

func _input(event):
	if event.is_action_pressed("dicea") and can_roll and not is_rolling:
		start_roll()

func start_roll():
	is_rolling = true
	can_roll = false  # Disable rolling until attack finishes
	
	# Hide all static faces and show rolling animation
	for f in faces:
		f.visible = false
	animated_dice.visible = true
	animated_dice.animation = "roll"
	animated_dice.play()
	animated_dice.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished():
	animated_dice.visible = false
	animated_dice.stop()
	animated_dice.disconnect("animation_finished", Callable(self, "_on_animation_finished"))
	show_random_face()
	is_rolling = false

func show_random_face():
	if faces.is_empty():
		return
	
	var idx = rng.randi_range(0, faces.size() - 1)
	for i in range(faces.size()):
		faces[i].visible = (i == idx)
	
	# Store value in global Gamemanager
	Gamemanager.dicea = idx + 1  # 1-6
