/// oPlayer — Room Start  (ADD AT TOP)
// Always unlock gameplay input on arrival
if (!is_undefined(global.input)) {
    global.input.input_enabled = true;
    global.input.player_locked = false;
    global.input.ui_captured   = false;

    // clear one-frame pulses so first press in the room isn't eaten
    global.input.jump_pressed   = false;
    global.input.attack_pressed = false;
}

// Clear any legacy per-instance lock if it exists
if (variable_instance_exists(id,"input_locked")) input_locked = false;

// Reset any combat cooldown the portal might leave nonzero
with (oPlayerCombat) {
    if (instance_exists(id) && variable_instance_exists(id,"attack_cd")) attack_cd = 0;
}


if (variable_global_exists("spawn_tag_next")) {
    var want = string(global.spawn_tag_next);
    var sp = noone, n = instance_number(oSpawn);
    for (var i = 0; i < n; i++) {
        var inst = instance_find(oSpawn, i);
        if (inst != noone && string(inst.spawn_id) == want) { sp = inst; break; }
    }
    if (sp != noone) { x = sp.x; y = sp.y; }
    global.spawn_tag_next = undefined;
}
