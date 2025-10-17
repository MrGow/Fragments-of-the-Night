/// oPlayerCombat — Step (spawns oPlayerSlash on attack)
var dt = delta_time/1000000;

// Find/track owner if needed
if (!instance_exists(owner)) {
    if (instance_exists(oPlayer)) owner = instance_nearest(x, y, oPlayer); else exit;
}

// Follow owner (optional)
x = owner.x; y = owner.y;

// Cooldown
if (attack_cd > 0) attack_cd -= dt;

// Input
var pressed = keyboard_check_pressed(attack_key_primary)
           || (attack_key_alt != -1 && keyboard_check_pressed(attack_key_alt));

if (pressed && attack_cd <= 0) {
    // Play the attack animation on the player (if you have it)
    if (spr_attack != -1) {
        with (owner) {
            sprite_index = other.spr_attack;
            image_index  = 0;
            image_speed  = other.attack_anim_speed;
        }
    }

    // Determine facing
    var forward = sign(owner.image_xscale);
    if (forward == 0) forward = 1;

    // Spawn the slash hitbox (AABB version you added earlier)
    var hb = instance_create_layer(owner.x + forward * slash_forward_px, owner.y, layer, oPlayerSlash);
    hb.owner          = owner;            // ✅ critical
    hb.direction_sign = forward;          // ✅ critical
    hb.damage         = slash_damage;     // ✅ critical

    show_debug_message("[Combat] Spawned oPlayerSlash dmg=" + string(hb.damage));

    attack_cd = attack_cd_s;
}

