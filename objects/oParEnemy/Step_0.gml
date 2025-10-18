/// oParEnemy — Step (self-heal death + early-out)

// --- Defensive defaults (in case a child forgot to init after a portal) ---
if (!variable_instance_exists(id,"hp"))                hp = 3;
if (!variable_instance_exists(id,"is_dead"))           is_dead = false;
if (!variable_instance_exists(id,"death_sprite"))      death_sprite = -1;
if (!variable_instance_exists(id,"death_image_speed")) death_image_speed = 0.25;
if (!variable_instance_exists(id,"explosion_object"))  explosion_object = noone;

// --- SAFETY: if HP already zero or below, force the death transition ---
if (!is_dead && hp <= 0) {
    is_dead = true;
    if (death_sprite != -1) {
        sprite_index = death_sprite;
        image_index  = 0;
        image_speed  = death_image_speed;
    } else {
        // when forcing death immediately
        if (explosion_object != -1) {
        instance_create_layer(x, y, layer, explosion_object);
        }
instance_destroy();

        exit;
    }
}

// --- Normal early-out while dead (prevents AI from overwriting the anim) ---
if (is_dead) {
    if (death_sprite != -1) {
        if (sprite_index != death_sprite) { sprite_index = death_sprite; image_index = 0; }
        image_speed = death_image_speed;
    } else {
        if (explosion_object != -1) {
        instance_create_layer(x, y, layer, explosion_object);
        }
        instance_destroy();

    }
    exit;
}

// (Child AI runs below this point; keep parent Step empty beyond here if you like)

