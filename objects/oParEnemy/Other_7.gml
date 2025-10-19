/// oParEnemy — Animation End
if (is_dead && sprite_index == death_sprite) {
    if (explosion_object != -1 && object_exists(explosion_object)) {
        instance_create_layer(x, y, layer, explosion_object);
    }
    instance_destroy();
}

