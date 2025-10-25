/// oPlayer — Step  (physics, collisions, heal/hurt, attack anim + LEDGE grab/pull)

// ===== One–frame guard so the first attack frame can't be clobbered =====
if (!variable_instance_exists(id, "attack_just_started")) attack_just_started = false;
var _skip_overrides_this_frame = attack_just_started;
// =======================================================================

// ---- Ensure tunables exist (hot-reload safety) ----
if (!variable_instance_exists(id, "air_attack_drift"))         air_attack_drift         = 1.15;
if (!variable_instance_exists(id, "attack_cooldown"))          attack_cooldown          = 0;
if (!variable_instance_exists(id, "attack_end_fired"))         attack_end_fired         = false;
if (!variable_instance_exists(id, "drink_anim_speed"))         drink_anim_speed         = 0.35;
if (!variable_instance_exists(id, "hurt_anim_speed"))          hurt_anim_speed          = 0.55;
if (!variable_instance_exists(id, "hurt_lock_frames_default")) hurt_lock_frames_default = 10;
if (!variable_instance_exists(id, "hurt_lock_timer"))          hurt_lock_timer          = 0;
if (!variable_instance_exists(id, "pc_combo_active"))          pc_combo_active          = false;
if (!variable_instance_exists(id, "last_seen_hurt_pulse"))     last_seen_hurt_pulse     = (variable_global_exists("_hurt_pulse_id") ? global._hurt_pulse_id : 0);
if (!variable_instance_exists(id, "attack_release_linger"))    attack_release_linger    = 0;
if (!variable_instance_exists(id, "use_player_step_attacks"))  use_player_step_attacks  = false; // attacks handled in oPlayerCombat

// ---- Safe initializer for global.tm_solids ----
if (!variable_global_exists("tm_solids")) global.tm_solids = undefined;
function __ensure_tm_solids() {
    if (is_undefined(global.tm_solids)) {
        var _lid = layer_get_id("Solids");
        global.tm_solids = (_lid != -1) ? layer_tilemap_get_id(_lid) : undefined;
    }
    return global.tm_solids;
}
__ensure_tm_solids();

// ---------- Tilemap helpers ----------
function __tile_solid_at(_x, _y) {
    return (!is_undefined(global.tm_solids)) && (tilemap_get_at_pixel(global.tm_solids, _x, _y) != 0);
}
function __rect_hits_solid(_dx, _dy) {
    var l = bbox_left   + _dx;
    var r = bbox_right  + _dx;
    var t = bbox_top    + _dy;
    var b = bbox_bottom + _dy;
    var eps = 0.1;
    if (__tile_solid_at(l + eps, t + eps)) return true;
    if (__tile_solid_at(r - eps, t + eps)) return true;
    if (__tile_solid_at(l + eps, b - eps)) return true;
    if (__tile_solid_at(r - eps, b - eps)) return true;
    return false;
}
function __on_ground_check() {
    var eps = 0.1;
    var l = bbox_left, r = bbox_right, b = bbox_bottom;
    return __tile_solid_at(l + eps, b + 1) || __tile_solid_at(r - eps, b + 1);
}

// ---------- Sprite switch helper: preserve FEET position ----------
function __set_sprite_keep_feet(_spr, _speed) {
    if (is_undefined(_spr)) return;
    var cur_yoff = sprite_get_yoffset(sprite_index);
    var cur_bot  = sprite_get_bbox_bottom(sprite_index);
    var feet_y   = y - cur_yoff + cur_bot;

    sprite_index = _spr; // _spr is Asset.GMSprite
    if (!is_undefined(_speed)) image_speed = _speed;

    var new_yoff = sprite_get_yoffset(sprite_index);
    var new_bot  = sprite_get_bbox_bottom(sprite_index);
    y = feet_y - (new_bot - new_yoff);
}

