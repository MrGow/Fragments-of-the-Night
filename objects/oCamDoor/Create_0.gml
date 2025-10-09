/// oCamDoor - Create

// Per-instance settings (set in Variables if you like)
if (!variable_instance_exists(id,"mode"))       mode = "mirror"; // this door is a mirror
if (!variable_instance_exists(id,"hub_room"))   hub_room = SaveRoom; // Room-typed
if (!variable_instance_exists(id,"use_fade"))   use_fade = true;
if (!variable_instance_exists(id,"freeze_player")) freeze_player = true;
if (!variable_instance_exists(id,"prompt_text"))   prompt_text = "Press \u2191 to enter";

// Runtime
activate_in  = 10;     // frames before the door can arm
cooldown_max = 12;     // small guard after use
cooldown     = 0;

armed        = false;  // becomes true once player fully leaves the door
hovering     = false;

interact_need = 3;     // frames you must hold Up while overlapping
interact_cnt  = 0;

// Input helper (pressed OR held; keyboard + pad)
up_pressed = function() {
    if (keyboard_check_pressed(vk_up) || keyboard_check(vk_up)) return true;
    for (var dev = 0; dev < 8; dev++) {
        if (!gamepad_is_connected(dev)) continue;
        if (gamepad_button_check_pressed(dev, gp_padu) || gamepad_button_check(dev, gp_padu)) return true;
    }
    return false;
};

// Do the transition (called from Step when conditions are met)
do_mirror_transition = function(pl) {
    // Where to return (room-typed) + where to land back in source room
    global.return_room     = room;
    global.return_spawn_id = "mirror_exit_back";  // put an oSpawn with this tag near the mirror (offset a few px)

    // Where to land in SaveRoom
    global.spawn_tag_next  = "mirror_entry";

    // Optional: lock input briefly
    if (freeze_player && pl != noone) {
        with (pl) {
            if (!variable_instance_exists(id,"input_locked")) input_locked = false;
            input_locked = true; alarm[0] = 12;
        }
    }

    // Ensure fade exists, then start fade → hub_room
    var f = instance_exists(oFade) ? instance_find(oFade, 0)
                                   : instance_create_layer(0, 0, "Instances", oFade);

    with (f) {
        target_room    = other.hub_room;  // ROOM asset
        pending_switch = true;
        if (state == 0) { state = 1; transit_ttl = 12; }
    }

    // Disarm & cooldown so it won’t retrigger while overlapping
    armed = false;
    cooldown = cooldown_max;
    interact_cnt = 0;
};
