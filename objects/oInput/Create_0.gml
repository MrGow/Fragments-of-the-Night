/// oInput — Create
persistent = true;
if (instance_number(oInput) > 1) { instance_destroy(); exit; }

// Gamepad tracking
pad_id = -1;
for (var i = 0; i < 8; i++) if (gamepad_is_connected(i)) { pad_id = i; break; }

// Public API (global gates included)
global.input = {
    move_x: 0,                // -1 .. +1
    jump_down: false,
    jump_pressed: false,      // one-frame pulse
    attack_down: false,
    attack_pressed: false,    // one-frame pulse

    // Global gates (portal/fade toggles these)
    input_enabled: true,
    ui_captured:  false,
    player_locked: false
};

// Internal prev-state for edge detection
_jump_prev   = false;
_attack_prev = false;

// Tunables
deadzone = 0.25;
