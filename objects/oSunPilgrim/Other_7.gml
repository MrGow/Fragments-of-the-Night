/// oParEnemy — Animation End (finish death)
if (variable_instance_exists(id,"is_dead") && is_dead && sprite_index == death_sprite) {
    if (explosion_object != noone && object_exists(explosion_object)) {
        instance_create_layer(x, y, layer, explosion_object);
    }
    instance_destroy();
}

