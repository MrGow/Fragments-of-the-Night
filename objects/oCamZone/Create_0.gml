/// oCamZone - Create (snap settings + helpers)
if (!variable_instance_exists(id, "zone_name")) zone_name = "";

// Choose ONE snap mode
snap_to_tile  = true;   // snap to tile grid (e.g., 32x32)
snap_to_view  = false;  // snap to full screens (e.g., 640x360)

// Grid sizes
tile_w = 32; tile_h = 32;
view_w = 640; view_h = 360;

// Rect placeholders (set individually — no chained assignment)
left  = 0;
top   = 0;
right = 0;
bottom= 0;

// Helper: snap the instance transform to grid
snap_transform = function() {
    var spr = sprite_index;
    var sw  = (spr != -1) ? sprite_get_width(spr)  : view_w;
    var sh  = (spr != -1) ? sprite_get_height(spr) : view_h;

    var cur_l = x;
    var cur_t = y;
    var cur_w = sw * image_xscale;
    var cur_h = sh * image_yscale;

    var gx = snap_to_view ? view_w : tile_w;
    var gy = snap_to_view ? view_h : tile_h;

    var snap_l = floor(cur_l / gx) * gx;
    var snap_t = floor(cur_t / gy) * gy;
    var snap_w = max(gx, round(cur_w / gx) * gx);
    var snap_h = max(gy, round(cur_h / gy) * gy);

    // Assuming sprite origin = Top-Left (0,0)
    x = snap_l;
    y = snap_t;
    image_xscale = snap_w / sw;
    image_yscale = snap_h / sh;
};
