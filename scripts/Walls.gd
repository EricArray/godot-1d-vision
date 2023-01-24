extends TileMap

export var wall_tile_size := 16

# colors of each side depending from where the camera is looking
export var color_down = Color(1.0, 1.0, 0.0)
export var color_left = Color(1.0, 1.0, 0.0)
export var color_right = Color(1.0, 1.0, 0.0)
export var color_up = Color(1.0, 1.0, 0.0)

export var tiled_wall_modulate = Color.white

export var ambient_occlusion := true
export var ambient_occlusion_strength := 0.5

func get_color_at(global_point: Vector2, normal: Vector2) -> Color:
	var color = get_base_color(global_point, normal)
	
	if ambient_occlusion:
		var ao = get_ambient_occlusion_at(global_point, normal)
		color = color * Color(1.0 - ao, 1.0 - ao, 1.0 - ao)
	
	return color


func get_base_color(global_point: Vector2, normal: Vector2) -> Color:
	var color = get_color_of_side(normal)

	global_point = global_point + normal
	var col = floor(global_point.x / wall_tile_size)
	var row = floor(global_point.y / wall_tile_size)
	var variant = int(col + row) % 2
	
	if variant == 0:
		return color * tiled_wall_modulate
	
	return color


func get_color_of_side(normal: Vector2) -> Color:
	match normal:
		Vector2(0, 1):
			return color_right
		Vector2(0, -1):
			return color_left
		Vector2(1, 0):
			return color_down
		Vector2(-1, 0):
			return color_up
		_:
			return Color(1.0, 1.0, 1.0)


func get_ambient_occlusion_at(global_point: Vector2, normal: Vector2) -> float:
	var map_position = world_to_map(to_local(global_point - normal))
	
	var corners = get_two_corners(map_position, normal)

	var p = to_local(global_point)/64
	var c1 = corners[0] as Vector2
	var c2 = corners[1] as Vector2
	var ao1 = get_ambient_occlusion_at_corner(c1)
	var ao2 = get_ambient_occlusion_at_corner(c2)
	
	var d1 = (p - c1).length_squared()
	var d2 = (p - c2).length_squared()
	
	return (
		ambient_occlusion_strength *
		(
			ao1 * pow(d2/(d1 + d2), 2) +
			ao2 * pow(d1/(d1 + d2), 2)
		)
	)


const CORNER_UP_LEFT = Vector2(0, 0)
const CORNER_DOWN_LEFT = Vector2(0, 1)
const CORNER_UP_RIGHT = Vector2(1, 0)
const CORNER_DOWN_RIGHT = Vector2(1, 1)

func get_two_corners(map_position: Vector2, normal: Vector2) -> Array:
	# TODO: proof this by round normal
	match normal:
		Vector2(0, 1):
			return [map_position + CORNER_DOWN_LEFT, map_position + CORNER_DOWN_RIGHT]
		Vector2(0, -1):
			return [map_position + CORNER_UP_LEFT, map_position + CORNER_UP_RIGHT]
		Vector2(1, 0):
			return [map_position + CORNER_UP_RIGHT, map_position + CORNER_DOWN_RIGHT]
		Vector2(-1, 0), _:
			return [map_position + CORNER_DOWN_LEFT, map_position + CORNER_UP_LEFT]

var ambient_occlusion_cache = {}
func get_ambient_occlusion_at_corner(corner: Vector2) -> float:
	if not ambient_occlusion_cache.has(corner):
		ambient_occlusion_cache[corner] = get_ambient_occlusion_at_corner_impl(corner)
		
	return ambient_occlusion_cache.get(corner)
	
func get_ambient_occlusion_at_corner_impl(corner: Vector2) -> float:
	# diagonal
	if (
		(is_wall(corner + Vector2(-1, -1)) and is_wall(corner + Vector2(0, 0))) or
		(is_wall(corner + Vector2(-1, 0)) and is_wall(corner + Vector2(0, -1)))
	):
		return 1.0
	
	# ortogonal
	if (
		(is_wall(corner + Vector2(-1, -1)) and is_wall(corner + Vector2(-1, 0))) or
		(is_wall(corner + Vector2(0, -1)) and is_wall(corner + Vector2(0, 0))) or
		(is_wall(corner + Vector2(-1, -1)) and is_wall(corner + Vector2(0, -1))) or
		(is_wall(corner + Vector2(-1, 0)) and is_wall(corner + Vector2(0, 0)))
	):
		return 0.5
	
	return 0.0


# TODO: may return empty on the exact corners
var is_wall_cache = {}
func is_wall(map_position: Vector2) -> bool:
	if not is_wall_cache.has(map_position):
		is_wall_cache[map_position] = tile_set.tile_get_name(get_cellv(map_position)) == 'wall'
	return is_wall_cache.get(map_position)
