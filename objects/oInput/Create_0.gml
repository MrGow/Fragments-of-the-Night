/// oInput Create
pad_id = -1;
deadzone = 0.22;
trigger_thresh = 0.5; // unused for now; fine to keep

// rumble
rumble_frames = 0;
rumble_left   = 0;
rumble_right  = 0;

// find a pad (0..3)
for (var i = 0; i < 4; i++) if (gamepad_is_connected(i)) { pad_id = i; break; }
for (var i = 0; i < 4; i++) gamepad_set_axis_deadzone(i, deadzone);

// init the global snapshot (STRUCT)
global.input = {
    move_x:0, move_y:0, aim_x:0, aim_y:0,
    dpad_x:0, dpad_y:0,
    jump_down:false,  jump_pressed:false,  jump_released:false,
    attack_down:false,attack_pressed:false,attack_released:false,
    dash_pressed:false, interact_pressed:false,
    flask_pressed:false, parry_pressed:false,
    // (omit LT/RT for now to avoid constant differences)
    menu_pressed:false, map_pressed:false,
    last_device:"kb"
};

// ensure singleton
if (instance_number(oInput) > 1) instance_destroy();
