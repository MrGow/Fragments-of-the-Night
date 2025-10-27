/// oPlayer — Step  (movement, collisions, combat hooks, marker-ledges)

// ---------- one-frame guard ----------
if (!variable_instance_exists(id,"attack_just_started")) attack_just_started = false;
var _skip_overrides_this_frame = attack_just_started;

// ---------- hot-reload safety ----------
if (!variable_instance_exists(id,"state"))                   state = "idle";
if (!variable_instance_exists(id,"hsp"))                     hsp = 0;
if (!variable_instance_exists(id,"vsp"))                     vsp = 0;
if (!variable_instance_exists(id,"image_xscale"))            image_xscale = 1;

if (!variable_instance_exists(id,"move_speed"))              move_speed = 2.5;
if (!variable_instance_exists(id,"jump_speed"))              jump_speed = -4.0;
if (!variable_instance_exists(id,"gravity_amt"))             gravity_amt = 0.2;
if (!variable_instance_exists(id,"low_jump_multiplier"))     low_jump_multiplier = 1.7;
if (!variable_instance_exists(id,"fall_multiplier"))         fall_multiplier = 1.5;
if (!variable_instance_exists(id,"max_fall"))                max_fall = 8.0;

if (!variable_instance_exists(id,"air_attack_drift"))        air_attack_drift = 1.15;
if (!variable_instance_exists(id,"attack_cooldown"))         attack_cooldown = 0;
if (!variable_instance_exists(id,"attack_end_fired"))        attack_end_fired = false;
if (!variable_instance_exists(id,"pc_combo_active"))         pc_combo_active = false;
if (!variable_instance_exists(id,"attack_anim_speed"))       attack_anim_speed = 1;

if (!variable_instance_exists(id,"coyote_time_frames"))      coyote_time_frames = 6;
if (!variable_instance_exists(id,"jump_buffer_time_frames")) jump_buffer_time_frames = 6;
if (!variable_instance_exists(id,"coyote_timer"))            coyote_timer = 0;
if (!variable_instance_exists(id,"jump_buffer_timer"))       jump_buffer_timer = 0;

if (!variable_instance_exists(id,"drink_anim_speed"))        drink_anim_speed = 0.35;
if (!variable_instance_exists(id,"hurt_anim_speed"))         hurt_anim_speed  = 0.55;
if (!variable_instance_exists(id,"hurt_lock_frames_default"))hurt_lock_frames_default = 10;
if (!variable_instance_exists(id,"hurt_lock_timer"))         hurt_lock_timer  = 0;
if (!variable_instance_exists(id,"last_seen_hurt_pulse"))    last_seen_hurt_pulse = (variable_global_exists("_hurt_pulse_id") ? global._hurt_pulse_id : 0);
if (!variable_instance_exists(id,"attack_release_linger"))   attack_release_linger = 0;

// ledge/jump spam cooldown + pull watchdog (+ stall detector)
if (!variable_instance_exists(id,"ledge_nojump_frames"))     ledge_nojump_frames = 0;
if (!variable_instance_exists(id,"ledge_pull_watch"))        ledge_pull_watch = 0;
if (!variable_instance_exists(id,"ledge_stall_frames"))      ledge_stall_frames = 0;
if (!variable_instance_exists(id,"ledge_prev_x"))            ledge_prev_x = x;
if (!variable_instance_exists(id,"ledge_prev_y"))            ledge_prev_y = y;
if (!variable_instance_exists(id,"ledge_prev_phase"))        ledge_prev_phase = 0;
if (ledge_nojump_frames > 0) ledge_nojump_frames--;
if (ledge_pull_watch  > 0) ledge_pull_watch--;

// walk-off lock + ground memory
if (!variable_instance_exists(id,"ledge_walkoff_lock")) ledge_walkoff_lock = 0;
if (!variable_instance_exists(id,"was_on_ground"))      was_on_ground      = false;
if (ledge_walkoff_lock > 0) ledge_walkoff_lock--;

