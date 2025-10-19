/// oPlayerCombat — Create (robust; owns its own edge-detector)
owner              = noone;          // oPlayer instance; auto-resolved if not set

// Cooldown (seconds)
attack_cd_s        = 0.30;
attack_cd          = 0;

// Slash settings
slash_forward_px   = 18;
slash_damage       = 1;

// Optional attack sprite (not required)
spr_attack = -1;
var _maybe = asset_get_index("spriteSwordAttack");
if (_maybe != -1) spr_attack = _maybe;

// Local input edge detector (so we don't rely only on global pulses)
attack_down_prev = false;  // <--- NEW
