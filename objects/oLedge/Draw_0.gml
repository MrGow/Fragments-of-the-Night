/// oLedge — Draw
draw_set_color(c_yellow);
draw_circle(x, y, 2, false);
draw_line(x, y, x + max(0,facing)*8 - max(0,-facing)*8, y);
draw_set_alpha(0.4);
draw_rectangle(x-2, y-2, x+2, y+2, false);
draw_set_alpha(1);
