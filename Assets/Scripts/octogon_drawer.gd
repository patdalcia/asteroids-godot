@tool
extends Node2D

@export var radius : float = 50.0
@export var line_width : float = 2.0
@export var line_color : Color = Color(1,1,1,1)  # white
@export var sides : int = 8

@onready var coll_poly := $"../CollisionPolygon2D"  # exact name/path


func _ready():
	_update_polygon()
	queue_redraw()  # instead of update()
	
func _update_polygon():
	var pts := PackedVector2Array()
	for i in range(sides):
		var angle = (i / float(sides)) * TAU
		var p = Vector2(cos(angle), sin(angle)) * radius
		pts.append(p)
	coll_poly.polygon = pts

func _draw():
	var pts := PackedVector2Array()
	for i in range(sides):
		var angle = (i / float(sides)) * TAU
		var p = Vector2(cos(angle), sin(angle)) * radius
		pts.append(p)
	for i in range(pts.size()):
		var p1 = pts[i]
		var p2 = pts[(i + 1) % pts.size()]
		draw_line(p1, p2, line_color, line_width)
