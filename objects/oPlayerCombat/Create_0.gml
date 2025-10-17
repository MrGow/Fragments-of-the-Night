/// oPlayerCombat — Create (sprite-agnostic spawner)
owner              = noone;          // oPlayer instance; auto-resolved if not set
attack_key_primary = ord("Z");       // change if you like
attack_key_alt     = -1;             // set to vk_space etc. if you want a 2nd key
attack_cd_s        = 0.30;           // seconds
attack_cd          = 0;

slash_forward_px   = 18;             // spawn offset in front of player
slash_damage       = 1;              // REAL number

// Optional attack sprite (not required)
spr_attack = -1;
var _maybe = asset_get_index("spriteSwordAttack"); if (_maybe != -1) spr_attack = _maybe;
attack_anim_speed  = 2;

