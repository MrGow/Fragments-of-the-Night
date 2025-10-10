// This runs after the world draws, regardless of GUI state.
// No surfaces/shaders fiddling: keep it simple & reliable.

var vw = camera_get_view_width(view_camera[0]);
var vh = camera_get_view_height(view_camera[0]);
var vx = camera_get_view_x(view_camera[0]);
var vy = camera_get_view_y(view_camera[0]);

// Full-screen dim over the view
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(vx, vy, vx + vw, vy + vh, false);
draw_set_alpha(1);

// Centered panel in view-space
var px = vx + vw * 0.5;
var py = vy + vh * 0.5;

draw_set_color(make_color_rgb(24,24,28));
draw_rectangle(px-260, py-160, px+260, py+160, false);

// Title
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(px, py-120, "PAUSED");

// Items
var line_h = 36;
for (var i = 0; i < array_length(menu_items); i++) {
    var item_y = py - 40 + i * line_h;
    if (i == sel) {
        draw_set_alpha(0.25);
        draw_set_color(c_white);
        draw_rectangle(px-220, item_y-14, px+220, item_y+14, false);
        draw_set_alpha(1);
    }
    draw_set_color(c_white);
    draw_text(px, item_y, menu_items[i]);
}
