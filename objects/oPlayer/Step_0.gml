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
    if (variable_instance_exists(id,"spr_hurt") && spr_hurt != -1) {
        sprite_index = spr_hurt; image_index = 0; image_speed = hurt_anim_speed;
    }
    hsp = 0;

    var frames_in_strip = (sprite_index == spr_hurt) ? image_number : 0;
    if (spr_hurt == -1 || frames_in_strip <= 1) { hurt_lock_timer = max(1, hurt_lock_frames_default); }
    else { hurt_lock_timer = 0; }
}

// ==================== ATTACK ANIM HARDENING + RELEASE ====================
var _sprA = asset_get_index("spriteSwordAttackA");
var _sprB = asset_get_index("spriteSwordAttackB");
var _sprC = asset_get_index("spriteSwordAttackC");
var _sprU = asset_get_index("spriteSwordAttackUp");

var _is_attack_sprite =
    (_sprA != -1 && sprite_index == _sprA) ||
    (_sprB != -1 && sprite_index == _sprB) ||
    (_sprC != -1 && sprite_index == _sprC) ||
    (_sprU != -1 && sprite_index == _sprU);

if (_is_attack_sprite) {
    state = "attack";
    image_speed = 0; // driven by oPlayerCombat
}

if (_is_attack_sprite) {
    var _frames = max(1, image_number);
    var at_last = (image_index >= _frames - 1.0);
    if (!pc_combo_active && at_last) {
        attack_release_linger++;
        if (attack_release_linger >= 2) {
            attack_release_linger = 0;
            // locomotion handoff happens below when combo is inactive
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

// ===================== LEDGE: ENTER/MAINTAIN/PULL (revised) =====================
// ===================== LEDGE: ENTER/MAINTAIN/PULL (parameterized) =====================
// Tunables for this frame
var GRAB_MAX_GAP_PX = 3;   // max distance from wall to allow a grab
var HEAD_CLEAR_PX   = 6;   // empty space above head needed to hang
var PULL_FWD_X_PX   = 12;  // forward distance during pull
var PULL_UP_Y_PX    = 14;  // upward distance during pull

function __solid_xy(_x, _y) {
    return (!is_undefined(global.tm_solids)) && (tilemap_get_at_pixel(global.tm_solids, _x, _y) != 0);
}

// Find nearest wall gap (0.._gap_max) at chest height on _dir side.
// Returns -1 if not found.
function __nearest_wall_gap(_dir, _chest_y, _gap_max) {
    if (_dir > 0) {
        for (var dx = 0; dx <= _gap_max; dx++) {
            var px = bbox_right + dx;
            if (__solid_xy(px, _chest_y)) return dx;
        }
    } else {
        for (var dxn = 0; dxn <= _gap_max; dxn++) {
            var pxl = bbox_left - dxn;
            if (__solid_xy(pxl, _chest_y)) return dxn;
        }
    }
    return -1;
}

// Try to enter ledge grab; snaps X flush, keeps current Y (no big teleports)
function __try_ledge_grab(_dir, _gap_max, _head_clear, _pull_fwd, _pull_up) {
    if (!ledge_enabled) return false;
    if (state == "ledge" || state == "ledge_pull") return false;

    // Don’t grab while attacking/combos
    var sprA = asset_get_index("spriteSwordAttackA");
    var sprB = asset_get_index("spriteSwordAttackB");
    var sprC = asset_get_index("spriteSwordAttackC");
    var sprU = asset_get_index("spriteSwordAttackUp");
    var is_attack_now =
        (sprA != -1 && sprite_index == sprA) ||
        (sprB != -1 && sprite_index == sprB) ||
        (sprC != -1 && sprite_index == sprC) ||
        (sprU != -1 && sprite_index == sprU) ||
        pc_combo_active;
    if (is_attack_now) return false;

    // Falling & not grounded
    if (vsp <= 0.25) return false;
    if (__on_ground_check()) return false;

    // Probe positions
    var chest_y = bbox_top + 14;
    var head_y  = bbox_top + _head_clear;
    var feet_y  = bbox_bottom + 1;

    // 1) Need a wall near chest
    var found_gap = __nearest_wall_gap(_dir, chest_y, _gap_max);
    if (found_gap < 0) return false;

    // 2) Space above head next to the wall
    var wall_x = (_dir > 0) ? (bbox_right + found_gap) : (bbox_left - found_gap);
    if (__solid_xy(wall_x, head_y)) return false;

    // 3) No floor directly in front of feet
    if (__solid_xy(wall_x, feet_y)) return false;

    // Snap flush to wall with 1px safety gap
    var dx_to_flush = (_dir > 0)
        ? ((bbox_right + found_gap) - (bbox_right + 1))   // move left by (found_gap-1)
        : ((bbox_left  - found_gap) - (bbox_left  - 1));  // move right by (found_gap-1)
    x -= dx_to_flush;

    // Enter hang
    state     = "ledge";
    ledge_dir = _dir;
    hsp = 0; vsp = 0;

    if (spr_ledge_grab != -1) { sprite_index = spr_ledge_grab; image_speed = 0.25; }

    ledge_start_x = x;  ledge_start_y = y;
    // Default pull target
    ledge_target_x = x + ledge_dir * _pull_fwd;
    ledge_target_y = y - _pull_up;

    return true;
}

if (ledge_enabled) {
    if (state == "ledge") {
        hsp = 0; vsp = 0;
        image_xscale = (ledge_dir > 0) ? 1 : -1;
        if (spr_ledge_grab != -1 && sprite_index != spr_ledge_grab) { sprite_index = spr_ledge_grab; image_speed = 0.25; }

        // Drop
        if (k_down || (move_x != 0 && sign(move_x) == -ledge_dir)) {
            state = "jump"; vsp = 1.5;
        }
        // Pull up
        else if (jump_p) {
            state = "ledge_pull";
            if (spr_ledge_pull != -1) { sprite_index = spr_ledge_pull; image_index = 0; image_speed = 0.6; }
            ledge_t = 0;

            // Derive duration from anim if available
            var frames_pull = max(1, image_number);
            var dur_s = (image_speed > 0) ? (frames_pull / (image_speed * room_speed)) : ledge_pull_time;
            ledge_pull_time = max(0.15, dur_s);

            // Choose a collision-safe target (shorten path if blocked)
            var tx = x + ledge_dir * PULL_FWD_X_PX;
            var ty = y - PULL_UP_Y_PX;
            var ok = true;
            for (var step = 0; step <= 6; step++) {
                var try_x = x + ledge_dir * max(0, PULL_FWD_X_PX - step * 2);
                var try_y = y - max(0, PULL_UP_Y_PX  - step * 2);
                var dx = try_x - x;
                var dy = try_y - y;
                if (!__rect_hits_solid(dx, dy)) { tx = try_x; ty = try_y; ok = true; break; }
                ok = false;
            }
            ledge_start_x = x; ledge_start_y = y;
            ledge_target_x = ok ? tx : x;
            ledge_target_y = ok ? ty : y;
        }
    }
    else if (state == "ledge_pull") {
        // Timed pull with continuous collision safety
        ledge_t += 1 / room_speed;
        var t = clamp(ledge_t / max(0.001, ledge_pull_time), 0, 1);

        var px = lerp(ledge_start_x, ledge_target_x, t);
        var py = lerp(ledge_start_y, ledge_target_y, t);

        var segs = 4, safe_x = x, safe_y = y, blocked = false;
        for (var s = 1; s <= segs; s++) {
            var tt = t * (s / segs);
            var ix = lerp(ledge_start_x, ledge_target_x, tt);
            var iy = lerp(ledge_start_y, ledge_target_y, tt);
            var dx = ix - x;
            var dy = iy - y;
            if (__rect_hits_solid(dx, dy)) { blocked = true; break; }
            safe_x = ix; safe_y = iy;
        }
        if (blocked) { x = safe_x; y = safe_y; } else { x = px; y = py; }

        hsp = 0; vsp = 0;

        var finished = (image_speed == 0) ? (t >= 1.0) : (image_index >= image_number - 1.0);
        if (t >= 1.0 || finished) {
            state = "idle";
            if (spr_idle != -1) { sprite_index = spr_idle; image_speed = 0.4; }
        }
    }
    else {
        var wish_dir = (move_x != 0) ? sign(move_x) : sign(image_xscale);
        if (wish_dir == 0) wish_dir = 1;
        __try_ledge_grab(wish_dir, GRAB_MAX_GAP_PX, HEAD_CLEAR_PX, PULL_FWD_X_PX, PULL_UP_Y_PX);
    }
}
// =================== END LEDGE (parameterized) ===================


// =================== END LEDGE ===================

// ----------------- Locks / state booleans (update with ledge) -----------------
in_lock_state  = in_lock_state || (state == "ledge") || (state == "ledge_pull");
var ledge_now  = (state == "ledge") || (state == "ledge_pull");

// -------- COYOTE & JUMP BUFFER TIMERS --------------------
if (!variable_instance_exists(id, "coyote_time_frames"))      coyote_time_frames = 6;
if (!variable_instance_exists(id, "jump_buffer_time_frames")) jump_buffer_time_frames = 6;
if (!variable_instance_exists(id, "coyote_timer"))            coyote_timer = 0;
if (!variable_instance_exists(id, "jump_buffer_timer"))       jump_buffer_timer = 0;

if (on_ground) coyote_timer = coyote_time_frames; else if (coyote_timer > 0) coyote_timer--;
if (jump_p)    jump_buffer_timer = jump_buffer_time_frames; else if (jump_buffer_timer > 0) jump_buffer_timer--;

// -------- HORIZONTAL MOVEMENT ----------------------------
var hsp_target = in_lock_state ? 0 : (move_x * move_speed);

// Only lock grounded movement when actually attacking right now (or ledge states)
if (!in_lock_state && on_ground && (pc_combo_active || ledge_now)) {
    hsp_target = 0;
}

// Add a touch of extra drift when attacking mid-air
if (!on_ground && pc_combo_active) {
    hsp_target *= air_attack_drift;
}

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
    repeat (floor(mx)) {
        if (!__rect_hits_solid(sx, 0)) x += sx; else { hsp = 0; break; }
    }
    var fracx = mx - floor(mx);
    if (fracx > 0 && hsp != 0) {
        if (!__rect_hits_solid(sx * fracx, 0)) x += sx * fracx; else hsp = 0;
    }
}

// -------- COLLISIONS (V) — tilemap -----------------------
if (!ledge_now && vsp != 0) {
    var sy = sign(vsp);
    var my = abs(vsp);
    repeat (floor(my)) {
        if (!__rect_hits_solid(0, sy)) y += sy; else { vsp = 0; break; }
    }
    var fracy = my - floor(my);
    if (fracy > 0 && vsp != 0) {
        if (!__rect_hits_solid(0, sy * fracy)) y += sy * fracy; else vsp = 0;
    }
}

// -------- RECHECK GROUND (post-move) ---------------------
on_ground = __on_ground_check();

// -------- FACING ----------------------------------------
if (!in_lock_state && !pc_combo_active && !ledge_now && abs(move_x) > 0.001 && !_skip_overrides_this_frame) {
    image_xscale = (move_x > 0) ? 1 : -1;
}

// -------- LOCOMOTION STATE (ungated by lingering attack sprite) ---
if (!pc_combo_active && !ledge_now && !_skip_overrides_this_frame) {
    if (!in_lock_state) {
        if (!on_ground) {
            if (variable_instance_exists(id,"spr_jump") && spr_jump != -1) { state = "jump"; sprite_index = spr_jump; image_speed = 0.3; }
            else state = "jump";
        } else if (abs(move_x) > 0.001) {
            if (variable_instance_exists(id,"spr_run") && spr_run != -1)  { state = "run";  sprite_index = spr_run;  image_speed = 1.2; }
            else state = "run";
        } else {
            if (variable_instance_exists(id,"spr_idle") && spr_idle != -1) { state = "idle"; sprite_index = spr_idle; image_speed = 0.4; }
            else state = "idle";
        }
    }
}

// -------- HURT fallback auto-exit (no anim) -------------
if (state == "hurt" && hurt_lock_timer > 0 && !_skip_overrides_this_frame) {
    hurt_lock_timer--;
    if (hurt_lock_timer <= 0) {
        if (!on_ground) {
            if (variable_instance_exists(id,"spr_jump") && spr_jump != -1) { state = "jump"; sprite_index = spr_jump; image_speed = 0.3; }
            else state = "jump";
        } else if (abs(move_x) > 0.001) {
            if (variable_instance_exists(id,"spr_run") && spr_run != -1)  { state = "run";  sprite_index = spr_run;  image_speed = 1.2; }
            else state = "run";
        } else {
            if (variable_instance_exists(id,"spr_idle") && spr_idle != -1) { state = "idle"; sprite_index = spr_idle; image_speed = 0.4; }
            else state = "idle";
        }
    }
}

// ===== Clear the one-frame guard at the very end =====
if (attack_just_started) attack_just_started = false;
