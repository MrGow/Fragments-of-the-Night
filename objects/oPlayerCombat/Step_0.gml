/// oPlayerCombat — Step (robust input: own edge detector + oInput fallback)
var dt = delta_time / 1000000;

// --- Resolve/track owner ---
if (!instance_exists(owner)) {
    if (instance_exists(oPlayer)) owner = instance_nearest(x, y, oPlayer); else exit;
}
x = owner.x;
y = owner.y;

// --- Cooldown ---
if (attack_cd > 0) attack_cd -= dt;

// --- Gather input ---
// Prefer oInput's "down" + "pressed" fields, but also compute our own local edge.
var down_now = false;
var pressed_pulse = false;

if (object_exists(oInput) && instance_number(oInput) > 0 && !is_undefined(global.input)) {
    // oInput exports attack_down + attack_pressed already gated
    down_now      = !!global.input.attack_down;
    pressed_pulse = !!global.input.attack_pressed;
} else {
    // Fallback to direct keyboard/mouse
    down_now = keyboard_check(ord("Z")) || keyboard_check(ord("X")) || mouse_check_button(mb_left);
    pressed_pulse = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("X")) || mouse_check_button_pressed(mb_left);
}

// Local edge detection (works even if global pulse timing is off)
var pressed_local = (down_now && !attack_down_prev);
attack_down_prev  = down_now;

// Combine: either global pulse OR our local edge
var pressed_any = pressed_pulse || pressed_local;

if (pressed_any) {
    show_debug_message("[PC] attack pressed; cd=" + string(attack_cd));
}

// --- Spawn slash if ready ---
if (pressed_any && attack_cd <= 0) {
    // Facing
    var forward = sign(owner.image_xscale); if (forward == 0) forward = 1;

    // Optional owner attack anim
    var use_attack_sprite = spr_attack;
    if (use_attack_sprite == -1 && variable_instance_exists(owner, "spriteAttack")) {
        use_attack_sprite = owner.spriteAttack;
    }
    if (use_attack_sprite != -1) {
        owner.sprite_index = use_attack_sprite;
        owner.image_index  = 0;
        owner.image_speed  = 1.0;
    }

    // Spawn hitbox on our current layer
    var hb = instance_create_layer(owner.x + forward * slash_forward_px, owner.y, layer, oPlayerSlash);
    hb.owner          = owner;
    hb.direction_sign = forward;
    hb.damage         = slash_damage;

    show_debug_message("[SPAWN] slash at (" + string(hb.x) + "," + string(hb.y) + ") fwd=" + string(forward) + " dmg=" + string(hb.damage));
    attack_cd = attack_cd_s;
}
