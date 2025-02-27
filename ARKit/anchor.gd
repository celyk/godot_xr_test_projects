extends XRAnchor3D

@export var material: Material = null: get = get_material, set = set_material
#var anchor_id : int = 0

func set_material(p_new_material):
	material = p_new_material
	if is_inside_tree() and $MeshInstance3D.mesh:
		$MeshInstance3D.set_surface_override_material(0, material)

func get_material():
	return material

func _ready() -> void:
	XRServer.tracker_updated.connect(on_ARVRAnchor_mesh_updated)

func on_ARVRAnchor_mesh_updated(tracker_name: StringName, type: int):
	if tracker_name != tracker: return
	
	var my_tracker : XRTracker = XRServer.get_tracker(tracker_name)
	
	var mesh : Mesh
	if my_tracker.get_class() == "ARKitAnchorMesh":
		mesh = my_tracker.mesh
		print(mesh)
	
	if mesh:
		# update our mesh
		$MeshInstance3D.mesh = mesh
		$MeshInstance3D.set_surface_override_material(0, material)
		$MeshInstance3D.visible = true
		
		# update our collision shape
		$StaticBody3D/CollisionShape3D.shape = mesh.create_trimesh_shape()
		$StaticBody3D/CollisionShape3D.disabled = false
	else:
		$MeshInstance3D.visible = false
		$StaticBody3D/CollisionShape3D.disabled = true
		
