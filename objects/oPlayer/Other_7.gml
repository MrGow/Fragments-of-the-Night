/// oPlayer — Animation End
// We ONLY handle non-attack locks here (drink/hurt).
// Attacks are driven by oPlayerCombat and released from oPlayer Step when the combo/up timer ends.

// Minimal tilemap ground check (local helper)
function __hud_tile_solid_at(_x, _y) {
    return (variable_global_exists("tm_solids") && !is_undefined(global.tm_solids))
        && (tilemap_get_at_pixel(global.tm_solids, _x, _y) != 0);
}
function __hud_on_ground() {
    var eps = 0.1;
    var l = bbox_left, r = bbox_right, b = bbox_bottom;
    return __hud_tile_solid_at(l + eps, b + 1) || __hud_tile_solid_at(r - eps, b + 1);
}

if (state == "drink" || state == "hurt") {
    attack_lock = false;

    // Restore locomotion
    var on_ground = __hud_on_ground();
    if (!on_ground) {
        state = "jump"; if (spr_jump != -1) { sprite_index = spr_jump; image_speed = 0.3; }
    } else if (abs(hsp) > 0.001) {
        state = "run";  if (spr_run  != -1) { sprite_index = spr_run;  image_speed = 1.2; }
    } else {
        state = "idle"; if (spr_idle != -1) { sprite_index = spr_idle; image_speed = 0.4; }
    }
}

// NOTE: We intentionally do NOT handle "attack" here.
// oPlayer Step will restore when pc_combo_active/up_timer is released.
