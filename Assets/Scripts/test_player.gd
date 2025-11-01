# @tool
extends Node2D

@export var ship_size: float = 20.0
@export var ship_color: Color = Color(1,1,1)
@export var thrust_speed: float = 200.0
var velocity: Vector2 = Vector2.ZERO

func _draw():
	var s = ship_size
	var pts = PackedVector2Array()
	pts.append(Vector2(0.0, -s))
	pts.append(Vector2(s * 0.6, s * 0.6))
	pts.append(Vector2(-s * 0.6, s * 0.6))
	draw_polygon(pts, [ship_color])

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		rotation -= 3.0 * delta
	if Input.is_action_pressed("ui_right"):
		rotation += 3.0 * delta
	if Input.is_action_pressed("ui_up"):
		velocity += Vector2.UP.rotated(rotation) * thrust_speed * delta
	position += velocity * delta
	var screen_size = get_viewport_rect().size
	position.x = wrapf(position.x, 0.0, screen_size.x)
	position.y = wrapf(position.y, 0.0, screen_size.y)
