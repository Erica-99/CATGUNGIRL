shader_type canvas_item;

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

void fragment()
{
    // Auto-detect pixel size of the TextureRect's texture
    vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));

    float r = texture(TEXTURE, UV + pixel_size * r_displacement).r;
    float g = texture(TEXTURE, UV + pixel_size * g_displacement).g;
    float b = texture(TEXTURE, UV + pixel_size * b_displacement).b;

    COLOR = vec4(r, g, b, 1.0);
}

