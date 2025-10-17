/// take_damage(amount, from_x)
function take_damage(amount, from_x) {
    if (state == SP_STATE.DEATH) exit;
    hp -= amount;

    if (hp <= 0) {
        state = SP_STATE.DEATH;
        sprite_index = spriteSunPilgrimDeath;
        image_index  = 0;
        image_speed  = 0.25;
        hsp = 0; vsp = 0;
    } else {
        state = SP_STATE.HURT;
    }
}
