/// oSunPilgrim — Step

// ----- EARLY-OUT IF DEAD (let the death anim play; AI frozen) -----
if (is_dead) {
    if (death_sprite != -1) {
        if (sprite_index != death_sprite) { sprite_index = death_sprite; image_index = 0; }
        image_speed = death_image_speed;
    } else {
        if (explosion_object != noone && object_exists(explosion_object)) {
            instance_create_layer(x, y, layer, explosion_object);
        }
        instance_destroy();
    }
    hsp = 0; vsp = 0;
    exit;
}

// ----- COOLDOWNS / TARGET -----
var dt = delta_time/1000000;
if (attack_cd > 0) attack_cd -= dt;

if (!instance_exists(target) && instance_exists(oPlayer)) {
    target = instance_nearest(x, y, oPlayer);
}

// ----- (optional) gravity / collisions -----
/*
vsp += grav;
y += vsp;
*/

// ----- helper: face unless locked during attack -----
function _face(dir) {
    if (!attack_face_locked && dir != 0) image_xscale = dir;
}

// ================== STATE MACHINE ==================
switch (state) {

    // -------- PATROL --------
    case SP_STATE.PATROL: {
        var left_bound  = home_x - patrol_radius;
        var right_bound = home_x + patrol_radius;

        hsp = walk_speed * patrol_dir;
        x += hsp;

        // flip at bounds
        if (x <= left_bound)  patrol_dir = 1;
        if (x >= right_bound) patrol_dir = -1;

        _face(patrol_dir);

        // choose animation (run while moving, idle if effectively stopped)
        if (abs(hsp) > 0.05) {
            sprite_index = spriteSunPilgrimRun;
            // movement-synced image_speed to avoid foot slide
            var rate = 0.16 / max(0.001, walk_speed);
            image_speed = clamp(abs(hsp) * rate, 0.08, 0.22);
        } else {
            sprite_index = spriteSunPilgrimIdle;
            image_index  = 0;
            image_speed  = 0;
        }

        // aggro if player nearby (mostly horizontal check, small vertical tolerance)
        if (instance_exists(target)) {
            var dx = abs(target.x - x);
            var dy = abs(target.y - y);
            if (dx <= aggro_range && dy < 64) state = SP_STATE.CHASE;
        }
    } break;

    // -------- CHASE --------
    case SP_STATE.CHASE: {
        if (!instance_exists(target)) { state = SP_STATE.PATROL; break; }

        var dir  = sign(target.x - x);
        _face(dir);

        hsp = dir * run_speed;
        x += hsp;

        sprite_index = spriteSunPilgrimRun;
        var rate = 0.20 / max(0.001, run_speed);
        image_speed = clamp(abs(hsp) * rate, 0.12, 0.30);

        var dist = point_distance(x, y, target.x, target.y);

        // enter attack only when in range and off cooldown
        if (dist <= attack_range && attack_cd <= 0) {
            state = SP_STATE.ATTACK;
            sprite_index = spriteSunPilgrimAttack;
            image_index  = 0;
            image_speed  = 0.25;
            attack_spawned_hitbox = false;

            // hard-face player and lock facing for the swing
            var f = sign(target.x - x); if (f == 0) f = (image_xscale == 0) ? 1 : image_xscale;
            image_xscale = f;
            attack_face_locked = true;

            hsp = 0;
        }
        // leash back to patrol if player gets far
        else if (dist > aggro_range * 1.5) {
            state = SP_STATE.PATROL;
            patrol_dir = choose(-1, 1);
        }
    } break;

    // -------- ATTACK --------
    case SP_STATE.ATTACK: {
        // keep explicit attack sprite & fixed speed
        sprite_index = spriteSunPilgrimAttack;
        image_speed  = 0.25;

        // spawn hitbox exactly once in active frames (tune to your sheet)
        var active_a = 3.0;
        var active_b = 5.5;

        if (!attack_spawned_hitbox && image_index >= active_a && image_index <= active_b) {
            attack_spawned_hitbox = true;

            var off = 22;
            var hb = instance_create_layer(x + image_xscale * off, y, layer, oSunPilgrimSlash);
            hb.owner          = id;
            hb.direction_sign = image_xscale;
            // if oSunPilgrimSlash uses its own lifetime/damage, it will read defaults
        }

        // stand still while attacking
        hsp = 0;
    } break;
}

// ----- apply horizontal movement if you later add collisions -----
/*
x += hsp;
*/

