class_name SprintingPlayerState extends State

@export var ANIMATION : AnimationPlayer
@export var TOP_ANIM_SPEED : float = 1.6

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func enter() -> void:
	ANIMATION.play("Sprinting", 0.5, 1.0)
	Global.player._speed = Global.player.SPRINTING_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func update(delta):
	set_animation_speed(Global.player.velocity.length())

func set_animation_speed(speed) -> void:
	var alpha = remap(speed, 0.0, Global.player.SPRINTING_SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIM_SPEED, alpha)

func _input(event) -> void:
	if event.is_action_released("sprint"):
		transition.emit("WalkingPlayerState")