// -------- INPUT (keyboard wins; then oInput) --------
var kx = (keyboard_check(vk_right) || keyboard_check(ord("D")))
       - (keyboard_check(vk_left)  || keyboard_check(ord("A")));
kx = clamp(kx, -1, 1);

var k_jump_p = keyboard_check_pressed(vk_space);
var k_jump_h = keyboard_check(vk_space);
var k_heal_p = keyboard_check_pressed(ord("E"));
var k_down   = keyboard_check(vk_down) || keyboard_check(ord("S"));

var move_x = kx;
var jump_p = k_jump_p;
var jump_h = k_jump_h;

if (variable_global_exists("input") && is_struct(global.input)) {
    if (move_x == 0 && variable_struct_exists(global.input, "move_x"))
        move_x = clamp(global.input.move_x, -1, 1);

    if (variable_struct_exists(global.input, "jump_pressed"))
        jump_p = jump_p || global.input.jump_pressed;

    if (variable_struct_exists(global.input, "jump_down"))
        jump_h = jump_h || global.input.jump_down;
}

// -------- Optional legacy cooldown --------
if (attack_cooldown > 0) attack_cooldown--;

// -------- I-FRAME VISUAL -----------------------------------------
if (variable_global_exists("_iframes_timer") && global._iframes_timer > 0) {
    image_blend = make_color_rgb(255, 160, 160);
    image_alpha = 1;
} else {
    image_blend = c_white;
    image_alpha = 1;
}

// -------- HEAL (E key) --------------------------------------------
if (k_heal_p && (!variable_global_exists("paused") || !global.paused) && !_skip_overrides_this_frame) {
    script_health_use_flask();
}

// -------- HURT pulse consumption (overrides) -----------------------
var _pulse_now = (variable_global_exists("_hurt_pulse_id") ? global._hurt_pulse_id : 0);
var _new_hurt  = (_pulse_now != last_seen_hurt_pulse);
if (_new_hurt && state != "drink") {
    last_seen_hurt_pulse = _pulse_now;
    pc_combo_active = false;
    attack_lock     = false;
    if (state == "ledge" || state == "ledge_pull") vsp = max(vsp, 1.5);

    state = "hurt";
    if (!is_undefined(spr_hurt)) {
        __set_sprite_keep_feet(spr_hurt, hurt_anim_speed);
        image_index = 0;
    }
    hsp = 0;

    var frames_in_strip = (!is_undefined(spr_hurt) && sprite_index == spr_hurt) ? image_number : 0;
    if (is_undefined(spr_hurt) || frames_in_strip <= 1) { hurt_lock_timer = max(1, hurt_lock_frames_default); }
    else { hurt_lock_timer = 0; }
}

// ==================== ATTACK ANIM HARDENING + RELEASE ====================
var _sprA = __spr("spriteSwordAttackA");
var _sprB = __spr("spriteSwordAttackB");
var _sprC = __spr("spriteSwordAttackC");
var _sprU = __spr("spriteSwordAttackUp");

var _is_attack_sprite =
    (!is_undefined(_sprA) && sprite_index == _sprA) ||
    (!is_undefined(_sprB) && sprite_index == _sprB) ||
    (!is_undefined(_sprC) && sprite_index == _sprC) ||
    (!is_undefined(_sprU) && sprite_index == _sprU);

if (_is_attack_sprite) {
    state = "attack";
}

if (_is_attack_sprite) {
    var _frames = max(1, image_number);
    var at_last = (image_index >= _frames - 1.0);
    if (!pc_combo_active && at_last) {
        attack_release_linger++;
        if (attack_release_linger >= 2) {
            attack_release_linger = 0;
        }
    } else {
        attack_release_linger = 0;
    }
} else {
    attack_release_linger = 0;
}

// ----------------- Locks / state booleans -----------------
var in_lock_state  = (state == "drink") || (state == "hurt");
var attacking_now  = _is_attack_sprite || pc_combo_active;

// -------- ENV / GROUND CHECK (pre-move) ------------------
var on_ground = __on_ground_check();