// ---------- sprite locals ----------
var sprIdle_step      = __spr("spritePlayerIdle");
var sprRun_step       = __spr("spritePlayerRun");
var sprJump_step      = __spr("spritePlayerJump");
var sprHurt_step      = __spr("spritePlayerHurt");
var sprDrink_step     = __spr("spritePlayerDrink");
var sprLedgeGrab_step = __spr("spritePlayerLedgeGrab");
var sprLedgePull_step = __spr("spritePlayerLedgePull");

// ---------- tilemap access ----------
if (!variable_global_exists("tm_solids"))      global.tm_solids = undefined;
if (!variable_global_exists("tm_solids_name")) global.tm_solids_name = "";

function __ensure_tm_solids() {
    if (!is_undefined(global.tm_solids) && global.tm_solids != -1) return global.tm_solids;

    var lid = layer_get_id("Solids");
    if (lid != -1) {
        var elems = layer_get_all_elements(lid);
        for (var i = 0; i < array_length(elems); i++) {
            var el = elems[i];
            if (layer_get_element_type(el) == layerelementtype_tilemap) {
                global.tm_solids      = el;
                global.tm_solids_name = layer_get_name(lid);
                return el;
            }
        }
    }
    var layers = layer_get_all();
    for (var j = 0; j < array_length(layers); j++) {
        var lid2  = layers[j];
        var els = layer_get_all_elements(lid2);
        for (var k = 0; k < array_length(els); k++) {
            var el2 = els[k];
            if (layer_get_element_type(el2) == layerelementtype_tilemap) {
                global.tm_solids      = el2;
                global.tm_solids_name = layer_get_name(lid2);
                return el2;
            }
        }
    }
    global.tm_solids = undefined;
    global.tm_solids_name = "";
    return undefined;
}
__ensure_tm_solids();

// ---------- collision helpers (EDGE-SAMPLING + climb capsule) ----------
function __tile_solid_at(_x,_y) {
    return (!is_undefined(global.tm_solids)) && (tilemap_get_at_pixel(global.tm_solids,_x,_y)!=0);
}

/*
  During ledge_pull we shrink the effective rectangle:
    - inset TOP by 6 px (avoid head snag)
    - inset the BACK shoulder by 5 px (opposite ledge_dir)
*/
function __rect_hits_solid(_dx,_dy) {
    var l = bbox_left  + _dx;
    var r = bbox_right + _dx;
    var t = bbox_top   + _dy;
    var b = bbox_bottom+ _dy;

    if (state == "ledge_pull") {
        var inset_top  = 6;
        var inset_back = 5;
        t += inset_top;
        if (ledge_dir > 0) l += inset_back; else if (ledge_dir < 0) r -= inset_back;
        if (r <= l + 1) r = l + 1;
        if (b <= t + 1) b = t + 1;
    }

    var e = 0.1;   // inward epsilon
    var step_v = 4;
    var step_h = 4;

    // left & right edges
    var yy = t + e;
    while (yy <= b - e + 0.0001) {
        if (__tile_solid_at(l + e, yy)) return true;
        if (__tile_solid_at(r - e, yy)) return true;
        yy += step_v;
    }
    if (__tile_solid_at(l + e, b - e)) return true;
    if (__tile_solid_at(r - e, b - e)) return true;

    // top & bottom edges
    var xx = l + e;
    while (xx <= r - e + 0.0001) {
        if (__tile_solid_at(xx, t + e)) return true;
        if (__tile_solid_at(xx, b - e)) return true;
        xx += step_h;
    }
    if (__tile_solid_at(r - e, t + e)) return true;
    if (__tile_solid_at(r - e, b - e)) return true;

    return false;
}

