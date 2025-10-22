/// oMirrorTransition - Draw End  (overlay refraction; OUT=app surf, IN=cached surf)
if (phase == Phase.Idle) exit;

// If the application surface is missing, skip this frame safely.
if (!surface_exists(application_surface)) exit;

var dw = display_get_width();
var dh = display_get_height();

// ----------------------------------------
// IN LEG: ensure we have a cached scene from the *new* room,
// then use THAT for refraction so we never sample the previous room.
// ----------------------------------------
if (phase == Phase.In && !cache_ready) {
    // (Re)create cache if needed or size changed
    var need_new = (!surface_exists(surf_cache)) || (surface_get_width(surf_cache) != dw) || (surface_get_height(surf_cache) != dh);
    if (need_new) {
        if (surface_exists(surf_cache)) surface_free(surf_cache);
        surf_cache = surface_create(dw, dh);
    }
    if (surface_exists(surf_cache)) {
        surface_set_target(surf_cache);
        draw_clear_alpha(c_black, 0);
        // Copy the *current room* image into cache
        draw_surface(application_surface, 0, 0);
        surface_reset_target();
        cache_ready = true;
    }
}

// Compute progress for refraction (0→1 on OUT, 1→0 on IN)
var p = 0;
if (phase == Phase.Out) {
    var denom = max(1, abs(img_end - img_start));
    p = clamp((image_index - img_start) / denom, 0, 1);
} else if (phase == Phase.In) {
    var denom2 = max(1, abs(img_start - img_end));
    p = clamp((img_start - image_index) / denom2, 0, 1);
} else {
    p = 0;
}

// Strength — tune to taste after testing
var amount = 0.016 * p;

// Safe sampler state
gpu_set_texrepeat(false);
gpu_set_texfilter(false);

// Pick which surface to refract
var src_surf = application_surface;
if (phase == Phase.In && cache_ready && surface_exists(surf_cache)) {
    src_surf = surf_cache;
}

// Apply refraction shader as an overlay
var sh = sh_refraction_simple;
if (sh != -1) {
    shader_set(sh);
    var u_c = shader_get_uniform(sh, "u_center");
    var u_a = shader_get_uniform(sh, "u_amount");
    if (u_c != -1) shader_set_uniform_f(u_c, 0.5, 0.5);
    if (u_a != -1) shader_set_uniform_f(u_a, amount);

    // Inset 1px to avoid edge sampling (prevents texture page bleed)
    draw_surface_stretched(src_surf, 1, 1, dw - 2, dh - 2);

    shader_reset();
} else {
    draw_surface_stretched(src_surf, 0, 0, dw, dh);
}

// Restore defaults
gpu_set_texfilter(true);
gpu_set_texrepeat(false);

