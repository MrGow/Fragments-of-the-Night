/// oHUD_HPFlask — Step

// ====== Handle HP cap changes safely ======
if (!variable_global_exists("max_hp")) global.max_hp = max(1, max_hp_cache);
if (global.max_hp != max_hp_cache) {
    max_hp_cache = global.max_hp;
    var cap = max(1, max_hp_cache);

    array_resize(moon_state, cap);
    array_resize(moon_frame, cap);
    array_resize(moon_dir,   cap);

    display_hp = clamp(display_hp, 0, cap);
    var last = sprite_get_number(spr_moon_fill_strip) - 1;

    for (var i = 0; i < cap; i++) {
        if (i < display_hp) {
            moon_state[i] = 1;
            moon_frame[i] = 0;
            moon_dir[i]   = 0;
        } else {
            moon_state[i] = 0;
            moon_frame[i] = last;
            moon_dir[i]   = 0;
        }
    }
    active_anim_index = -1;
}

// ====== Consume feedback signals from controller ======
if (variable_global_exists("_hurt_this_step") && global._hurt_this_step) {
    skull_alert_t = skull_alert_ms;
}
if (variable_global_exists("_healed_this_step") && global._healed_this_step) {
    chal_anim_t = heal_anim_ms;
}
if (skull_alert_t > 0) skull_alert_t--;
if (chal_anim_t   > 0) chal_anim_t--;

// ====== Sync target HP from controller ======
if (!variable_global_exists("hp")) global.hp = display_hp;
target_hp = clamp(global.hp, 0, max_hp_cache);

// ====== If no moon animating, start one step toward the target ======
if (active_anim_index == -1) {
    if (display_hp < target_hp) {
        var idx = display_hp; // fill next
        if (idx >= 0 && idx < max_hp_cache) {
            active_anim_index = idx;
            moon_state[idx]   = 2;
            moon_dir[idx]     = +1; // forward
            moon_frame[idx]   = 0;
        }
    } else if (display_hp > target_hp) {
        var idx = display_hp - 1; // empty last filled
        if (idx >= 0 && idx < max_hp_cache) {
            active_anim_index = idx;
            moon_state[idx]   = 2;
            moon_dir[idx]     = -1; // backward
            moon_frame[idx]   = sprite_get_number(spr_moon_fill_strip) - 1;
        }
    }
}

// ====== Drive current moon animation (if any) ======
if (active_anim_index != -1) {
    var i    = active_anim_index;
    var last = sprite_get_number(spr_moon_fill_strip) - 1;

    moon_frame[i] += anim_speed * moon_dir[i];

    if (moon_dir[i] > 0) {
        if (moon_frame[i] >= last) {
            moon_state[i] = 1;
            moon_frame[i] = 0;
            moon_dir[i]   = 0;
            display_hp    = min(display_hp + 1, max_hp_cache);
            active_anim_index = -1;
        }
    } else if (moon_dir[i] < 0) {
        if (moon_frame[i] <= 0) {
            moon_state[i] = 0;
            moon_frame[i] = last;
            moon_dir[i]   = 0;
            display_hp    = max(display_hp - 1, 0);
            active_anim_index = -1;
        }
    } else {
        active_anim_index = -1;
    }
}

