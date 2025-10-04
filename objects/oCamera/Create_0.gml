// --- CONFIG ---
cell_w = 640;
cell_h = 360;
smooth_snap = 0.25;
target_obj = oPlayer;   // store the TYPE
target = noone;         // we'll resolve the INSTANCE in Step

enter_gate_x = 24;   // must move this many px into next cell to switch (horizontal)
enter_gate_y = 48;   // a bit larger for vertical to avoid bobbing
snap_cd_max  = 8;    // frames to ignore further snaps after a switch
snap_cd      = 0;


deadzone_margin = 24;

// --- CAMERA SETUP ---
view_index = 0;
cam = view_camera[view_index];

view_w = camera_get_view_width(cam);
view_h = camera_get_view_height(cam);
if (view_w != cell_w || view_h != cell_h) {
    camera_set_view_size(cam, cell_w, cell_h);
    view_w = cell_w; view_h = cell_h;
}

// Track current cell & desired view pos
cur_cell_x = -9999;
cur_cell_y = -9999;
tview_x = 0;
tview_y = 0;

// Boss/lock support
lock_enabled = false;
lock_left = 0;
lock_top  = 0;
lock_right = room_width;
lock_bottom = room_height;

// Optional: persistent safety (avoid duplicate cameras across rooms)
if (instance_number(oCamera) > 1) instance_destroy();

var p = instance_find(target_obj, 0);
if (p != noone) {
    var cell_x = floor(p.x / cell_w);
    var cell_y = floor(p.y / cell_h);
    tview_x = cell_x * cell_w;
    tview_y = cell_y * cell_h;
    camera_set_view_pos(cam, tview_x, tview_y);
    cur_cell_x = cell_x;
    cur_cell_y = cell_y;
}


