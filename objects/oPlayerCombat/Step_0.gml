/// oPlayerCombat — Step
// Find/track owner if needed
if (!instance_exists(owner)) {
    if (instance_exists(oPlayer)) owner = instance_nearest(x, y, oPlayer); else exit;
}

// Follow owner
x = owner.x; y = owner.y;

// Cooldown
if (attack_cd > 0) attack_cd -= delta_time/1000000;

// Input → trigger attack anim
var pressed_primary = keyboard_check_pressed(attack_key_primary);
var pressed_alt     = (attack_key_alt != -1) && keyboard_check_pressed(attack_key_alt);

if (attack_cd <= 0 && (pressed_primary || pressed_alt)) {
    // Start the player's attack animation (expects spr_attack to be valid)
    if (spr_attack != -1) {
        with (owner) {
            sprite_index = other.spr_attack;
            image_index  = 0;
            image_speed  = 0.25;
        }
    }
    spawned_this_swing = false;
    attack_cd = attack_cd_s;
}

// During the owner's attack animation, spawn hitbox once in active frames
if (spr_attack != -1 && owner.sprite_index == spr_attack) {
    var idx = owner.image_index;
    if (!spawned_this_swing && idx >= hit_start && idx <= hit_end) {
        spawned_this_swing = true;

        var forward = sign(owner.image_xscale);
        if (forward == 0) forward = 1;

        var hb = instance_create_layer(owner.x + forward * hit_off, owner.y, layer, oPlayerSlash);
        hb.direction_sign = forward;
        hb.damage         = atk_damage;
        hb.owner          = owner;
    }
}
