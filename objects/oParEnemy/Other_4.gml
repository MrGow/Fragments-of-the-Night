/// oParEnemy — Room Start  (robust post-teleport reset)
invul_frames    = 0;
image_alpha     = 1.0;
invincible      = false;
hurtbox_active  = true;

if (is_dead && hp > 0) is_dead = false;

if (!variable_instance_exists(id,"corpse_persist")) corpse_persist = false;

// Reset touch-damage timer so you can’t be hit on same frame after teleport
_touch_cd = 0;
