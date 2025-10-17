// ========================= oPlayer :: Create =========================

// Ensure the global exists so later reads are safe.
if (!variable_global_exists("tm_solids")) global.tm_solids = undefined;

// --- State ---
state = "idle";

// --- Movement (single system: hsp/vsp only) ---
hsp = 0;
vsp = 0;
move_speed = 2.6;         // horizontal speed (tune to taste)
jump_speed = -8;          // initial jump velocity (up = negative)

// --- Gravity & fall behaviour (variable jump uses these) ---
gravity_amt         = 0.5; // base gravity applied each step
max_fall            = 12;  // terminal velocity
fall_multiplier     = 1.8; // stronger pull when falling
low_jump_multiplier = 3.2; // extra pull if jump released early (short hop)

// --- Coyote & buffer (in frames; scales with room_speed) ---
coyote_time_frames      = round(0.12 * room_speed); // ~120 ms
jump_buffer_time_frames = round(0.12 * room_speed); // ~120 ms
coyote_timer      = 0;
jump_buffer_timer = 0;

// --- Attack system ---
attack_lock     = false;
can_attack      = true;    // set false if you want cooldown to gate re-attacks
attack_cooldown = 0;       // frames

// --- Sprites / visuals ---
sprite_index = spritePlayerIdle;
mask_index   = spritePlayerCollisionMask;
image_speed  = 0.4;
image_xscale = 1;

// Non-looping attack sprite/sequence
spr_attack = spriteSwordAttack;


