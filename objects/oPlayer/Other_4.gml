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
