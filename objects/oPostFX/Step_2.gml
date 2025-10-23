/// oPostFX: End Step
_time += delta_time * 0.001;

switch (global.vfx_quality) {
    case 0:
        fx_use_lut = fx_use_fog = fx_use_vign_grain = false;
        break;
    case 1:
        lut_strength      = 0.18;
        grain_strength    = 1;
        fog_strength      = 0.15;
        vignette_strength = 0.35;
        break;
    case 2:
        // keep the stronger debug values for now
        break;
}
