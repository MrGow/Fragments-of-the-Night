/// oGame — Draw GUI (fallback)
if (global.paused) {
    var gw = display_get_gui_width();
    var gh = display_get_gui_height();
    if (gw <= 0 || gh <= 0) { gw = 800; gh = 450; }

    draw_set_alpha(0.45);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    draw_text(gw*0.5, gh*0.5, "PAUSED — oGame fallback");
}

