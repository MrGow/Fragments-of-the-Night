/// oSunPilgrimSlash — Create
life_frames    = 6;     // active window
damage         = 1;     // tune per enemy
direction_sign = 1;     // +1 right, -1 left (set by spawner)
owner          = noone; // set by spawner
knockback_px   = 5;     // light push on hit
team           = "enemy";

// spawn a little in front of the owner
x += direction_sign * 10;

// invisible debugless hitbox (no sprite/mask)
image_alpha = 0;
