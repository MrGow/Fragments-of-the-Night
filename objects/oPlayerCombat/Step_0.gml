/// oPlayerCombat — Step (maintain/advance only; starts are in Begin Step)
var dt = delta_time / 1000000;

// Warm start ratio (local)
var warm_ratio = 0.12;

// --- Defensive inits ---
if (!variable_instance_exists(id, "up_timer"))             up_timer = 0.0;
if (!variable_instance_exists(id, "combo_active"))         combo_active = false;
if (!variable_instance_exists(id, "combo_time"))           combo_time = 0.0;
if (!variable_instance_exists(id, "spawned_this_swing"))   spawned_this_swing = false;
if (!variable_instance_exists(id, "queued_next"))          queued_next = false;
if (!variable_instance_exists(id, "combo_reset_timer"))    combo_reset_timer = 0.0;
if (!variable_instance_exists(id, "attack_cd"))            attack_cd = 0.0;
if (!variable_instance_exists(id, "attack_cd_s"))          attack_cd_s = 0.50;
if (!variable_instance_exists(id, "current_spr"))          current_spr = -1;
if (!variable_instance_exists(id, "combo_index"))          combo_index = 0;
if (!variable_instance_exists(id, "last_finished_index"))  last_finished_index = 0;
if (!variable_instance_exists(id, "combo_dur_s"))          combo_dur_s = 0.55;
if (!variable_instance_exists(id, "active_start_t"))       active_start_t = 0.35;
if (!variable_instance_exists(id, "active_end_t"))         active_end_t   = 0.55;
if (!variable_instance_exists(id, "follow_open_t"))        follow_open_t  = 0.60;
if (!variable_instance_exists(id, "follow_close_t"))       follow_close_t = 0.95;
if (!variable_instance_exists(id, "combo_reset_s"))        combo_reset_s  = 0.45;
if (!variable_instance_exists(id, "slash_forward_px"))     slash_forward_px = 18;
if (!variable_instance_exists(id, "slash_damage"))         slash_damage = 1;
if (!variable_instance_exists(id, "slash_up_y_offset"))    slash_up_y_offset = 12;
if (!variable_instance_exists(id, "slash_up_damage"))      slash_up_damage = 1;
if (!variable_instance_exists(id, "attack_down_prev"))     attack_down_prev = false;

// --- Resolve owner ---
if (!instance_exists(owner)) { if (instance_exists(oPlayer)) owner = instance_nearest(x, y, oPlayer); else exit; }
x = owner.x; y = owner.y;

// ===== FAILSAFE UNLOCK =====
// If we’re not in a combo and no up-slash lock is running, make 100% sure the
// player isn’t stuck in “attack” locks from a previous swing.
if (!combo_active && up_timer <= 0) {
    owner.pc_combo_active = false;
    owner.attack_lock     = false;
    // (Do NOT force sprite/state here; oPlayer handles release/locomotion)
}
// ===========================

// Break on owner hard states
if (variable_instance_exists(owner,"state")) {
    var st = owner.state;
    if (st == "hurt" || st == "drink") {
        combo_active = false; combo_time = 0; spawned_this_swing = false; queued_next = false;
        combo_reset_timer = 0; owner.pc_combo_active = false; owner.attack_lock = false;
        up_timer = 0; current_spr = -1;
    }
}

// Maintain up-slash lock (manual frames; engine OFF)
if (up_timer > 0) {
    up_timer -= dt;
    if (up_timer <= 0) {
        up_timer = 0;
        owner.pc_combo_active = false;
        owner.attack_lock = false;
        current_spr = -1;
    } else {
        owner.state = "attack";
        owner.pc_combo_active = true;
        owner.attack_lock = true;

        if (spr_attack_up != -1) {
            if (owner.sprite_index != spr_attack_up) {
                var keep_idx_up = owner.image_index;
                owner.sprite_index = spr_attack_up;
                owner.image_index  = keep_idx_up;
            }
            var frames_up = max(1, sprite_get_number(spr_attack_up));
            var step_up   = frames_up / (max(0.001, attack_cd_s) * room_speed);
            owner.image_speed = 0;          // ENGINE OFF
            owner.image_index += step_up;   // manual advance
            if (owner.image_index >= frames_up) owner.image_index = frames_up - 0.001;
        }
    }
}

// Cooldowns tick here
if (attack_cd > 0) attack_cd -= dt;

// Read input for queuing NEXT (no new starts here)
var down_now = false, pressed_pulse = false;
if (object_exists(oInput) && instance_number(oInput) > 0 && !is_undefined(global.input)) {
    down_now      = !!global.input.attack_down;
    pressed_pulse = !!global.input.attack_pressed;
} else {
    down_now      = keyboard_check(ord("Z")) || keyboard_check(ord("X")) || mouse_check_button(mb_left);
    pressed_pulse = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("X")) || mouse_check_button_pressed(mb_left);
}
var pressed_local = (down_now && !attack_down_prev);
attack_down_prev  = down_now;
var pressed_any   = pressed_pulse || pressed_local;

// ===================== DURING COMBO =====================
if (combo_active) {
    // reassert sprite w/o resetting index
    if (current_spr != -1 && owner.sprite_index != current_spr) {
        var keep_idx2 = owner.image_index;
        owner.sprite_index = current_spr;
        owner.image_index  = keep_idx2;
    }

    // MANUAL advance; ENGINE OFF
    var frames_now = max(1, sprite_get_number(current_spr));
    var step_now   = frames_now / (max(0.001, combo_dur_s) * room_speed);
    owner.image_speed = 0;
    owner.image_index += step_now;
    if (owner.image_index >= frames_now) owner.image_index = frames_now - 0.001;

    // progress timer
    combo_time += dt;
    var t = combo_time / max(0.001, combo_dur_s); // 0..1

    // spawn once
    if (!spawned_this_swing && t >= active_start_t) {
        var forward = sign(owner.image_xscale); if (forward == 0) forward = 1;
        if (object_exists(oPlayerSlash)) {
            var hb = instance_create_layer(owner.x + forward * slash_forward_px, owner.y, layer, oPlayerSlash);
            hb.owner          = owner;
            hb.direction_sign = forward;
            hb.damage         = slash_damage;
        }
        spawned_this_swing = true;
    }

    // queue follow-up inside window
    if (t >= follow_open_t && t <= follow_close_t) if (pressed_any) queued_next = true;

    // finish swing
    if (t >= 1.0) {
        last_finished_index = combo_index;
        combo_active = false;
        combo_time   = 0;
        spawned_this_swing = false;

        if (queued_next) {
            combo_index = (combo_index + 1) mod 3;
            combo_active = true;
            queued_next  = false;

            owner.state = "attack";
            owner.attack_lock = true;
            owner.pc_combo_active = true;

            var spr2 = -1;
            if (combo_index == 0)      spr2 = spr_attack_a;
            else if (combo_index == 1) spr2 = spr_attack_b;
            else                       spr2 = spr_attack_c;

            current_spr = spr2;
            if (spr2 != -1) {
                owner.sprite_index = spr2;

                var frames2 = max(1, sprite_get_number(spr2));
                var step2   = frames2 / (max(0.001, combo_dur_s) * room_speed);
                var bias2   = clamp(frames2 * warm_ratio, 0, max(0, frames2 - 1));
                owner.image_speed = 0;
                owner.image_index = min(frames2 - 0.001, bias2 + step2);
            }
        } else {
            combo_reset_timer = combo_reset_s;
            attack_cd = 0.06;
            owner.pc_combo_active = false;
            owner.attack_lock = false;
            current_spr = -1;
        }
    }
}
