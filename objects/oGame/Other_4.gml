/// oGame :: Room Start  (FULL REPLACEMENT)

// ---- Local helpers (defined before use)
function _find_spawn(_tag) {
    with (oSpawn) if (spawn_id == _tag) return id;
    return noone;
}

function _snap_to_ground(_x, _y, _max_down) {
    if (!variable_global_exists("tm_solids") || is_undefined(global.tm_solids)) return [_x, _y];

    var xx = _x, yy = _y;

    // If starting inside solid, nudge up first
    for (var i = 0; i < 32; i++) {
        if (tilemap_get_at_pixel(global.tm_solids, xx, yy) == 0) break;
        yy -= 1;
    }
    // Drop until solid is directly beneath
    for (var j = 0; j < _max_down; j++) {
        if (tilemap_get_at_pixel(global.tm_solids, xx, yy + 1) != 0) break;
        yy += 1;
    }
    return [xx, yy];
}

// ---- Acquire Solids tilemap for this room
var lid = layer_get_id("Solids");
global.tm_solids = (lid != -1) ? layer_tilemap_get_id(lid) : undefined;

// ---- Decide which spawn tag to use
var tag = "default";
if (variable_global_exists("spawn_tag_next") && !is_undefined(global.spawn_tag_next)) {
    tag = global.spawn_tag_next;
    global.spawn_tag_next = undefined; // consume it
}

// ---- Move existing player to spawn (snap to ground)
var sp = _find_spawn(tag);
if (sp != noone) {
    var pl = instance_exists(oPlayer) ? instance_find(oPlayer, 0) : noone;
    if (pl != noone) {
        var pos = _snap_to_ground(sp.x, sp.y, 64);
        with (pl) {
            x = pos[0];
            y = pos[1];
            hsp = 0; vsp = 0;
            input_locked = false; // ensure control after transitions
        }
    }
}

/// oGame — Room Start  (APPEND after your spawn code)

// Normalize timing for this room (removes any post-portal slow/fast effects)
room_speed = 60; // <-- set your intended FPS here

// Always unlock gameplay input on arrival
if (!is_undefined(global.input)) {
    global.input.input_enabled = true;
    global.input.player_locked = false;
    global.input.ui_captured   = false;

    // Clear one-frame pulses on first frame in the room
    global.input.jump_pressed   = false;
    global.input.attack_pressed = false;
}

// Clear any legacy per-instance locks/cooldowns that might block the first swing
with (oPlayer)       if (variable_instance_exists(id,"input_locked")) input_locked = false;
with (oPlayerCombat) if (variable_instance_exists(id,"attack_cd"))    attack_cd    = 0;
