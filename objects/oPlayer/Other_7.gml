/// oPlayer Animation End

// Only care about non-looping sequences (e.g., attack)
if (state == "attack") {
    attack_lock = false;
    can_attack  = true;

    // Ground & input snapshot
    var on_ground = place_meeting(x, y + 1, oSolid);

    // Movement intent: pad first (if available), else keyboard
    var moving = false;
    if (variable_global_exists("input")) {
        moving = (abs(global.input.move_x) > 0.001);
    } else {
        moving = (keyboard_check(vk_left) || keyboard_check(vk_right));
    }

    // Choose next state
    if (!on_ground) {
        state = "jump";
        sprite_index = spritePlayerJump;
        image_speed  = 0.3;
        image_index  = 0;
    } else if (moving) {
        state = "run";
        sprite_index = spritePlayerRun;
        image_speed  = 1.2;
        image_index  = 0;
    } else {
        state = "idle";
        sprite_index = spritePlayerIdle;
        image_speed  = 0.4;
        image_index  = 0;
    }

    show_debug_message("ANIM END: attack finished -> " + string(state));
}

// If you later add other non-looping states (e.g., "hurt", "land"),
// you can branch them here similarly and return to idle/run/jump.