// Ground check: sample across the feet
function __on_ground_check() {
    var l = bbox_left;
    var r = bbox_right;
    var b = bbox_bottom;
    var e = 0.1;
    var step = 4;
    var xx = l + e;
    while (xx <= r - e + 0.0001) {
        if (__tile_solid_at(xx, b + 1)) return true;
        xx += step;
    }
    return __tile_solid_at(r - e, b + 1);
}

// ---------- SAFE-LANDING FINDER ----------
// Search just inside the platform for a legal place to stand.
// Returns [found_bool, new_x, new_y]
function __find_safe_stand_near(_cx, _cy, _dir) {
    var max_inward = 24;
    var lateral_step = 4;
    var vertical_scan_up   = 24;
    var vertical_scan_down = 72;

    for (var inward = 0; inward <= max_inward; inward += 2) {
        var base_x = _cx + _dir * inward;
        for (var side = -8; side <= 8; side += lateral_step) {
            var px = base_x + side;

            // Start a little above, scan downward to find the first floor
            var y0 = _cy - vertical_scan_up;
            var y1 = _cy + vertical_scan_down;

            var yscan = y0;
            // descend until tile below is solid
            while (yscan < y1 && !__tile_solid_at(px, yscan + 1)) {
                yscan++;
            }
            if (yscan >= y1) continue;           // no floor in range
            if (__tile_solid_at(px, yscan)) continue; // inside a wall

            // compute deltas to place feet exactly on that floor y
            var dx = px - x;
            var dy = (yscan - bbox_bottom);
            if (!__rect_hits_solid(dx, dy)) {
                return [true, x + dx, y + dy];
            }
        }
    }
    return [false, _cx, _cy];
}

// ---------- sprite switch (keep feet) ----------
function __set_sprite_keep_feet(_spr,_speed){
    if (_spr == -1) return;
    var cur_yoff = sprite_get_yoffset(sprite_index);
    var cur_bot  = sprite_get_bbox_bottom(sprite_index);
    var feet_y   = y - cur_yoff + cur_bot;
    sprite_index = _spr;
    if (!is_undefined(_speed)) image_speed = _speed;
    var new_yoff = sprite_get_yoffset(sprite_index);
    var new_bot  = sprite_get_bbox_bottom(sprite_index);
    y = feet_y - (new_bot - new_yoff);
}

// ---------- input ----------
var kx = (keyboard_check(vk_right)||keyboard_check(ord("D"))) - (keyboard_check(vk_left)||keyboard_check(ord("A")));
kx = clamp(kx,-1,1);
var k_jump_p = keyboard_check_pressed(vk_space);
var k_jump_h = keyboard_check(vk_space);
var k_heal_p = keyboard_check_pressed(ord("E"));
var k_down   = keyboard_check(vk_down) || keyboard_check(ord("S"));

var move_x = kx;
var jump_p = k_jump_p;
var jump_h = k_jump_h;
if (variable_global_exists("input") && is_struct(global.input)) {
    if (move_x==0 && variable_struct_exists(global.input,"move_x")) move_x = clamp(global.input.move_x,-1,1);
    if (variable_struct_exists(global.input,"jump_pressed"))        jump_p = jump_p || global.input.jump_pressed;
    if (variable_struct_exists(global.input,"jump_down"))           jump_h = jump_h || global.input.jump_down;
}
if (attack_cooldown>0) attack_cooldown--;

// ---------- heal ----------
if (k_heal_p && (!variable_global_exists("paused") || !global.paused) && !_skip_overrides_this_frame) {
    script_health_use_flask();
}

// ---------- hurt pulse ----------
var _pulse_now = (variable_global_exists("_hurt_pulse_id") ? global._hurt_pulse_id : 0);
if (_pulse_now != last_seen_hurt_pulse && state!="drink") {
    last_seen_hurt_pulse = _pulse_now;
    pc_combo_active = false;
    if (state=="ledge"||state=="ledge_pull") vsp = max(vsp,1.5);
    state = "hurt";
    if (sprHurt_step != -1) { __set_sprite_keep_feet(sprHurt_step,hurt_anim_speed); image_index=0; }
    hsp=0;
    var frames = (sprite_index==sprHurt_step)? image_number : 0;
    if (sprHurt_step==-1 || frames<=1) hurt_lock_timer = max(1,hurt_lock_frames_default); else hurt_lock_timer = 0;
}

