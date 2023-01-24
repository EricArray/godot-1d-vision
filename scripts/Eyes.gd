extends Node2D
class_name Eyes

export var draw_fan := false
export(Color) var draw_color := Color.red
export var max_range := 500
export var vision_angle_degs := 90
export var vision_pixels = 19

export var draw_rays := false
export var draw_normals := false

var what_is_seeing = []

signal change_what_is_seeing(what_is_seeing)

# TODO: vision starts from the eyes, or from the center of the head?

func _process(delta):
	what_is_seeing = []
	
	var vision_angle_rads = deg2rad(vision_angle_degs)
	for i in range(vision_pixels):
		var local_ray_angle = float(i - vision_pixels/2) / vision_pixels * vision_angle_rads
		var global_ray_angle = local_ray_angle + global_rotation
		var local_direction = Vector2(cos(local_ray_angle), sin(local_ray_angle))
		var direction = Vector2(cos(global_ray_angle), sin(global_ray_angle))
		
		var space_state = get_world_2d().direct_space_state
		var ray_result = space_state.intersect_ray(global_position, global_position + direction * max_range, [get_parent()])
		
		if draw_rays:
			if ray_result.has("position"):
				draw_line(Vector2(0, 0), to_local(ray_result.get("position")), draw_color, 1.0, false)
				draw_circle(to_local(ray_result.get("position")), 4.0, draw_color)
				
				if draw_normals:
					draw_line(
						to_local(ray_result.get("position")),
						to_local(ray_result.get("position")) + ray_result.get("normal") * 15,
						Color.green,
						2.0)
			else:
				draw_line(Vector2(0, 0), local_direction * max_range, draw_color, 1.0, false)
		
		what_is_seeing.push_back(ray_result)
	
	emit_signal("change_what_is_seeing", what_is_seeing)
	
	if draw_rays:
		update()

func _draw():
	var vision_angle_rads = deg2rad(vision_angle_degs)
	for i in range(what_is_seeing.size()):
		if what_is_seeing[i].has("position"):
			var point = what_is_seeing[i].get("position") as Vector2
			draw_line(Vector2(0, 0), to_local(point), draw_color, 1.0, false)
			draw_circle(to_local(point), 4.0, draw_color)
			
			if draw_normals:
				var normal = what_is_seeing[i].get("normal")
				draw_line(
					to_local(point),
					to_local(point) + normal * 15,
					Color.green,
					2.0)
		else:
			var local_ray_angle = float(i - vision_pixels/2) / vision_pixels * vision_angle_rads
			var local_direction = Vector2(cos(local_ray_angle), sin(local_ray_angle))
			draw_line(Vector2(0, 0), local_direction * max_range / global_scale, draw_color, 1.0, false)
