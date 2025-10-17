/// oPlayerSlash — Create (rect-list based, no sprite needed)
owner          = noone;    // set by spawner
direction_sign = 1;        // +1 right, -1 left (set by spawner)
damage         = 1;        // MUST be a real number
life_frames    = 6;
forward_px     = 10;

// Rect size (tune to your swing)
hit_w = 64;
hit_h = 24;

// Resolve enemy parent asset
enemy_parent = noone;
if (object_exists(oParEnemy)) enemy_parent = oParEnemy;
else if (object_exists(parEnemy)) enemy_parent = parEnemy;

// Debug flags
debug_draw     = false;     // turn on to see the box
debug_logging  = true;      // prints hit count to Output

