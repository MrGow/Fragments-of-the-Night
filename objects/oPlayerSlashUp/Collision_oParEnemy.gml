/// oPlayerSlashUp — Collision with oParEnemy
// Simple, readable damage. Replace with your enemy damage script if you have one.
if (other.hp > 0) {
    // soft i-frames on enemy
    if (!other.invincible && other.invul_frames <= 0) {
        other.hp -= max(1, damage);
        other.invul_frames = 12;
        other.image_alpha  = 0.6;
    }
}
instance_destroy(); // single-hit; remove if you want multi-hit
