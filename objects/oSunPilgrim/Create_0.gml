/// oSunPilgrim — Create

// --- sprite base orientation ---
// +1 if default frames face RIGHT; -1 if they face LEFT (most sheets do)
BASE_FACING = -1;

// ---- STATS / DEATH VISUALS ----
hp                = 3;
is_dead           = false;
death_sprite      = spriteSunPilgrimDeath;
death_image_speed = 0.75;
explosion_object  = oSunPilgrimExplosion; // set to noone if this type shouldn't explode

// ---- MOVEMENT / AI ----
hsp = 0; vsp = 0;
run_speed   = 1.6;
walk_speed  = 1.0;
grav        = 0;    // raise & add collisions if you need gravity

aggro_range  = 140;
attack_range = 38;

home_x        = x;
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
sprite_index = spriteSunPilgrimIdle;
image_index  = 0;
image_speed  = 0.30;
mask_index   = spriteSunPilgrimCollisionMask;

// ---- SIMPLE FSM ----
enum SP_STATE { PATROL, CHASE, ATTACK }
state = SP_STATE.PATROL;

// ---------- Helpers (respect art's base direction) ----------
function _dir_to_xscale(dir) {
    // world dir: -1 left, +1 right
    return BASE_FACING * clamp(dir, -1, 1);
}
function _set_face(dir) {
    if (!attack_face_locked && dir != 0) image_xscale = _dir_to_xscale(dir);
}
function _forward_sign() {
    // +1 = "in front of him" in world space regardless of art base
    return sign(image_xscale) * sign(BASE_FACING);
}