// ---------- attack sprite detection ----------
var _sprA = __spr("spriteSwordAttackA");
var _sprB = __spr("spriteSwordAttackB");
var _sprC = __spr("spriteSwordAttackC");
var _sprU = __spr("spriteSwordAttackUp");
var _is_attack_sprite =
    (_sprA!=-1 && sprite_index==_sprA) ||
    (_sprB!=-1 && sprite_index==_sprB) ||
    (_sprC!=-1 && sprite_index==_sprC) ||
    (_sprU!=-1 && sprite_index==_sprU);

if (_is_attack_sprite) {
    state="attack";
    var _frames = max(1,image_number);
    var at_last = (image_index >= _frames - 1.0);
    if (!pc_combo_active && at_last) { attack_release_linger++; if (attack_release_linger>=2) attack_release_linger=0; }
    else attack_release_linger=0;
} else {
    attack_release_linger=0;
    if (pc_combo_active) pc_combo_active = false;
}

// ---------- env pre-check ----------
var on_ground = __on_ground_check();


// ======================================================================
// ================= M A R K E R - B A S E D   L E D G E S ==============
// ======================================================================

if (!variable_instance_exists(id,"ledge_enabled"))     ledge_enabled  = true;
if (!variable_instance_exists(id,"ledge_dir"))         ledge_dir      = 1;
if (!variable_instance_exists(id,"ledge_phase"))       ledge_phase    = 0;
if (!variable_instance_exists(id,"ledge_regrab_cd"))   ledge_regrab_cd= 0;
if (!variable_instance_exists(id,"ledge_grab_grace"))  ledge_grab_grace = 0;
if (!variable_instance_exists(id,"ledge_autopull"))    ledge_autopull = true;
if (!variable_instance_exists(id,"ledge_pull_time"))   ledge_pull_time= 0.30;
if (!variable_instance_exists(id,"ledge_snap_y"))      ledge_snap_y   = y;

// phase targets
if (!variable_instance_exists(id,"phase0_tx")) phase0_tx = x;
if (!variable_instance_exists(id,"phase0_ty")) phase0_ty = y;
if (!variable_instance_exists(id,"phase1_tx")) phase1_tx = x;
if (!variable_instance_exists(id,"phase1_ty")) phase1_ty = y;
if (!variable_instance_exists(id,"phase2_tx")) phase2_tx = x;
if (!variable_instance_exists(id,"phase2_ty")) phase2_ty = y;

// --- helpers for marker approach ---
function __move_axis_pixelwise(_dx, _dy, _spd) {
    var moved = 0;
    var sx = sign(_dx);
    var sy = sign(_dy);
    var ax = abs(_dx);
    var ay = abs(_dy);

    if (ax > 0) {
        var mx = min(ax, _spd);
        repeat (floor(mx)) { if (!__rect_hits_solid(sx, 0)) { x += sx; moved++; } else return moved; }
        var fx = mx - floor(mx);
        if (fx > 0 && !__rect_hits_solid(sx*fx, 0)) { x += sx*fx; moved += fx; }
        return moved;
    }
    if (ay > 0) {
        var my = min(ay, _spd);
        repeat (floor(my)) { if (!__rect_hits_solid(0, sy)) { y += sy; moved++; } else return moved; }
        var fy = my - floor(my);
        if (fy > 0 && !__rect_hits_solid(0, sy*fy)) { y += sy*fy; moved += fy; }
        return moved;
    }
    return 0;
}
function __pull_phase_step(_tx, _ty, _prefer_axis) {
    var px = _tx - x;
    var py = _ty - y;
    var frames_left = max(1, round(ledge_pull_time * room_speed * 0.85));
    var _spd = min(max(1.0, (abs(px) + abs(py)) / frames_left), 8);
    if (_prefer_axis == "y") {
        if (abs(py) > 0.001) __move_axis_pixelwise(0,  py, _spd);
        if (abs(px) > 0.001) __move_axis_pixelwise(px, 0,  _spd);
    } else {
        if (abs(px) > 0.001) __move_axis_pixelwise(px, 0,  _spd);
        if (abs(py) > 0.001) __move_axis_pixelwise(0,  py, _spd);
    }
    return (point_distance(x, y, _tx, _ty) <= 1.0);
}

