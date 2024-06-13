extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_group("Player")
@export var CROUCH_SHAPECAST : Node3D
@export var TOGGLE_CROUCH : bool = false
@export var ANIMATION_PLAYER : AnimationPlayer
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMARA_CONTROLLER : Camera3D
@export var MOUSE_SENSITIVITY : float = 0.5
@export var CONTROLLER_SENSITIVITY : float = 3
@export var SPEED_DEFAULT : float = 5.0
@export var SPEED_CROUCH : float = 2.0
@export var SPEED = 3.0
@export var JUMP_VELOCITY = 7.0
@export var TOGGLE_MOUSE_MODE : bool = false
@export_range(-10, 10, 0.1) var CROUCH_SPEED: float = 7.0

var _speed : float
var _mouse_rotation: Vector3
var _rotation_input: float = 0.0
var _tilt_input: float = 0.0
var _joystick_rotation: Vector3
var _player_rotation: Vector3
var _camara_rotation: Vector3
var _is_crouching : bool = false

func _ready():
	_speed = SPEED_DEFAULT
	CROUCH_SHAPECAST.add_exception($".")

func _input(event):
	if event.is_action_pressed("crouch") and is_on_floor():
		toggle_crouch()
	if event.is_action_pressed("crouch") and _is_crouching == false and is_on_floor() and not TOGGLE_CROUCH:
		crouching(true)
	if event.is_action_released("crouch") and TOGGLE_CROUCH == false:
		if CROUCH_SHAPECAST.is_colliding() == false:
			crouching(false)
		elif CROUCH_SHAPECAST.is_colliding() == true:
			uncrouch_check()
		
func uncrouch_check():
	if CROUCH_SHAPECAST.is_colliding() == false:
		crouching(false)
	if CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch_check()
	
func _unhandled_input(event):
	if event.is_action_pressed("click"):
		print("mouse has been captured!")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		TOGGLE_MOUSE_MODE = true
		
	if event.is_action_pressed("toggle_mouse_mode"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			TOGGLE_MOUSE_MODE = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			TOGGLE_MOUSE_MODE = true
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#print("Mouse mode: ", str(_mouse_input))
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		

func update_joystick_camara(delta):
	if InputEventJoypadMotion:
		var controller_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")	
		var joy_rotation_input = -controller_dir.x * CONTROLLER_SENSITIVITY
		var joy_tilt_input = -controller_dir.y * CONTROLLER_SENSITIVITY
		
		_joystick_rotation.x += joy_tilt_input * delta
		_joystick_rotation.x = clamp(_joystick_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
		_joystick_rotation.y +=  joy_rotation_input * delta
		
		_player_rotation = Vector3(0.0, _joystick_rotation.y, 0.0)
		_camara_rotation = Vector3(_joystick_rotation.x, 0.0, 0.0)
		
		CAMARA_CONTROLLER.transform.basis = Basis.from_euler(_camara_rotation)
		CAMARA_CONTROLLER.rotation.z = 0.0
		
		global_transform.basis = Basis.from_euler(_player_rotation)


func update_camara(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camara_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	CAMARA_CONTROLLER.transform.basis = Basis.from_euler(_camara_rotation)
	CAMARA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if TOGGLE_MOUSE_MODE:
		update_camara(delta) # handle mouse movement
	else:
		update_joystick_camara(delta) # handle joystick input

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !_is_crouching:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)
		velocity.z = move_toward(velocity.z, 0, _speed)

	move_and_slide()

func crouching(state: bool):
	match state:
		true:
			ANIMATION_PLAYER.play("crouch", -1, CROUCH_SPEED)
			set_movement_speed("crouching")
		false:
			ANIMATION_PLAYER.play("crouch", -1, -CROUCH_SPEED, true)
			set_movement_speed("default")

func toggle_crouch():
	print(CROUCH_SHAPECAST.is_colliding())
	if _is_crouching == true and CROUCH_SHAPECAST.is_colliding() == false:
		crouching(false)
	elif _is_crouching == false:
		crouching(true)

func _on_animation_player_animation_started(anim_name):
	if anim_name == "crouch":
		_is_crouching = !_is_crouching

func set_movement_speed(state: String):
	match state:
		"default":
			_speed = SPEED_DEFAULT
		"crouching":
			_speed = SPEED_CROUCH
