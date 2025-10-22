/// oPlayer — Animation End
if (state == "attack" || state == "drink" || state == "hurt") {
    attack_lock = false;
    // Resume appropriate locomotion
    var on_ground = (bbox_bottom + 1) < room_height && place_meeting(x, bbox_bottom + 1, oSolid) /*fallback*/ ? true : true;
    // Just use the same return logic as Step does:
    if (!place_meeting(x, y + 1, oSolid)) {
        state = "jump";
        if (spr_jump != -1) { sprite_index = spr_jump; image_speed = 0.3; }
    } else {
        if (abs(hsp) > 0.001) {
            state = "run";
            if (spr_run != -1) { sprite_index = spr_run; image_speed = 1.2; }
        } else {
            state = "idle";
            if (spr_idle != -1) { sprite_index = spr_idle; image_speed = 0.4; }
        }
    }
}