function __begin_ledge_from_marker(_m) {
    var fx = (_m.facing == 0) ? (sign(image_xscale)==0? 1 : sign(image_xscale)) : _m.facing;

    var hang_x = _m.x + ((_m.facing == 0) ? _m.hang_dx : _m.hang_dx * fx);
    var hang_y = _m.y + _m.hang_dy;

    // stand target: push deeper onto platform (+8px)
    var tx = _m.x + ((_m.facing == 0) ? (_m.pull_dx + 8) : (_m.pull_dx + 8) * fx);
    var ty = _m.y + _m.pull_dy;

    state = "ledge";
    ledge_dir = fx;
    hsp = 0;
    vsp = 0;

    var dx = hang_x - x;
    var sx = sign(dx);
    var ax = abs(dx);
    repeat (floor(ax)) { if (!__rect_hits_solid(sx, 0)) x += sx; }
    var fxr = ax - floor(ax);
    if (fxr > 0 && !__rect_hits_solid(sx*fxr, 0)) x += sx*fxr;

    var dy = hang_y - y;
    if (dy > 0) {
        var left = dy;
        while (left > 0) {
            if (!__rect_hits_solid(0, 1)) { y += 1; left -= 1; }
            else break;
        }
    }
    ledge_snap_y = y;

    var sprGrab = __spr("spritePlayerLedgeGrab");
    if (sprGrab != -1) { __set_sprite_keep_feet(sprGrab, 0.65); image_index = 0; }

    // --- phase targets: OUT (bigger), UP (higher), then final stand ---
    ledge_phase = 0;
    phase0_tx   = x + (ledge_dir * 14);
    phase0_ty   = y;
    phase1_tx   = phase0_tx;
    phase1_ty   = _m.y - 12;
    phase2_tx   = tx;
    phase2_ty   = ty;

    ledge_pull_time   = 0.30;
    ledge_grab_grace  = 7;
    ledge_regrab_cd   = 16;
    ledge_autopull    = _m.autopull;

    image_xscale = (ledge_dir > 0) ? 1 : -1;
}

function __try_ledge_marker(_dir) {
    if (!ledge_enabled || ledge_regrab_cd > 0) return false;
    if (state == "ledge" || state == "ledge_pull") return false;
    if (ledge_walkoff_lock > 0) return false;

    // Only allow grabs while falling, not rising/jumping.
    if (__on_ground_check() || vsp < 0.3) return false;

    // Block while attacking
    var __atkA = __spr("spriteSwordAttackA");
    var __atkB = __spr("spriteSwordAttackB");
    var __atkC = __spr("spriteSwordAttackC");
    var __atkU = __spr("spriteSwordAttackUp");
    var is_attacking =
        (__atkA!=-1 && sprite_index==__atkA) ||
        (__atkB!=-1 && sprite_index==__atkB) ||
        (__atkC!=-1 && sprite_index==__atkC) ||
        (__atkU!=-1 && sprite_index==__atkU) ||
        pc_combo_active;
    if (is_attacking) return false;

    var R   = 80;
    var VY  = 48;
    var fwd = (image_xscale >= 0) ? 1 : -1;

    __scan_R  = R;
    __scan_VY = VY;
    __scan_fwd = fwd;

    __ledge_best    = noone;
    __ledge_best_d2 = 1000000000.0;

    if (object_exists(oLedge)) {
        with (oLedge) {
            var dx_local = x - other.x;
            var dy_local = y - other.y;

            var ok = true;
            if (ok && facing != 0) if (facing != other.__scan_fwd) ok = false;
            if (ok && abs(dx_local) > other.__scan_R) ok = false;
            if (ok && abs(dy_local) > other.__scan_VY) ok = false;

            if (ok) {
                var d2_local = dx_local*dx_local + dy_local*dy_local;
                if (d2_local < other.__ledge_best_d2) {
                    other.__ledge_best_d2 = d2_local;
                    other.__ledge_best    = id;
                }
            }
        }
    }

    if (__ledge_best != noone) {
        var _best_id = __ledge_best;
        with (_best_id) {
            other.__begin_ledge_from_marker(id);
        }
        return true;
    }
    return false;
}


