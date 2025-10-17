/// oSunPilgrim — Create

// ---- STATS / DEATH VISUALS ----
hp                = 4;
is_dead           = false;
death_sprite      = spriteSunPilgrimDeath;   // set your asset
death_image_speed = 1;
explosion_object  = oSunPilgrimExplosion;    // set to noone if this enemy shouldn't explode

// ---- MOVEMENT / AI ----
hsp = 0; vsp = 0;
run_speed   = 1.6;
walk_speed  = 0.6;
grav        = 0;    // set >0 if you use vertical collisions

aggro_range  = 140; // start chasing within this horizontal distance
attack_range = 38;  // start attack within this distance

home_x        = x;  // patrol center
patrol_radius = 48;
patrol_dir    = choose(-1, 1);

// ---- ATTACK CONTROL ----
attack_cd_s           = 0.70; // seconds between swings
attack_cd             = 0;
attack_spawned_hitbox = false;
attack_face_locked    = false;

// ---- TARGET ----
target = noone;

// ---- SPRITES / MASK ----
sprite_index = spriteSunPilgrimIdle;   // idle on spawn
image_index  = 0;
image_speed  = 0.18;
mask_index   = spriteSunPilgrimCollisionMask;

// ---- SIMPLE FSM ----
enum SP_STATE { PATROL, CHASE, ATTACK }
state = SP_STATE.PATROL;

