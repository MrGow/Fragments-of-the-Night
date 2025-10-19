// ========================= oPlayer :: Step =========================
// Tilemap collisions + keyboard-first input merge

// ---- Safe initializer for global.tm_solids (no reads before it exists)
if (!variable_global_exists("tm_solids")) global.tm_solids = undefined;

function __ensure_tm_solids() {
    if (is_undefined(global.tm_solids)) {
        var _lid = layer_get_id("Solids");
        if (_lid != -1) global.tm_solids = layer_tilemap_get_id(_lid);
    }
    return global.tm_solids;
}
__ensure_tm_solids();

// ---------- Local helpers (tilemap collision) ----------
function __tile_solid_at(_x, _y) {
    return (!is_undefined(global.tm_solids)) && (tilemap_get_at_pixel(global.tm_solids, _x, _y) != 0);
}

function __rect_hits_solid(_dx, _dy) {
    // Predict the bbox at (x+dx, y+dy) and test corners
    var l = bbox_left   + _dx;
    var r = bbox_right  + _dx;
    var t = bbox_top    + _dy;
    var b = bbox_bottom + _dy;

    var eps = 0.1; // tiny inset to reduce snagging
    if (__tile_solid_at(l + eps, t + eps)) return true;
    if (__tile_solid_at(r - eps, t + eps)) return true;
    if (__tile_solid_at(l + eps, b - eps)) return true;
    if (__tile_solid_at(r - eps, b - eps)) return true;
    return false;
}

function __on_ground_check() {
    // Check 1px below feet using corner probes
    var eps = 0.1;
    var l = bbox_left;
    var r = bbox_right;
    var b = bbox_bottom;
    return __tile_solid_at(l + eps, b + 1) || __tile_solid_at(r - eps, b + 1);
}

// -------- INPUT (keyboard wins; struct ORs on top) --------
var kx = (keyboard_check(vk_right) || keyboard_check(ord("D")))
       - (keyboard_check(vk_left)  || keyboard_check(ord("A")));
kx = clamp(kx, -1, 1);

// JUMP = Space; ATTACK = Z (also accept X/mouse)
var k_jump_p = keyboard_check_pressed(vk_space);
var k_jump_h = keyboard_check(vk_space);
var k_atk_p  = keyboard_check_pressed(ord("Z"))
            || keyboard_check_pressed(ord("X"))
            || mouse_check_button_pressed(mb_left);

// Defaults from keyboard
var move_x = kx;
var jump_p = k_jump_p;
var jump_h = k_jump_h;
var atk_p  = k_atk_p;

// Merge struct (if present). Keyboard keeps priority.
if (variable_global_exists("input") && is_struct(global.input)) {
    if (move_x == 0 && variable_struct_exists(global.input, "move_x"))
        move_x = clamp(global.input.move_x, -1, 1);

    if (variable_struct_exists(global.input, "jump_pressed"))
        jump_p = jump_p || global.input.jump_pressed;

    // oInput publishes jump_down (not jump_held)
    if (variable_struct_exists(global.input, "jump_down"))
        jump_h = jump_h || global.input.jump_down;

    if (variable_struct_exists(global.input, "attack_pressed"))
        atk_p = atk_p || global.input.attack_pressed;
}

// -------- COOLDOWN -----------------------------------------------
if (attack_cooldown > 0) attack_cooldown--;

// -------- ENV / GROUND CHECK (pre-move) --------------------------
var on_ground = __on_ground_check();

// -------- COYOTE & JUMP BUFFER TIMERS ----------------------------
if (on_ground) coyote_timer = coyote_time_frames; else if (coyote_timer > 0) coyote_timer--;
if (jump_p)    jump_buffer_timer = jump_buffer_time_frames; else if (jump_buffer_timer > 0) jump_buffer_timer--;

// -------- ATTACK TRIGGER (no freeze if no sprite) ----------------
if (state != "attack" && can_attack && atk_p) {
    if (spr_attack != -1) {
        state        = "attack";
        sprite_index = spr_attack;
        image_index  = 0;
        image_speed  = 1;
        attack_lock  = true;               // lock only when anim will run
    } else {
        // No attack sprite available — optionally enable a tiny frame-lock:
        // attack_lock_frames = 4;         // ~4 frames of movement lock
    }
}

// -------- HORIZONTAL MOVEMENT ------------------------------------
var hsp_target = move_speed * move_x;
if (state == "attack" || attack_lock || attack_lock_frames > 0) hsp_target = 0;
hsp = hsp_target; // (replace with acceleration if desired)

// -------- EXECUTE JUMP (buffer + coyote) --------------------------
if (state != "attack" && jump_buffer_timer > 0 && coyote_timer > 0) {
    vsp = jump_speed;               // up is negative
    jump_buffer_timer = 0;
    coyote_timer      = 0;
}

// -------- VARIABLE GRAVITY ---------------------------------------
var g = gravity_amt;
if (!on_ground) {
    if (vsp < 0) { // rising
        if (!jump_h) g += gravity_amt * (low_jump_multiplier - 1.0); // short hop
    } else { // falling
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
if (abs(move_x) > 0.001) image_xscale = (move_x > 0) ? 1 : -1;

// -------- STATE / ANIMATION --------------------------------------
if (state != "attack") {
    if (!on_ground) {
        if (state != "jump") {
            state = "jump";
            sprite_index = spritePlayerJump; image_speed = 0.3;
        }
    } else if (abs(move_x) > 0.001) {
        if (state != "run") {
            state = "run";
            sprite_index = spritePlayerRun;  image_speed = 1.2;
        }
    } else {
        if (state != "idle") {
            state = "idle";
            sprite_index = spritePlayerIdle; image_speed = 0.4;
        }
    }
}

// -------- FAILSAFE: attack anim end -------------------------------
if (state == "attack" && image_index >= image_number - 1) {
    event_perform(ev_other, ev_animation_end);
}
