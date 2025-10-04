if (state == "attack") {
    attack_lock = false;

    // Decide next state
    if (!place_meeting(x, y+1, o_solid)) {
        state = "jump";
        sprite_index = spritePlayerJump; image_speed = 0.3;
    } else if (keyboard_check(vk_right) || keyboard_check(vk_left)) {
        state = "run";
        sprite_index = spritePlayerRun;  image_speed = 1;
    } else {
        state = "idle";
        sprite_index = spritePlayerIdle; image_speed = 0.2;
    }

    can_attack = true; // reset attack
    show_debug_message("ANIM END: attack finished");
}

