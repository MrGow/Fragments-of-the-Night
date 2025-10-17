/// oParEnemy — Step (early-out when dead)
if (is_dead) {
    if (death_sprite != -1) {
        if (sprite_index != death_sprite) { sprite_index = death_sprite; image_index = 0; }
        image_speed = death_image_speed;
    } else {
        if (explosion_object != noone && object_exists(explosion_object)) {
            instance_create_layer(x, y, layer, explosion_object);
        }
        instance_destroy();
    }
    exit;
}
