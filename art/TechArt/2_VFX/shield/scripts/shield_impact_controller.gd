class_name ShieldImpactController
extends Node3D

signal impact_registered(world_point: Vector3, world_normal: Vector3)

@export var base_mesh_path: NodePath = ^"base/shield_base_icosphere"
@export var impact_particles_path: NodePath = ^"ImpactParticles"
@export var animation_player_path: NodePath = ^"AnimationPlayer"
@export var particles_enabled: bool = true
@export var merge_same_frame: bool = true
@export var unique_materials_per_instance: bool = true
@export var debug_enabled: bool = false
@export var debug_shield_radius: float = 0.97

const IMPACT_ANIM := &"impact"

var _base_mesh: MeshInstance3D
var _base_mat: ShaderMaterial
var _particles: Node3D
var _anim: AnimationPlayer

var _pending_points: PackedVector3Array = PackedVector3Array()
var _pending_normals: PackedVector3Array = PackedVector3Array()
var _flush_queued: bool = false


func _ready() -> void:
	_base_mesh = get_node_or_null(base_mesh_path) as MeshInstance3D
	if _base_mesh != null:
		_base_mat = _base_mesh.material_override as ShaderMaterial
		if unique_materials_per_instance and _base_mat != null:
			_base_mat = _base_mat.duplicate()
			_base_mesh.material_override = _base_mat
	if _base_mat == null:
		push_warning("ShieldImpactController: no shield material found at %s" % base_mesh_path)
	else:
		_base_mat.set_shader_parameter("hit_age", -1.0)
	_particles = get_node_or_null(impact_particles_path) as Node3D
	if _particles == null:
		push_warning("ShieldImpactController: no particle rig at %s" % impact_particles_path)
	elif not particles_enabled:
		_particles.visible = false
	_anim = get_node_or_null(animation_player_path) as AnimationPlayer
	if _anim == null:
		push_warning("ShieldImpactController: no AnimationPlayer at %s" % animation_player_path)
	set_process_unhandled_input(debug_enabled)


func register_impact(world_point: Vector3, world_normal: Vector3 = Vector3.ZERO) -> void:
	_pending_points.append(world_point)
	_pending_normals.append(world_normal)
	if not _flush_queued:
		_flush_queued = true
		_flush_pending.call_deferred()


func _flush_pending() -> void:
	_flush_queued = false
	var count := _pending_points.size()
	if count == 0:
		return
	var point := _pending_points[count - 1]
	var normal := _pending_normals[count - 1]

	if merge_same_frame and count > 1:
		var centroid := Vector3.ZERO
		for p in _pending_points:
			centroid += to_local(p)
		centroid /= float(count)
		var surface_dist := to_local(point).length()
		if centroid.length() > 0.05 and surface_dist > 0.001:
			point = to_global(centroid.normalized() * surface_dist)
			normal = Vector3.ZERO

	if normal == Vector3.ZERO:
		normal = (point - global_position).normalized()
		if normal.is_zero_approx():
			normal = Vector3.UP

	if _base_mat != null:
		var local_point := _base_mesh.to_local(point) if _base_mesh != null else to_local(point)
		_base_mat.set_shader_parameter("hit_position", local_point)

	if particles_enabled and _particles != null:
		var up := Vector3.UP if absf(normal.y) < 0.99 else Vector3.RIGHT
		_particles.look_at_from_position(point, point + normal, up)

	if _anim != null:
		_anim.stop()
		_anim.play(IMPACT_ANIM)
		_anim.advance(0.0)

	impact_registered.emit(point, normal)
	_pending_points.clear()
	_pending_normals.clear()


func _unhandled_input(event: InputEvent) -> void:
	if not debug_enabled:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_debug_fire(event.position)


func _debug_fire(screen_pos: Vector2) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var ro := cam.project_ray_origin(screen_pos)
	var rd := cam.project_ray_normal(screen_pos)
	var c := global_position
	var r := debug_shield_radius * global_transform.basis.get_scale().x
	var oc := ro - c
	var b := oc.dot(rd)
	var cc := oc.dot(oc) - r * r
	var disc := b * b - cc
	if disc < 0.0:
		return
	var t := -b - sqrt(disc)
	if t < 0.0:
		return
	var p := ro + rd * t
	register_impact(p, (p - c).normalized())
