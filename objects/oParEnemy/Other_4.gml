/// oParEnemy — Room Start
// Ensure sane defaults when a room (re)loads
if (!variable_instance_exists(id,"is_dead")) is_dead = false;

// If you want enemies to always respawn fresh on re-entry, uncomment:
// if (!variable_instance_exists(id,"hp")) hp = 3; else hp = max(1, hp);

// Make sure death anim will play at a visible speed if triggered immediately
if (!variable_instance_exists(id,"death_image_speed")) death_image_speed = 0.25;
