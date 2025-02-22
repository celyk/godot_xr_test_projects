shader_type spatial;

render_mode unshaded;
render_mode cull_disabled;
render_mode skip_vertex_transform;

uniform sampler2D camera_y : repeat_disable;
uniform sampler2D camera_CbCr : repeat_disable;

uniform mat4 feed_transform = mat4(1);

void vertex() {
	UV = VERTEX.xy * 0.5 + 0.5;
	VERTEX.xy = mat2(feed_transform) * VERTEX.xy;

	// Far plane
	VERTEX.z = CLIP_SPACE_FAR + 0.0001;

	POSITION = vec4(VERTEX,1);
}

void fragment() {
	vec2 uv = UV;

	vec3 color = vec3(0);
	color.r = texture(camera_y, uv).r;
	color.gb = texture(camera_CbCr, uv).rg - vec2(0.5, 0.5);

	// YCbCr -> SRGB conversion
	// Using BT.709 which is the standard for HDTV
	color.rgb = mat3(
						vec3(1.00000, 1.00000, 1.00000),
						vec3(0.00000, -0.18732, 1.85560),
						vec3(1.57481, -0.46813, 0.00000)) *
				color.rgb;

	/*if(OUTPUT_IS_SRGB){
		// sRGB to linear conversion
		color.rgb = pow(color.rgb, vec3(2.2));
	}*/

	ALBEDO.rgb = color.rgb;

	//ALBEDO = vec3(uv,0);
}