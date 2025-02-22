shader_type spatial;
render_mode cull_disabled;

render_mode blend_mul;

void fragment() {
	
	ALPHA = 1.0;
}

void light() {
	float shadow = min(ALPHA, clamp(1.0 - length(ATTENUATION), 0.0, 1.0));
	DIFFUSE_LIGHT = ALBEDO;;
	DIFFUSE_LIGHT *= 0.3 * (1.0 - shadow*0.9);
	
	//DIFFUSE_LIGHT = vec3(1);
	//DIFFUSE_LIGHT += min(ALPHA, clamp(1.0 - length(ATTENUATION), 0.0, 1.0));
	//ALPHA = min(ALPHA, clamp(1.0 - length(ATTENUATION), 0.0, 1.0));
	//ALPHA = .1;
}