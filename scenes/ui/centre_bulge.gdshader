shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;

uniform float strength = 0.35; // how strong the bulge is
uniform float radius   = 1.0;  // how far the effect reaches

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 centered = uv - vec2(0.5);
    float dist = length(centered);

    // Normalized radial distance
    float t = dist / radius;

    // Smooth S-curve remap (no stretching)
    float k = strength;
    float remapped = t + k * t * (1.0 - t);

    // Convert back to UV space
    float scale = (dist == 0.0) ? 1.0 : remapped / t;
    vec2 warped_uv = vec2(0.5) + centered * scale;

    // Clamp to avoid sampling outside screen
    warped_uv = clamp(warped_uv, vec2(0.0), vec2(1.0));

    COLOR = texture(screen_tex, warped_uv);
}