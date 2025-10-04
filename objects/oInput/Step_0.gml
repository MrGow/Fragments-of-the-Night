/// oInput Step

// hot-plug
if (pad_id != -1 && !gamepad_is_connected(pad_id)) pad_id = -1;
if (pad_id == -1) {
    for (var i = 0; i < 4; i++) if (gamepad_is_connected(i)) { pad_id = i; break; }
}
var use_pad = (pad_id != -1);

// ----- STICKS -----
var lx = use_pad ? gamepad_axis_value(pad_id, gp_axislh) : 0;
var ly = use_pad ? gamepad_axis_value(pad_id, gp_axislv) : 0;
var rx = use_pad ? gamepad_axis_value(pad_id, gp_axisrh) : 0;
var ry = use_pad ? gamepad_axis_value(pad_id, gp_axisrv) : 0;

// deadzone clamp
if (abs(lx) < deadzone) lx = 0;
if (abs(ly) < deadzone) ly = 0;
if (abs(rx) < deadzone) rx = 0;
if (abs(ry) < deadzone) ry = 0;

// keyboard fallback
var kb_x = keyboard_check(vk_right) - keyboard_check(vk_left);
var kb_y = keyboard_check(vk_down)  - keyboard_check(vk_up);

// choose movement source
var use_pad_move = use_pad && (abs(lx) + abs(ly) >= abs(kb_x) + abs(kb_y));
var move_x = use_pad_move ? lx : kb_x;
var move_y = use_pad_move ? ly : kb_y;

// ----- DPAD -----
var dpx = use_pad ? (gamepad_button_check(pad_id, gp_padr) - gamepad_button_check(pad_id, gp_padl)) : 0;
var dpy = use_pad ? (gamepad_button_check(pad_id, gp_padd) - gamepad_button_check(pad_id, gp_padu)) : 0;

// ----- ACTIONS -----
// Jump (Space / A)
var jump_down    = keyboard_check(vk_space)                     || (use_pad && gamepad_button_check(pad_id, gp_face1));
var jump_pressed = keyboard_check_pressed(vk_space)             || (use_pad && gamepad_button_check_pressed(pad_id, gp_face1));

// Attack (J / X)
var attack_down    = keyboard_check(ord("J"))                   || (use_pad && gamepad_button_check(pad_id, gp_face3));
var attack_pressed = keyboard_check_pressed(ord("J"))           || (use_pad && gamepad_button_check_pressed(pad_id, gp_face3));

// Dash (K / B)
var dash_pressed = keyboard_check_pressed(ord("K"))             || (use_pad && gamepad_button_check_pressed(pad_id, gp_face2));

// Interact (E / Y)
var interact_pressed = keyboard_check_pressed(ord("E"))         || (use_pad && gamepad_button_check_pressed(pad_id, gp_face4));

// Flask / Parry (LB / RB)
var flask_pressed = keyboard_check_pressed(ord("Q"))            || (use_pad && gamepad_button_check_pressed(pad_id, gp_shoulderl));
var parry_pressed = keyboard_check_pressed(ord("L"))            || (use_pad && gamepad_button_check_pressed(pad_id, gp_shoulderr));

// Menu / Map (Enter / Start, M / Back)
var menu_pressed = keyboard_check_pressed(vk_enter)             || (use_pad && gamepad_button_check_pressed(pad_id, gp_start));
var map_pressed  = keyboard_check_pressed(ord("M"))             || (use_pad && gamepad_button_check_pressed(pad_id, gp_select));

// ----- Right stick aim -----
var aim_x = rx;
var aim_y = ry;

// ----- UPDATE SNAPSHOT (assign directly; no `with`) -----
global.input.move_x = clamp(move_x, -1, 1);
global.input.move_y = clamp(move_y, -1, 1);
global.input.aim_x  = clamp(aim_x,  -1, 1);
global.input.aim_y  = clamp(aim_y,  -1, 1);
global.input.dpad_x = dpx;
global.input.dpad_y = dpy;

global.input.jump_down     = jump_down;
global.input.jump_pressed  = jump_pressed;

global.input.attack_down    = attack_down;
global.input.attack_pressed = attack_pressed;

global.input.dash_pressed     = dash_pressed;
global.input.interact_pressed = interact_pressed;

global.input.flask_pressed = flask_pressed;
global.input.parry_pressed = parry_pressed;

global.input.menu_pressed = menu_pressed;
global.input.map_pressed  = map_pressed;

// last device heuristic
var pad_used = use_pad && (use_pad_move || jump_pressed || attack_pressed || dash_pressed || interact_pressed || flask_pressed || parry_pressed || menu_pressed || map_pressed || (abs(lx)+abs(ly)+abs(rx)+abs(ry) > 0));
var kb_used  = (!pad_used) && (kb_x || kb_y || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("J")) || keyboard_check_pressed(ord("K")) || keyboard_check_pressed(ord("E")) || keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("L")) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("M")));
global.input.last_device = pad_used ? "pad" : (kb_used ? "kb" : global.input.last_device);

// ----- RUMBLE -----
if (rumble_frames > 0 && pad_id != -1) {
    gamepad_set_vibration(pad_id, rumble_left, rumble_right);
    rumble_frames--;
} else if (pad_id != -1) {
    gamepad_set_vibration(pad_id, 0, 0);
}
