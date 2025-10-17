/// oInput — Create
// Persistent input manager
persistent = true;

// Track a connected gamepad (if any)
pad_id = -1;
for (var i = 0; i < 4; i++) if (gamepad_is_connected(i)) { pad_id = i; break; }

// Public API (one place for the rest of the game to read)
global.input = {
    move_x: 0,                // -1 left, +1 right (digital-ized with deadzone)
    jump_pressed: false,      // fires ONCE on the press frame
    jump_down: false,         // held state
    attack_pressed: false,    // fires ONCE on the press frame
    attack_down: false,       // held state

    // Gating flags (set these from menus, pause screens, cutscenes, etc.)
    input_enabled: true,      // master enable/disable
    ui_captured:  false,      // true when a UI is consuming input
    player_locked: false      // true while player-control is intentionally locked
};

// Internal prev-frame latches for edge detection
_jump_down_prev   = false;
_attack_down_prev = false;

// Tunables
deadzone = 0.25;   // analog stick deadzone
