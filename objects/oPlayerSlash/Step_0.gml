/// oPlayerSlash — Step
life_frames--;
if (life_frames <= 0) instance_destroy();

if (instance_exists(owner)) {
    x = owner.x + direction_sign * 8;
    y = owner.y;
}
