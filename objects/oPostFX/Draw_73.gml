/// oPostFX: Draw End  — build passes only (no present)
if (!surface_exists(_surfA) || !surface_exists(_surfB)) {
    // device reset or surface lost
    var was = _lastGood;
    _surface_recreate();
    _lastGood = was; // keep last reference if any
}

var haveApp = surface_exists(application_surface);
if (!haveApp) {
    // nothing to process; keep last good
    exit;
}

// 1) Copy app surface → _surfA at base res
surface_set_target(_surfA);
draw_clear_alpha(c_black, 0);
draw_surface_stretched(application_surface, 0, 0, _sW, _sH);
surface_reset_target();

var src = _surfA;
var dst = _surfB;

// 2) LUT (optional)
if (fx_use_lut && sh_lut_id != -1 && lut_tex != -1) {
    shader_set(sh_lut_id);
    var s_lut      = shader_get_sampler_index(sh_lut_id, "u_LUT");
    var u_rows     = shader_get_uniform(sh_lut_id, "u_LUTRows");
    var u_strength = shader_get_uniform(sh_lut_id, "u_Strength");
    texture_set_stage(s_lut, lut_tex);
    shader_set_uniform_f(u_rows, lut_rows);
    shader_set_uniform_f(u_strength, lut_strength);

    surface_set_target(dst);
    draw_clear_alpha(c_black, 0);
    draw_surface(src, 0, 0);
    surface_reset_target();
    shader_reset();

    var t = src; src = dst; dst = t;
}

// 3) Fog/Dither
if (fx_use_fog && sh_fog_dither_id != -1) {
    shader_set(sh_fog_dither_id);
    var u_time   = shader_get_uniform(sh_fog_dither_id, "u_Time");
    var u_params = shader_get_uniform(sh_fog_dither_id, "u_Params"); // yStart,yEnd,strength,pad
    shader_set_uniform_f(u_time, _time);
    shader_set_uniform_f_array(u_params, [fog_y_start, fog_y_end, fog_strength, 0]);

    surface_set_target(dst);
    draw_clear_alpha(c_black, 0);
    draw_surface(src, 0, 0);
    surface_reset_target();
    shader_reset();

    var t2 = src; src = dst; dst = t2;
}

// 4) Vignette + Grain
if (fx_use_vign_grain && sh_vign_grain_id != -1) {
    shader_set(sh_vign_grain_id);
    var u_time = shader_get_uniform(sh_vign_grain_id, "u_Time");
    var u_vs   = shader_get_uniform(sh_vign_grain_id, "u_VigStrength");
    var u_gs   = shader_get_uniform(sh_vign_grain_id, "u_GrainStrength");
    var u_res  = shader_get_uniform(sh_vign_grain_id, "u_Resolution");
    shader_set_uniform_f(u_time, _time);
    shader_set_uniform_f(u_vs, vignette_strength);
    shader_set_uniform_f(u_gs, grain_strength);
    shader_set_uniform_f_array(u_res, [_sW, _sH]);

    surface_set_target(dst);
    draw_clear_alpha(c_black, 0);
    draw_surface(src, 0, 0);
    surface_reset_target();
    shader_reset();

    var t3 = src; src = dst; dst = t3;
}

// Save for GUI present + other systems (mirror)
_lastGood = src;

// Publish globals so oMirrorTransition can sample the processed frame
global.postfx_ready   = surface_exists(_lastGood);
global.postfx_surface = _lastGood;
global.postfx_w       = _sW;
global.postfx_h       = _sH;
