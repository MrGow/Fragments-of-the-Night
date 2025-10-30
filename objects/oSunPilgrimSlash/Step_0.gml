/// oSunPilgrimSlash — Step

// lifetime
life_frames--;
if (life_frames <= 0) { instance_destroy(); exit; }

// follow owner; if owner gone, expire
if (instance_exists(owner)) {
    x = owner.x + direction_sign * 10;
    y = owner.y;
} else {
    instance_destroy();
    exit;
}

// ===== manual rectangle hit test (simple, fast) =====
var half_w = 10;
var half_h = 8;
var x1 = x - half_w, y1 = y - half_h;
var x2 = x + half_w, y2 = y + half_h;

// find the player once
var victim = collision_rectangle(x1, y1, x2, y2, oPlayer, false, true);

if (victim != noone) {
    // Route through unified damage; only proceed if it actually applied
    if (script_health_take_damage(damage, owner)) {

        // Knockback away from attacker (gentle, iframe-safe)
        var dir = instance_exists(owner) ? sign(victim.x - owner.x) : direction_sign;
        if (dir == 0) dir = choose(-1, 1);

        if (variable_instance_exists(victim, "hsp")) victim.hsp += dir * max(1, knockback_px / 3);
        if (variable_instance_exists(victim, "vsp")) victim.vsp  = min(victim.vsp, -2.0);

        // One-and-done on successful hit so it can’t multi-hit this swing
        instance_destroy();
    }
}
