/// oSunPilgrimSlash — Collision with oPlayer
if (other != owner) {
    // Only damage the player if you have a dedicated player-damage script.
    // (You don't yet in this build, so this is safe and won't crash.)
    if (script_exists(script_player_take_damage)) {
        script_player_take_damage(other, damage, x); // (player, amount, from_x)
    }
    // Always remove the slash on contact (adjust if you want multi-hit)
    instance_destroy();
}
