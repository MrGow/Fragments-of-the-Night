death_sprite     = spriteSunPilgrimDeath;
explosion_object = oSunPilgrimExplosion; // object ASSET, not an instance
hp               = 4;


///  +1  => default sprite looks to the RIGHT
///  -1  => default sprite looks to the LEFT (very common in pixel sheets)
BASE_FACING = -1; // ⬅️ set this correctly for your sheet

hp                = 4;
walk_speed        = 0.6;
run_speed         = 1.6;
aggro_range       = 140;
attack_range      = 38;
attack_cooldown_s = 0.8;
touch_damage      = 0;

home_x        = x;
patrol_radius = 48;
patrol_dir    = choose(-1, 1);

hsp = 0; vsp = 0;
grav = 0; // keep 0 until you wire collisions

target = noone;

enum SP_STATE { PATROL, CHASE, ATTACK, HURT, DEATH }
state = SP_STATE.PATROL;

image_speed = 0.18;
attack_cd   = 0;
attack_spawned_hitbox = false;

// Facing lock during attack
attack_face_locked = false;

// Visual + mask
sprite_index = spriteSunPilgrimIdle;
image_index  = 0;
mask_index   = spriteSunPilgrimCollisionMask;
image_alpha  = 1;

// ---------- Helpers (use everywhere) ----------
function _dir_to_xscale(dir) {
    // dir is -1 (left), +1 (right) in world terms.
    // Multiply by BASE_FACING so the visual flip matches your art.
    return BASE_FACING * clamp(dir, -1, 1);
}
function _set_face(dir) {
    if (!attack_face_locked && dir != 0) image_xscale = _dir_to_xscale(dir);
}
function _forward_sign() {
    // Returns +1 in "in-front-of-him" space, regardless of BASE_FACING.
    // If he visually faces right, this is +1; if left, it's -1.
    return sign(image_xscale) * sign(BASE_FACING);
}
