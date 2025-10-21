/// script_health_take_damage(amount, attacker)
// 2.3+ function; centralizes player damage + i-frames + HUD signals

function script_health_take_damage(_amount, _attacker) {

    // ---------- Seed all globals safely ----------
    if (!variable_global_exists("max_hp"))              global.max_hp = 10;
    if (!variable_global_exists("hp"))                  global.hp = global.max_hp;

    if (!variable_global_exists("iframes_time"))        global.iframes_time = 22; // frames
    if (!variable_global_exists("_iframes_timer"))      global._iframes_timer = 0;

    if (!variable_global_exists("_drinking_timer"))     global._drinking_timer = 0;
    if (!variable_global_exists("_drink_lockout"))      global._drink_lockout = 14;

    if (!variable_global_exists("_hp_changed_this_step")) global._hp_changed_this_step = 0;
    if (!variable_global_exists("_healed_this_step"))     global._healed_this_step = false;
    if (!variable_global_exists("_hurt_this_step"))       global._hurt_this_step = false;

    if (!variable_global_exists("dead"))                global.dead = false;

    // ---------- Early outs ----------
    var amt = max(0, _amount);
    if (amt <= 0) return;

    // If in invulnerability window, ignore new hits
    if (global._iframes_timer > 0) return;

    if (global.dead) return;

    // ---------- Apply damage ----------
    global.hp = clamp(global.hp - amt, 0, global.max_hp);
    global._hp_changed_this_step += -amt;
    global._hurt_this_step = true;

    // Start i-frames
    global._iframes_timer = max(0, global.iframes_time);

    // Optional: small camera/player feedback can go here later

    // ---------- Death check ----------
    if (global.hp <= 0) {
        global.dead = true;
        // You can trigger respawn/altar logic from oGame Step or a death controller.
    }
}
