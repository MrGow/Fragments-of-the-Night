/// oCamera Step  — grid commit + cooldown using bbox center

// --- Resolve target instance ---
if (!instance_exists(target)) {
    if (instance_number(oPlayer) > 0) {
        target = instance_find(oPlayer, 0);
    } else {
        exit;
    }
}

// --- LOCK MODE ---
if (lock_enabled) {
    var tx = clamp(target.x - view_w * 0.5, lock_left,  max(lock_left,  lock_right  - view_w));
    var ty = clamp(target.y - view_h * 0.5, lock_top,   max(lock_top,   lock_bottom - view_h));
    tview_x = floor(tx);
    tview_y = floor(ty);
    exit;
}

// --- GRID MODE: init on first run ---
var max_cell_x = max(0, room_width  div cell_w - 1);
var max_cell_y = max(0, room_height div cell_h - 1);

if (cur_cell_x == -9999) {
    cur_cell_x = clamp(floor(target.x / cell_w), 0, max_cell_x);
    cur_cell_y = clamp(floor(target.y / cell_h), 0, max_cell_y);
    tview_x = cur_cell_x * cell_w;
    tview_y = cur_cell_y * cell_h;
    exit;
}

// --- Use bbox center so the switch happens when ~half the body crosses ---
var px = (target.bbox_left + target.bbox_right) * 0.5;
var py = (target.bbox_top  + target.bbox_bottom) * 0.5;

// cooldown
if (snap_cd > 0) snap_cd--;

// gate lines
var left_gate   =  cur_cell_x      * cell_w - enter_gate_x;
var right_gate  = (cur_cell_x + 1) * cell_w + enter_gate_x;
var top_gate    =  cur_cell_y      * cell_h - enter_gate_y;
var bottom_gate = (cur_cell_y + 1) * cell_h + enter_gate_y;

var moved = false;

// Prefer horizontal commit first
if (snap_cd <= 0) {
    if      (px > right_gate) { cur_cell_x = min(cur_cell_x + 1, max_cell_x); moved = true; }
    else if (px < left_gate)  { cur_cell_x = max(cur_cell_x - 1, 0);          moved = true; }

    if (!moved) {
        if      (py > bottom_gate) { cur_cell_y = min(cur_cell_y + 1, max_cell_y); moved = true; }
        else if (py < top_gate)    { cur_cell_y = max(cur_cell_y - 1, 0);          moved = true; }
    }

    if (moved) snap_cd = snap_cd_max;
}

// Commit target view
tview_x = cur_cell_x * cell_w;
tview_y = cur_cell_y * cell_h;

// Safety clamp
tview_x = clamp(tview_x, 0, room_width  - view_w);
tview_y = clamp(tview_y, 0, room_height - view_h);

