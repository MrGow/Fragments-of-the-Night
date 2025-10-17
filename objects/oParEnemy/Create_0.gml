/// oParEnemy — Create
// Core stats
hp                = 3;
is_dead           = false;

// Death visuals (child should set death_sprite)
death_sprite      = -1;     // e.g., sprMyEnemyDeath
death_image_speed = 0.25;

// Optional extras (all default OFF / NONE)
explosion_object  = noone;  // e.g., oSunPilgrimExplosion (only for enemies that explode)
death_sfx         = -1;     // e.g., sndEnemyDie
death_particles   = -1;     // you can call a script in Animation End if wanted
corpse_persist    = false;  // if true, we won’t auto-destroy in Animation End

// Gameplay hooks
contact_damage    = 0;
knockback_px      = 0;      // nudge on hit, if your child uses hsp/vsp
invul_frames      = 0;      // simple hit cooldown (set by damage script)
