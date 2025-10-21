/// oSunPilgrimSlash — Step
life_frames--;
if (life_frames <= 0) instance_destroy();

// Follow the owner so the box stays lined up if they move
if (instance_exists(owner)) {
    x = owner.x + direction_sign * 10;
    y = owner.y;
}

// ===== Manual rectangle hit test so we don't need a sprite mask =====
// Define a small box in front of the pilgrim; tweak to taste
var half_w = 10;
var half_h = 8;
var x1 = x - half_w;
var y1 = y - half_h;
var x2 = x + half_w;
var y2 = y + half_h;

var victim = collision_rectangle(x1, y1, x2, y2, oPlayer, false, true);

if (victim != noone) {
    // Route through the unified damage function (handles i-frames/HUD/etc.)
    script_health_take_damage(damage, owner);

    // Light knockback away from the attacker
    var dir = instance_exists(owner) ? sign(victim.x - owner.x) : direction_sign;
    if (dir == 0) dir = choose(-1, 1);
    if (variable_instance_exists(victim, "hsp")) victim.hsp += dir * max(1, knockback_px / 3);

    // One-and-done so the slash can’t multi-hit
    instance_destroy();
}
