// Persistent input manager
persistent = true;

// Gamepad tracking
pad_id = -1; // unknown / none
for (var i = 0; i < 4; i++) if (gamepad_is_connected(i)) { pad_id = i; break; }

// Input state exposed to the game
global.input = {
    move_x: 0,
    jump_pressed: false,
    jump_held: false,
    attack_pressed: false
};
