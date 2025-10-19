/// oSunPilgrim — Step (parent-first; AI only, parent governs death/i-frames)

// 1) Let the parent (oParEnemy) run universal logic first (death, i-frames, etc.)
event_inherited();          // calls oParEnemy Step
if (is_dead) exit;          // if parent marked us dead this step, stop AI immediately

// 2) Cooldowns / target
var dt = delta_time / 1000000;
if (attack_cd > 0) attack_cd -= dt;

if (!instance_exists(target) && instance_exists(oPlayer)) {
    target = instance_nearest(x, y, oPlayer);
}

// 3) (Optional) gravity/collisions (disabled in your current setup)
// vsp += grav;
// y += vsp;

// ================== STATE MACHINE ==================
switch (state) {

    // -------- PATROL --------
    case SP_STATE.PATROL: {
        var left_bound  = home_x - patrol_radius;
        var right_bound = home_x + patrol_radius;

        hsp = walk_speed * patrol_dir;
        x += hsp;

        // flip at bounds and face along motion
        if (x <= left_bound)  patrol_dir = 1;
        if (x >= right_bound) patrol_dir = -1;
        _set_face(patrol_dir);

        // anim
        if (abs(hsp) > 0.05) {
            sprite_index = spriteSunPilgrimRun;
            var rate = 0.16 / max(0.001, walk_speed);
            image_speed = clamp(abs(hsp) * rate, 0.08, 0.22);
        } else {
            sprite_index = spriteSunPilgrimIdle;
            image_index  = 0;
            image_speed  = 0;
        }

        // aggro if player nearby
        if (instance_exists(target)) {
            var dx = abs(target.x - x);
            var dy = abs(target.y - y);
            if (dx <= aggro_range && dy < 64) state = SP_STATE.CHASE;
        }
    } break;

    // -------- CHASE --------
    case SP_STATE.CHASE: {
        if (!instance_exists(target)) { state = SP_STATE.PATROL; break; }

        var dir = sign(target.x - x);
        _set_face(dir);

        hsp = dir * run_speed;
        x += hsp;

        sprite_index = spriteSunPilgrimRun;
        var rate = 0.20 / max(0.001, run_speed);
        image_speed = clamp(abs(hsp) * rate, 0.12, 0.30);

        var dist = point_distance(x, y, target.x, target.y);

        // enter attack when in range & off cooldown
        if (dist <= attack_range && attack_cd <= 0) {
            state = SP_STATE.ATTACK;
            sprite_index = spriteSunPilgrimAttack;
            image_index  = 0;
            image_speed  = 0.50;
            attack_spawned_hitbox = false;

            // lock facing toward player for the swing (respect base art)
            var f = sign(target.x - x);
            if (f == 0) f = (image_xscale == 0) ? 1 : sign(image_xscale);
            image_xscale = _dir_to_xscale(f);
            attack_face_locked = true;

            hsp = 0;
        }
        else if (dist > aggro_range * 1.5) {
            state = SP_STATE.PATROL;
            patrol_dir = choose(-1, 1);
        }
    } break;

    // -------- ATTACK --------
    case SP_STATE.ATTACK: {
        // keep explicit attack sprite & fixed speed
        sprite_index = spriteSunPilgrimAttack;
        image_speed  = 0.35;

        // spawn hitbox exactly once during active frames
        var active_a = 3.0;
        var active_b = 5.5;

        if (!attack_spawned_hitbox && image_index >= active_a && image_index <= active_b) {
            attack_spawned_hitbox = true;

            var off = 22;
            var hb = instance_create_layer(x + _forward_sign() * off, y, layer, oSunPilgrimSlash);
            hb.owner          = id;
            hb.direction_sign = _forward_sign();
        }

        // stand still while attacking
        hsp = 0;
    } break;
}

// (No death handling here — parent manages death animation and cleanup)



