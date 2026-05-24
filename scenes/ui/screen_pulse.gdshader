shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest;

uniform float base_strength = 0.03;
uniform float pulse_strength = 0.12;
uniform float pulse_speed = 2.5;
uniform float focus_radius = 0.4;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Centered coordinate system
    vec2 centered = uv - vec2(0.5, 0.5);
    float dist = length(centered);

    // Breathing pulse
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

    // Outward bulge strength
    float strength = base_strength + pulse * pulse_strength;

    // Mask: 1 at center → 0 at focus_radius
    float center_mask = 1.0 - smoothstep(0.0, focus_radius, dist);

    // Final distortion strength
    strength *= center_mask;

    // OUTWARD bulge using centered vector (NOT normalize)
    vec2 offset = centered * strength;

    vec2 warped_uv = uv + offset;

    COLOR = texture(screen_tex, warped_uv);
}
