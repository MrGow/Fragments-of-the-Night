/// oPlayerSlash — Create (sprite-free rect hitbox)
owner          = noone;    // set by spawner
direction_sign = 1;        // +1 right, -1 left
damage         = 1;        // MUST be real
life_frames    = 6;
forward_px     = 18;

// Rectangle size (tune if needed)
hit_w = 64;
hit_h = 24;

// Resolve enemy parent asset (supports either naming)
enemy_parent = noone;
if (object_exists(oParEnemy)) enemy_parent = oParEnemy;
else if (object_exists(parEnemy)) enemy_parent = parEnemy;

// Debug toggles
debug_draw    = false; // set true to see the red box
debug_logging = true;  // prints hit count
