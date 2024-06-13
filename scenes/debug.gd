extends PanelContainer

@onready var property_container: VBoxContainer = $MarginContainer/VBoxContainer
var property: Label
var fps : String

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	add_debug_property("FPS", fps)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		fps = "%.2f" % (1.0/delta)
		property.text = property.name + ": " + str(fps)

func _input(event):
	if event.is_action_pressed("debug"):
		visible = !visible

func add_debug_property(title: String, value):
	property = Label.new()
	property_container.add_child(property)
	property.name = title
	property.text = property.name


