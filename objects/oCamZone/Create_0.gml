/// oCamZone - Create
// Optional: give each zone a name in Instance Vars (zone_name)
if (!variable_instance_exists(id, "zone_name")) zone_name = "";

// Rectangle the camera will use (computed every Step)
left   = 0;
top    = 0;
right  = 0;
bottom = 0;

// If you assign a sprite (e.g., sCamZone_debug 640x360) and scale the instance,
// the Step event below will compute the true room-space rect from the transform.
