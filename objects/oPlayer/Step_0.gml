/// oPlayer — Step  (physics, collisions, heal/hurt, attack anim hardening + release)

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
    // Direct call; script exists in this project
    script_health_use_flask();
}

// -------- HURT pulse consumption ----------------------------------
var _pulse_now = (variable_global_exists("_hurt_pulse_id") ? global._hurt_pulse_id : 0);
var _new_hurt  = (_pulse_now != last_seen_hurt_pulse);

if (_new_hurt && state != "hurt" && state != "drink" && !_skip_overrides_this_frame) {
    last_seen_hurt_pulse = _pulse_now;

    var has_hurt_anim = (variable_instance_exists(id,"spr_hurt") && spr_hurt != -1);
    state        = "hurt";
    if (has_hurt_anim) { sprite_index = spr_hurt; image_index = 0; image_speed = hurt_anim_speed; }
    hsp = 0;

    var frames_in_strip = has_hurt_anim ? image_number : 0;
    if (!has_hurt_anim || frames_in_strip <= 1) { hurt_lock_timer = max(1, hurt_lock_frames_default); }
    else { hurt_lock_timer = 0; }
}

// ==================== ATTACK ANIM HARDENING + RELEASE ====================
// Detect attack sprites (A/B/C/Up)
var _sprA = asset_get_index("spriteSwordAttackA");
var _sprB = asset_get_index("spriteSwordAttackB");
var _sprC = asset_get_index("spriteSwordAttackC");
var _sprU = asset_get_index("spriteSwordAttackUp");

var _is_attack_sprite =
    (_sprA != -1 && sprite_index == _sprA) ||
    (_sprB != -1 && sprite_index == _sprB) ||
    (_sprC != -1 && sprite_index == _sprC) ||
    (_sprU != -1 && sprite_index == _sprU);

// While an attack sprite is active, engine anim OFF (oPlayerCombat drives frames)
if (_is_attack_sprite) {
    state = "attack";
    image_speed = 0; // <- critical: prevent engine looping
}

// Release back to locomotion once combo controller drops AND we’ve shown last frame briefly
if (_is_attack_sprite) {
    var _frames = max(1, image_number);
    var at_last = (image_index >= _frames - 1.0);
    if (!pc_combo_active && at_last) {
        attack_release_linger++;
        if (attack_release_linger >= 2) {
            attack_release_linger = 0;

            // Restore locomotion state
            var on_ground_now = __on_ground_check();
            if (!on_ground_now) {
                if (variable_instance_exists(id,"spr_jump") && spr_jump != -1) { state = "jump"; sprite_index = spr_jump; image_speed = 0.3; }
            } else if (abs(move_x) > 0.001) {
                if (variable_instance_exists(id,"spr_run") && spr_run != -1)  { state = "run";  sprite_index = spr_run;  image_speed = 1.2; }
            } else {
                if (variable_instance_exists(id,"spr_idle") && spr_idle != -1) { state = "idle"; sprite_index = spr_idle; image_speed = 0.4; }
            }
        }
    } else {
        attack_release_linger = 0;
    }
} else {
    attack_release_linger = 0;
}

// ----------------- Locks / state booleans -----------------
var in_lock_state  = (state == "drink") || (state == "hurt");
var attacking_now  = _is_attack_sprite || pc_combo_active; // true only while a swing is actually active

// -------- ENV / GROUND CHECK (pre-move) ------------------
var on_ground = __on_ground_check();

// -------- COYOTE & JUMP BUFFER TIMERS --------------------
if (!variable_instance_exists(id, "coyote_time_frames"))      coyote_time_frames = 6;
if (!variable_instance_exists(id, "jump_buffer_time_frames")) jump_buffer_time_frames = 6;
if (!variable_instance_exists(id, "coyote_timer"))            coyote_timer = 0;
if (!variable_instance_exists(id, "jump_buffer_timer"))       jump_buffer_timer = 0;

if (on_ground) coyote_timer = coyote_time_frames; else if (coyote_timer > 0) coyote_timer--;
if (jump_p)    jump_buffer_timer = jump_buffer_time_frames; else if (jump_buffer_timer > 0) jump_buffer_timer--;

// -------- HORIZONTAL MOVEMENT ----------------------------
var hsp_target = in_lock_state ? 0 : (move_x * move_speed);

// Only lock grounded movement when actually attacking right now
if (!in_lock_state && on_ground && attacking_now) {
    hsp_target = 0;
}

// Add a touch of extra drift when attacking mid-air
if (!on_ground && attacking_now) {
    hsp_target *= air_attack_drift;
}

hsp = hsp_target;

// -------- EXECUTE JUMP (buffer + coyote) -----------------
if (!in_lock_state && !attacking_now && jump_buffer_timer > 0 && coyote_timer > 0 && !_skip_overrides_this_frame) {
    vsp = jump_speed;
    jump_buffer_timer = 0;
    coyote_timer      = 0;
}

// -------- VARIABLE GRAVITY -------------------------------
var g = gravity_amt;
if (!on_ground) {
    if (vsp < 0) {
        if (!jump_h) g += gravity_amt * (low_jump_multiplier - 1.0);
    } else {
        g += gravity_amt * (fall_multiplier - 1.0);
    }
}
vsp += g;
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
if (vsp != 0) {
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
if (!in_lock_state && !attacking_now && abs(move_x) > 0.001 && !_skip_overrides_this_frame) {
    image_xscale = (move_x > 0) ? 1 : -1;
}

// -------- LOCOMOTION STATE (when not in attack/locks) ---
if (!attacking_now && state != "attack" && !_skip_overrides_this_frame) {
    if (!in_lock_state) {
        if (!on_ground) {
            if (variable_instance_exists(id,"spr_jump") && spr_jump != -1) { state = "jump"; sprite_index = spr_jump; image_speed = 0.3; }
        } else if (abs(move_x) > 0.001) {
            if (variable_instance_exists(id,"spr_run") && spr_run != -1)  { state = "run";  sprite_index = spr_run;  image_speed = 1.2; }
        } else {
            if (variable_instance_exists(id,"spr_idle") && spr_idle != -1) { state = "idle"; sprite_index = spr_idle; image_speed = 0.4; }
        }
    }
}

// -------- HURT fallback auto-exit (no anim) -------------
if (state == "hurt" && hurt_lock_timer > 0 && !_skip_overrides_this_frame) {
    hurt_lock_timer--;
    if (hurt_lock_timer <= 0) {
        // unlock to locomotion
        if (!on_ground) {
            if (variable_instance_exists(id,"spr_jump") && spr_jump != -1) { state = "jump"; sprite_index = spr_jump; image_speed = 0.3; }
        } else if (abs(move_x) > 0.001) {
            if (variable_instance_exists(id,"spr_run") && spr_run != -1)  { state = "run";  sprite_index = spr_run;  image_speed = 1.2; }
        } else {
            if (variable_instance_exists(id,"spr_idle") && spr_idle != -1) { state = "idle"; sprite_index = spr_idle; image_speed = 0.4; }
        }
    }
}

// ===== Clear the one-frame guard at the very end =====
if (attack_just_started) attack_just_started = false;
