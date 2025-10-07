/// oPlayer :: Animation End
if (state == "attack") {
    attack_lock = false;
    can_attack  = true;

    var on_ground_now = place_meeting(x, y + 1, oSolid);
    var moving_now    = abs(hsp) > 0.001; // use motion, not fresh input

    if (!on_ground_now) {
        state = "jump";
        sprite_index = spritePlayerJump; image_speed = 0.3; image_index = 0;
    } else if (moving_now) {
        state = "run";
        sprite_index = spritePlayerRun;  image_speed = 1.2; image_index = 0;
    } else {
        state = "idle";
        sprite_index = spritePlayerIdle; image_speed = 0.4; image_index = 0;
    }
}



