/// oParEnemy — Room Start  (robust post-teleport reset)

// Variables already declared in Create; just assign here (no GM2016)
invul_frames    = 0;
image_alpha     = 1.0;
invincible      = false;
hurtbox_active  = true;

// Recover from bad state (flagged dead but has HP)
if (is_dead && hp > 0) is_dead = false;

// Do NOT heal here unless desired
// hp = 3;
/// oParEnemy — Room Start (safety)
if (!variable_instance_exists(id,"corpse_persist")) corpse_persist = false;
