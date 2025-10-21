/// oPlayerSlash — Step (robust overlaps + tolerant filter + pre/post HP logs)

if (!instance_exists(owner)) { instance_destroy(); exit; }

// Keep in front of the player
x = owner.x + direction_sign * forward_px;
y = owner.y;

// Build AABB
var w2 = hit_w * 0.5, h2 = hit_h * 0.5;
var x1 = x - w2, y1 = y - h2, x2 = x + w2, y2 = y + h2;

// ------------------------------------------------------------
// 0) Sanity: ensure damage function exists (or we log & bail)
var has_damage = (asset_get_index("enemy_take_damage") != -1);
if (!has_damage) {
    show_debug_message("[SLASH][ERR] enemy_take_damage() NOT FOUND!");
    // bail (keep lifetime so error is visible)
}

// 1) Get ALL instances overlapping our rect (engine AABB)
var raw = ds_list_create();
var first = collision_rectangle_list(x1, y1, x2, y2, all, false, false, raw, true);

// DEBUG: list every overlapped instance and whether it's an oParEnemy child
if (debug_logging) {
    var nraw = ds_list_size(raw);
    for (var d = 0; d < nraw; d++) {
        var inst_dbg = raw[| d];
        if (!instance_exists(inst_dbg)) continue;
        with (inst_dbg) {
            show_debug_message(
                "[RAW] " + object_get_name(object_index) +
                " isChild=" + string(object_is_ancestor(oParEnemy, object_index)) +
                " has_hp=" + string(variable_instance_exists(id,"hp")) +
                " has_dead=" + string(variable_instance_exists(id,"is_dead"))
            );
        }
    }
}

// 2) Filter to enemies (ancestor OR has hp/is_dead OR name whitelist)
var hits = ds_list_create();
if (first != noone) {
    var n = ds_list_size(raw);
    for (var i = 0; i < n; i++) {
        var inst = raw[| i];
        if (!instance_exists(inst)) continue;
        if (inst == id) continue;

        var keep = false;
        var nm = "";
        with (inst) {
            nm = object_get_name(object_index);

            // Best: inherits parent
            if (object_is_ancestor(oParEnemy, object_index)) keep = true;

            // Next best: looks like an enemy by vars
            else if (variable_instance_exists(id,"hp") && variable_instance_exists(id,"is_dead")) keep = true;

            // Final fallback: explicit whitelist by name
            else if (nm == "oSunPilgrim") keep = true;
        }

        if (keep) ds_list_add(hits, inst);
    }
}

// Optional: FORCE-HIT any oSunPilgrim overlapped (toggle if needed)
var FORCE_HIT_PILGRIMS = false;
if (FORCE_HIT_PILGRIMS) {
    var nraw2 = ds_list_size(raw);
    for (var k = 0; k < nraw2; k++) {
        var inst2 = raw[| k];
        if (!instance_exists(inst2)) continue;
        with (inst2) {
            if (object_get_name(object_index) == "oSunPilgrim") {
                ds_list_add(other.hits, id);
            }
        }
    }
}

// Debug counts
if (debug_logging) {
    show_debug_message("[SLASH] rect=(" + string(x1) + "," + string(y1) + ")-(" + string(x2) + "," + string(y2) +
                       ") raw=" + string(ds_list_size(raw)) + " hits=" + string(ds_list_size(hits)));
}

// 3) Apply damage then consume the slash
if (ds_list_size(hits) > 0 && has_damage) {
    for (var j = 0; j < ds_list_size(hits); j++) {
        var enemy_id = hits[| j];
        if (!instance_exists(enemy_id)) continue;
		
        // Pre / Post HP logs for certainty
        with (enemy_id) {
            var prehp = variable_instance_exists(id,"hp") ? string(hp) : "NA";
            var name  = object_get_name(object_index);
            show_debug_message("[DMG->] " + name + " pre hp=" + prehp);
        }

        // Call the damage function directly
        enemy_take_damage(enemy_id, damage, x);

        with (enemy_id) {
            var posthp = variable_instance_exists(id,"hp") ? string(hp) : "NA";
            var dead   = variable_instance_exists(id,"is_dead") ? string(is_dead) : "NA";
            var name2  = object_get_name(object_index);
            show_debug_message("[DMG<-] " + name2 + " post hp=" + posthp + " is_dead=" + dead);
        }
    }
    ds_list_destroy(raw);
    ds_list_destroy(hits);
    instance_destroy();
    exit;
}

// 4) No hits this frame
ds_list_destroy(raw);
ds_list_destroy(hits);

// Lifetime
life_frames--;
if (life_frames <= 0) instance_destroy();
