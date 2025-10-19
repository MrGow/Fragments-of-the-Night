/// oGame — Room Start  (normalize timing; safe spawn to ground; enemy sanity)

game_set_speed(60, gamespeed_fps);   // replaces deprecated room_speed

// ---- Reacquire Solids tilemap for this room ----
var _lid = layer_get_id("Solids");
if (_lid == -1) {
    // fallback: first tilemap found
    var _layers = layer_get_all();
    for (var i = 0; i < array_length(_layers); i++) {
        var _tm = layer_tilemap_get_id(_layers[i]);
        if (_tm != -1) { _lid = _layers[i]; break; }
    }
}
global.tm_solids = (_lid != -1) ? layer_tilemap_get_id(_lid) : undefined;

// ---- Spawn helpers ----
function _tile_solid_at(_x, _y) {
    return (!is_undefined(global.tm_solids)) && (tilemap_get_at_pixel(global.tm_solids, _x, _y) != 0);
}

function _rect_inside_solid(_inst, _dx, _dy) {
    var l = _inst.bbox_left   + _dx;
    var r = _inst.bbox_right  + _dx;
    var t = _inst.bbox_top    + _dy;
    var b = _inst.bbox_bottom + _dy;
    var eps = 0.1;
    return  _tile_solid_at(l+eps, t+eps) || _tile_solid_at(r-eps, t+eps)
         || _tile_solid_at(l+eps, b-eps) || _tile_solid_at(r-eps, b-eps);
}

/// Return a safe (x,y) near the target spawn:
/// 1) if starting inside, move up to 128px upwards until free
/// 2) then drop up to _max_down pixels until the tile below is solid
function _snap_to_ground(_inst, _x, _y, _max_down) {
    var xx = _x, yy = _y;

    // 1) Escape if spawned inside solid
    var up_tries = 0;
    while (_rect_inside_solid(_inst, xx - _inst.x, yy - _inst.y) && up_tries < 128) {
        yy -= 1; up_tries++;
    }

    // 2) Drop until there is solid directly beneath
    var down_tries = 0;
    while (down_tries < _max_down) {
        var l = _inst.bbox_left  + (xx - _inst.x);
        var r = _inst.bbox_right + (xx - _inst.x);
        var b = _inst.bbox_bottom+ (yy - _inst.y);
        var eps = 0.1;
        if (_tile_solid_at(l+eps, b+1) || _tile_solid_at(r-eps, b+1)) break;
        yy += 1; down_tries++;
    }

    return [xx, yy];
}

function _find_spawn(_tag) {
    with (oSpawn) if (spawn_id == _tag) return id;
    return noone;
}

// ---- Decide which spawn tag to use ----
var tag = "default";
if (variable_global_exists("spawn_tag_next") && !is_undefined(global.spawn_tag_next)) {
    tag = global.spawn_tag_next;
    global.spawn_tag_next = undefined; // consume it
}

// ---- Move existing player to spawn (snap to ground) ----
var sp = _find_spawn(tag);
if (sp != noone) {
    var pl = instance_exists(oPlayer) ? instance_find(oPlayer, 0) : noone;
    if (pl != noone) {
        var pos = _snap_to_ground(pl, sp.x, sp.y, 96);
        with (pl) {
            x = pos[0];
            y = pos[1];
            hsp = 0; vsp = 0;
            if (variable_instance_exists(id,"input_locked")) input_locked = false;
        }
    }
}

// ---- Always unlock gameplay input on arrival ----
if (!is_undefined(global.input)) {
    global.input.input_enabled  = true;
    global.input.player_locked  = false;
    global.input.ui_captured    = false;
    global.input.jump_pressed   = false;
    global.input.attack_pressed = false;
}

// ---- Enemy sanity so hits always land even if a Create was skipped ----
with (oParEnemy) {
    if (!variable_instance_exists(id,"hp"))           hp = 3;
    if (!variable_instance_exists(id,"is_dead"))      is_dead = false;
    if (!variable_instance_exists(id,"invul_frames")) invul_frames = 0;
    invincible      = false;
    hurtbox_active  = true;
    image_alpha     = 1.0;
}
with (oSunPilgrim) {
    if (!variable_instance_exists(id,"hp"))           hp = 4;
    if (!variable_instance_exists(id,"is_dead"))      is_dead = false;
    if (!variable_instance_exists(id,"invul_frames")) invul_frames = 0;
}
if (!is_undefined(global.input)) {
    show_debug_message("[GATE] enabled=" + string(global.input.input_enabled) + " locked=" + string(global.input.player_locked) + " ui=" + string(global.input.ui_captured));
}
