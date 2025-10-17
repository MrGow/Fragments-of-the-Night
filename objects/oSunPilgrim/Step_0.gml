/// oSunPilgrim — Step (early-out when dead)
if (variable_instance_exists(id,"is_dead") && is_dead) {
    // freeze AI and keep the death animation visible until Animation End
    if (death_sprite != -1) {
        if (sprite_index != death_sprite) {
            sprite_index = death_sprite;
            image_index  = 0; // ensure it starts from frame 0 the first frame of death
        }
        image_speed = death_image_speed;
    }
    hsp = 0; vsp = 0; // stop movement if you use these
    exit;             // IMPORTANT: do not run patrol/chase/attack code below
}


/// oSunPilgrim — Step (facing-correct; no moonwalk)
if (attack_cd > 0) attack_cd -= delta_time/1000000;

// Target
if (!instance_exists(target) && instance_exists(oPlayer)) {
    target = instance_nearest(x, y, oPlayer);
}

// vsp += grav; y += vsp; // enable when collisions are ready

switch (state) {
    case SP_STATE.PATROL: {
        var left_bound  = home_x - patrol_radius;
        var right_bound = home_x + patrol_radius;

        sprite_index = spriteSunPilgrimRun;

        hsp = walk_speed * patrol_dir;
        x += hsp;

        _set_face(patrol_dir); // face where we're walking

        if (x <= left_bound)  patrol_dir = 1;
        if (x >= right_bound) patrol_dir = -1;

        if (instance_exists(target)) {
            var dx = abs(target.x - x);
            var dy = abs(target.y - y);
            if (dx <= aggro_range && dy < 64) state = SP_STATE.CHASE;
        }

        var anim_rate_walk = 0.16 / max(0.001, walk_speed);
        image_speed = clamp(abs(hsp) * anim_rate_walk, 0.08, 0.22);
        if (abs(hsp) < 0.01) { image_index = 0; image_speed = 0; }
    } break;

    case SP_STATE.CHASE: {
        if (!instance_exists(target)) { state = SP_STATE.PATROL; break; }

        sprite_index = spriteSunPilgrimRun;

        var dist = point_distance(x, y, target.x, target.y);
        var dir  = sign(target.x - x); // world dir to player: -1 left, +1 right

        hsp = dir * run_speed;
        x += hsp;

        _set_face(dir); // always face where we’re running

        if (dist <= attack_range && attack_cd <= 0) {
            // ---- ENTER ATTACK ----
            state = SP_STATE.ATTACK;
            sprite_index = spriteSunPilgrimAttack;
            image_index  = 0;
            image_speed  = 0.25;
            attack_spawned_hitbox = false;

            // Lock facing toward player for whole swing
            var face_dir = (dir == 0) ? ( (_forward_sign() >= 0) ? 1 : -1 ) : dir;
            image_xscale = _dir_to_xscale(face_dir);
            attack_face_locked = true;

            hsp = 0;
        } else if (dist > aggro_range * 1.5) {
            state = SP_STATE.PATROL;
            patrol_dir = choose(-1, 1);
        }

        var anim_rate_run = 0.20 / max(0.001, run_speed);
        image_speed = clamp(abs(hsp) * anim_rate_run, 0.12, 0.30);
        if (abs(hsp) < 0.01) { image_index = 0; image_speed = 0; }
    } break;

    case SP_STATE.ATTACK: {
        sprite_index = spriteSunPilgrimAttack;

        // Active frames -> spawn slash
        var mid_a = 3.0;
        var mid_b = 5.5;

        if (!attack_spawned_hitbox && image_index >= mid_a && image_index <= mid_b) {
            attack_spawned_hitbox = true;

            var forward = _forward_sign(); // +1 in front, -1 behind (independent of art)
            var off = 22;

            var hb = instance_create_layer(x + forward * off, y, layer, oSunPilgrimSlash);
            hb.direction_sign = forward; // hitbox knows "front" correctly
            hb.owner          = id;
        }

        image_speed = 0.25; // fixed during swing
        // No facing changes here (locked)
    } break;

    case SP_STATE.HURT: {
        state = instance_exists(target) ? SP_STATE.CHASE : SP_STATE.PATROL;
    } break;

    case SP_STATE.DEATH: {
        hsp = 0;
        image_speed = 0.25;
    } break;
}

// Optional touch damage
if (touch_damage > 0 && instance_exists(oPlayer) && place_meeting(x, y, oPlayer)) {
    if (is_undefined(oPlayer.take_damage)) {
        if (script_exists(scr_player_take_damage)) scr_player_take_damage(oPlayer, touch_damage, x);
    } else with (oPlayer) take_damage(other.touch_damage, other.x);
}
