/// oGame — Create  (persistent; no closures = no GM1049)

// --- Singleton / persistence ---
persistent = true;
if (instance_number(oGame) > 1) { instance_destroy(); exit; }

application_surface_enable(true);

// --- Init globals for pause/UI (kept from your code) ---
if (!variable_global_exists("paused"))        global.paused = false;
if (!variable_global_exists("pause_menu_id")) global.pause_menu_id = noone;

can_toggle = true; // debounce for pause toggle

// ===================== HP / Flask SYSTEM (NEW) =====================

// Core player stats (session truth)
global.max_hp      = 10;
global.hp          = global.max_hp;

global.flask_max   = 3;
global.flask_stock = 1;
global.heal_amount = 3;

// Damage & state
global.iframes_time   = 22;
global._iframes_timer = 0;
global.dead           = false;

// HUD / VFX signals (reset each Step)
global._hp_changed_this_step = 0;  // negative on hurt, positive on heal
global._healed_this_step     = false;
global._hurt_this_step       = false;

// Drink lock (prevents attack/roll while “drinking”)
global._drinking_timer = 0;
global._drink_lockout  = 14;

// Checkpoint (altar will set later)
global.checkpoint_room = noone;
global.checkpoint_x    = 0;
global.checkpoint_y    = 0;
// ==================================================================
