/// oPostFX: Create
application_surface_enable(true);
// IMPORTANT: keep auto draw ON while we debug
application_surface_draw_enable(true);

persistent = true;

// Quality: 0=Off, 1=Low, 2=High
global.vfx_quality = 1;

// Toggles (start obvious so you can see it)
fx_use_lut        = false; // enable later after adding sLUT
fx_use_fog        = false;
fx_use_vign_grain = false;

// Internal target resolution (your base camera)
_sW = 640;
_sH = 360;

// Surfaces
_surfA = -1;
_surfB = -1;
_lastGood = -1;

// Time
_time = 0;

// Shader resource handles (use resource constants, don't assign to them)
sh_lut_id        = sh_lut;
sh_vign_grain_id = sh_vign_grain;
sh_fog_dither_id = sh_fog_dither;

// LUT params (only used if fx_use_lut=true and sLUT exists)
lut_tex      = -1;       // set to sprite_get_texture(sLUT,0) when you import sLUT
lut_rows     = 16.0;
lut_strength = 0.25;

// Effect strengths (start strong to be obvious)
vignette_strength = 0.;
grain_strength    = 0.2
fog_strength      = 0;
fog_y_start       = 0;
fog_y_end         = _sH;

// Create our ping-pong surfaces
function _surface_recreate() {
    if (surface_exists(_surfA)) surface_free(_surfA);
    if (surface_exists(_surfB)) surface_free(_surfB);
    _surfA = surface_create(_sW, _sH);
    _surfB = surface_create(_sW, _sH);
}
_surface_recreate();
