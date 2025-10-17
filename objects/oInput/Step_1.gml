// --- Keep pad_id valid
if (pad_id != -1 && !gamepad_is_connected(pad_id)) pad_id = -1;
if (pad_id == -1) {
    for (var i = 0; i < 4; i++) if (gamepad_is_connected(i)) { pad_id = i; break; }
}

// --- Keyboard
var kx = (keyboard_check(vk_right) || keyboard_check(ord("D"))) 
       - (keyboard_check(vk_left)  || keyboard_check(ord("A")));
kx = clamp(kx, -1, 1);

var k_jump_p = keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("Z"));
var k_jump_h = keyboard_check(vk_space)         || keyboard_check(ord("Z"));
var k_atk_p  = keyboard_check_pressed(ord("X")) || mouse_check_button_pressed(mb_left);

// --- Gamepad (if present)
var gx = 0, g_jump_p = false, g_jump_h = false, g_atk_p = false;
if (pad_id != -1) {
    var ax = gamepad_axis_value(pad_id, gp_axislh);
    if (abs(ax) > 0.25) gx = sign(ax);
    gx = clamp(gx + (gamepad_button_check(pad_id, gp_padr) - gamepad_button_check(pad_id, gp_padl)), -1, 1);

    g_jump_p = gamepad_button_check_pressed(pad_id, gp_face1); // A/Cross
    g_jump_h = gamepad_button_check(pad_id, gp_face1);
    g_atk_p  = gamepad_button_check_pressed(pad_id, gp_face2); // B/Circle
}

// --- Merge (keyboard wins if active)
var mx = (kx != 0) ? kx : gx;

global.input.move_x         = mx;
global.input.jump_pressed   = k_jump_p || g_jump_p;
global.input.jump_held      = k_jump_h || g_jump_h;
global.input.attack_pressed = k_atk_p  || g_atk_p;
