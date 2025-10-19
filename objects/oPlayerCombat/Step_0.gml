/// oPlayerCombat — Step (clean; trust oInput for gating)
var dt = delta_time / 1000000;

// --- Resolve owner and follow ---
if (!instance_exists(owner)) {
    if (instance_exists(oPlayer)) owner = instance_nearest(x, y, oPlayer); else exit;
}
x = owner.x;
y = owner.y;

// --- Cooldown ---
if (attack_cd > 0) attack_cd -= dt;

// --- Read input strictly from oInput (oInput already applies global gates) ---
var pressed = false;
if (object_exists(oInput) && instance_number(oInput) > 0) {
    pressed = global.input.attack_pressed; // one-frame pulse, already gated
} else {
    // Fallback only if no oInput exists
    pressed = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("X"));
}

// --- Spawn slash ---
if (pressed && attack_cd <= 0) {
    // Facing
    var forward = sign(owner.image_xscale);
    if (forward == 0) forward = 1;

    // Optional fixed attack sprite
    var use_attack_sprite = spr_attack;
    if (use_attack_sprite == -1 && variable_instance_exists(owner, "spriteAttack")) {
        use_attack_sprite = owner.spriteAttack;
    }
    if (use_attack_sprite != -1) {
        with (owner) {
            sprite_index = use_attack_sprite;
            image_index  = 0;
            image_speed  = 1.0;
        }
    }

    // Spawn hitbox on our current layer
    var hb = instance_create_layer(owner.x + forward * slash_forward_px, owner.y, layer, oPlayerSlash);
    hb.owner          = owner;
    hb.direction_sign = forward;
    hb.damage         = slash_damage;

    show_debug_message("[Combat] Slash spawned; dmg=" + string(hb.damage));
    attack_cd = attack_cd_s;
}
