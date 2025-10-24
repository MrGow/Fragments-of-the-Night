/// oPlayerCombat — Begin Step (start attacks early; warm-start; set just-start flag)
var dt = delta_time / 1000000;

// --- Defensive inits (hot-load safe) ---
if (!variable_instance_exists(id, "up_timer"))             up_timer = 0.0;
if (!variable_instance_exists(id, "combo_active"))         combo_active = false;
if (!variable_instance_exists(id, "combo_time"))           combo_time = 0.0;
if (!variable_instance_exists(id, "spawned_this_swing"))   spawned_this_swing = false;
if (!variable_instance_exists(id, "queued_next"))          queued_next = false;
if (!variable_instance_exists(id, "combo_reset_timer"))    combo_reset_timer = 0.0;
if (!variable_instance_exists(id, "attack_cd"))            attack_cd = 0.0;
if (!variable_instance_exists(id, "attack_cd_s"))          attack_cd_s = 0.50;  // tweak
if (!variable_instance_exists(id, "current_spr"))          current_spr = -1;
if (!variable_instance_exists(id, "combo_index"))          combo_index = 0;
if (!variable_instance_exists(id, "last_finished_index"))  last_finished_index = 0;
if (!variable_instance_exists(id, "combo_dur_s"))          combo_dur_s = 0.55;  // tweak
if (!variable_instance_exists(id, "active_start_t"))       active_start_t = 0.35;
if (!variable_instance_exists(id, "active_end_t"))         active_end_t   = 0.55;
if (!variable_instance_exists(id, "follow_open_t"))        follow_open_t  = 0.60;
if (!variable_instance_exists(id, "follow_close_t"))       follow_close_t = 0.95;
if (!variable_instance_exists(id, "combo_reset_s"))        combo_reset_s  = 0.45;
if (!variable_instance_exists(id, "slash_forward_px"))     slash_forward_px = 18;
if (!variable_instance_exists(id, "slash_damage"))         slash_damage = 1;
if (!variable_instance_exists(id, "slash_up_y_offset"))    slash_up_y_offset = 12;
if (!variable_instance_exists(id, "slash_up_damage"))      slash_up_damage = 1;
if (!variable_instance_exists(id, "combo_debug"))          combo_debug = false;

// Warm start so frame 0 never “sticks”
var warm_ratio = 0.12;

// --- Resolve/track owner ---
if (!instance_exists(owner)) { if (instance_exists(oPlayer)) owner = instance_nearest(x, y, oPlayer); else exit; }
x = owner.x; y = owner.y;

// Cancel starts if owner in hard-lock states
if (variable_instance_exists(owner,"state")) {
    var st = owner.state;
    if (st == "hurt" || st == "drink") exit;
}

// --- Read inputs (oInput also runs in Begin Step) ---
var down_now      = false;
var pressed_pulse = false;
if (object_exists(oInput) && instance_number(oInput) > 0 && !is_undefined(global.input)) {
    down_now      = !!global.input.attack_down;
    pressed_pulse = !!global.input.attack_pressed;
} else {
    down_now      = keyboard_check(ord("Z")) || keyboard_check(ord("X")) || mouse_check_button(mb_left);
    pressed_pulse = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("X")) || mouse_check_button_pressed(mb_left);
}
var pressed_any = pressed_pulse || (down_now && !attack_down_prev);

// Up held?
var up_held = keyboard_check(vk_up) || keyboard_check(ord("W"));
for (var i = 0; i < 4; i++) {
    if (!gamepad_is_connected(i)) continue;
    up_held = up_held || gamepad_button_check(i, gp_padu);
    var ly = gamepad_axis_value(i, gp_axislv);
    var ry = gamepad_axis_value(i, gp_axisry);
    if (ly < -0.5 || ry < -0.5) up_held = true;
}

// ---------- Start UP-SLASH here ----------
if (pressed_any && !combo_active && up_timer <= 0 && attack_cd <= 0 && up_held && object_exists(oPlayerSlashUp)) {
    owner.state = "attack";
    owner.attack_lock = true;
    owner.pc_combo_active = true;
    owner.attack_just_started = true;

    current_spr = spr_attack_up;
    if (spr_attack_up != -1) {
        owner.sprite_index = spr_attack_up;

        // Use owner's sprite_index for frame count (type-safe)
        var frames_up0 = max(1, sprite_get_number(owner.sprite_index));
        var step_up0   = frames_up0 / (max(0.001, attack_cd_s) * room_speed);
        var bias_up    = clamp(frames_up0 * warm_ratio, 0, max(0, frames_up0 - 1));
        owner.image_speed = 0; // ENGINE OFF — we drive manually
        owner.image_index = min(frames_up0 - 0.001, bias_up + step_up0);
    }

    var hb_u = instance_create_layer(owner.x, owner.y - slash_up_y_offset, layer, oPlayerSlashUp);
    hb_u.owner  = owner;
    hb_u.damage = slash_up_damage;
    if (variable_instance_exists(hb_u, "facing")) {
        var forward = sign(owner.image_xscale); if (forward == 0) forward = 1;
        hb_u.facing = forward;
    }

    up_timer  = attack_cd_s;
    attack_cd = attack_cd_s;
    exit;
}

// ---------- Start COMBO swing here ----------
if (!combo_active && pressed_any && up_timer <= 0 && attack_cd <= 0) {
    if (combo_reset_timer > 0) combo_index = (last_finished_index + 1) mod 3; else combo_index = 0;

    combo_active = true;
    combo_time   = 0;
    spawned_this_swing = false;
    queued_next        = false;

    owner.state = "attack";
    owner.attack_lock = true;
    owner.pc_combo_active = true;
    owner.attack_just_started = true;

    var spr = -1;
    if (combo_index == 0)      spr = spr_attack_a;
    else if (combo_index == 1) spr = spr_attack_b;
    else                       spr = spr_attack_c;

    current_spr = spr;
    if (spr != -1) {
        owner.sprite_index = spr;

        // Type-safe frame count from owner's current sprite
        var frames0 = max(1, sprite_get_number(owner.sprite_index));
        var step0   = frames0 / (max(0.001, combo_dur_s) * room_speed);
        var bias0   = clamp(frames0 * warm_ratio, 0, max(0, frames0 - 1));
        owner.image_speed = 0; // ENGINE OFF
        owner.image_index = min(frames0 - 0.001, bias0 + step0);
    }
}
