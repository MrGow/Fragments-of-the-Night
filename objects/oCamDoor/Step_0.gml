/// oCamDoor — Step
if (activate_in > 0) activate_in--;
if (cooldown > 0)    cooldown--;

var pl = instance_nearest(x, y, oPlayer);
hovering = (pl != noone) && place_meeting(x, y, oPlayer);

// Arm only AFTER the player is fully clear
if (!hovering && cooldown <= 0 && activate_in <= 0) armed = true;

// Count Up-hold frames only when overlapping AND armed
if (hovering && armed && mode == "mirror") {
    if (up_pressed()) interact_cnt++; else interact_cnt = 0;
    if (interact_cnt >= interact_need) {
        do_mirror_transition(pl); // now waits for pose to finish
    }
} else {
    interact_cnt = 0;
}

// Fail-safe: if we're waiting for pose but player vanished, just go.
if (waiting_for_pose) {
    if (pl == noone || !instance_exists(pl)) {
        start_transition_now();
    }
}
