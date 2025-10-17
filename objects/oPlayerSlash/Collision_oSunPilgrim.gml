/// oPlayerSlash — Collision with parEnemy
if (other != owner) {
    if (is_undefined(other.take_damage)) {
        if (script_exists(scr_enemy_take_damage)) scr_enemy_take_damage(other, damage, x);
    } else {
        with (other) take_damage(other.damage, other.x);
    }
    instance_destroy();
}
