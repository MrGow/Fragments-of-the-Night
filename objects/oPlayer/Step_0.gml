// 1 = right key, -1 = left key, 0 = no input
var move = keyboard_check(vk_right) - keyboard_check(vk_left);


// o_player: Step Event

// --- Movement ---
hsp = (keyboard_check(vk_right) - keyboard_check(vk_left)) * move_speed;

// Jump
if (keyboard_check_pressed(vk_space) && place_meeting(x, y+1, o_solid)) {
    vsp = jump_speed;
}

// Apply gravity
vsp += 0.5; 
if (vsp > 12) vsp = 12;

// Collisions
if (place_meeting(x + hsp, y, o_solid)) {
    while (!place_meeting(x + sign(hsp), y, o_solid)) x += sign(hsp);
    hsp = 0;
}
x += hsp;

if (place_meeting(x, y + vsp, o_solid)) {
    while (!place_meeting(x, y + sign(vsp), o_solid)) y += sign(vsp);
    vsp = 0;
}
y += vsp;

// Set facing based on input (or velocity)
if (move > 0)  image_xscale = 1;
if (move < 0)  image_xscale = -1;
// Optional: if you prefer velocity-based
// if (hsp > 0.1) image_xscale = 1;
// if (hsp < -0.1) image_xscale = -1;

// --- State / Animation ---
if (!place_meeting(x, y+1, o_solid)) {
    state = "jump";
}
else if (keyboard_check(vk_right) || keyboard_check(vk_left)) {
    state = "run";
}
else {
    state = "idle";
}

// --- Switch Sprites ---
switch (state) {
    case "idle": sprite_index = spritePlayerIdle; image_speed = 0.2; break;
    case "run":  sprite_index = spritePlayerRun;  image_speed = 1;   break;
    case "jump": sprite_index = spritePlayerJump; image_speed = 0.3; break;
}
