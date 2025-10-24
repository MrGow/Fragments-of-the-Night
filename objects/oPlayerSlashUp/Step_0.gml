/// oPlayerSlashUp — Step
life_frames--;
if (life_frames <= 0) instance_destroy();

// Track owner in case they move
if (instance_exists(owner)) {
    x = owner.x;
    y = owner.y - 12;
}
