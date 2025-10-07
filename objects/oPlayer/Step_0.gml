// ========================= oPlayer :: Step =========================
// -------- INPUT (safe / defensive) --------
var has_input = !is_undefined(global.input);
var move_x = (has_input && variable_struct_exists(global.input, "move_x")) ? global.input.move_x 
             : (keyboard_check(vk_right) - keyboard_check(vk_left));
var jump_p = (has_input && variable_struct_exists(global.input, "jump_pressed")) ? global.input.jump_pressed 
             : keyboard_check_pressed(vk_space);
var jump_h = (has_input && variable_struct_exists(global.input, "jump_held")) ? global.input.jump_held 
             : keyboard_check(vk_space);
var atk_p  = (has_input && variable_struct_exists(global.input, "attack_pressed")) ? global.input.attack_pressed 
             : keyboard_check_pressed(ord("X"));


// -------- COOLDOWN -----------------------------------------------
if (attack_cooldown > 0) attack_cooldown--;

// -------- ENV / GROUND CHECK (pre-move) --------------------------
var on_ground = place_meeting(x, y + 1, oSolid);

// -------- COYOTE & JUMP BUFFER TIMERS ----------------------------
// (Assumes these exist from Create: coyote_timer, coyote_time_frames, jump_buffer_timer, jump_buffer_time_frames)
if (on_ground) coyote_timer = coyote_time_frames; else if (coyote_timer > 0) coyote_timer--;
if (jump_p)    jump_buffer_timer = jump_buffer_time_frames; else if (jump_buffer_timer > 0) jump_buffer_timer--;

// -------- ATTACK TRIGGER -----------------------------------------
if (state != "attack" && can_attack && atk_p) {
    state        = "attack";
    sprite_index = spr_attack;
    image_index  = 0;
    image_speed  = 1;
    attack_lock  = true;

    // if (instance_exists(oInput)) with (oInput) scr_input_rumble(0.45, 0.45, 8);
}

// -------- HORIZONTAL MOVEMENT ------------------------------------
var hsp_target = move_speed * move_x;
if (state == "attack" || attack_lock) hsp_target = 0;
hsp = hsp_target; // (If you use acceleration, blend toward this instead)

// -------- EXECUTE JUMP (buffer + coyote) --------------------------
if (state != "attack" && jump_buffer_timer > 0 && coyote_timer > 0) {
    vsp = jump_speed;               // up is negative
    jump_buffer_timer = 0;
    coyote_timer      = 0;

    // optional one-time state/anim on takeoff:
    // state = "jump"; sprite_index = spritePlayerJump; image_speed = 0.3;
}

// -------- VARIABLE GRAVITY ---------------------------------------
// Assumes you set these in Create: gravity_amt, max_fall, fall_multiplier, low_jump_multiplier
var g = gravity_amt;

if (!on_ground) {
    if (vsp < 0) {
        // Rising
        if (!jump_h) g += gravity_amt * (low_jump_multiplier - 1.0); // short hop if released early
    } else {
        // Falling snappier
        g += gravity_amt * (fall_multiplier - 1.0);
    }
}

// Apply gravity and clamp
vsp += g;
if (vsp > max_fall) vsp = max_fall;

// -------- COLLISIONS (H) -----------------------------------------
if (hsp != 0) {
    var sx = sign(hsp);
    var mx = abs(hsp);
    // move pixel-by-pixel to avoid tunneling & infinite loops
    repeat (floor(mx)) {
        if (!place_meeting(x + sx, y, oSolid)) x += sx; else { hsp = 0; break; }
    }
    // handle leftover fractional step safely
    var fracx = mx - floor(mx);
    if (fracx > 0 && hsp != 0) {
        if (!place_meeting(x + sx, y, oSolid)) x += sx * fracx; else hsp = 0;
    }
}

// -------- COLLISIONS (V) -----------------------------------------
if (vsp != 0) {
    var sy = sign(vsp);
    var my = abs(vsp);
    repeat (floor(my)) {
        if (!place_meeting(x, y + sy, oSolid)) y += sy;
        else { vsp = 0; break; }
    }
    // leftover fractional step
    var fracy = my - floor(my);
    if (fracy > 0 && vsp != 0) {
        if (!place_meeting(x, y + sy, oSolid)) y += sy * fracy; else vsp = 0;
    }
}

// -------- RECHECK GROUND (post-move) ------------------------------
on_ground = place_meeting(x, y + 1, oSolid);

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
            sprite_index = spritePlayerRun; image_speed = 1.2;
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

