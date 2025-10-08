/// oCamDoor Create
// Set these per instance in the room editor:
// target_zone_name : string name to find an oCamZone (or directly set target_zone_id)
// use_fade         : whether to fade during snap (true/false)
// offset_x/y       : optional pixel offsets to nudge camera within target zone center

if (!variable_instance_exists(id, "target_zone_name")) target_zone_name = "";
if (!variable_instance_exists(id, "use_fade"))         use_fade = true;
if (!variable_instance_exists(id, "offset_x"))         offset_x = 0;
if (!variable_instance_exists(id, "offset_y"))         offset_y = 0;

target_zone_id = noone; // can be set directly if you want
