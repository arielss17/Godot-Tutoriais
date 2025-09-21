shader_type canvas_item;

const int t = 4;
uniform vec4 original_0 : source_color;
uniform vec4 original_1 : source_color;
uniform vec4 original_2 : source_color;
uniform vec4 original_3 : source_color;

uniform vec4 replace_0 : source_color;
uniform vec4 replace_1 : source_color;
uniform vec4 replace_2 : source_color;
uniform vec4 replace_3 : source_color;

const float precision = 0.1;

vec4 replace_color(vec4 color){
	vec4 original_colors[t] = vec4[t](original_0,original_1,original_2,original_3);
	vec4 replace_colors[t] = vec4[t](replace_0,replace_1,replace_2,replace_3);
	
	for(int i = 0; i < t;i++){
		if(distance(color,original_colors[i]) <= precision){
			color = replace_colors[i];
		}
	}
	return color;
}

void fragment() {
	COLOR = replace_color(texture(TEXTURE,UV));
}
