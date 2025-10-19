function enemy_take_damage(enemy_id, amount, from_x) {
    /// enemy_take_damage(enemy_id, amount, from_x)
    if (!instance_exists(enemy_id)) return;

    var _amt    = real(amount);
    var _from_x = from_x;

    with (enemy_id) {
        // Defensive defaults
        if (!variable_instance_exists(id,"hp"))                hp = 3;
        if (!variable_instance_exists(id,"is_dead"))           is_dead = false;
        if (!variable_instance_exists(id,"death_sprite"))      death_sprite = -1;
        if (!variable_instance_exists(id,"death_image_speed")) death_image_speed = 0.25;
/* @type {asset.object} */
        if (!variable_instance_exists(id,"explosion_object"))  explosion_object = -1;
        if (!variable_instance_exists(id,"invul_frames"))      invul_frames = 0;
        if (!variable_instance_exists(id,"knockback_px"))      knockback_px = 5;

        // Gate: ignore while invulnerable or already dead
        if (invul_frames > 0 || is_dead) exit;

        // Apply damage
        hp -= _amt;

        // Small knockback (optional)
        var _dir = sign(x - _from_x); if (_dir == 0) _dir = choose(-1, 1);
        if (variable_instance_exists(id,"hsp")) hsp += _dir * knockback_px;

        // Grant brief i-frames and (optional) blink handled in parent Step
        invul_frames = 12;

        // Debug
        show_debug_message("[DMG] " + object_get_name(object_index) + " hp=" + string(hp));

        // Start death if needed; actual cleanup handled by parent Step/AnimEnd
        if (hp <= 0) {
            is_dead = true;
            if (death_sprite != -1) {
                sprite_index = death_sprite;
                image_index  = 0;
                image_speed  = death_image_speed;
            } else {
                if (explosion_object != -1 && object_exists(explosion_object)) {
                    instance_create_layer(x, y, layer, explosion_object);
                }
                instance_destroy();
            }
        }
    }
}