// ===================== LEDGE: ENTER/MAINTAIN/PULL =====================
// Tunables for 43x26 mask, 16px tiles
var GRAB_MAX_GAP_PX   = 1;
var HEAD_CLEAR_PX     = 9;
var MAX_LIP_SEARCH_PX = 16;
var MAX_DROP_TO_LIP   = 2;
var MAX_RISE_TO_LIP   = 12;
var PULL_FWD_X_PX     = 11;
var PULL_UP_Y_PX      = 18;
var PULL_TIME_S       = 0.28;
var PULL_SEGMENTS     = 10;
var REGRAB_COOLDOWN   = 10; // frames

// Ensure vars
if (!variable_instance_exists(id,"ledge_snap_y"))     ledge_snap_y   = y;
if (!variable_instance_exists(id,"ledge_dir"))        ledge_dir      = 1;
if (!variable_instance_exists(id,"ledge_t"))          ledge_t        = 0;
if (!variable_instance_exists(id,"ledge_pull_time"))  ledge_pull_time= PULL_TIME_S;
if (!variable_instance_exists(id,"ledge_start_x"))    ledge_start_x  = x;
if (!variable_instance_exists(id,"ledge_start_y"))    ledge_start_y  = y;
if (!variable_instance_exists(id,"ledge_target_x"))   ledge_target_x = x;
if (!variable_instance_exists(id,"ledge_target_y"))   ledge_target_y = y;
if (!variable_instance_exists(id,"ledge_enabled"))    ledge_enabled  = true;
if (!variable_instance_exists(id,"ledge_regrab_cd"))  ledge_regrab_cd= 0;
if (ledge_regrab_cd > 0) ledge_regrab_cd--;

// Local helpers
function __solid_xy(_x, _y) {
    return (!is_undefined(global.tm_solids)) && (tilemap_get_at_pixel(global.tm_solids, _x, _y) != 0);
}
function __nearest_wall_gap(_dir, _probe_y, _gap_max) {
    if (_dir > 0) {
        for (var dx = 0; dx <= _gap_max; dx++) if (__solid_xy(bbox_right + dx, _probe_y)) return dx;
    } else {
        for (var dxn = 0; dxn <= _gap_max; dxn++) if (__solid_xy(bbox_left - dxn, _probe_y)) return dxn;
    }
    return -1;
}
// Prefer higher lips first
function __find_lip_y(_wall_x, _chest_y, _search_px) {
    for (var oy = -_search_px; oy <= _search_px; oy++) {
        var yy_air   = _chest_y + oy;
        var yy_solid = yy_air + 1;
        if (!__solid_xy(_wall_x, yy_air) && __solid_xy(_wall_x, yy_solid)) return yy_air;
    }
    return undefined;
}
function __is_valid_lip(_dir, _gap_max, _head_clear, _search_px, _max_drop, _max_rise) {
    var h = bbox_bottom - bbox_top;
    var chest_y = bbox_top + clamp(round(h * 0.35), 8, 14);
    var feet_y  = bbox_bottom + 1;

    var gap = __nearest_wall_gap(_dir, chest_y, _gap_max);
    if (gap < 0) return [false, 0, 0];

    var wall_x = (_dir > 0) ? (bbox_right + gap) : (bbox_left - gap);

    var lip_y = __find_lip_y(wall_x, chest_y, _search_px);
    if (is_undefined(lip_y)) return [false, 0, 0];

    var dY = lip_y - chest_y;
    if (dY > _max_drop) return [false, 0, 0];
    if (dY < -_max_rise) return [false, 0, 0];

    if (__solid_xy(wall_x, feet_y)) return [false, 0, 0];
    if (__solid_xy(wall_x, chest_y - _head_clear)) return [false, 0, 0];

    return [true, wall_x, lip_y];
}
// Find a *standing* Y at tx: rise a bit, then drop to first ground
function __solve_standing_y(_tx, _pull_up) {
    var max_drop = 32;
    var yy = y - _pull_up - 2;

    // small rise if we start embedded
    for (var up = 0; up < 8; up++) {
        if (!__rect_hits_solid(_tx - x, (yy - up) - y)) { yy -= up; break; }
    }
    // drop until ground
    var d = 0;
    while (d < max_drop) {
        if (__rect_hits_solid(_tx - x, (yy + 1) - y)) break;
        yy += 1; d++;
    }
    return yy;
}
function __resolve_small_embed() {
    var tries = 6;
    while (__rect_hits_solid(0,0) && tries-- > 0) y -= 1;
}

