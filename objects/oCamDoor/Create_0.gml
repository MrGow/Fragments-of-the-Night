/// oCamDoor - Create (bidirectional + hysteresis)
use_fade       = false;  // set true if using oFade
activate_in    = 10;     // delay before door goes live (avoid spawn hits)
cooldown_max   = 16;     // frames after use to ignore re-triggers
cooldown       = 0;

// Arm/disarm so we only fire once per overlap
armed                = false; // becomes true once the player is NOT overlapping
rearm_when_cleared   = true;  // rearm automatically when player leaves

// Optional editor var for named target fallback
if (!variable_instance_exists(id, "target_zone_name")) target_zone_name = "";

// internal hit slots that WITH(oCamZone) can write to
z_hit0 = noone;
z_hit1 = noone;

