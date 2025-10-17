/// oSunPilgrimSlash — Step
life_frames--;
if (life_frames <= 0) instance_destroy();

// Track with owner a bit in case of movement (optional)
if (instance_exists(owner)) {
    x = owner.x + direction_sign * 10;
    y = owner.y;
}
