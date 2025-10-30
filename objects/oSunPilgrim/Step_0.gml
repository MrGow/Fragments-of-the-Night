/// oSunPilgrim — Step (parent-first; AI only, parent governs death/i-frames)
event_inherited();
if (is_dead) exit;

// ---------- Tile helpers ----------
function __ensure_tm_solids_local() {
    if (!is_undefined(global.tm_solids) && global.tm_solids != -1) return global.tm_solids;
    var lid = layer_get_id("Solids");
    if (lid != -1) {
        var elems = layer_get_all_elements(lid);
        for (var i = 0; i < array_length(elems); i++) {
            var el = elems[i];
            if (layer_get_element_type(el) == layerelementtype_tilemap) { global.tm_solids = el; return el; }
        }
    }
    var layers = layer_get_all();
    for (var j = 0; j < array_length(layers); j++) {
        var els = layer_get_all_elements(layers[j]);
        for (var k = 0; k < array_length(els); k++) {
            var el2 = els[k];
            if (layer_get_element_type(el2) == layerelementtype_tilemap) { global.tm_solids = el2; return el2; }
        }
    }
    global.tm_solids = undefined; return undefined;
}
__ensure_tm_solids_local();

function __tile_solid_at(_x,_y) {
    return (!is_undefined(global.tm_solids)) && (tilemap_get_at_pixel(global.tm_solids,_x,_y) != 0);
}
function __on_ground_check_enemy() {
    var l = bbox_left, r = bbox_right, b = bbox_bottom;
    var e = 0.1, step = 4, xx = l + e;
    while (xx <= r - e + 0.0001) { if (__tile_solid_at(xx, b + 1)) return true; xx += step; }
    return __tile_solid_at(r - e, b + 1);
}
function __rect_hits_solid_enemy(_dx,_dy) {
    var l = bbox_left  + _dx, r = bbox_right + _dx;
    var t = bbox_top   + _dy, b = bbox_bottom+ _dy;
    var e = 0.1, sv = 4, sh = 4, yy = t + e;
    while (yy <= b - e + 0.0001) { if (__tile_solid_at(l+e,yy) || __tile_solid_at(r-e,yy)) return true; yy += sv; }
    if (__tile_solid_at(l+e,b-e) || __tile_solid_at(r-e,b-e)) return true;
    var xx = l + e;
    while (xx <= r - e + 0.0001) { if (__tile_solid_at(xx,t+e) || __tile_solid_at(xx,b-e)) return true; xx += sh; }
    if (__tile_solid_at(r-e,t+e) || __tile_solid_at(r-e,b-e)) return true;
    return false;
}
function __move_h(_spd) {
    if (_spd == 0) return;
    var sx = sign(_spd), mx = abs(_spd);
    repeat (floor(mx))  { if (!__rect_hits_solid_enemy(sx,0)) x += sx; else break; }
    var fx = mx - floor(mx);
    if (fx > 0) { if (!__rect_hits_solid_enemy(sx*fx,0)) x += sx*fx; }
}
function __ahead_wall(_dir) {
    var px = (_dir > 0) ? (bbox_right + wall_sense_dist) : (bbox_left - wall_sense_dist);
    return __tile_solid_at(px, bbox_bottom - 4) || __tile_solid_at(px, bbox_top + 8);
}
function __ground_ahead(_dir) {
    var px = (_dir > 0) ? (bbox_right + cliff_sense_dist) : (bbox_left - cliff_sense_dist);
    return __tile_solid_at(px, bbox_bottom + 1);
}

// ---------- cooldowns / target ----------
var dt = delta_time / 1000000;
if (attack_cd > 0) attack_cd -= dt;
if (!instance_exists(target) && instance_exists(oPlayer)) target = instance_nearest(x, y, oPlayer);

// Optional verticals if you later enable gravity
if (grav != 0) {
    vsp += grav;
    var sy = sign(vsp), my = abs(vsp);
    repeat (floor(my)) { if (!__rect_hits_solid_enemy(0, sy)) y += sy; else { vsp = 0; break; } }
    var fy = my - floor(my);
    if (fy > 0 && vsp != 0) { if (!__rect_hits_solid_enemy(0, sy*fy)) y += sy*fy; else vsp = 0; }
}

var on_ground = __on_ground_check_enemy();
if (_turn_cd > 0) _turn_cd--;

