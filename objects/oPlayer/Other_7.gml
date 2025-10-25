/// oPlayer — Animation End
// Return to locomotion after lock-states finish (attack/hurt/drink).

function __ground_now() {
    if (variable_global_exists("tm_solids") && !is_undefined(global.tm_solids)) {
        var eps = 0.1;
        return (tilemap_get_at_pixel(global.tm_solids, bbox_left  + eps, bbox_bottom + 1) != 0)
            || (tilemap_get_at_pixel(global.tm_solids, bbox_right - eps, bbox_bottom + 1) != 0);
    }
    return (bbox_bottom >= room_height - 2);
}
function __read_move_x() {
    if (variable_global_exists("input") && is_struct(global.input) && variable_struct_exists(global.input, "move_x")) {
        return clamp(global.input.move_x, -1, 1);
    }
    return 0;
}
function __to_locomotion(_on_ground, _mx) {
    if (!_on_ground) {
        if (!is_undefined(spr_jump)) { state = "jump"; sprite_index = spr_jump; image_speed = 0.3; }
        else { state = "jump"; }
    } else if (abs(_mx) > 0.001) {
        if (!is_undefined(spr_run))  { state = "run";  sprite_index = spr_run;  image_speed = 1.2; }
        else { state = "run"; }
    } else {
        if (!is_undefined(spr_idle)) { state = "idle"; sprite_index = spr_idle; image_speed = 0.4; }
        else { state = "idle"; }
    }
}

var __on_ground_now = __ground_now();
var __mx            = __read_move_x();

switch (state) {
    case "attack":
        pc_combo_active = false;  // release combo lock
        __to_locomotion(__on_ground_now, __mx);
        break;

    case "hurt":
        if (variable_instance_exists(id,"hurt_lock_timer")) hurt_lock_timer = 0;
        __to_locomotion(__on_ground_now, __mx);
        break;

    case "drink":
        if (variable_global_exists("_drinking_timer")) global._drinking_timer = 0;
        __to_locomotion(__on_ground_now, __mx);
        break;
}
