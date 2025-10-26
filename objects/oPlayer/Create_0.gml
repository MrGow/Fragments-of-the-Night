/// oPlayer — Create  (typed sprites, stable mask, tunables, ledge cooldowns)

// ---------- Typed Sprite lookup ----------
/**
 * @func __spr
 * @param {string} _name
 * @return {Asset.GMSprite}
 */
function __spr(_name) {
    var s = asset_get_index(_name);   // generic Asset id
    return (s != -1) ? s : -1;        // typed by @return
}

// ---------- Sprites (typed via __spr) ----------
/** @type {Asset.GMSprite} */ spr_idle       = __spr("spritePlayerIdle");
/** @type {Asset.GMSprite} */ spr_run        = __spr("spritePlayerRun");
/** @type {Asset.GMSprite} */ spr_jump       = __spr("spritePlayerJump");
/** @type {Asset.GMSprite} */ spr_attack     = __spr("spriteSwordAttack");   // optional legacy
/** @type {Asset.GMSprite} */ spr_ledge_grab = __spr("spritePlayerLedgeGrab");
/** @type {Asset.GMSprite} */ spr_ledge_pull = __spr("spritePlayerLedgePull");
/** @type {Asset.GMSprite} */ spr_hurt       = __spr("spritePlayerHurt");
/** @type {Asset.GMSprite} */ spr_drink      = __spr("spritePlayerDrink");

// Dedicated collision mask so bbox_* stays stable across animations
/** @type {Asset.GMSprite} */ var __sprMask = __spr("spritePlayerCollisionMask");
if (__sprMask != -1) mask_index = __sprMask;

// Start in Idle if available
if (spr_idle != -1) { sprite_index = spr_idle; image_speed = 0.4; }

// ---------- Movement / control ----------
stunned  = false;
can_move = true;
hsp = 0;
vsp = 0;

// ---------- State / animation ----------
state               = "idle";
image_xscale        = 1;
attack_lock         = false;
attack_lock_frames  = 0;
attack_anim_speed   = 1; // read by oPlayerCombat

// ---------- Movement tuning ----------
move_speed          = 2.5;
jump_speed          = -4.0;   // up is negative
gravity_amt         = 0.2;
low_jump_multiplier = 1.7;
fall_multiplier     = 1.5;
max_fall            = 8.0;

// ---------- Coyote / buffer (frames) ----------
coyote_time_frames      = 6;
jump_buffer_time_frames = 6;
coyote_timer            = 0;
jump_buffer_timer       = 0;

// ---------- Attack gating ----------
can_attack       = true;
attack_cooldown  = 0;
attack_end_fired = false;
air_attack_drift = 1.15;

// Legacy lock
if (!variable_instance_exists(id,"input_locked")) input_locked = false;

// Ensure a Combat companion exists and is bound to this player
if (instance_number(oPlayerCombat) == 0) {
    var _pc = instance_create_layer(x, y, "Actors", oPlayerCombat);
    _pc.owner = id;
} else {
    var _pc2 = instance_nearest(x, y, oPlayerCombat);
    if (_pc2 != noone) _pc2.owner = id;
}

// ---------- Ledge system defaults (tuned for 30×46 mask) ----------
ledge_enabled       = true;
ledge_dir           = 1;
ledge_t             = 0;
ledge_pull_time     = 0.30;
ledge_start_x       = x;
ledge_start_y       = y;
ledge_target_x      = x;
ledge_target_y      = y;
ledge_regrab_cd     = 0;
ledge_grab_grace    = 0;
ledge_nojump_frames = 0; // blocks buffered/coyote jumps right after ledge states

// Tunables
LG_GRAB_MAX_GAP_PX   = 1;
LG_HEAD_CLEAR_PX     = 9;
LG_MAX_LIP_SEARCH_PX = 16;
LG_MAX_DROP_TO_LIP   = 3;
LG_MAX_RISE_TO_LIP   = 14;
LG_PULL_FWD_X_PX     = 11;   // mostly superseded by computed landing
LG_PULL_UP_Y_PX      = 26;   // crest 1-tile lips cleanly
LG_PULL_TIME_S       = 0.30;
LG_PULL_SEGMENTS     = 10;
LG_REGRAB_COOLDOWN   = 10;
LG_PULL_SYNC_TO_ANIM = true;

// Hurt helpers
hurt_lock_frames_default = 10;
hurt_lock_timer          = 0;
last_seen_hurt_pulse     = (variable_global_exists("_hurt_pulse_id") ? global._hurt_pulse_id : 0);

// Tilemap handle
if (!variable_global_exists("tm_solids")) global.tm_solids = undefined;
