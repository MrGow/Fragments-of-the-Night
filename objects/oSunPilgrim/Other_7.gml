/// oSunPilgrim — Animation End

// Attack finishes -> start cooldown & return to chase
if (sprite_index == spriteSunPilgrimAttack) {
    attack_cd = attack_cd_s;
    attack_face_locked = false;   // unlock facing after swing
    state = SP_STATE.CHASE;
    exit;
}

// Death cleanup (safe even if a parent also handles it)
if (is_dead && sprite_index == death_sprite) {
    if (explosion_object != noone && object_exists(explosion_object)) {
        instance_create_layer(x, y, layer, explosion_object);
    }
    instance_destroy();
}