// --- ledge state machine (marker-driven only) ---
if (ledge_enabled) {
    if (state=="ledge") {
        y = ledge_snap_y;
        hsp = 0;
        vsp = 0;
        image_xscale = (ledge_dir>0) ? 1 : -1;
        if (sprLedgeGrab_step != -1 && sprite_index != sprLedgeGrab_step) __set_sprite_keep_feet(sprLedgeGrab_step, 0.25);

        if (ledge_grab_grace>0) ledge_grab_grace--;

        var want_drop = k_down && (ledge_grab_grace<=0);
        if (want_drop) {
            state="jump";
            vsp=1.5;
            ledge_regrab_cd=16;
            ledge_nojump_frames=6;
        } else {
            if (!variable_instance_exists(id,"__ledge_t")) __ledge_t = 0;
            __ledge_t += 1/room_speed;

            var jump_now = k_jump_p;
            var should_pull = jump_now || ((ledge_grab_grace<=0) && (ledge_autopull) && (__ledge_t>=0.05));
            if (should_pull) {
                var pre_dx = ledge_dir * 14;
                if (!__rect_hits_solid(pre_dx, 0)) x += pre_dx;

                var sprPull = __spr("spritePlayerLedgePull");
                if (sprPull != -1) {
                    __set_sprite_keep_feet(sprPull, 0.90);
                    image_index = 0;
                    var frames = max(1, image_number);
                    var spd    = max(0.01, image_speed);
                    ledge_pull_time = frames / spd / room_speed;
                } else {
                    ledge_pull_time = 0.30;
                }

                state="ledge_pull";

                var watch_frames = ceil(max(ledge_pull_time * room_speed * 2.5, room_speed * 6.0));
                ledge_pull_watch = watch_frames;

                ledge_stall_frames = 0;
                ledge_prev_x = x;
                ledge_prev_y = y;
                ledge_prev_phase = ledge_phase;

                jump_buffer_timer = 0;
                coyote_timer      = 0;
                if (variable_global_exists("input") && is_struct(global.input)) global.input.jump_pressed = false;
            }
        }
    }
    else if (state=="ledge_pull") {
        if (ledge_regrab_cd>0) ledge_regrab_cd--;

        var reached = false;
        if (ledge_phase == 0) { reached = __pull_phase_step(phase0_tx, phase0_ty, "x"); if (reached) ledge_phase = 1; }
        if (ledge_phase == 1) { reached = __pull_phase_step(phase1_tx, phase1_ty, "y"); if (reached) ledge_phase = 2; }
        if (ledge_phase == 2) { reached = __pull_phase_step(phase2_tx, phase2_ty, "y"); }

        var progressed = (abs(x - ledge_prev_x) > 0.05) || (abs(y - ledge_prev_y) > 0.05) || (ledge_phase != ledge_prev_phase);
        if (progressed) {
            ledge_stall_frames = 0;
            ledge_prev_x = x;
            ledge_prev_y = y;
            ledge_prev_phase = ledge_phase;
        } else {
            ledge_stall_frames++;
        }
        if (!progressed) ledge_pull_watch--;

        var close_enough = (abs(x - phase2_tx) <= 10) && (abs(y - phase2_ty) <= 12);

        if (sprLedgePull_step != -1 && sprite_index == sprLedgePull_step && image_number > 0 && image_index >= image_number - 1.0) {
            image_index = image_number - 1.0;
            image_speed = 0;
        }
        var finished_anim = (sprLedgePull_step != -1) && (sprite_index == sprLedgePull_step) && (image_speed == 0) && (image_index >= image_number - 1.0);

        var stuck = (ledge_stall_frames >= ceil(room_speed * 1.0));

        if (reached || close_enough || finished_anim || stuck || (ledge_pull_watch <= 0)) {
            // --- FINAL: prefer a SAFE LAND near the intended stand point ---
            var want_x = phase2_tx;
            var want_y = phase2_ty;
            var found = __find_safe_stand_near(want_x, want_y, ledge_dir);
            if (found[0]) {
                x = found[1];
                y = found[2];
            } else {
                // fallback: sweep/snap + settle
                var dx_final = want_x - x;
                if (abs(dx_final) > 0.001) __move_axis_pixelwise(dx_final, 0, 10);
                var dx_left = want_x - x;
                if (abs(dx_left) <= 4 && !__rect_hits_solid(dx_left, 0)) x = want_x;
                if (y < want_y) y = want_y;
                var nudged_x = x + (ledge_dir > 0 ? 1 : -1);
                if (!__rect_hits_solid(nudged_x - x, 0)) x = nudged_x;

                var settle_limit = 48;
                var s = 0;
                while (s < settle_limit && !__rect_hits_solid(0, 1)) { y += 1; s++; }
                if (__rect_hits_solid(0, 1)) y -= 1;
            }

            // Only exit once we truly have ground underfoot
            if (!__on_ground_check()) {
                // give ourselves a few extra frames to hunt a landing
                ledge_pull_watch = max(ledge_pull_watch, ceil(room_speed * 0.5));
            } else {
                state="idle";
                if (sprIdle_step != -1) __set_sprite_keep_feet(sprIdle_step,0.4);
                ledge_regrab_cd     = 16;
                ledge_nojump_frames = 8;
                hsp=0; vsp=0;
                jump_buffer_timer = 0;
                coyote_timer      = 0;
                if (variable_global_exists("input") && is_struct(global.input)) global.input.jump_pressed = false;
            }
        } else {
            hsp = 0;
            vsp = 0; // freeze physics during pull
        }
    }
    else {
        if (ledge_regrab_cd>0) ledge_regrab_cd--;
        var wish_dir = (abs(move_x)>0.001)? sign(move_x) : (sign(image_xscale)==0?1:sign(image_xscale));
        __try_ledge_marker(wish_dir);
    }
}
// ========================= END LEDGE =========================

