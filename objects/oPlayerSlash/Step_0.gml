/// oPlayerSlash — Step (direct call to enemy_take_damage)

if (!instance_exists(owner)) { instance_destroy(); exit; }

// Keep in front of the player
x = owner.x + direction_sign * forward_px;
y = owner.y;

// Build AABB
var w2 = hit_w * 0.5, h2 = hit_h * 0.5;
var x1 = x - w2, y1 = y - h2, x2 = x + w2, y2 = y + h2;

// Pick target object set (parent if available, else fallback)
var target_obj = enemy_parent;
if (target_obj == noone && object_exists(oSunPilgrim)) {
    target_obj = oSunPilgrim; // fallback
}

// Collect overlaps
var list = ds_list_create();
var hits = 0;
if (target_obj != noone) {
    var first_id = collision_rectangle_list(x1, y1, x2, y2, target_obj, false, true, list, true);
    if (first_id != noone) hits = ds_list_size(list);
}

// (Optional) Debug
if (debug_logging) {
    show_debug_message("[Slash] AABB=(" + string(x1) + "," + string(y1) + ")-(" + string(x2) + "," + string(y2) + "), hits=" + string(hits));
}

if (hits > 0) {
    for (var i = 0; i < ds_list_size(list); i++) {
        var enemy_id = list[| i];
        if (!instance_exists(enemy_id)) continue;

        // Common enemy gates (ignore if those vars don't exist)
        var can_hit = true;
        with (enemy_id) {
            if (variable_instance_exists(id,"invincible") && invincible) can_hit = false;
            if (variable_instance_exists(id,"hurtbox_active") && !hurtbox_active) can_hit = false;
        }
        if (!can_hit) continue;

        // --- Apply damage via your script (signature: enemy_take_damage(enemy_id, amount, from_x)) ---
        enemy_take_damage(enemy_id, damage, x);
    }

    ds_list_destroy(list);
    instance_destroy();
    exit;
}

// No hits this frame
ds_list_destroy(list);

// Lifetime
life_frames--;
if (life_frames <= 0) instance_destroy();
