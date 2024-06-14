extends CenterContainer

@export var RETICLE_LINES : Array[Line2D]
@export var PLAYER_CONTROLLER : CharacterBody3D
@export var RETICLE_SPEED : float = 0.25
@export var RETICLE_DISTANCE : float = 2.0
@export var DOT_RADIUS : float = 3.0
@export var DOT_COLOR : Color = Color.NAVAJO_WHITE
@export var DOT_STROKE : Color

# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	adjust_reticle_lines()

func _draw():
	draw_circle(Vector2(0,0), 6.0, Color.BLACK) # Circle Stroked
	draw_circle(Vector2(0,0), DOT_RADIUS, DOT_COLOR) # Main Dot
	
func adjust_reticle_lines():
	var vel = PLAYER_CONTROLLER.get_real_velocity()
	var origin = Vector3(0, 0, 0)
	var pos = Vector2(0, 0)
	var speed = origin.distance_to(vel)
	
	var rp1 = RETICLE_LINES[0].position
	var rp2 = RETICLE_LINES[1].position
	var rp3 = RETICLE_LINES[2].position
	var rp4 = RETICLE_LINES[3].position
	
	RETICLE_LINES[0].position = lerp(rp1, pos + Vector2(0, -speed * RETICLE_DISTANCE), RETICLE_SPEED) # Top
	RETICLE_LINES[1].position = lerp(rp2, pos + Vector2(speed * RETICLE_DISTANCE, 0), RETICLE_SPEED) # Right
	RETICLE_LINES[2].position = lerp(rp3, pos + Vector2(0, speed * RETICLE_DISTANCE), RETICLE_SPEED) # Bottom
	RETICLE_LINES[3].position = lerp(rp4, pos + Vector2(-speed * RETICLE_DISTANCE, 0), RETICLE_SPEED) # Left


