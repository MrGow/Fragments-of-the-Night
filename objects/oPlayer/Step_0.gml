/// oPlayer — Step  (tilemap collisions, air-attack drift, ground lock during attack)

// ---- Ensure tunables exist (if hot-reloaded) ----
if (!variable_instance_exists(id, "air_attack_drift"))     air_attack_drift     = 1.15;
if (!variable_instance_exists(id, "attack_anim_speed"))    attack_anim_speed    = 0.35;
if (!variable_instance_exists(id, "attack_cooldown"))      attack_cooldown      = 0;
if (!variable_instance_exists(id, "attack_end_fired"))     attack_end_fired     = false;
if (!variable_instance_exists(id, "drink_anim_speed"))     drink_anim_speed     = 0.35;
if (!variable_instance_exists(id, "hurt_anim_speed"))      hurt_anim_speed      = 0.55;

// ---- Safe initializer for global.tm_solids
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

// -------- INPUT (keyboard wins; then struct; ATTACK pulse is consumed) --------
var kx = (keyboard_check(vk_right) || keyboard_check(ord("D")))
       - (keyboard_check(vk_left)  || keyboard_check(ord("A")));
kx = clamp(kx, -1, 1);

var k_jump_p = keyboard_check_pressed(vk_space);
var k_jump_h = keyboard_check(vk_space);

var k_atk_p  = keyboard_check_pressed(ord("Z"))
            || keyboard_check_pressed(ord("X"))
            || mouse_check_button_pressed(mb_left);

var k_heal_p = keyboard_check_pressed(ord("E"));

var move_x = kx;
var jump_p = k_jump_p;
var jump_h = k_jump_h;
var atk_p  = k_atk_p;

if (variable_global_exists("input") && is_struct(global.input)) {
    if (move_x == 0 && variable_struct_exists(global.input, "move_x"))
        move_x = clamp(global.input.move_x, -1, 1);

    if (variable_struct_exists(global.input, "jump_pressed"))
        jump_p = jump_p || global.input.jump_pressed;

    if (variable_struct_exists(global.input, "jump_down"))
        jump_h = jump_h || global.input.jump_down;

    // Consume attack pulse exactly once
    if (variable_struct_exists(global.input, "attack_pressed")) {
        if (global.input.attack_pressed) {
            atk_p = true;
            global.input.attack_pressed = false; // consume
        }
    }
}

// -------- COOLDOWN -----------------------------------------------
if (attack_cooldown > 0) attack_cooldown--;

// -------- I-FRAME VISUAL -----------------------------------------
if (variable_global_exists("_iframes_timer") && global._iframes_timer > 0) {
    image_blend = make_color_rgb(255, 160, 160);
    image_alpha = 1;
} else {
    image_blend = c_white;
    image_alpha = 1;
}

// -------- STATE ENTRIES: DRINK / HURT ----------------------------

// Enter DRINK state when E consumes a flask (and not already locked)
if (k_heal_p && (!variable_global_exists("paused") || !global.paused)) {
    // Only start an anim if the heal actually happened
    var _did_drink = script_health_use_flask(); // returns true on success
    if (_did_drink && spr_drink != -1) {
        state        = "drink";
        sprite_index = spr_drink;
        image_index  = 0;
        image_speed  = drink_anim_speed;
        attack_lock  = true;            // reuse lock to block inputs
        attack_end_fired = false;
        // Stop motion while drinking
        hsp = 0;
        // (Let gravity run so you land if airborne; or set vsp=0 if you want total freeze)
    }
}

// Enter HURT state when damage lands (pulse set by the damage script)
if (state != "hurt" && state != "drink") {
    if (variable_global_exists("_hurt_this_step") && global._hurt_this_step) {
        if (spr_hurt != -1) {
            state        = "hurt";
            sprite_index = spr_hurt;
            image_index  = 0;
            image_speed  = hurt_anim_speed;
            attack_lock  = true;
            attack_end_fired = false;
            hsp = 0; // tiny stun: no horizontal motion this frame
        }
    }
}

// If in DRINK or HURT, ignore new attack inputs
var in_lock_state = (state == "drink") || (state == "hurt");
if (in_lock_state) {
    atk_p = false;
}

