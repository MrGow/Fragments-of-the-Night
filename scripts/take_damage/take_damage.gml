/// take_damage(amount, from_x)
// Defensive defaults in case caller isn't fully initialised / not parented yet
if (!variable_instance_exists(id,"is_dead"))           is_dead = false;
if (!variable_instance_exists(id,"hp"))                hp = 1;
if (!variable_instance_exists(id,"death_sprite"))      death_sprite = -1;
if (!variable_instance_exists(id,"death_image_speed")) death_image_speed = 0.25;
if (!variable_instance_exists(id,"explosion_object"))  explosion_object = noone;
if (!variable_instance_exists(id,"knockback_px"))      knockback_px = 0;

if (is_dead) exit;

var amount = max(1, argument0);
hp -= amount;

if (hp <= 0) {
    is_dead = true;

    if (death_sprite != -1) {
        sprite_index = death_sprite;
        image_index  = 0;
        image_speed  = death_image_speed;
    } else {
        if (explosion_object != noone) instance_create_layer(x, y, layer, oSunPilgrimExplosion);
        instance_destroy();
    }
} else {
    var from_x = argument1;
    if (!is_undefined(from_x) && knockback_px != 0) {
        var dir = sign(x - from_x);
        if (variable_instance_exists(id,"hsp")) hsp += dir * knockback_px;
    }
}

