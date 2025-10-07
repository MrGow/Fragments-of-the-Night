/// oInput :: Create
pad_id        = -1;
deadzone      = 0.22;
trigger_thresh= 0.5; // (reserved)

rumble_frames = 0;
rumble_left   = 0;
rumble_right  = 0;

// discover a pad (0..3)
for (var i = 0; i < 4; i++) if (gamepad_is_connected(i)) { pad_id = i; break; }
for (var i = 0; i < 4; i++) gamepad_set_axis_deadzone(i, deadzone);

// prev-state edges
prev_jump_down   = false;
prev_attack_down = false;

// global input snapshot (STRUCT)
global.input = {
    // analog / movement
    move_x:0, move_y:0,
    aim_x:0,  aim_y:0,
    dpad_x:0, dpad_y:0,

    // actions
    jump_down:false,  jump_pressed:false,  jump_released:false, jump_held:false,
    attack_down:false,attack_pressed:false,attack_released:false,
    dash_pressed:false, interact_pressed:false,
    flask_pressed:false, parry_pressed:false,
    menu_pressed:false,  map_pressed:false,

    // misc
    last_device:"kb"
};

// ensure singleton
if (instance_number(oInput) > 1) instance_destroy();

