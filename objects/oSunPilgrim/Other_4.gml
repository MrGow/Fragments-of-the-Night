/// oSunPilgrim — Room Start (hard reset of transient state)
is_dead            = false;
attack_cd          = 0;
attack_spawned_hitbox = false;
attack_face_locked = false;

// (Re-apply death config just in case any room scripts touched assets)
death_sprite       = spriteSunPilgrimDeath;
death_image_speed  = 1;
explosion_object   = oSunPilgrimExplosion;

// (Optional) reset HP here too if you want the enemy to always be fresh on room entry
// hp = 4;  // uncomment if Pilgrim should respawn full health when you re-enter
