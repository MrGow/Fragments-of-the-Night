/// oPlayer — Animation End  (return to locomotion after lock-states, keep feet)

// Inline feet-preserving setter (local to this event)
function __set_sprite_keep_feet_local(_spr, _spd) {
    if (_spr == -1) return;
    var cur_yoff = sprite_get_yoffset(sprite_index);
    var cur_bot  = sprite_get_bbox_bottom(sprite_index);
    var feet_y   = y - cur_yoff + cur_bot;

    sprite_index = _spr;
    if (!is_undefined(_spd)) image_speed = _spd;

    var new_yoff = sprite_get_yoffset(sprite_index);
    var new_bot  = sprite_get_bbox_bottom(sprite_index);
    y = feet_y - (new_bot - new_yoff);
}

// Ground check (inline; no local static)
var __on_ground_now;
if (variable_global_exists("tm_solids") && !is_undefined(global.tm_solids)) {
    var __eps = 0.1;
    __on_ground_now =
        (tilemap_get_at_pixel(global.tm_solids, bbox_left  + __eps, bbox_bottom + 1) != 0) ||
        (tilemap_get_at_pixel(global.tm_solids, bbox_right - __eps, bbox_bottom + 1) != 0);
} else {
    __on_ground_now = (bbox_bottom >= room_height - 2);
}

// Read horizontal input (inline)
var __mx = 0;
if (variable_global_exists("input") && is_struct(global.input) && variable_struct_exists(global.input, "move_x")) {
    __mx = clamp(global.input.move_x, -1, 1);
}

// Typed sprite lookups (via __spr from Create)
var __sprIdle = __spr("spritePlayerIdle");
var __sprRun  = __spr("spritePlayerRun");
var __sprJump = __spr("spritePlayerJump");

// Decide next locomotion state (feet-preserving)
switch (state) {
    case "attack":
        pc_combo_active = false;
        if (!__on_ground_now) {
            __set_sprite_keep_feet_local(__sprJump, 0.3); state = "jump";
        } else if (abs(__mx) > 0.001) {
            __set_sprite_keep_feet_local(__sprRun,  1.2); state = "run";
        } else {
            __set_sprite_keep_feet_local(__sprIdle, 0.4); state = "idle";
        }
        break;

    case "hurt":
        if (variable_instance_exists(id,"hurt_lock_timer")) hurt_lock_timer = 0;
        if (!__on_ground_now) {
            __set_sprite_keep_feet_local(__sprJump, 0.3); state = "jump";
        } else if (abs(__mx) > 0.001) {
            __set_sprite_keep_feet_local(__sprRun,  1.2); state = "run";
        } else {
            __set_sprite_keep_feet_local(__sprIdle, 0.4); state = "idle";
        }
        break;

    case "drink":
        if (variable_global_exists("_drinking_timer")) global._drinking_timer = 0;
        if (!__on_ground_now) {
            __set_sprite_keep_feet_local(__sprJump, 0.3); state = "jump";
        } else if (abs(__mx) > 0.001) {
            __set_sprite_keep_feet_local(__sprRun,  1.2); state = "run";
        } else {
            __set_sprite_keep_feet_local(__sprIdle, 0.4); state = "idle";
        }
        break;
}
