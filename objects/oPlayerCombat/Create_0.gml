/// oPlayerCombat — Create (robust; owns its own edge-detector)
owner              = noone;          // oPlayer instance; auto-resolved if not set

// ===== Cooldown (seconds) =====
attack_cd_s        = 0.50;
attack_cd          = 0;

// ===== Slash settings =====
slash_forward_px   = 18;
slash_damage       = 1;

// ===== Up-slash settings (optional but supported) =====
slash_up_y_offset  = 12;
slash_up_damage    = 1;

// ===== Attack sprites =====
spr_attack_a   = -1;
spr_attack_b   = -1;
spr_attack_c   = -1;
spr_attack_up  = -1;

var _a = asset_get_index("spriteSwordAttackA"); if (_a != -1) spr_attack_a = _a;
var _b = asset_get_index("spriteSwordAttackB"); if (_b != -1) spr_attack_b = _b;
var _c = asset_get_index("spriteSwordAttackC"); if (_c != -1) spr_attack_c = _c;

var _up = asset_get_index("spriteSwordAttackUp"); // optional
if (_up != -1) spr_attack_up = _up;

// ===== Input edge detector =====
attack_down_prev = false;  // local edge so we don't rely only on global pulses

// ===== Combo state =====
// 0:A, 1:B, 2:C
combo_index          = 0;
combo_active         = false;
combo_time           = 0.0;     // seconds elapsed in current swing
combo_dur_s          = 0.60;    // duration per swing (tune per feel)
active_start_t       = 0.10;    // normalized time to spawn hitbox (0..1)
active_end_t         = 0.10;    // (reserved for linger)
follow_open_t        = 0.60;    // window to accept next-press opens here
follow_close_t       = 0.95;    // window closes here
spawned_this_swing   = false;   // ensures we spawn hitbox only once
queued_next          = false;   // pressed inside follow-up window
combo_reset_s        = 0.45;    // time after end to still chain to next
combo_reset_timer    = 0.0;     // counts down after a swing ends
last_finished_index  = 0;       // used if pressing during reset window

// ===== Debug flag (optional) =====
combo_debug = false;

