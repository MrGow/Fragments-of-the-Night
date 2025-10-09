/// oFade - Create
alpha        = 0;
state        = 0;      // 0 idle, 1 out, 2 in, 3 in-transit
speed        = 0.10;
target_room  = room;   // <— Room-typed variable (starts as current room)
pending_switch = false;
transit_ttl  = 0;

persistent   = true;
visible      = false;
if (instance_number(oFade) > 1) { instance_destroy(); exit; }
