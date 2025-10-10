// If, for any reason, Draw End is ever obscured, this still shows a label.
if (global.paused) {
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    if (gw <= 0 || gh <= 0) { gw = 800; gh = 450; }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_yellow);
    draw_text(10, 10, "Pause overlay (Draw End) active");
}
