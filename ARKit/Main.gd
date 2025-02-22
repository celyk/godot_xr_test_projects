extends Node3D

var arkit = null
var anchor = preload("res://Anchor.tscn")

var _num_trackers := 0
func _on_tracker_added(p_name, p_type):
	if p_type == XRServer.TRACKER_ANCHOR:
		var tracker = XRServer.get_tracker(p_name)
		
		var p_id = 0
		var name = "anchor_" + p_name
		print("Adding " + name + " (" + p_name + ")")
		
		var new_anchor = anchor.instantiate()
		new_anchor.tracker = p_name
		new_anchor.name = name
		#new_anchor.pose = "default"
		
		if tracker.get_class() == "ARKitAnchorMesh":
			print("Yes, tracker is an ARKitAnchorMesh")
			var mesh_instance := MeshInstance3D.new()
			mesh_instance.mesh = tracker.mesh
			print("Tracker mesh: ", tracker.mesh)
			#print("Tracker facees: ", tracker.mesh.get_faces())
			#new_anchor.add_child(mesh_instance)
			
			#XRServer.tracker_updated.connect(new_anchor.on_ARVRAnchor_mesh_updated)
		
		$XROrigin3D.add_child(new_anchor)

func _on_tracker_updated(tracker_name: StringName, type: int):
	print("tracker_upated")
	if type == XRServer.TRACKER_ANCHOR:
		var tracker = XRServer.get_tracker(tracker_name)
		if tracker.get_class() == "ARKitAnchorMesh":
			print("Yes, tracker updating")

func _on_tracker_removed(p_name, p_type):
	if p_type == XRServer.TRACKER_ANCHOR:
		var p_id = 0
		var name = "anchor_" + p_name
		print("Removing " + name + " (" + p_name + ")")

		var old_anchor = $XROrigin3D.find_child(name, false, false)
		if old_anchor:
			$XROrigin3D.remove_child(old_anchor)
		else:
			print("Couldn't find " + name)

func _ready():
	# Register some signals we need
	XRServer.connect("tracker_added", Callable(self, "_on_tracker_added"))
	XRServer.connect("tracker_updated", Callable(self, "_on_tracker_updated"))
	XRServer.connect("tracker_removed", Callable(self, "_on_tracker_removed"))
	
	# Hide our godotballs for now
	$GodotBalls.visible = false
	
	# Called every time the node is added to the scene.
	# Initialization here
	arkit = XRServer.find_interface('ARKit')
	if arkit:
		print("Found ARKit")
		arkit.initialize()
		
		arkit.ar_is_anchor_detection_enabled = true
		get_node("toggle_plane_detection").set_text("Turn plane detection off")
		
		# we're doing AR :)
		get_viewport().use_xr = true
		
		# make sure our environment is set to the right camera feed
		get_viewport().get_camera_3d().environment.background_camera_feed_id = arkit.get_camera_feed_id()
	else:
		print("Couldn't find ARKit")
		get_node("toggle_plane_detection").set_text("No ARKIT")


func _on_toggle_plane_detection():
	if arkit:
		if (arkit.ar_is_anchor_detection_enabled):
			arkit.ar_is_anchor_detection_enabled = false
			get_node("toggle_plane_detection").set_text("Turn plane detection on")
		else:
			arkit.ar_is_anchor_detection_enabled = true
			get_node("toggle_plane_detection").set_text("Turn plane detection off")
			
func _process(delta):
	var info_text = "FPS: " + str(Engine.get_frames_per_second()) + "\n"

	if arkit:
		var status = arkit.get_tracking_status() 
		if status == 4:
			info_text += "Not tracking, move your device around for ARKit to detect features\n"
		elif status == 0:
			info_text += "Tracking a-ok\n"
		elif status == 1:
			info_text += "Insufficient tracking, moving your device to fast\n"
		elif status == 2:
			info_text += "Insufficient features, move further away or improve lighting conditions\n"
		else:
			info_text += "Unknown tracking status\n"
			
	$Info.text = info_text

func _input(event):
	if event.is_class("InputEventMouseButton") and event.pressed:
		var camera = get_node("XROrigin3D/XRCamera3D")
		var space = camera.get_world_3d().get_space()
		var state = PhysicsServer3D.space_get_direct_state(space)
		
		var from = camera.project_ray_origin(event.position)
		var direction = camera.project_ray_normal(event.position)
		
		var ray_query := PhysicsRayQueryParameters3D.create(from, from + (direction * 100.0))
		var result = state.intersect_ray(ray_query)
		if !result.is_empty():
			var transform = Transform3D()
			
			# position at our intersection point
			transform.origin = result["position"]
			
			# and apply to our godot balls
			$GodotBalls.global_transform = transform
			$GodotBalls.visible = true
