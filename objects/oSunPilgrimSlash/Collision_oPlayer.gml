/// oSunPilgrimSlash — Collision with oPlayer
if (other != owner) {
    var dealt = false;
    if (is_undefined(other.take_damage)) {
        if (script_exists(scr_player_take_damage)) {
            scr_player_take_damage(other, damage, x);
            dealt = true;
        }
    } else {
        with (other) take_damage(other, other.x);
        dealt = true;
    }
    if (dealt) instance_destroy();
}
