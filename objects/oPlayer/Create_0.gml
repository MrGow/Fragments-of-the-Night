// Player state
state = "idle";

// Movement
hsp = 0;
vsp = 0;
move_speed = 2.5;     // tweak to taste
jump_speed = -9;      // tweak to taste
gravity_amt = 0.5;
max_fall   = 12;

// Attack system
attack_lock = false;
can_attack = true;
attack_cooldown = 0;  // optional cooldown timer (frames)

// Starting sprite
sprite_index  = spritePlayerIdle;
image_speed   = 0.4;
image_xscale  = 1;

// (Optional) which sprite to use for the attack state:
spr_attack = spriteSwordAttack;  // make sure this animation does NOT loop

