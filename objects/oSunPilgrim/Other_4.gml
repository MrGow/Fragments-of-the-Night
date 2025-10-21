/// oSunPilgrim — Room Start (robust reset; parent handles death/i-frames)

is_dead               = false;          // child doesn't force death here; parent governs it
attack_cd             = 0;
attack_spawned_hitbox = false;
attack_face_locked    = false;

// Keep death visuals consistent with Create (don’t overwrite to 1.0)
death_sprite      = spriteSunPilgrimDeath;
death_image_speed = 1;

/* @type {asset.object} */
explosion_object  = oSunPilgrimExplosion;  // OBJECT ASSET, not an instance

// (Optional) If you want full heal on room load, uncomment:
hp = 4;
