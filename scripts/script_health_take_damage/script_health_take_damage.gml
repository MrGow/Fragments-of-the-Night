/// script_health_take_damage(amount, source)
// Returns true if damage was applied this frame.

function script_health_take_damage(amount, source) {
    // Safe seeds
    if (!variable_global_exists("max_hp"))         global.max_hp = 10;
    if (!variable_global_exists("hp"))             global.hp = global.max_hp;
    if (!variable_global_exists("iframes_time"))   global.iframes_time = 22;
    if (!variable_global_exists("_iframes_timer")) global._iframes_timer = 0;
    if (!variable_global_exists("_hurt_this_step")) global._hurt_this_step = false;
    if (!variable_global_exists("_hp_changed_this_step")) global._hp_changed_this_step = 0;
    if (!variable_global_exists("_hurt_pulse_id")) global._hurt_pulse_id = 0;
    if (!variable_global_exists("dead"))           global.dead = false;

    if (global.dead) return false;

    // Hard i-frame gate: ignore while invulnerable
    if (global._iframes_timer > 0) return false;

    var dmg = max(0, floor(amount));
    if (dmg <= 0) return false;

    global.hp = max(0, global.hp - dmg);
    global._hp_changed_this_step -= dmg;
    global._hurt_this_step = true;

    // Start i-frames
    global._iframes_timer = max(1, global.iframes_time);

    // Emit a NEW one-shot hurt pulse id (consumed by oPlayer)
    global._hurt_pulse_id += 1;

    // Death flag
    if (global.hp <= 0) {
        global.dead = true;
    }

    return true;
}

