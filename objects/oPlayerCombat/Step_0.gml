/// oPlayerCombat — Step (clean + oInput-aware)
var dt = delta_time/1000000;

// Resolve owner
if (!instance_exists(owner)) {
    if (instance_exists(oPlayer)) owner = instance_nearest(x, y, oPlayer); else exit;
}
x = owner.x; 
y = owner.y;

// Cooldown
if (attack_cd > 0) attack_cd -= dt;
    
// Gate by global lock (set by door/fade); still allows your keyboard fallback
var inputs_blocked = (!is_undefined(global.input)) &&
                     (!global.input.input_enabled || global.input.player_locked || global.input.ui_captured);

// --- READ INPUT (single source of truth) ---
var pressed = false;

// Prefer oInput (one-frame pulse set in Begin Step, cleared in End Step)
if (object_exists(oInput) && instance_number(oInput) > 0){
    pressed = global.input.attack_pressed;
} else {
    // Fallback if oInput isn't present yet
    pressed = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("X"));
}

// --- SPAWN SLASH ---
if (!inputs_blocked && pressed && attack_cd <= 0) {
 {
    // Optional: play attack sprite if available
    var use_attack_sprite = spr_attack;
    if (use_attack_sprite == -1 && variable_instance_exists(owner, "spriteAttack")) {
        use_attack_sprite = owner.spriteAttack;
    }
    if (use_attack_sprite != -1) {
        with (owner) {
            sprite_index = use_attack_sprite;
            image_index  = 0;
            image_speed  = other.attack_anim_speed;
        }
    }

    // Facing
    var forward = sign(owner.image_xscale); 
    if (forward == 0) forward = 1;

    // Spawn hitbox (AABB oPlayerSlash)
    var hb = instance_create_layer(owner.x + forward * slash_forward_px, owner.y, layer, oPlayerSlash);
    hb.owner          = owner;
    hb.direction_sign = forward;
    hb.damage         = slash_damage;

    show_debug_message("[Combat] Slash spawned; dmg=" + string(hb.damage));

    attack_cd = attack_cd_s;
}




}
