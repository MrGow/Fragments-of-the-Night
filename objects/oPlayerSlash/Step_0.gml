/// oPlayerSlash — Step  (simple lifetime + rectangle overlap to enemies)
if (!instance_exists(owner)) { instance_destroy(); exit; }

// Follow owner
x = owner.x + direction_sign * forward_px;
y = owner.y;

// Build AABB
var w2 = hit_w * 0.5, h2 = hit_h * 0.5;
var x1 = x - w2, y1 = y - h2, x2 = x + w2, y2 = y + h2;

// Prepare overlap list
var lst = ds_list_create();
var any = collision_rectangle_list(x1, y1, x2, y2, all, false, false, lst, true);

// Damage function present?
var can_dmg = (asset_get_index("enemy_take_damage") != -1);

// Filter and apply
if (any && can_dmg) {
    var n = ds_list_size(lst);
    for (var i = 0; i < n; i++) {
        var inst = lst[| i];
        if (!instance_exists(inst)) continue;
        if (inst == id) continue;

        var is_enemy = false;
        with (inst) {
            is_enemy = object_is_ancestor(oParEnemy, object_index)
                       || (variable_instance_exists(id,"hp") && variable_instance_exists(id,"is_dead"))
                       || (object_get_name(object_index) == "oSunPilgrim");
        }
        if (!is_enemy) continue;

        enemy_take_damage(inst, damage, x);
    }
}

// Clean up list
ds_list_destroy(lst);

// Lifetime
life_frames--;
if (life_frames <= 0) instance_destroy();
