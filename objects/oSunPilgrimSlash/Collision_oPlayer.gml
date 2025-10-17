/// oSunPilgrimSlash — Collision with oPlayer
if (other != owner) {
    var dealt = false;
    if (is_undefined(other.take_damage)) {
        if (script_exists(scr_player_take_damage)) {
            scr_player_take_damage(other, damage, x);
            dealt = true;
        }
    } else {
        /// oSunPilgrimSlash — Collision with oPlayer
if (other != owner) {
    // Call player's damage in the player's context; 'other' here becomes the slash instance
    with (other) take_damage(other.damage, other.x); // ✅ amount is REAL (slash.damage), from_x is REAL
}

    }
    if (dealt) instance_destroy();
}