// Attempt a ledge grab (all tunables passed IN)
function __try_ledge_grab(_dir, _gap_max, _head_clear, _search_px, _max_drop, _max_rise, _pull_fwd, _pull_up) {
    if (!ledge_enabled) return false;
    if (ledge_regrab_cd > 0) return false;
    if (state == "ledge" || state == "ledge_pull") return false;

    var sprA = __spr("spriteSwordAttackA");
    var sprB = __spr("spriteSwordAttackB");
    var sprC = __spr("spriteSwordAttackC");
    var sprU = __spr("spriteSwordAttackUp");
    var is_attack_now =
        (!is_undefined(sprA) && sprite_index == sprA) ||
        (!is_undefined(sprB) && sprite_index == sprB) ||
        (!is_undefined(sprC) && sprite_index == sprC) ||
        (!is_undefined(sprU) && sprite_index == sprU) ||
        pc_combo_active;
    if (is_attack_now) return false;

    if (vsp <= 0.25) return false;
    if (__on_ground_check()) return false;

    var vr = __is_valid_lip(_dir, _gap_max, _head_clear, _search_px, _max_drop, _max_rise);
    if (!vr[0]) return false;
    var wall_x = vr[1];

    // Snap X flush to wall (1px safety), no Y move
    var deltaX = (_dir > 0) ? (wall_x - 1) - bbox_right : (wall_x + 1) - bbox_left;
    if (!__rect_hits_solid(deltaX, 0)) x += deltaX;

    state       = "ledge";
    ledge_dir   = _dir;
    hsp = 0; vsp = 0;

    if (!is_undefined(spr_ledge_grab)) { __set_sprite_keep_feet(spr_ledge_grab, 0.25); image_index = 0; }

    ledge_start_x = x;  ledge_start_y = y;
    ledge_target_x = x + ledge_dir * _pull_fwd; // provisional
    ledge_target_y = y - _pull_up;              // provisional
    ledge_snap_y   = y;

    return true;
}

