/// oGame — Room Start (lean, no pending-unlock)

// Helpers
function _find_spawn(_tag) {
    with (oSpawn) if (spawn_id == _tag) return id;
    return noone;
}
function _snap_to_ground(_x, _y, _max_down) {
    if (!variable_global_exists("tm_solids") || is_undefined(global.tm_solids)) return [_x, _y];
    var xx = _x, yy = _y;
    for (var i = 0; i < 32; i++) { if (tilemap_get_at_pixel(global.tm_solids, xx, yy) == 0) break; yy -= 1; }
    for (var j = 0; j < _max_down; j++) { if (tilemap_get_at_pixel(global.tm_solids, xx, yy + 1) != 0) break; yy += 1; }
    return [xx, yy];
}

// Solids tilemap
var _lid = layer_get_id("Solids");
global.tm_solids = (_lid != -1) ? layer_tilemap_get_id(_lid) : undefined;

// Spawn tag
var _tag = "default";
if (variable_global_exists("spawn_tag_next") && !is_undefined(global.spawn_tag_next)) {
    _tag = global.spawn_tag_next; global.spawn_tag_next = undefined;
}

// Move player to spawn
var _sp = _find_spawn(_tag);
if (_sp != noone) {
    var _pl = instance_exists(oPlayer) ? instance_find(oPlayer, 0) : noone;
    if (_pl != noone) {
        var _pos = _snap_to_ground(_sp.x, _sp.y, 64);
        with (_pl) {
            x = _pos[0]; y = _pos[1];
            if (variable_instance_exists(id,"hsp")) hsp = 0;
            if (variable_instance_exists(id,"vsp")) vsp = 0;
            if (variable_instance_exists(id,"input_locked")) input_locked = false;
        }
    }
}

// Normalize timing
room_speed = 60;

// Baseline input (kept harmless)
if (!is_undefined(global.input)) {
    global.input.input_enabled  = true;
    global.input.ui_captured    = false;
    global.input.player_locked  = false;
    global.input.jump_pressed   = false;
    global.input.attack_pressed = false;
}

// Reset oInput edges
if (object_exists(oInput) && instance_number(oInput) > 0) {
    with (oInput) { _jump_prev = false; _attack_prev = false; }
}

// Clear any leftover cooldown on player combat
with (oPlayerCombat) if (variable_instance_exists(id,"attack_cd")) attack_cd = 0;

// Enemy sanity (starts enemies hittable on entry)
with (all) if (object_is_ancestor(oParEnemy, object_index)) {
    if (!variable_instance_exists(id,"hp"))                hp = 3;
    if (!variable_instance_exists(id,"is_dead"))           is_dead = false;
    if (!variable_instance_exists(id,"death_sprite"))      death_sprite = -1;
    if (!variable_instance_exists(id,"death_image_speed")) death_image_speed = 0.25;
    if (!variable_instance_exists(id,"explosion_object"))  explosion_object = -1;
    if (!variable_instance_exists(id,"invul_frames"))      invul_frames = 0;

    invul_frames = 0;
    if (variable_instance_exists(id,"invincible"))     invincible = false;
    if (variable_instance_exists(id,"hurtbox_active")) hurtbox_active = true;
    if (is_dead && hp > 0) is_dead = false;
}
