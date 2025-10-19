/// oParEnemy — Animation End
if (is_dead && sprite_index == death_sprite) {

    // optional explosion
    if (explosion_object != -1 && object_exists(explosion_object)) {
        instance_create_layer(x, y, layer, explosion_object);
    }

    // only destroy if not set to persist (defensive: assume false if missing)
    var _persist = variable_instance_exists(id,"corpse_persist") ? corpse_persist : false;
    if (!_persist) instance_destroy();
}
