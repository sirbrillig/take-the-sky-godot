shader_type canvas_item;

uniform float alpha;
uniform vec4 solid_color: source_color;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    COLOR = vec4(mix(texture_color.rgb, solid_color.rgb, alpha), texture_color.a);
}