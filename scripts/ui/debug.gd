extends PanelContainer

@onready var VBox: VBoxContainer = $MarginContainer/VBoxContainer
var fps : String

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	Global.debug = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		fps = "%.2f" % (1.0/delta)
		add_property("FPS", fps, 2)

func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible

func add_property(title: String, value, order):
	var target
	target = VBox.find_child(title, true, false)
	if !target:
		target = Label.new()
		VBox.add_child(target)
		target.name = title
		target.text = target.name +  ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		VBox.move_child(target, order)