// ================== STATE MACHINE ==================
switch (state) {

    // -------- PATROL --------
    case SP_STATE.PATROL: {
        var left_bound  = home_x - patrol_radius;
        var right_bound = home_x + patrol_radius;

        var dir = patrol_dir;

        var wall_hit   = __ahead_wall(dir);
        var ground_fwd = __ground_ahead(dir);
        var must_turn  = (on_ground && (wall_hit || !ground_fwd));

        if ((x <= left_bound) || (x >= right_bound)) must_turn = true;

        if (must_turn && _turn_cd <= 0) { patrol_dir = -dir; dir = patrol_dir; _turn_cd = turn_cooldown; }

        hsp = walk_speed * dir;
        __move_h(hsp);
        _set_face(dir);

        if (abs(hsp) > 0.05) {
            sprite_index = spriteSunPilgrimRun;
            var rate = 0.16 / max(0.001, walk_speed);
            image_speed = clamp(abs(hsp) * rate, 0.08, 0.22);
        } else {
            sprite_index = spriteSunPilgrimIdle; image_index = 0; image_speed = 0;
        }

        if (instance_exists(target)) {
            var dx = abs(target.x - x), dy = abs(target.y - y);
            if (dx <= aggro_range && dy < 64) state = SP_STATE.CHASE;
        }
    } break;

    // -------- CHASE (with keep-distance + retreat) --------
    case SP_STATE.CHASE: {
        if (!instance_exists(target)) { state = SP_STATE.PATROL; break; }

        var dx  = target.x - x;
        var adx = abs(dx);
        var dir_to_player = (adx > face_deadband_px) ? sign(dx) : ( (image_xscale == 0) ? 1 : sign(image_xscale) );
        _set_face(dir_to_player);

        // stop at walls/chasms regardless
        var blocked_fwd = __ahead_wall(dir_to_player) || !__ground_ahead(dir_to_player);

        // Retreat window right after an attack
        if (retreat_frames > 0) {
            retreat_frames--;
            var retreat_dir = -dir_to_player;
            if (!blocked_fwd) { __move_h(retreat_dir * walk_speed); }
            hsp = 0; // we already moved; keep reported hsp simple
            sprite_index = spriteSunPilgrimIdle; image_speed = 0.15;
        }
        else {
            // Approach with brake + keep-distance hysteresis
            if (adx > keep_resume_dist && !blocked_fwd) {
                // far: run in
                var spd = run_speed;
                __move_h(dir_to_player * spd);
                sprite_index = spriteSunPilgrimRun;
                var rate = 0.20 / max(0.001, run_speed);
                image_speed = clamp(spd * rate, 0.12, 0.30);
            }
            else if (adx > keep_stop_dist && !blocked_fwd) {
                // near: slow down as we enter the stop band
                var gap = adx - keep_stop_dist; // 0..approach_brake_px
                var t   = clamp(gap / max(1, approach_brake_px), 0, 1);
                var spd = lerp(0.35, walk_speed, t); // gentle creep
                __move_h(dir_to_player * spd);
                sprite_index = spriteSunPilgrimRun;
                image_speed  = 0.12;
            }
            else {
                // inside stop band: hold position; tiny backstep if too close
                if (adx < keep_stop_dist - 4 && on_ground && !__ahead_wall(-dir_to_player)) {
                    __move_h(-dir_to_player * 0.6); // small nudge back
                }
                sprite_index = spriteSunPilgrimIdle;
                image_speed  = 0.15;
            }
        }

        // Attempt the attack when in range & off cooldown
        var dist = point_distance(x, y, target.x, target.y);
        if (dist <= attack_range && attack_cd <= 0) {
            state = SP_STATE.ATTACK;
            sprite_index = spriteSunPilgrimAttack;
            image_index  = 0;
            image_speed  = 0.50;
            attack_spawned_hitbox = false;

            // lock facing toward player for the swing
            var f = sign(target.x - x); if (f == 0) f = (image_xscale == 0) ? 1 : sign(image_xscale);
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
        sprite_index = spriteSunPilgrimAttack;
        image_speed  = 0.35;

        var active_a = 3.0, active_b = 5.5;
        if (!attack_spawned_hitbox && image_index >= active_a && image_index <= active_b) {
            attack_spawned_hitbox = true;
            var off = 22;
            var hb = instance_create_layer(x + _forward_sign() * off, y, layer, oSunPilgrimSlash);
            hb.owner          = id;
            hb.direction_sign = _forward_sign();
        }
        hsp = 0;
    } break;
}

