/// oParEnemy — Create (add defaults that Animation End expects)
hp                = 3;
is_dead           = false;

death_sprite      = -1;
death_image_speed = 0.25;

/* @type {asset.object} */
explosion_object  = -1;   // use -1 for "none" here

death_sfx         = -1;
death_particles   = -1;

/* NEW: ensure this exists */
corpse_persist    = false;

// --- Damage plumbing ---
contact_damage    = 0;    // 0 = no body touch damage (recommended default)
knockback_px      = 5;
invul_frames      = 0;

invincible        = false;
hurtbox_active    = true;

// --- Touch-damage rate limit (so standing on enemy isn't a blender) ---
_touch_cd_max     = 24;   // frames between body hits
_touch_cd         = 0;

