/// oHubExit — Collision with oPlayer (robust, no missing `target` crash)

// --- Optional: require UP to use the exit ---
var require_up = true;
if (require_up) {
    var pressed_up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
    for (var dev = 0; dev < 8; dev++) {
        if (!gamepad_is_connected(dev)) continue;
        if (gamepad_button_check_pressed(dev, gp_padu)) pressed_up = true;
    }
    if (!pressed_up) exit;
}

if (variable_global_exists("_transition_busy") && global._transition_busy) exit;

// --- Resolve destination room safely ---
function _get_exit_target(inst) {
    // try common instance vars set in Room Editor
    if (variable_instance_exists(inst, "target"))      return inst.target;
    if (variable_instance_exists(inst, "room_target")) return inst.room_target;
    if (variable_instance_exists(inst, "target_room")) return inst.target_room;

    // fallback: if we're in SaveRoom, go back to the stored return room
    if (room == SaveRoom && !is_undefined(global.return_room)) return global.return_room;

    return undefined;
}

var _dest = _get_exit_target(id);

if (is_undefined(_dest)) {
    // Nothing set — don’t crash; just warn in the output
    show_debug_message("[oHubExit] No destination room set (target/room_target/target_room missing), and no global.return_room fallback.");
    exit;
}

// --- Prepare spawn tag (if we saved one on the way in) ---
if (!is_undefined(global.return_spawn_id)) {
    global.spawn_tag_next = string(global.return_spawn_id);
} else {
    // Optional: a per-exit spawn tag variable you can set in editor
    if (variable_instance_exists(id, "spawn_tag")) {
        global.spawn_tag_next = string(spawn_tag);
    } else {
        global.spawn_tag_next = undefined;
    }
}

// ===== PLAYER: lock forward "look into mirror" pose (50% faster) =====
var pl = other; // oPlayer
if (instance_exists(pl)) with (pl) {
    if (!variable_instance_exists(id,"forced_anim_active"))  forced_anim_active  = false;
    if (!variable_instance_exists(id,"forced_anim_sprite"))  forced_anim_sprite  = -1;
    if (!variable_instance_exists(id,"forced_anim_speed"))   forced_anim_speed   = 0.45; // faster
    if (!variable_instance_exists(id,"forced_anim_reverse")) forced_anim_reverse = false;
    if (!variable_instance_exists(id,"forced_anim_started")) forced_anim_started = false;

    forced_anim_sprite  = __spr("spritePlayerLookInwards");
    if (forced_anim_sprite == -1) forced_anim_sprite = spritePlayerLookInwards;
    forced_anim_speed   = 0.45;
    forced_anim_reverse = false;    // forward as we leave SaveRoom
    forced_anim_active  = true;
    forced_anim_started = false;
}

// --- Run the unified transition ---
script_transition_goto(_dest, global.spawn_tag_next);
