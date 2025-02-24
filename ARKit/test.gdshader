shader_type spatial;

render_mode cull_disabled, shadows_disabled, unshaded;

void vertex() {
	VERTEX *= 0.3;
	//VERTEX.z += 0.5;
	//POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * (VERTEX,1);
}

void fragment() {
	// Called for every pixel the material is visible on.
	/*EMISSION += .3;

	if(!FRONT_FACING){
		EMISSION.x += .3;
	}*/

	ALBEDO = vec3(1) * FRAGCOORD.z;
	if (SCREEN_UV.x<0.2) {
		ALBEDO = vec3(1);
		if (SCREEN_UV.y<0.5) ALBEDO = vec3(0);
	}
}