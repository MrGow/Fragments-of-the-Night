/// oSunPilgrim — Animation End

// Attack finishes -> start cooldown & return to chase
if (sprite_index == spriteSunPilgrimAttack) {
    attack_cd = attack_cd_s;
    attack_face_locked = false;
    state = SP_STATE.CHASE;
    exit;
}

// Let the parent handle death cleanup
event_inherited();

