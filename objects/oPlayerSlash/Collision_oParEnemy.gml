/// oPlayerSlash — Collision with parEnemy
if (other != owner) {
    enemy_take_damage(other, other.damage, other.x); // target, amount, from_x
    instance_destroy();
}

