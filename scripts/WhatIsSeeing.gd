extends Node2D

var what_is_seeing := []

export var width := 600
export var height := 150

export var fog_pow := 2
export var fog_multiplier := 2
export var fog_color := Color.blue

export var draw_crosshair := true
export var crosshair_width := 1
export var crosshair_color := Color.beige

export(NodePath) var eyes: NodePath
onready var eyes_node: Eyes = get_node(eyes)

func _on_Eyes_change_what_is_seeing(what_is_seeing):
	self.what_is_seeing = what_is_seeing
	update()

func _draw():
	draw_rect(Rect2(Vector2(0, 0), Vector2(width, height)), Color.blue)
	
	var n = what_is_seeing.size()
	for i in range(n):
		var point = what_is_seeing[i].get("position")
		
		var x_start = width * i / n
		var next_x_start = width * (i + 1) / n # to solve rounding errors
		
		var base_color: Color
		if point:
			base_color = what_is_seeing[i].get("collider").get_color_at(point, what_is_seeing[i].get("normal"))
		else:
			base_color = Color.black
		
		var fog: float
		if point:
			var distance = (eyes_node.global_position - point).length()
			fog = distance / eyes_node.max_range
			fog = pow(fog, fog_pow) * fog_multiplier
			fog = min(1.0, fog)
		else:
			fog = 1.0
		
		var color = (
			base_color * Color(1.0 - fog, 1.0 - fog, 1.0 - fog) +
			fog_color * Color(fog, fog, fog)
		)
		
		draw_rect(
			Rect2(Vector2(x_start, 0), Vector2(next_x_start - x_start, height)),
			color
		)

	if draw_crosshair:
		var pos1 = width/2 - crosshair_width/2
		var pos2 = width/2 + crosshair_width/2
		draw_line(Vector2(pos1, 0), Vector2(pos1, height), crosshair_color)
		draw_line(Vector2(pos2, 0), Vector2(pos2, height), crosshair_color)
