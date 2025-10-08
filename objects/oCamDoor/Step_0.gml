/// oCamDoor - Step
if (activate_in > 0) activate_in--;
if (cooldown > 0)    cooldown--;

// (Re)arm once the player is no longer overlapping the door
if (rearm_when_cleared && cooldown <= 0) {
    if (!place_meeting(x, y, oPlayer)) {
        armed = true;
    }
}
