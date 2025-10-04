// --- INPUT ---
var move_input = keyboard_check(vk_right) - keyboard_check(vk_left);
var atk_pressed = keyboard_check_pressed(ord("X")); // change key if needed

// --- COOLDOWN ---
if (attack_cooldown > 0) attack_cooldown--;

// --- ATTACK TRIGGER ---
if (state != "attack" && can_attack && atk_pressed) {
    state        = "attack";
    sprite_index = spriteSwordAttack;   // attack sprite (make sure Loop = OFF)
    image_index  = 0;
    image_speed  = 1;
    attack_lock  = true;

    // If you want cooldowns, uncomment these:
    // attack_cooldown = room_speed * 0.2; // ~0.2s
    // can_attack = false;
}

// --- MOVEMENT ---
var hsp_target = move_input * move_speed;

// Lock horizontal while attacking
if (state == "attack") hsp_target = 0;

hsp = hsp_target;

// Jump (block during attack)
if (state != "attack" && keyboard_check_pressed(vk_space) && place_meeting(x, y+1, o_solid)) {
    vsp = jump_speed;
}

// Gravity
vsp += 0.5;
if (vsp > 12) vsp = 12;

// Collisions (H)
if (place_meeting(x + hsp, y, o_solid)) {
    while (!place_meeting(x + sign(hsp), y, o_solid)) x += sign(hsp);
    hsp = 0;
}
x += hsp;

// Collisions (V)
if (place_meeting(x, y + vsp, o_solid)) {
    while (!place_meeting(x, y + sign(vsp), o_solid)) y += sign(vsp);
    vsp = 0;
}
y += vsp;

// Facing
if (move_input > 0)  image_xscale = 1;
if (move_input < 0)  image_xscale = -1;

// --- STATE / ANIMATION (skip if attacking) ---
if (state != "attack") {
    if (!place_meeting(x, y+1, o_solid)) {
        state = "jump";
        sprite_index = spritePlayerJump; image_speed = 0.3;
    } else if (keyboard_check(vk_right) || keyboard_check(vk_left)) {
        state = "run";
        sprite_index = spritePlayerRun;  image_speed = 1;
    } else {
        state = "idle";
        sprite_index = spritePlayerIdle; image_speed = 0.2;
    }
}

// --- FAILSAFE: if attack sprite somehow loops, force animation end ---
if (state == "attack" && image_index >= image_number - 1) {
    event_perform(ev_other, ev_animation_end);
}
