
/// oLedge — Draw (anchor-aware, matches oPlayer logic)

// Read per-instance settings (with safe defaults)
var _use_corners = variable_instance_exists(id, "use_cell_corners") ? use_cell_corners : false;
var _cell        = variable_instance_exists(id, "cell_size")        ? cell_size        : 32;
var _corner      = variable_instance_exists(id, "anchor_corner")    ? anchor_corner    : 0; // 0 TL,1 TR,2 BL,3 BR
var _ox          = variable_instance_exists(id, "marker_x_offset")  ? marker_x_offset  : 0;
var _oy          = variable_instance_exists(id, "marker_y_offset")  ? marker_y_offset  : 0;

// Fallback scheme vars (if not using corners)
var _grid_h      = variable_instance_exists(id, "grid_h")           ? grid_h           : 32;
var _half        = variable_instance_exists(id, "anchor_bottom_half") ? anchor_bottom_half : false;

// Compute the same anchor the player uses
var ax, ay;
if (_use_corners) {
    var cx = floor(x / _cell) * _cell;
    var cy = floor(y / _cell) * _cell;
    switch (_corner) {
        case 0: ax = cx;         ay = cy;          break; // TL
        case 1: ax = cx + _cell; ay = cy;          break; // TR
        case 2: ax = cx;         ay = cy + _cell;  break; // BL
        default:ax = cx + _cell; ay = cy + _cell;  break; // BR
    }
    ax += _ox; ay += _oy;
} else {
    ax = x + _ox;
    ay = y + (_half ? _grid_h*0.5 : 0) + _oy;
}

// Facing preview (0 = either -> draw as +1)
var fx = (facing == 0) ? 1 : facing;

// Optional: preview hang/stand points (same math as player)
var hang_x = ax + ((facing == 0) ? hang_dx : hang_dx * fx);
var hang_y = ay + hang_dy;
var stand_x = ax + ((facing == 0) ? pull_dx : pull_dx * fx);
var stand_y = ay + pull_dy;

// ---- Draw gizmo ----
draw_set_alpha(1);

// Anchor (yellow)
draw_set_color(c_yellow);
draw_circle(ax, ay, 2, false);
draw_line(ax, ay, ax + fx*12, ay);

// Hang (cyan) & Stand (lime) — comment out if too noisy
draw_set_color(c_aqua);
draw_circle(hang_x, hang_y, 2, false);
draw_set_color(c_lime);
draw_circle(stand_x, stand_y, 2, false);

// Small anchor box (faint)
draw_set_alpha(0.4);
draw_set_color(c_yellow);
draw_rectangle(ax-2, ay-2, ax+2, ay+2, false);
draw_set_alpha(1);