// -------- ENV / GROUND CHECK (pre-move) --------------------------
var on_ground = __on_ground_check();

// -------- COYOTE & JUMP BUFFER TIMERS ----------------------------
if (on_ground) coyote_timer = coyote_time_frames; else if (coyote_timer > 0) coyote_timer--;
if (jump_p)    jump_buffer_timer = jump_buffer_time_frames; else if (jump_buffer_timer > 0) jump_buffer_timer--;

// -------- ATTACK TRIGGER (ties cooldown to sprite length) --------
if (state != "attack" && !in_lock_state && can_attack && atk_p && attack_cooldown <= 0) {
    if (spr_attack != -1) {
        state            = "attack";
        sprite_index     = spr_attack;
        image_index      = 0;
        image_speed      = attack_anim_speed;
        attack_lock      = true;
        attack_end_fired = false;

        var _frames = max(1, image_number);
        var _dur    = ceil(_frames / max(0.001, attack_anim_speed));
        attack_cooldown = _dur + 2;
    }
}

// -------- HORIZONTAL MOVEMENT ------------------------------------
var hsp_target = in_lock_state ? 0 : (move_speed * move_x);

// Lock movement ONLY if grounded & attacking; allow drift in air while attacking
if (!in_lock_state && on_ground && (state == "attack" || attack_lock || attack_lock_frames > 0)) {
    hsp_target = 0;
}

// Add a touch of extra drift when attacking mid-air
if (!on_ground && state == "attack") {
    hsp_target *= air_attack_drift;
}

hsp = hsp_target;

// -------- EXECUTE JUMP (buffer + coyote) --------------------------
if (!in_lock_state && state != "attack" && jump_buffer_timer > 0 && coyote_timer > 0) {
    vsp = jump_speed;
    jump_buffer_timer = 0;
    coyote_timer      = 0;
}

// -------- VARIABLE GRAVITY ---------------------------------------
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

// -------- COLLISIONS (H) — tilemap --------------------------------
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

// -------- COLLISIONS (V) — tilemap --------------------------------
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

// -------- RECHECK GROUND (post-move) ------------------------------
on_ground = __on_ground_check();

// -------- OPTIONAL tiny frame-lock countdown ---------------------
if (attack_lock_frames > 0) {
    attack_lock_frames--;
    if (attack_lock_frames <= 0) attack_lock_frames = 0;
}

// -------- FACING -------------------------------------------------
if (!in_lock_state && abs(move_x) > 0.001) image_xscale = (move_x > 0) ? 1 : -1;

// -------- STATE / ANIMATION (non-attack/non-locked) --------------
if (state != "attack" && !in_lock_state) {
    if (!on_ground) {
        if (state != "jump") { state = "jump"; if (spr_jump != -1) sprite_index = spr_jump; image_speed = 0.3; }
    } else if (abs(move_x) > 0.001) {
        if (state != "run")  { state = "run";  if (spr_run  != -1) sprite_index = spr_run;  image_speed = 1.2; }
    } else {
        if (state != "idle") { state = "idle"; if (spr_idle != -1) sprite_index = spr_idle; image_speed = 0.4; }
    }
}

// -------- ATTACK / DRINK / HURT END (one-shot; prefer last frame) ---------------
if ((state == "attack" || state == "drink" || state == "hurt") && !attack_end_fired) {
    var on_last = (image_index >= max(0, image_number - 1));
    var time_up = (attack_cooldown <= 0); // relevant only for attack

    if (on_last || (time_up && state == "attack" && image_number <= 1)) {
        attack_end_fired = true;
        image_speed = 0;
        image_index = max(0, image_number - 1);
        attack_lock = false;

        // Return to locomotion immediately after the anim
        if (!on_ground) {
            state = "jump"; if (spr_jump != -1) sprite_index = spr_jump; image_speed = 0.3;
        } else if (abs(move_x) > 0.001) {
            state = "run";  if (spr_run  != -1) sprite_index = spr_run;  image_speed = 1.2;
        } else {
            state = "idle"; if (spr_idle != -1) sprite_index = spr_idle; image_speed = 0.4;
        }
    }
}
