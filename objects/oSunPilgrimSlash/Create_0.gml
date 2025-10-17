/// oSunPilgrimSlash — Create
life_frames    = 6;
damage         = 1;
direction_sign = 1;   // set by spawner: +1 front, -1 back (already normalized)
owner          = noone;

x += direction_sign * 10;
image_alpha = 0; // invisible debugless hitbox
