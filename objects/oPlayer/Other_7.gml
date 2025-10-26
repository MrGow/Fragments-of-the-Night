/// oPlayer — Animation End

// If we’re grabbing or pulling a ledge, never let Animation End change state.
if (state == "ledge" || state == "ledge_pull") {
    exit;
}

// Helper: go back to locomotion while preserving feet
function __to_locomotion() {
    var sprIdle = __spr("spritePlayerIdle");
    var sprRun  = __spr("spritePlayerRun");
    var sprJump = __spr("spritePlayerJump");

    // quick ground & input read (mirrors Step)
    var eps = 0.1;
    var on_ground =
        (!is_undefined(global.tm_solids)) &&
        (tilemap_get_at_pixel(global.tm_solids, bbox_left  + eps, bbox_bottom + 1) != 0 ||
         tilemap_get_at_pixel(global.tm_solids, bbox_right - eps, bbox_bottom + 1) != 0);

    var kx = (keyboard_check(vk_right)||keyboard_check(ord("D"))) -
             (keyboard_check(vk_left) ||keyboard_check(ord("A")));
    var move_x = clamp(kx, -1, 1);
    if (variable_global_exists("input") && is_struct(global.input) && move_x == 0) {
        if (variable_struct_exists(global.input,"move_x")) move_x = clamp(global.input.move_x, -1, 1);
    }

    if (!on_ground) {
        if (sprJump != -1) { __set_sprite_keep_feet(sprJump, 0.3); }
        state = "jump";
    } else if (abs(move_x) > 0.001) {
        if (sprRun  != -1) { __set_sprite_keep_feet(sprRun, 1.2); }
        state = "run";
    } else {
        if (sprIdle != -1) { __set_sprite_keep_feet(sprIdle, 0.4); }
        state = "idle";
    }
}

switch (state) {
    case "attack":
        // IMPORTANT: release the movement lock when the attack anim ends
        pc_combo_active = false;
        attack_just_started = false;
        __to_locomotion();
        break;

    case "hurt":
        __to_locomotion();
        break;

    case "drink":
        __to_locomotion();
        break;
}
