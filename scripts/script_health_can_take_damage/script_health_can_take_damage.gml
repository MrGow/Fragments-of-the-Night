/// @function script_health_can_take_damage()
/// @returns {bool}
/// Returns whether the player can currently take damage.
function script_health_can_take_damage() {
    // Block while in iframes or during drinking animation lock
    if (global._iframes_timer > 0) return false;
    if (global._drinking_timer > 0) return false;

    // Later you can OR more flags here (cutscenes, transitions, UI)
    return (!global.dead);
}
