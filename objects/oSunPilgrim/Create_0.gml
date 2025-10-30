/// oSunPilgrim — Create
contact_shrink_h      = 12;
contact_shrink_top    = 14;
contact_shrink_bottom = 6;

// --- sprite base orientation ---
BASE_FACING = -1;

// ---- STATS / DEATH VISUALS ----
hp                = 3;
is_dead           = false;
death_sprite      = spriteSunPilgrimDeath;
death_image_speed = 0.75;
/* @type {asset.object} */
explosion_object  = oSunPilgrimExplosion; // set to noone if this type shouldn't explode

// ---- MOVEMENT / AI ----
hsp = 0; vsp = 0;
run_speed   = 1.6;
walk_speed  = 1.0;
grav        = 0;    // keep 0 unless you add vertical/platform play

aggro_range  = 140;
attack_range = 38;

home_x        = x;
patrol_radius = 48;
patrol_dir    = choose(-1, 1);

// ---- EDGE/WALL SENSING ----
cliff_sense_dist = 6;
wall_sense_dist  = 1;
turn_cooldown    = 8;
_turn_cd         = 0;

// ---- KEEP-DISTANCE / HYSTERESIS (NEW) ----
// He tries to stay inside [keep_stop_dist, keep_resume_dist] around attack range.
keep_stop_dist     = max(8, attack_range - 4);  // if closer than this, stop/back off
keep_resume_dist   = attack_range + 12;         // must get this far before re-approach
approach_brake_px  = 12;                        // slow down when within this of stop
face_deadband_px   = 6;                         // don't flip if within this horizontal gap

// Retreat after a completed slash (NEW)
after_attack_retreat_frames = 18;               // ~0.3s @60fps
retreat_frames               = 0;

// ---- ATTACK CONTROL ----
attack_cd_s           = 0.70;
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

// ---- Visual-only oblique centering (draw offset like player) ----
oblique_draw_inset         = 8;
oblique_only_when_grounded = true;

// ---------- Helpers (respect art's base direction) ----------
function _dir_to_xscale(dir) { return BASE_FACING * clamp(dir, -1, 1); }
function _set_face(dir) {
    if (!attack_face_locked && dir != 0) image_xscale = _dir_to_xscale(dir);
}
function _forward_sign() { return sign(image_xscale) * sign(BASE_FACING); }
