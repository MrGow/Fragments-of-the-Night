// ------- INPUT (pad-first if available, else keyboard) -------
var use_pad = !is_undefined(global.input);
var move_x  = use_pad ? global.input.move_x : (keyboard_check(vk_right) - keyboard_check(vk_left));
var jump_p  = use_pad ? global.input.jump_pressed : keyboard_check_pressed(vk_space);
var atk_p   = use_pad ? global.input.attack_pressed : keyboard_check_pressed(ord("X"));

// ------- COOLDOWN -------
if (attack_cooldown > 0) attack_cooldown--;

// ------- ENV / GROUND CHECK -------
var on_ground = place_meeting(x, y + 1, oSolid);

// ------- ATTACK TRIGGER (single path) -------
if (state != "attack" && can_attack && atk_p) {
    state        = "attack";
    sprite_index = spr_attack;   // attack sprite (Loop OFF)
    image_index  = 0;
    image_speed  = 1;
    attack_lock  = true;

    // Optional cooldown window:
    // attack_cooldown = room_speed * 0.20;  // ~0.2s
    // can_attack = false;

    // 🔔 RUMBLE on attack start (test)
    if (instance_exists(oInput)) {
        with (oInput) scr_input_rumble(0.45, 0.45, 8);  // left,right,strengthFrames
    }
}

// ------- MOVEMENT -------
var hsp_target = move_speed * move_x;

// Lock horizontal while attacking
if (state == "attack" || attack_lock) hsp_target = 0;

// Apply horizontal
hsp = hsp_target;

// Jump (block during attack)
if (state != "attack" && jump_p && on_ground) {
    vsp = jump_speed;
}

// Gravity
vsp += gravity_amt;
if (vsp > max_fall) vsp = max_fall;

// ------- COLLISIONS (H) -------
if (place_meeting(x + hsp, y, oSolid)) {
    while (!place_meeting(x + sign(hsp), y, oSolid)) x += sign(hsp);
    hsp = 0;
}
x += hsp;

// ------- COLLISIONS (V) -------
if (place_meeting(x, y + vsp, oSolid)) {
    while (!place_meeting(x, y + sign(vsp), oSolid)) y += sign(vsp);
    vsp = 0;
}
y += vsp;

// Recompute ground after moving
on_ground = place_meeting(x, y + 1, oSolid);

// ------- FACING -------
if (abs(move_x) > 0.001) {
    image_xscale = (move_x > 0) ? 1 : -1;
}

// ------- STATE / ANIMATION (when NOT attacking) -------
if (state != "attack") {
    if (!on_ground) {
        state = "jump";
        sprite_index = spritePlayerJump; image_speed = 0.3;
    } else if (abs(move_x) > 0.001) {
        state = "run";
        sprite_index = spritePlayerRun;  image_speed = 1.2;
    } else {
        state = "idle";
        sprite_index = spritePlayerIdle; image_speed = 0.4;
    }
}

// ------- FAILSAFE: force Animation End if an attack sprite tries to loop -------
if (state == "attack" && image_index >= image_number - 1) {
    event_perform(ev_other, ev_animation_end);
}

