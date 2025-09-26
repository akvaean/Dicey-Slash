extends Node


@onready var pause: Button = $"."
@onready var pausepop: PopupPanel = $pause

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_pressed()
	if event.is_action_released("pause"):
		_on_resume_pressed()


func _process(_delta: float) -> void:
	if not pausepop.visible:
		Engine.time_scale = 1
		pause.show()

	
	
	
func _on_resume_pressed() -> void:
	Engine.time_scale = 1
	pausepop.hide()
	pause.show()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_pressed() -> void: 
	pausepop.popup_centered()		
	Engine.time_scale = 0
	pause.hide()