// --- LEDGE STATE MACHINE ---
if (ledge_enabled) {
    if (state == "ledge") {
        // Maintain hang
        y = ledge_snap_y;
        hsp = 0; vsp = 0;
        image_xscale = (ledge_dir > 0) ? 1 : -1;
        if (!is_undefined(spr_ledge_grab) && sprite_index != spr_ledge_grab) __set_sprite_keep_feet(spr_ledge_grab, 0.25);

        // Drop off
        if (k_down || (move_x != 0 && sign(move_x) == -ledge_dir)) {
            state = "jump"; vsp = 1.5; ledge_regrab_cd = REGRAB_COOLDOWN;
        }
        // Pull up (Jump)
        else if (jump_p) {
            // Solve a collision-safe stand target on top
            var tx = x + ledge_dir * PULL_FWD_X_PX;
            var ty = __solve_standing_y(tx, PULL_UP_Y_PX);

            // Fallback if somehow blocked
            if (__rect_hits_solid(tx - x, ty - y)) {
                tx = x + ledge_dir * (PULL_FWD_X_PX - 4);
                ty = y - (PULL_UP_Y_PX - 2);
            }

            state = "ledge_pull";
            image_index = 0;
            if (!is_undefined(spr_ledge_pull)) __set_sprite_keep_feet(spr_ledge_pull, 0.65);

            ledge_t = 0;
            ledge_start_x = x; ledge_start_y = y;
            ledge_target_x = tx; ledge_target_y = ty;

            var frames_pull = max(1, image_number);
            var dur_s = (image_speed > 0) ? (frames_pull / (image_speed * room_speed)) : PULL_TIME_S;
            ledge_pull_time = max(0.15, dur_s);

            ledge_regrab_cd = REGRAB_COOLDOWN; // block immediate re-grab during pull
        }
    }
    else if (state == "ledge_pull") {
        // Interpolate with INCREMENTAL collision: step from last safe point
        ledge_t += 1 / room_speed;
        var t = clamp(ledge_t / max(0.001, ledge_pull_time), 0, 1);

        var prevx = x, prevy = y;
        var steps = max(2, PULL_SEGMENTS);
        var blocked = false;

        for (var s = 1; s <= steps; s++) {
            var tt = t * (s / steps);
            var ix = lerp(ledge_start_x, ledge_target_x, tt);
            var iy = lerp(ledge_start_y, ledge_target_y, tt);
            var dx = ix - prevx;
            var dy = iy - prevy;
            if (__rect_hits_solid(dx, dy)) { blocked = true; break; }
            prevx = ix; prevy = iy;
        }
        x = prevx; y = prevy;

        hsp = 0; vsp = 0;

        // Finish either on time or when anim ends
        var finished = (image_speed == 0) ? (t >= 1.0) : (image_index >= image_number - 1.0);
        if (t >= 1.0 || finished || blocked) {
            // Final safety: snap feet to ground at current X
            var stand_y = __solve_standing_y(x, 0);
            if (!__rect_hits_solid(0, stand_y - y)) y = stand_y;
            __resolve_small_embed();

            state = "idle";
            if (!is_undefined(spr_idle)) __set_sprite_keep_feet(spr_idle, 0.4);

            ledge_regrab_cd = REGRAB_COOLDOWN; // short cooldown so we don't instantly re-grab
        }
    }
    else {
        // Try a grab only when near a wall; use facing if no input
        var wish_dir = (move_x != 0) ? sign(move_x) : sign(image_xscale);
        if (wish_dir == 0) wish_dir = 1;
        __try_ledge_grab(
            wish_dir,
            GRAB_MAX_GAP_PX, HEAD_CLEAR_PX, MAX_LIP_SEARCH_PX,
            MAX_DROP_TO_LIP, MAX_RISE_TO_LIP,
            PULL_FWD_X_PX, PULL_UP_Y_PX
        );
    }
}
// =================== END LEDGE ===================


// ----------------- Locks / state booleans (update with ledge) -----------------
var ledge_now  = (state == "ledge") || (state == "ledge_pull");
in_lock_state  = in_lock_state || ledge_now;

// -------- COYOTE & JUMP BUFFER TIMERS --------------------
if (!variable_instance_exists(id, "coyote_time_frames"))      coyote_time_frames = 6;
if (!variable_instance_exists(id, "jump_buffer_time_frames")) jump_buffer_time_frames = 6;
if (!variable_instance_exists(id, "coyote_timer"))            coyote_timer = 0;
if (!variable_instance_exists(id, "jump_buffer_timer"))       jump_buffer_timer = 0;

if (on_ground) coyote_timer = coyote_time_frames; else if (coyote_timer > 0) coyote_timer--;
if (jump_p)    jump_buffer_timer = jump_buffer_time_frames; else if (jump_buffer_timer > 0) jump_buffer_timer--;

// -------- HORIZONTAL MOVEMENT ----------------------------
var hsp_target = in_lock_state ? 0 : (move_x * move_speed);
if (!in_lock_state && on_ground && (pc_combo_active || ledge_now)) hsp_target = 0;
if (!on_ground && pc_combo_active) hsp_target *= air_attack_drift;
hsp = ledge_now ? 0 : hsp_target;

