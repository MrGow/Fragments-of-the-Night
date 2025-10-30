/// oGame — Create  (persistent; crisp pixels, integer scaling, HUD lock)
// Single-instance guard
persistent = true;
if (instance_number(oGame) > 1) { instance_destroy(); exit; }

// -------- Render/Base sizing --------
var base_w = 640, base_h = 360;  // logical/internal resolution
var scale  = 2;                  // 1, 2, 3... (integer only)

// Camera may not be ready in Create on some runtimes—guard it.
var cam_ok = (array_length_1d(view_camera) > 0) && (view_camera[0] != -1);
if (cam_ok) {
    camera_set_view_size(view_camera[0], base_w, base_h);
}

// Window to integer multiple of base (prevents dropped pixel columns/rows)
window_set_size(base_w * scale, base_h * scale);

// Crisp pixels (nearest-neighbor) & ensure app surface exists
gpu_set_texfilter(false);
application_surface_enable(true);

// (Optional) If something resized the app surface earlier, force it to base.
if (surface_exists(application_surface)) {
    surface_resize(application_surface, base_w, base_h);
}

// Lock GUI to the same logical size so HUD stays sharp
// Let GUI match the window; HUD normalizes itself in Draw GUI
display_set_gui_maximize(true);


// Project option to double-check in editor (no code): 
// Project → Options → Graphics → Interpolate colours between pixels = OFF.

// -------- Gameplay globals --------
global.FLOOR_BASE_FROM_TOP = 32; // for 32px tiles; adjust if your art changes

// Pause/UI state
if (!variable_global_exists("paused"))        global.paused = false;
if (!variable_global_exists("pause_menu_id")) global.pause_menu_id = noone;
can_toggle = true; // debounce for pause toggle

// ===================== HP / Flask SYSTEM =====================
global.max_hp      = 10;
global.hp          = global.max_hp;

global.flask_max   = 3;
global.flask_stock = 1;
global.heal_amount = 3;

global.iframes_time   = 44; // extended i-frames per earlier tuning
global._iframes_timer = 0;
global.dead           = false;

// HUD / VFX signals (reset each Step)
global._hp_changed_this_step = 0;   // negative on hurt, positive on heal
global._healed_this_step     = false;
global._hurt_this_step       = false;

// Drink lock (prevents attack/roll while “drinking”)
global._drinking_timer = 0;
global._drink_lockout  = 14;

// Checkpoint (altar will set later)
global.checkpoint_room = noone;
global.checkpoint_x    = 0;
global.checkpoint_y    = 0;
// ==============================================================
