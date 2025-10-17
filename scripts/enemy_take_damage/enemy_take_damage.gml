/// enemy_take_damage(target, amount, from_x)
/// Call like: enemy_take_damage(other, damage, x);
if (!instance_exists(argument0)) exit;

var _t   = argument0;
var _amt = max(1, argument1);
var _fx  = argument2;

with (_t) {
    // Defensive defaults so missing init can't crash
    if (!variable_instance_exists(id,"is_dead"))            is_dead = false;
    if (!variable_instance_exists(id,"hp"))                 hp = 1;
    if (!variable_instance_exists(id,"death_sprite"))       death_sprite = -1;
    if (!variable_instance_exists(id,"death_image_speed"))  death_image_speed = 0.25;
    if (!variable_instance_exists(id,"explosion_object"))   explosion_object = noone;
    if (!variable_instance_exists(id,"knockback_px"))       knockback_px = 0;

    if (is_dead) exit;

    hp -= _amt;

    if (hp <= 0) {
        is_dead = true;

        if (death_sprite != -1) {
            sprite_index = death_sprite;
            image_index  = 0;
            image_speed  = death_image_speed;
        } else {
            if (explosion_object != noone && object_exists(explosion_object)) {
                instance_create_layer(x, y, layer, explosion_object);
            }
            instance_destroy();
        }
    } else {
        if (!is_undefined(_fx) && knockback_px != 0) {
            var dir = sign(x - _fx);
            if (variable_instance_exists(id,"hsp")) hsp += dir * knockback_px;
        }
    }
}
