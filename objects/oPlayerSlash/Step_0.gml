/// oPlayerSlash — Step (collision_rectangle_list)
if (!instance_exists(owner)) { instance_destroy(); exit; }

// Keep in front of the player
x = owner.x + direction_sign * forward_px;
y = owner.y;

// Build AABB
var w2 = hit_w * 0.5, h2 = hit_h * 0.5;
var x1 = x - w2, y1 = y - h2, x2 = x + w2, y2 = y + h2;

// What to hit:
var target_obj = enemy_parent;
if (target_obj == noone && object_exists(oSunPilgrim)) target_obj = oSunPilgrim; // fallback

// Collect overlaps
var list = ds_list_create();
var hits = 0;
if (target_obj != noone) {
    var first_id = collision_rectangle_list(x1, y1, x2, y2, target_obj, false, true, list, true);
    if (first_id != noone) hits = ds_list_size(list);
}

if (debug_logging) {
    show_debug_message("[Slash] rect hits=" + string(hits));
}

// Apply damage once to each hit enemy, then consume slash
if (hits > 0) {
    for (var i = 0; i < ds_list_size(list); i++) {
        var enemy_id = list[| i];
        if (instance_exists(enemy_id)) {
            enemy_take_damage(enemy_id, damage, x); // explicit, context-safe
        }
    }
    ds_list_destroy(list);
    instance_destroy();
    exit;
}

ds_list_destroy(list);

// Lifetime
life_frames--;
if (life_frames <= 0) instance_destroy();

