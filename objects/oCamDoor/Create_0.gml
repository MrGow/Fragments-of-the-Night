/// oCamDoor - Create (bidirectional door)
use_fade      = false;   // set true if you have oFade and want fades
activate_in   = 10;      // frames before door starts working (avoids spawn triggers)
cooldown_max  = 10;      // frames after use to prevent bounce-back
cooldown      = 0;

// Optional editor-facing var (define via Object Variables UI is fine too)
if (!variable_instance_exists(id, "target_zone_name")) target_zone_name = "";

// Internal holders that WITH(oCamZone) will write into (must be instance vars)
z_hit0 = noone;
z_hit1 = noone;
