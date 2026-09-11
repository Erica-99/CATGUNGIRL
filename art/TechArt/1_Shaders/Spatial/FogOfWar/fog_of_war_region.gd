@tool
class_name FogOfWarRegion
extends Area3D


const GROUP := &"fog_of_war_region"

@export var region_id: String = ""

@export_group("Falloff")
@export_range(0.0, 60.0, 0.1) var feather: float = 6.0
@export_range(0.0, 200.0, 0.1) var prox_inner: float = 4.0
@export_range(0.0, 200.0, 0.1) var prox_outer: float = 30.0
@export_range(0.0, 1.0, 0.01) var neighbour_max: float = 0.55

@export_group("Timing")
@export_range(0.0, 30.0, 0.1) var exit_padding: float = 2.0
@export_range(0.01, 5.0, 0.01) var reveal_in_time: float = 0.25
@export_range(0.01, 10.0, 0.01) var reveal_out_time: float = 1.2

var reveal: float = 0.0

var _centre := Vector3.ZERO
var _extents := Vector3.ONE
var _occupied := false
var _forced := false


func _ready() -> void:
	add_to_group(GROUP)
	if Engine.is_editor_hint():
		return
	monitoring = false


func _find_shape_node() -> CollisionShape3D:
	for child in get_children():
		if child is CollisionShape3D:
			return child
	return null


func refresh_bounds(z_center: float, z_extent: float) -> void:
	var shape_node := _find_shape_node()
	if shape_node == null or shape_node.shape is not BoxShape3D:
		return
	var xform := shape_node.global_transform
	var basis_scale := xform.basis.get_scale().abs()
	_centre = Vector3(xform.origin.x, xform.origin.y, z_center)
	var size := (shape_node.shape as BoxShape3D).size * 0.5 * basis_scale
	_extents = Vector3(size.x, size.y, z_extent)


func signed_distance(point: Vector3) -> float:
	var q := (point - _centre).abs() - _extents
	var outside := Vector3(maxf(q.x, 0.0), maxf(q.y, 0.0), maxf(q.z, 0.0)).length()
	var inside := minf(maxf(q.x, maxf(q.y, q.z)), 0.0)
	return outside + inside


func update_reveal(delta: float, player_position: Vector3, has_player: bool) -> void:
	var target := 0.0
	if has_player:
		var distance := signed_distance(player_position)
		if distance <= 0.0:
			_occupied = true
		elif distance > exit_padding:
			_occupied = false
			_forced = false
		var proximity := 1.0 - smoothstep(prox_inner, prox_outer, distance)
		var occupancy := 1.0 if (_occupied or _forced) else 0.0
		target = maxf(neighbour_max * proximity, occupancy)

	var duration := reveal_in_time if target > reveal else reveal_out_time
	if duration <= 0.0:
		reveal = target
	else:
		reveal = move_toward(reveal, target, delta / duration)


func force_reveal() -> void:
	_forced = true


func get_gpu_bounds() -> Vector4:
	return Vector4(_centre.x, _centre.y, _extents.x, _extents.y)
