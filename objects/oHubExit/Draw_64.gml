/// oHubExit - Draw GUI
if (hovering && prompt_text != "") {
    var cam = view_camera[0];
    var gx = camera_get_view_x(cam), gy = camera_get_view_y(cam);
    var px = clamp(x - gx, 0, display_get_gui_width());
    var py = clamp(y - 24 - gy, 0, display_get_gui_height());

    draw_set_alpha(0.95);
    draw_set_color(c_white);
    draw_text(px + 8, py, prompt_text);
    draw_set_alpha(1);
}
