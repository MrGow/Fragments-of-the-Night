/// oParEnemy — Step (central death + i-frame tick)

// Defensive defaults (if a child skipped Create somehow)
if (!variable_instance_exists(id,"hp"))                hp = 3;
if (!variable_instance_exists(id,"is_dead"))           is_dead = false;
if (!variable_instance_exists(id,"death_sprite"))      death_sprite = -1;
if (!variable_instance_exists(id,"death_image_speed")) death_image_speed = 0.25;
/* @type {asset.object} */
if (!variable_instance_exists(id,"explosion_object"))  explosion_object = -1;
if (!variable_instance_exists(id,"invul_frames"))      invul_frames = 0;

// Tick invulnerability every step (prevents getting stuck across rooms)
if (invul_frames > 0) {
    invul_frames--;
    // Optional blink while invulnerable
    image_alpha = (invul_frames % 2 == 0) ? 0.6 : 1;
} else {
    image_alpha = 1;
}

// Force death if hp <= 0 and not yet marked dead
if (!is_dead && hp <= 0) {
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
        exit;
    }
}

// While dead, play death anim and exit so child AI can’t overwrite it
if (is_dead) {
    if (death_sprite != -1) {
        if (sprite_index != death_sprite) { sprite_index = death_sprite; image_index = 0; }
        image_speed = death_image_speed;
    } else {
        if (explosion_object != -1 && object_exists(explosion_object)) {
            instance_create_layer(x, y, layer, explosion_object);
        }
        instance_destroy();
    }
    exit;
}

// (Child AI runs after event_inherited() in the child)


