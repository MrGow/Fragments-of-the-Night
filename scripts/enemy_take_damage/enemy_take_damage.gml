/// enemy_take_damage(target, amount, from_x)
if (!instance_exists(argument0)) exit;

var _t   = argument0;
var _amt = max(1, argument1);
var _fx  = argument2;

with (_t) {
    if (!variable_instance_exists(id,"hp")) hp = 1;
    if (!variable_instance_exists(id,"is_dead")) is_dead = false;
    if (is_dead) exit;

    hp -= _amt;
    // show_debug_message("[DMG] " + object_get_name(object_index) + " HP=" + string(hp));

    if (hp <= 0) {
        is_dead = true;
        if (death_sprite != -1) {
            sprite_index = death_sprite;
            image_index  = 0;
            image_speed  = (variable_instance_exists(id,"death_image_speed") ? death_image_speed : 0.25);
        } else {
            if (variable_instance_exists(id,"explosion_object") && explosion_object != noone && object_exists(explosion_object)) {
                instance_create_layer(x, y, layer, explosion_object);
            }
            instance_destroy();
        }
    }
}

