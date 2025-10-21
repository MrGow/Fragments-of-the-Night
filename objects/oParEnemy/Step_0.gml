/// oParEnemy — Step  (central death + i-frame tick + optional touch damage)

// ---------- Defensive defaults (covers children that skipped Create) ----------
if (!variable_instance_exists(id,"hp"))                hp = 3;
if (!variable_instance_exists(id,"is_dead"))           is_dead = false;
if (!variable_instance_exists(id,"death_sprite"))      death_sprite = -1;
if (!variable_instance_exists(id,"death_image_speed")) death_image_speed = 0.25;
if (!variable_instance_exists(id,"explosion_object"))  explosion_object = -1;

if (!variable_instance_exists(id,"invul_frames"))      invul_frames = 0;
if (!variable_instance_exists(id,"invincible"))        invincible = false;
if (!variable_instance_exists(id,"hurtbox_active"))    hurtbox_active = true;

// NEW: seed all touch-damage fields before any reads
if (!variable_instance_exists(id,"contact_damage"))    contact_damage = 0;   // 0 = no touch damage
if (!variable_instance_exists(id,"knockback_px"))      knockback_px   = 5;
if (!variable_instance_exists(id,"_touch_cd_max"))     _touch_cd_max  = 24;
if (!variable_instance_exists(id,"_touch_cd"))         _touch_cd      = 0;

// ---------- i-frames tick ----------
if (invul_frames > 0) {
    invul_frames--;
    image_alpha = (invul_frames % 2 == 0) ? 0.6 : 1.0;
} else {
    image_alpha = 1.0;
}

// ---------- Death gate ----------
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

// While dead, keep death anim and exit so child AI can’t overwrite it
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

// ================= OPTIONAL BODY TOUCH DAMAGE =================
if (_touch_cd > 0) _touch_cd--;

if (contact_damage > 0 && _touch_cd <= 0) {
    var pl = instance_exists(oPlayer) ? instance_nearest(x, y, oPlayer) : noone;
    if (pl != noone && place_meeting(x, y, oPlayer)) {
        // Unified damage call (respects i-frames)
        script_health_take_damage(contact_damage, id);

        // Optional tiny push
        if (variable_instance_exists(pl, "hsp")) {
            var dir = sign(pl.x - x); if (dir == 0) dir = choose(-1,1);
            pl.hsp += dir * 1.5;
        }
        _touch_cd = _touch_cd_max;
    }
}
// =============================================================

// (Child AI runs after event_inherited() in the child)