// ---------- update lock flags ----------
var ledge_now = (state=="ledge") || (state=="ledge_pull");
var in_lock_state = (state=="drink") || (state=="hurt") || ledge_now;

// ---------- coyote / buffer ----------
if (on_ground) coyote_timer = coyote_time_frames; else if (coyote_timer>0) coyote_timer--;
if (jump_p)    jump_buffer_timer = jump_buffer_time_frames; else if (jump_buffer_timer>0) jump_buffer_timer--;

// ---------- horizontal motion ----------
var hsp_target = in_lock_state ? 0 : (move_x * move_speed);
if (!in_lock_state && on_ground && (pc_combo_active || ledge_now)) hsp_target = 0;
if (!on_ground && pc_combo_active) hsp_target *= air_attack_drift;
hsp = ledge_now ? 0 : hsp_target;

// ---------- jump ----------
var can_jump_buffer = (!in_lock_state && !pc_combo_active && !ledge_now && jump_buffer_timer>0 && coyote_timer>0 && !_skip_overrides_this_frame && (ledge_nojump_frames<=0));
var can_jump_ground = (!in_lock_state && !pc_combo_active && !ledge_now && on_ground && k_jump_p && !_skip_overrides_this_frame && (ledge_nojump_frames<=0));
if (can_jump_buffer || can_jump_ground) { vsp = jump_speed; jump_buffer_timer=0; coyote_timer=0; }

