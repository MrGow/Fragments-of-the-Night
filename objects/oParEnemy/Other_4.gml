/// oParEnemy — Room Start (robust post-teleport reset)

// Ensure core fields exist (in case a portal skipped Create on a child)
if (!variable_instance_exists(id,"hp"))                hp = 3;
if (!variable_instance_exists(id,"is_dead"))           is_dead = false;
if (!variable_instance_exists(id,"death_sprite"))      death_sprite = -1;
if (!variable_instance_exists(id,"death_image_speed")) death_image_speed = 0.25;
/* @type {asset.object} */
if (!variable_instance_exists(id,"explosion_object"))  explosion_object = -1; // object asset or -1
if (!variable_instance_exists(id,"invul_frames"))      invul_frames = 0;

// Clear any lingering “can’t be hit” gates after teleports
invul_frames = 0;
image_alpha  = 1;
if (variable_instance_exists(id,"invincible"))     invincible = false;
if (variable_instance_exists(id,"hurtbox_active")) hurtbox_active = true;

// Recover from bad state (flagged dead but has HP)
if (is_dead && hp > 0) is_dead = false;

// Do NOT reset hp here unless you want full heals on re-entry.
// // hp = 3;
