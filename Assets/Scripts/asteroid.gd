class_name Asteroid
extends Area2D

signal exploded(pos: Vector2, side_count: int, points: int, velocity: Vector2)

@export var radius: float = 50.0
@export var line_width: float = 2.0
@export var line_color: Color = Color(0, 0, 0, 1)
@export var sides: int = 8

@onready var coll_poly := $CollisionPolygon2D

# Movement properties
var velocity: Vector2 = Vector2.ZERO
var speed: float = 50.0
var rotation_speed: float = 0.0

enum AsteroidSize { LARGE, MEDIUM, SMALL }
@export var size := AsteroidSize.LARGE

var points: int:
	get:
		match sides:
			3: return 100
			4: return 90
			5: return 80
			6: return 70
			7: return 60
			8: return 50
			_ : return 0

func _ready():
	randomize()
	if velocity == Vector2.ZERO:
		# only pick a random direction if none provided
		var angle = randf_range(0, TAU)
		velocity = Vector2(cos(angle), sin(angle))
	rotation_speed = randf_range(-2.0, 2.0)
	rotation = randf_range(0, TAU)

	_update_polygon()
	queue_redraw()

	match sides:
		3: speed = randf_range(150, 250)
		4: speed = randf_range(100, 200)
		5: speed = randf_range(80, 160)
		6: speed = randf_range(80, 120)
		7: speed = randf_range(70, 90)
		8: speed = randf_range(60, 80)
		_ : speed = randf_range(50, 70)

	# Debug print
	print("Asteroid spawned – sides=", sides, " velocity=", velocity, " speed=", speed)

func _physics_process(delta: float):
	rotation += rotation_speed * delta
	global_position += velocity * speed * delta

	var screen_size = get_viewport_rect().size
	if global_position.y + radius < 0:
		global_position.y = screen_size.y + radius
	elif global_position.y - radius > screen_size.y:
		global_position.y = -radius
	if global_position.x + radius < 0:
		global_position.x = screen_size.x + radius
	elif global_position.x - radius > screen_size.x:
		global_position.x = -radius

func _update_polygon():
	var pts := PackedVector2Array()
	for i in range(sides):
		var a = (i / float(sides)) * TAU
		pts.append(Vector2(cos(a), sin(a)) * radius)
	coll_poly.set_deferred("polygon", pts)

func _draw():
	var pts := PackedVector2Array()
	for i in range(sides):
		var a = (i / float(sides)) * TAU
		pts.append(Vector2(cos(a), sin(a)) * radius)
	for i in range(pts.size()):
		var p1 = pts[i]
		var p2 = pts[(i + 1) % pts.size()]
		draw_line(p1, p2, line_color, line_width)

func explode():
	emit_signal("exploded", global_position, sides, points, velocity)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