// ---------- gravity ----------
var g = gravity_amt;
if (!on_ground && !ledge_now) {
    if (vsp<0) { if (!k_jump_h) g += gravity_amt*(low_jump_multiplier-1.0); }
    else       { g += gravity_amt*(fall_multiplier-1.0); }
}
vsp += ledge_now ? 0 : g;
if (vsp > max_fall) vsp = max_fall;

// ---------- collisions (H) ----------
if (hsp != 0) {
    var sx = sign(hsp);
    var mx = abs(hsp);
    repeat (floor(mx)) { if (!__rect_hits_solid(sx,0)) x+=sx; else { hsp=0; break; } }
    var fx = mx - floor(mx);
    if (fx>0 && hsp!=0) { if (!__rect_hits_solid(sx*fx,0)) x+=sx*fx; else hsp=0; }
}

// ---------- collisions (V) ----------
if (!ledge_now && vsp != 0) {
    var sy = sign(vsp);
    var my = abs(vsp);
    repeat (floor(my)) { if (!__rect_hits_solid(0,sy)) y+=sy; else { vsp=0; break; } }
    var fy = my - floor(my);
    if (fy>0 && vsp!=0) { if (!__rect_hits_solid(0,sy*fy)) y+=sy*fy; else vsp=0; }
}

// ---------- ground recheck ----------
on_ground = __on_ground_check();

// ---------- walk-off lock ----------
var just_left_ground = (was_on_ground && !on_ground && vsp >= 0);
if (just_left_ground) ledge_walkoff_lock = 10;
was_on_ground = on_ground;

// ---------- facing ----------
if (!in_lock_state && !pc_combo_active && !ledge_now && abs(move_x)>0.001 && !_skip_overrides_this_frame) {
    image_xscale = (move_x>0)? 1 : -1;
}

// ---------- locomotion state ----------
if (!pc_combo_active && !ledge_now && !_skip_overrides_this_frame) {
    if (!in_lock_state) {
        if (!on_ground) {
            if (sprJump_step != -1) { __set_sprite_keep_feet(sprJump_step,0.3); state="jump"; }
            else state="jump";
        } else if (abs(move_x)>0.001) {
            if (sprRun_step  != -1) { __set_sprite_keep_feet(sprRun_step ,1.2); state="run";  }
            else state="run";
        } else {
            if (sprIdle_step != -1) { __set_sprite_keep_feet(sprIdle_step,0.4); state="idle"; }
            else state="idle";
        }
    }
}

// ---------- hurt auto-exit ----------
if (state=="hurt" && hurt_lock_timer>0 && !_skip_overrides_this_frame) {
    hurt_lock_timer--;
    if (hurt_lock_timer<=0) {
        if (!on_ground) {
            if (sprJump_step != -1) { __set_sprite_keep_feet(sprJump_step,0.3); state="jump"; }
            else state="jump";
        } else if (abs(move_x)>0.001) {
            if (sprRun_step  != -1) { __set_sprite_keep_feet(sprRun_step ,1.2); state="run";  }
            else state="run";
        } else {
            if (sprIdle_step != -1) { __set_sprite_keep_feet(sprIdle_step,0.4); state="idle"; }
            else state="idle";
        }
    }
}

// ---------- clear guard ----------
if (attack_just_started) attack_just_started = false;

