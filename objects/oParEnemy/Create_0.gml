/// oParEnemy — Create (parent defaults + patrol + oblique + touch damage)
hp                = 3;
is_dead           = false;

death_sprite      = -1;
death_image_speed = 0.25;

// Body-contact hurtbox shrink (per side). Children can override per enemy.
contact_shrink_h       = 8;  // trim this many px from LEFT and RIGHT
contact_shrink_top     = 10; // trim from TOP  (ignore helmets/halos)
contact_shrink_bottom  = 4;  // trim from BOTTOM (keep feet active)

/* @type {asset.object} */
explosion_object  = -1;   // -1/ noone = none

death_sfx         = -1;
death_particles   = -1;

corpse_persist    = false;

// --- Damage plumbing ---
contact_damage    = 1;    // <= bump-to-damage ON by default (set 0 to disable per child)
knockback_px      = 5;
invul_frames      = 0;

invincible        = false;
hurtbox_active    = true;

// --- Touch-damage rate limit / sticky-proof timers ---
_touch_cd_max     = 30;   // ~0.5s at 60fps
_touch_cd         = 0;

// =============== Patrol + basic kinematics (opt-in) ===============
patrol_enabled   = false;     // child sets true to use parent patrol
dir              = choose(-1, 1); // -1 left, +1 right
patrol_speed     = 1.2;

hsp              = 0;
vsp              = 0;
gravity_amt      = 0.20;
max_fall         = 8.0;

// ledge / wall sensing
cliff_sense_dist = 6;         // pixels ahead to look for ground
wall_sense_dist  = 1;         // pixels ahead to test wall face
turn_cooldown    = 8;         // frames after a turn
_turn_cd         = 0;

// =============== Visual-only oblique centering (used in Draw) ===============
oblique_draw_inset         = 16;   // 32px tiles → ~half a tile
oblique_only_when_grounded = true;

// Ensure global tilemap handle exists (oGame sets it; this is defensive)
if (!variable_global_exists("tm_solids")) global.tm_solids = undefined;
