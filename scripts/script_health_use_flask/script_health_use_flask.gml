/// script_health_use_flask()
/// Returns true if a flask was consumed and HP increased.

function script_health_use_flask() {
    // ---- Seed globals safely ----
    if (!variable_global_exists("max_hp"))              global.max_hp = 10;
    if (!variable_global_exists("hp"))                  global.hp = global.max_hp;

    if (!variable_global_exists("flask_max"))           global.flask_max = 3;
    if (!variable_global_exists("flask_stock"))         global.flask_stock = 0;

    if (!variable_global_exists("heal_amount"))         global.heal_amount = 2; // << 2 HP per drink
    if (!variable_global_exists("_drink_lockout"))      global._drink_lockout = 14;
    if (!variable_global_exists("_drinking_timer"))     global._drinking_timer = 0;

    if (!variable_global_exists("_hp_changed_this_step")) global._hp_changed_this_step = 0;
    if (!variable_global_exists("_healed_this_step"))     global._healed_this_step = false;

    if (!variable_global_exists("dead"))                global.dead = false;

    // ---- Hard stops ----
    if (global.dead)                    return false;
    if (global.flask_stock <= 0)        return false;
    if (global.hp >= global.max_hp)     return false; // no over-heal
    if (global._drinking_timer > 0)     return false; // already drinking

    // ---- Apply heal ----
    var missing   = global.max_hp - global.hp;
    var dose      = clamp(global.heal_amount, 1, missing);  // heal up to missing HP
    global.hp    += dose;
    global.flask_stock -= 1;

    // ---- Flags for HUD + effects ----
    global._hp_changed_this_step += dose;
    global._healed_this_step      = true;

    // Start short drink lock (oPlayer honors this to soften movement)
    global._drinking_timer = max(1, global._drink_lockout);

    return true;
}
