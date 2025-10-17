/// oPlayerCombat — Create
owner              = noone;          // player instance (set after create)
attack_key_primary = ord("Z");       // <- keyboard key for attack
attack_key_alt     = vk_space;       // <- optional alt key (or set to -1 to disable)

attack_cd_s        = 0.28;
attack_cd          = 0;
spawned_this_swing = false;

// timing windows relative to the player's attack sprite frames
hit_start = 3.0;     // first active frame
hit_end   = 6.0;     // last active frame

// offset in front of the player (pixels)
hit_off   = 18;

// damage dealt
atk_damage = 1;

// set this to your player’s attack sprite once (or from outside)
spr_attack = spriteSwordAttack; // change if your asset name differs

