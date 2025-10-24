/// oPlayerCombat — Step  (buffered 3-hit combo + upslash; drives player attack sprites)

// ---- Resolve/track owner ----
if (!instance_exists(owner)) {
    if (instance_exists(oPlayer)) owner = instance_nearest(x, y, oPlayer); else exit;
}
x = owner.x;
y = owner.y;

// ---- Safe inits (if Create was skipped) ----
if (!variable_instance_exists(id,"attack_cd_s"))        attack_cd_s        = 0.30;
if (!variable_instance_exists(id,"attack_cd"))          attack_cd          = 0;
if (!variable_instance_exists(id,"slash_forward_px"))   slash_forward_px   = 18;
if (!variable_instance_exists(id,"slash_damage"))       slash_damage       = 1;
if (!variable_instance_exists(id,"combo_index"))        combo_index        = 0;  // 0=A,1=B,2=C
if (!variable_instance_exists(id,"combo_timer_s"))      combo_timer_s      = 0.45;
if (!variable_instance_exists(id,"combo_timer"))        combo_timer        = 0;
if (!variable_instance_exists(id,"up_hold_timer"))      up_hold_timer      = 0;
// NEW: input buffer
if (!variable_instance_exists(id,"queued_attack"))      queued_attack      = false;
if (!variable_instance_exists(id,"queued_up"))          queued_up          = false;

// Sprite lookups (safe even if missing)
var sprA = asset_get_index("spriteSwordAttackA");
var sprB = asset_get_index("spriteSwordAttackB");
var sprC = asset_get_index("spriteSwordAttackC");
var sprU = asset_get_index("spriteSwordAttackUp");

// ---- Cooldowns / timers ----
var dt = 1 / room_speed;
if (attack_cd > 0) attack_cd = max(0, attack_cd - dt);

// IMPORTANT: do NOT tick the combo window down while the owner is mid-attack
if (!owner.pc_combo_active) {
    if (combo_timer > 0) combo_timer = max(0, combo_timer - dt);
}

// ---- Gather input (keyboard + gamepad + oInput) ----
var atk_pressed = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("X")) || mouse_check_button_pressed(mb_left);
var up_down     = keyboard_check(vk_up) || keyboard_check(ord("W"));
for (var i = 0; i < 8; i++) if (gamepad_is_connected(i)) up_down = up_down || gamepad_button_check(i, gp_padu);
if (object_exists(oInput) && instance_number(oInput) > 0 && !is_undefined(global.input)) {
    if (variable_struct_exists(global.input,"attack_pressed")) atk_pressed = atk_pressed || !!global.input.attack_pressed;
}
up_hold_timer = up_down ? up_hold_timer + dt : 0;

// ---- Buffer any press immediately (even during a swing) ----
if (atk_pressed) {
    queued_attack = true;
    queued_up     = up_down; // remember if Up was held when we queued
}

// ---- Fire when ready: only when not swinging and cooldown is done ----
var can_fire_now    = (attack_cd <= 0) && (!owner.pc_combo_active);
var in_combo_window = (combo_index == 0) || (combo_timer > 0); // first hit always allowed

if (queued_attack && can_fire_now && in_combo_window) {
    var use_spr = -1;
    var used_variant = "A";

    // Up-slash takes priority if requested and sprite exists
    if (queued_up && sprU != -1) {
        use_spr = sprU;
        used_variant = "U";
        // Up-slash does not advance ground-chain
        // (You can change this if you want U to be part of the chain.)
    } else {
        // Ground chain A -> B -> C (fallbacks if a sprite is missing)
        if (combo_index == 0) {
            if (sprA != -1) use_spr = sprA;
            else if (sprB != -1) use_spr = sprB;
            else use_spr = sprC;
            used_variant = "A";
        } else if (combo_index == 1) {
            if (sprB != -1) use_spr = sprB;
            else if (sprA != -1) use_spr = sprA;
            else use_spr = sprC;
            used_variant = "B";
        } else { // 2
            if (sprC != -1) use_spr = sprC;
            else if (sprB != -1) use_spr = sprB;
            else use_spr = sprA;
            used_variant = "C";
        }
        // Advance the chain and (re)open the combo window
        combo_index = (combo_index + 1) mod 3;
        combo_timer = combo_timer_s;
    }

    // Hand off to player (set anim and lock)
    _chosen_attack_sprite = use_spr; // instance var so 'with' can read it
    with (owner) {
        sprite_index        = other._chosen_attack_sprite;
        image_index         = 0;
        image_speed         = attack_anim_speed; // let it play
        pc_combo_active     = true;              // locomotion lock during swing
        attack_just_started = true;              // protect first frame
        state               = "attack";
    }

    // Spawn hitbox
    var fwd = sign(owner.image_xscale); if (fwd == 0) fwd = 1;
    var hb = instance_create_layer(owner.x + fwd * slash_forward_px, owner.y, layer, oPlayerSlash);
    hb.owner          = owner;
    hb.direction_sign = fwd;
    hb.damage         = slash_damage;

    if (used_variant == "U") {
        hb.forward_px = 8;
        hb.hit_w      = 36;
        hb.hit_h      = 64;
    }

    // Start cooldown and clear the buffer we just consumed
    attack_cd    = attack_cd_s;
    queued_attack = false;
    queued_up     = false;
}

// Safety: if the window expires while idle, reset to start of chain
if (!owner.pc_combo_active && combo_timer <= 0) {
    combo_index = 0;
}
