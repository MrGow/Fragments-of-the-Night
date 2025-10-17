/// oPlayerCombat — Create (spawner)
owner              = noone;          // oPlayer instance; we’ll resolve if not set
attack_key_primary = ord("Z");       // change if you like
attack_key_alt     = -1;             // set to vk_space or similar if you want a 2nd key

attack_cd_s        = 0.30;           // cooldown between swings (seconds)
attack_cd          = 0;

slash_forward_px   = 18;             // spawn offset in front of player
slash_damage       = 1;              // REAL number; what we pass to the hitbox

// Your attack sprite (so we can play it)
spr_attack         = spriteSwordAttack; // <-- set to your actual attack sprite asset
attack_anim_speed  = 0.25;

