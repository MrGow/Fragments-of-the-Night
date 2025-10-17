/// oPlayer :: Animation End

if (state == "attack") {
    attack_lock = false;
    can_attack  = true;

    // Safe ensure before any read:
    if (!variable_global_exists("tm_solids")) global.tm_solids = undefined;
    function __ensure_tm_solids() {
        if (is_undefined(global.tm_solids)) {
            var _lid = layer_get_id("Solids"); // or L_SOLIDS
            if (_lid != -1) global.tm_solids = layer_tilemap_get_id(_lid);
        }
        return global.tm_solids;
    }
    __ensure_tm_solids();

    // Tiny inline helpers
    function __tile_solid_at(_x, _y) {
        return (!is_undefined(global.tm_solids)) && (tilemap_get_at_pixel(global.tm_solids, _x, _y) != 0);
    }
    function __on_ground_check() {
        var eps = 0.1, l = bbox_left, r = bbox_right, b = bbox_bottom;
        return __tile_solid_at(l + eps, b + 1) || __tile_solid_at(r - eps, b + 1);
    }

    var on_ground_now = __on_ground_check();
    var moving_now    = abs(hsp) > 0.001;

    if (!on_ground_now) {
        state = "jump";
        sprite_index = spritePlayerJump;  image_speed = 0.3; image_index = 0;
    } else if (moving_now) {
        state = "run";
        sprite_index = spritePlayerRun;   image_speed = 1.2; image_index = 0;
    } else {
        state = "idle";
        sprite_index = spritePlayerIdle;  image_speed = 0.4; image_index = 0;
    }
}



