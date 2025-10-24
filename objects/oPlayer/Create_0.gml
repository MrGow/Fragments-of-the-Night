/// oPlayer — Create  (Space=jump, Z/X/mouse=attack)
use_player_step_attacks = false; // Combat is handled by oPlayerCombat

// ---------------- Movement / control ----------------
stunned                 = false;
can_move                = true;
hsp                     = 0;
vsp                     = 0;

// ---------------- State / animation -----------------
state                   = "idle";
image_xscale            = 1;
attack_lock             = false;
attack_lock_frames      = 0;

// ---------------- Sprites (look up by name) ----------------------
spr_idle     = asset_get_index("spritePlayerIdle");
spr_run      = asset_get_index("spritePlayerRun");
spr_jump     = asset_get_index("spritePlayerJump");
spr_attack   = asset_get_index("spriteSwordAttack");
spr_attack_up= asset_get_index("spriteSwordAttackUp"); // NEW up-slash sprite
spr_drink    = asset_get_index("spritePlayerDrink");   // optional
spr_hurt     = asset_get_index("spritePlayerHurt");    // optional

// Start in Idle if available
if (spr_idle != -1) { sprite_index = spr_idle; image_speed = 0.4; }

// ---------------- Movement tuning -------------------
move_speed              = 2.5;
jump_speed              = -4.0;
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
attack_anim_speed       = 0.35;

// ---- Drink/Hurt tuning (if used) -------------------
drink_anim_speed        = 0.35;
hurt_anim_speed         = 0.55;

// NEW: damage to deal per slash (both horizontal & up)
attack_damage           = 1;

// Air drift while attacking mid-air
air_attack_drift        = 1.15;

// Fallback hurt lock support (if no anim yet)
hurt_lock_frames_default = 10;
hurt_lock_timer          = 0;

// Legacy input lock
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

// Track which damage pulse we’ve reacted to (prevents hurt re-triggers)
last_seen_hurt_pulse = (variable_global_exists("_hurt_pulse_id") ? global._hurt_pulse_id : 0);
