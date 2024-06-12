extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	if Input.is_action_pressed("Escape"):
		get_tree().quit()
