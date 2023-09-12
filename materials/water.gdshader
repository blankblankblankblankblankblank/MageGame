shader_type spatial;
uniform sampler2D text;

void fragment(){
	ALBEDO = texture(text,UV*(sin(TIME/40.0)-cos(TIME/41.0))).rgb * vec3(0.1,0.4,1.0);
	ALPHA = 0.25;
}

void vertex() {
	VERTEX.y += max(sin(texture(text,UV).r*TIME*4.0)*1.3,1.0);
}
