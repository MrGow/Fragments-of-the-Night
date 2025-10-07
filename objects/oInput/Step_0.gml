/// oInput :: Step

// hot-plug detection
if (pad_id != -1 && !gamepad_is_connected(pad_id)) pad_id = -1;
if (pad_id == -1) { for (var i = 0; i < 4; i++) if (gamepad_is_connected(i)) { pad_id = i; break; } }
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

// keyboard fallback axes
var kb_x = keyboard_check(vk_right) - keyboard_check(vk_left);
var kb_y = keyboard_check(vk_down)  - keyboard_check(vk_up);

// choose movement source (whichever has stronger intent)
var use_pad_move = use_pad && (abs(lx) + abs(ly) >= abs(kb_x) + abs(kb_y));
var move_x = use_pad_move ? lx : kb_x;
var move_y = use_pad_move ? ly : kb_y;

// ----- DPAD -----
var dpx = use_pad ? (gamepad_button_check(pad_id, gp_padr) - gamepad_button_check(pad_id, gp_padl)) : 0;
var dpy = use_pad ? (gamepad_button_check(pad_id, gp_padd) - gamepad_button_check(pad_id, gp_padu)) : 0;

// ----- ACTIONS -----
// Jump (Space / A)
var jump_down_now     = keyboard_check(vk_space)                 || (use_pad && gamepad_button_check(pad_id, gp_face1));
var jump_pressed_now  = keyboard_check_pressed(vk_space)         || (use_pad && gamepad_button_check_pressed(pad_id, gp_face1));
var jump_released_now = (!jump_down_now && prev_jump_down);

// Attack (J / X)
var attack_down_now    = keyboard_check(ord("J"))                || (use_pad && gamepad_button_check(pad_id, gp_face3));
var attack_pressed_now = keyboard_check_pressed(ord("J"))        || (use_pad && gamepad_button_check_pressed(pad_id, gp_face3));

// Dash (K / B)
var dash_pressed = keyboard_check_pressed(ord("K"))              || (use_pad && gamepad_button_check_pressed(pad_id, gp_face2));

// Interact (E / Y)
var interact_pressed = keyboard_check_pressed(ord("E"))          || (use_pad && gamepad_button_check_pressed(pad_id, gp_face4));

// Flask / Parry (Q / L) ~ (LB / RB)
var flask_pressed = keyboard_check_pressed(ord("Q"))             || (use_pad && gamepad_button_check_pressed(pad_id, gp_shoulderl));
var parry_pressed = keyboard_check_pressed(ord("L"))             || (use_pad && gamepad_button_check_pressed(pad_id, gp_shoulderr));

// Menu / Map (Enter / Start, M / Back)
var menu_pressed = keyboard_check_pressed(vk_enter)              || (use_pad && gamepad_button_check_pressed(pad_id, gp_start));
var map_pressed  = keyboard_check_pressed(ord("M"))              || (use_pad && gamepad_button_check_pressed(pad_id, gp_select));

// ----- Right stick aim -----
var aim_x = rx;
var aim_y = ry;

// ----- UPDATE SNAPSHOT -----
global.input.move_x = clamp(move_x, -1, 1);
global.input.move_y = clamp(move_y, -1, 1);
global.input.aim_x  = clamp(aim_x,  -1, 1);
global.input.aim_y  = clamp(aim_y,  -1, 1);
global.input.dpad_x = dpx;
global.input.dpad_y = dpy;

global.input.jump_down     = jump_down_now;         // HELD (true while held)
global.input.jump_pressed  = jump_pressed_now;      // edge-down
global.input.jump_released = jump_released_now;     // edge-up
global.input.jump_held     = jump_down_now;         // alias used by player Step

global.input.attack_down    = attack_down_now;
global.input.attack_pressed = attack_pressed_now;

global.input.dash_pressed     = dash_pressed;
global.input.interact_pressed = interact_pressed;

global.input.flask_pressed = flask_pressed;
global.input.parry_pressed = parry_pressed;

global.input.menu_pressed = menu_pressed;
global.input.map_pressed  = map_pressed;

// ----- LAST DEVICE HEURISTIC -----
var pad_used = use_pad && (
    use_pad_move || jump_pressed_now || jump_down_now || attack_pressed_now || attack_down_now ||
    dash_pressed || interact_pressed || flask_pressed || parry_pressed || menu_pressed || map_pressed ||
    (abs(lx)+abs(ly)+abs(rx)+abs(ry) > 0)
);
var kb_used  = (!pad_used) && (
    kb_x || kb_y ||
    keyboard_check(vk_space) || keyboard_check_pressed(vk_space) ||
    keyboard_check(ord("J")) || keyboard_check_pressed(ord("J")) ||
    keyboard_check_pressed(ord("K")) || keyboard_check_pressed(ord("E")) ||
    keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(ord("L")) ||
    keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("M"))
);
global.input.last_device = pad_used ? "pad" : (kb_used ? "kb" : global.input.last_device);

// ----- STORE PREV -----
prev_jump_down   = jump_down_now;
prev_attack_down = attack_down_now;

// ----- RUMBLE -----
if (rumble_frames > 0 && pad_id != -1) {
    gamepad_set_vibration(pad_id, rumble_left, rumble_right);
    rumble_frames--;
} else if (pad_id != -1) {
    gamepad_set_vibration(pad_id, 0, 0);
}
