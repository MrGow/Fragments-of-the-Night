/// oSunPilgrim — Animation End

// Attack finishes -> cooldown, brief retreat, then chase
if (sprite_index == spriteSunPilgrimAttack) {
    attack_cd = attack_cd_s;
    attack_face_locked = false;

    // NEW: back off a little after each swing
    retreat_frames = after_attack_retreat_frames;

    state = SP_STATE.CHASE;
    exit;
}

// Let the parent handle death cleanup
event_inherited();

