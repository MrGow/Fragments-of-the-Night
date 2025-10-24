/// oPlayer — Animation End
// Return to locomotion after lock-states finish (attack/hurt/drink).
// Uses parameterised helpers so no out-of-scope reads happen.

// --- Local ground probe (works with or without tilemap) ---
function __ground_now() {
    if (variable_global_exists("tm_solids") && !is_undefined(global.tm_solids)) {
        var eps = 0.1;
        return (tilemap_get_at_pixel(global.tm_solids, bbox_left  + eps, bbox_bottom + 1) != 0)
            || (tilemap_get_at_pixel(global.tm_solids, bbox_right - eps, bbox_bottom + 1) != 0);
    }
    // fallback: near room bottom
    return (bbox_bottom >= room_height - 2);
}

// Read current desired move (for deciding run vs idle)
function __read_move_x() {
    if (variable_global_exists("input") && is_struct(global.input) && variable_struct_exists(global.input, "move_x")) {
        return clamp(global.input.move_x, -1, 1);
    }
    return 0;
}

// Helper to go back to locomotion cleanly (PARAMETERIZED!)
function __to_locomotion(_on_ground, _mx) {
    if (!_on_ground) {
        if (variable_instance_exists(id,"spr_jump") && spr_jump != -1) { state = "jump"; sprite_index = spr_jump; image_speed = 0.3; }
        else { state = "jump"; }
    } else if (abs(_mx) > 0.001) {
        if (variable_instance_exists(id,"spr_run") && spr_run != -1) { state = "run";  sprite_index = spr_run;  image_speed = 1.2; }
        else { state = "run"; }
    } else {
        if (variable_instance_exists(id,"spr_idle") && spr_idle != -1) { state = "idle"; sprite_index = spr_idle; image_speed = 0.4; }
        else { state = "idle"; }
    }
}

// Snapshot once for this event
var __on_ground_now = __ground_now();
var __mx            = __read_move_x();

// ---- State-based release ----
switch (state) {
    case "attack":
        // Attacks are driven by oPlayerCombat; when the sprite finishes, hand back to locomotion.
        __to_locomotion(__on_ground_now, __mx);
        break;

    case "hurt":
        // Clear any temporary locks and return to locomotion
        if (variable_instance_exists(id,"hurt_lock_timer")) hurt_lock_timer = 0;
        __to_locomotion(__on_ground_now, __mx);
        break;

    case "drink":
        // Clear drink lockouts (HUD drives flask UI separately)
        if (variable_global_exists("_drinking_timer")) global._drinking_timer = 0;
        __to_locomotion(__on_ground_now, __mx);
        break;

    // If ledge_pull uses an animation, Step’s ledge timer handles finishing the climb.
}
