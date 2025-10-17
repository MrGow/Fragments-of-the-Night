/// oSunPilgrim — Animation End
if (sprite_index == spriteSunPilgrimAttack) {
    attack_cd = attack_cooldown_s;
    attack_face_locked = false;   // unlock after swing
    state = SP_STATE.CHASE;
    sprite_index = spriteSunPilgrimRun;
}

if (sprite_index == spriteSunPilgrimDeath) {
    var ex = instance_create_layer(x, y, layer, oSunPilgrimExplosion);
    with (ex) damage = 1;
    instance_destroy();
}
