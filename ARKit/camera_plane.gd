extends GeometryInstance3D

var index := 0

@onready var xr_origin_3d: XROrigin3D = $"../.."
@onready var xr_camera_3d: XRCamera3D = $".."

var _prev_camera_transform : Transform3D
var _prev_projection : Projection
var desired_camera_transform : Transform3D

func _process(delta: float) -> void:
#func _ready() -> void:
	_setup_feed()

func _setup_feed():
	var camera : CameraFeed
	var feed_id := 0
	
	var arkit = XRServer.find_interface('ARKit')
	if CameraServer.get_feed_count():
		camera = CameraServer.feeds()[index % CameraServer.get_feed_count()]
		camera.feed_is_active = true
		feed_id = camera.get_id()
	else:
		print("no feeds found")
		if arkit == null:
			return
		
		#camera = CameraServer.get_feed(arkit.get_camera_feed_id())
		feed_id = arkit.get_camera_feed_id()
	
	if camera:
		#print("using camera ", camera, " (", camera.get_name(), ")")
		pass
	
	#print("using camera feed ", feed_id)
	
	
	
	var camera_y := CameraTexture.new()
	var camera_CbCr := CameraTexture.new()
	
	camera_y.camera_feed_id = feed_id
	camera_CbCr.camera_feed_id = feed_id
	
	camera_y.which_feed = CameraServer.FEED_Y_IMAGE
	camera_CbCr.which_feed = CameraServer.FEED_CBCR_IMAGE
	
	camera_y.camera_is_active = true
	camera_CbCr.camera_is_active = true
	
	#$ColorRect.material.set("shader_parameter/camera_y", camera_y)
	#$ColorRect.material.set("shader_parameter/camera_CbCr", camera_CbCr)
	var material : ShaderMaterial = material_override
	material.set_shader_parameter("camera_y", camera_y)
	material.set_shader_parameter("camera_CbCr", camera_CbCr)
	#material.set_shader_parameter("viewport_size", get_viewport().size)
	
	material.set_shader_parameter("feed_transform", camera.feed_transform)
