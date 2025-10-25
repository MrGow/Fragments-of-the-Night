/// oInput — Begin Step  (Space=jump, Z/X/mouse=attack)

// Keep pad_id valid / reconnect if needed
if (pad_id != -1 && !gamepad_is_connected(pad_id)) pad_id = -1;
if (pad_id == -1) {
    for (var i = 0; i < 8; i++) if (gamepad_is_connected(i)) { pad_id = i; break; }
}

// -------- Keyboard --------
var kx = (keyboard_check(vk_right) || keyboard_check(ord("D")))
       - (keyboard_check(vk_left)  || keyboard_check(ord("A")));
kx = clamp(kx, -1, 1);

// JUMP = Space; ATTACK = Z (also X) or mouse
var k_jump_down   = keyboard_check(vk_space);
var k_atk_down    = keyboard_check(ord("Z")) || keyboard_check(ord("X")) || mouse_check_button(mb_left);

var k_jump_pressed = keyboard_check_pressed(vk_space);
var k_atk_pressed  = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("X")) || mouse_check_button_pressed(mb_left);

// -------- Gamepad --------
var gx = 0, g_jump_down = false, g_atk_down = false, g_jump_pressed = false, g_atk_pressed = false;
if (pad_id != -1) {
    var ax = gamepad_axis_value(pad_id, gp_axislh);
    if (abs(ax) > deadzone) gx = sign(ax);
    gx = clamp(gx + (gamepad_button_check(pad_id, gp_padr) - gamepad_button_check(pad_id, gp_padl)), -1, 1);

    g_jump_down    = gamepad_button_check(pad_id, gp_face1);             // A/Cross
    g_atk_down     = gamepad_button_check(pad_id, gp_face2);             // B/Circle
    g_jump_pressed = gamepad_button_check_pressed(pad_id, gp_face1);
    g_atk_pressed  = gamepad_button_check_pressed(pad_id, gp_face2);
}

// -------- Merge (keyboard wins if active) --------
var mx          = (kx != 0) ? kx : gx;
var down_jump   = k_jump_down || g_jump_down;
var down_attack = k_atk_down  || g_atk_down;

var pressed_jump   = (k_jump_pressed || g_jump_pressed) || ( down_jump   && !_jump_prev   );
var pressed_attack = (k_atk_pressed  || g_atk_pressed ) || ( down_attack && !_attack_prev );
if (pressed_attack) {
    show_debug_message("[INPUT] attack_pressed pulse");
}

// -------- Publish --------
global.input.move_x         = mx;
global.input.jump_down      = down_jump;
global.input.attack_down    = down_attack;
global.input.jump_pressed   = pressed_jump;
global.input.attack_pressed = pressed_attack;

// -------- Latch for next frame --------
_jump_prev   = down_jump;
_attack_prev = down_attack;
