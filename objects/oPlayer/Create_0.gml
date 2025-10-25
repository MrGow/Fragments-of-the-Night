/// oPlayer — Create  (Space=jump, Z/X/mouse=attack)

// ---------------- Movement / control ----------------
stunned                 = false;
can_move                = true;
hsp                     = 0;
vsp                     = 0;

// ---------------- State / animation -----------------
state                   = "idle";
image_xscale            = 1;
attack_lock             = false;
attack_lock_frames      = 0;       // optional tiny frame-lock support

// ---------------- Typed Sprite lookup ----------------------
/// @func __spr
/// @param {string} _name
/// @return {Sprite}
function __spr(_name) {
    var s = asset_get_index(_name);  // generic Asset id
    return (s != -1) ? s : -1;       // typed by @return {Sprite}
}

// ---------------- Sprites (typed via __spr) ----------------
spr_idle        = __spr("spritePlayerIdle");
spr_run         = __spr("spritePlayerRun");
spr_jump        = __spr("spritePlayerJump");
spr_attack      = __spr("spriteSwordAttack"); // legacy single anim (kept if present)

// NEW: ledge + hurt/drink
spr_ledge_grab  = __spr("spritePlayerLedgeGrab");
spr_ledge_pull  = __spr("spritePlayerLedgePull");
spr_hurt        = __spr("spritePlayerHurt");   // may be -1 if not added yet
spr_drink       = __spr("spritePlayerDrink");  // optional

// Start in Idle if available
if (spr_idle != -1) { sprite_index = spr_idle; image_speed = 0.4; }

// ---------------- Movement tuning -------------------
move_speed              = 2.5;
jump_speed              = -4.0;    // up is negative
gravity_amt             = 0.2;
low_jump_multiplier     = 1.7;
fall_multiplier         = 1.5;
max_fall                = 8.0;

// --------------- Coyote / buffer (frames) -----------
coyote_time_frames      = 6;
jump_buffer_time_frames = 6;
coyote_timer            = 0;
jump_buffer_timer       = 0;

// ----------------- Attack gating --------------------
can_attack              = true;
attack_cooldown         = 0;
attack_end_fired        = false;
attack_anim_speed       = 1;
air_attack_drift        = 1.15;

// Legacy flag some code touches
if (!variable_instance_exists(id,"input_locked")) input_locked = false;

// --- Ensure a Combat companion exists and is bound to this player ---
if (instance_number(oPlayerCombat) == 0) {
    var _pc = instance_create_layer(x, y, layer, oPlayerCombat);
    _pc.owner = id;
    show_debug_message("[PC] Spawned oPlayerCombat and bound owner");
} else {
    var _pc2 = instance_nearest(x, y, oPlayerCombat);
    if (_pc2 != noone) { _pc2.owner = id; }
    show_debug_message("[PC] Rebound existing oPlayerCombat to player");
}

// ----------------- Ledge system -----------------
ledge_enabled     = true;
ledge_dir         = 1;
ledge_t           = 0;
ledge_pull_time   = 0.30;
ledge_start_x     = x;
ledge_start_y     = y;
ledge_target_x    = x;
ledge_target_y    = y;

// --- Misc lock helpers for hurt/drink ---
hurt_lock_frames_default = 10;
hurt_lock_timer          = 0;