// -------- EXECUTE JUMP (buffer + coyote) -----------------
var can_jump_buffer = (!in_lock_state && !pc_combo_active && !ledge_now && jump_buffer_timer > 0 && coyote_timer > 0 && !_skip_overrides_this_frame);
var can_jump_ground = (!in_lock_state && !pc_combo_active && !ledge_now && on_ground && jump_p && !_skip_overrides_this_frame);
if (can_jump_buffer || can_jump_ground) {
    vsp = jump_speed;
    jump_buffer_timer = 0;
    coyote_timer      = 0;
}

// -------- VARIABLE GRAVITY -------------------------------
var g = gravity_amt;
if (!on_ground && !ledge_now) {
    if (vsp < 0) {
        if (!jump_h) g += gravity_amt * (low_jump_multiplier - 1.0);
    } else {
        g += gravity_amt * (fall_multiplier - 1.0);
    }
}
vsp += ledge_now ? 0 : g;
if (vsp > max_fall) vsp = max_fall;

// -------- COLLISIONS (H) — tilemap -----------------------
if (hsp != 0) {
    var sx = sign(hsp);
    var mx = abs(hsp);
    repeat (floor(mx)) { if (!__rect_hits_solid(sx, 0)) x += sx; else { hsp = 0; break; } }
    var fracx = mx - floor(mx);
    if (fracx > 0 && hsp != 0) { if (!__rect_hits_solid(sx * fracx, 0)) x += sx * fracx; else hsp = 0; }
}

// -------- COLLISIONS (V) — tilemap -----------------------
if (!ledge_now && vsp != 0) {
    var sy = sign(vsp);
    var my = abs(vsp);
    repeat (floor(my)) { if (!__rect_hits_solid(0, sy)) y += sy; else { vsp = 0; break; } }
    var fracy = my - floor(my);
    if (fracy > 0 && vsp != 0) { if (!__rect_hits_solid(0, sy * fracy)) y += sy * fracy; else vsp = 0; }
}

// -------- RECHECK GROUND (post-move) ---------------------
on_ground = __on_ground_check();

// -------- FACING ----------------------------------------
if (!in_lock_state && !pc_combo_active && !ledge_now && abs(move_x) > 0.001 && !_skip_overrides_this_frame) {
    image_xscale = (move_x > 0) ? 1 : -1;
}

// -------- LOCOMOTION STATE --------------------------------
if (!pc_combo_active && !ledge_now && !_skip_overrides_this_frame) {
    if (!in_lock_state) {
        if (!on_ground) {
            if (!is_undefined(spr_jump)) { __set_sprite_keep_feet(spr_jump, 0.3); state = "jump"; }
            else state = "jump";
        } else if (abs(move_x) > 0.001) {
            if (!is_undefined(spr_run))  { __set_sprite_keep_feet(spr_run, 1.2); state = "run"; }
            else state = "run";
        } else {
            if (!is_undefined(spr_idle)) { __set_sprite_keep_feet(spr_idle, 0.4); state = "idle"; }
            else state = "idle";
        }
    }
}

// -------- HURT fallback auto-exit (no anim) -------------
if (state == "hurt" && hurt_lock_timer > 0 && !_skip_overrides_this_frame) {
    hurt_lock_timer--;
    if (hurt_lock_timer <= 0) {
        if (!on_ground) {
            if (!is_undefined(spr_jump)) { __set_sprite_keep_feet(spr_jump, 0.3); state = "jump"; }
            else state = "jump";
        } else if (abs(move_x) > 0.001) {
            if (!is_undefined(spr_run))  { __set_sprite_keep_feet(spr_run, 1.2); state = "run"; }
            else state = "run";
        } else {
            if (!is_undefined(spr_idle)) { __set_sprite_keep_feet(spr_idle, 0.4); state = "idle"; }
            else state = "idle";
        }
    }
}

// ===== Clear the one-frame guard at the very end =====
if (attack_just_started) attack_just_started = false;
