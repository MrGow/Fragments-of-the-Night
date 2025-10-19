/// oPlayer — Create  (fully declared; Space=jump, Z/X=attack)

// Movement/control
stunned                 = false;
can_move                = true;
hsp                     = 0;
vsp                     = 0;

// State / animation
state                   = "idle";
attack_lock             = false;

// Optional attack sprite (auto-detect; stays -1 if not present)
spr_attack = -1;
var _maybe = asset_get_index("spriteSwordAttack");
if (_maybe != -1) spr_attack = _maybe;

// Movement tuning (adjust to taste)
move_speed              = 2.0;
jump_speed              = -5.0;     // up is negative
gravity_amt             = 0.35;
low_jump_multiplier     = 1.7;
fall_multiplier         = 1.5;
max_fall                = 8.0;

// Coyote / buffer (frames)
coyote_time_frames      = 6;
jump_buffer_time_frames = 6;
coyote_timer            = 0;
jump_buffer_timer       = 0;

// Attack gating (Step reads these)
can_attack              = true;
attack_cooldown         = 0;

// Tiny frame-lock support (only used if you enable it in Step)
attack_lock_frames      = 0;

// Legacy flag some code touches
if (!variable_instance_exists(id,"input_locked")) input_locked = false;

// --- Ensure a Combat companion exists and is bound to this player ---
if (instance_number(oPlayerCombat) == 0) {
    var _pc = instance_create_layer(x, y, layer, oPlayerCombat);
    _pc.owner = id;
    show_debug_message("[PC] Spawned oPlayerCombat and bound owner");
} else {
    // Bind nearest combat to this player, just in case
    var _pc2 = instance_nearest(x, y, oPlayerCombat);
    if (_pc2 != noone) { _pc2.owner = id; }
    show_debug_message("[PC] Rebound existing oPlayerCombat to player");
}
