/// enemy_tick_invul(target)
if (!instance_exists(argument0)) exit;
with (argument0) {
    if (variable_instance_exists(id,"invul_frames") && invul_frames > 0) {
        invul_frames--;
        // Optional blink:
        image_alpha = (invul_frames % 2 == 0) ? 0.6 : 1;
        if (invul_frames <= 0) image_alpha = 1;
    }
}
