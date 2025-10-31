/// oCamDoor — Create  (NO LOCKING)

// Per-instance settings (or set in Variables panel)
if (!variable_instance_exists(id,"mode"))           mode = "mirror";
if (!variable_instance_exists(id,"hub_room"))       hub_room = SaveRoom;
if (!variable_instance_exists(id,"use_fade"))       use_fade = true;
if (!variable_instance_exists(id,"prompt_text"))    prompt_text = "Press \u2191 to enter";

// Runtime
activate_in   = 10;
cooldown_max  = 12;
cooldown      = 0;

armed         = false;
hovering      = false;

interact_need = 3;
interact_cnt  = 0;

// NEW: pose/transition handshake
waiting_for_pose = false;
pending_target   = noone;

// Input helper (pressed OR held; keyboard + pad)
up_pressed = function() {
    if (keyboard_check_pressed(vk_up) || keyboard_check(vk_up)) return true;
    for (var dev = 0; dev < 8; dev++) {
        if (!gamepad_is_connected(dev)) continue;
        if (gamepad_button_check_pressed(dev, gp_padu) || gamepad_button_check(dev, gp_padu)) return true;
    }
    return false;
};

// --- Helper: set SaveRoom return meta ---
set_return_info = function(_spawn_back_tag, _spawn_next_tag) {
    global.return_room     = room;               // where to go back to
    global.return_spawn_id = _spawn_back_tag;    // spawn to use when we come back FROM SaveRoom
    global.spawn_tag_next  = _spawn_next_tag;    // spawn to use on entry INTO SaveRoom
};

// ============= PUBLIC CALLBACK (called by oPlayer when pose hits last frame) =============
start_transition_now = function() {
    if (!waiting_for_pose) exit;
    // Kick the mirror transition right NOW (same step as last pose frame)
    if (!(variable_global_exists("_transition_busy") && global._transition_busy)) {
        script_transition_goto(pending_target, global.spawn_tag_next);
    }
    // Safety disarm
    armed = false;
    cooldown = cooldown_max;
    interact_cnt = 0;
    waiting_for_pose = false;
    pending_target   = noone;
};

// Do the transition (called from Step when conditions are met)
do_mirror_transition = function(pl) {
    // Remember where to return to, and the spawn we want when we come back
    set_return_info("mirror_exit_back", "mirror_entry");

    // Stop player velocity (nice to have)
    if (pl != noone) { with (pl) {
        if (variable_instance_exists(id,"hsp")) hsp = 0;
        if (variable_instance_exists(id,"vsp")) vsp = 0;
    }}

    // DO NOT start the transition yet — wait for pose final frame
    pending_target   = hub_room;
    waiting_for_pose = true;

    // ===== PLAYER: lock forward "look into mirror" pose (50% faster) =====
    if (pl != noone) with (pl) {
        if (!variable_instance_exists(id,"forced_anim_active"))  forced_anim_active  = false;
        if (!variable_instance_exists(id,"forced_anim_sprite"))  forced_anim_sprite  = -1;
        if (!variable_instance_exists(id,"forced_anim_speed"))   forced_anim_speed   = 0.45; // faster
        if (!variable_instance_exists(id,"forced_anim_reverse")) forced_anim_reverse = false;
        if (!variable_instance_exists(id,"forced_anim_started")) forced_anim_started = false;
        if (!variable_instance_exists(id,"forced_anim_notify"))  forced_anim_notify  = noone;
        if (!variable_instance_exists(id,"forced_anim_notified"))forced_anim_notified= false;

        forced_anim_sprite   = __spr("spritePlayerLookInwards");
        if (forced_anim_sprite == -1) forced_anim_sprite = spritePlayerLookInwards;
        forced_anim_speed    = 0.45;     // 50% faster than 0.30
        forced_anim_reverse  = false;    // forward going IN
        forced_anim_active   = true;
        forced_anim_started  = false;

        // Tell the player who to ping when it reaches the last frame
        forced_anim_notify   = other.id;
        forced_anim_notified = false;
    }

    // Disarm & start cooldown so it won’t retrigger while overlapping
    armed = false;
    cooldown = cooldown_max;
    interact_cnt = 0;
};
