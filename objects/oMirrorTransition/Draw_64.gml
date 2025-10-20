/// oMirrorTransition - Draw GUI
if (!visible) exit;

var _w = gui_w;
var _h = gui_h;

// Fill black first for fade (and also makes mirror look punchier over dark)
if (!use_mirror) {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    exit;
}

// MIRROR DRAW
// Scale the sprite to cover the GUI canvas while preserving aspect.
var sw = sprite_get_width(sprite_index);
var sh = sprite_get_height(sprite_index);

var sx = _w / sw;
var sy = _h / sh;
var s  = max(sx, sy);  // cover

var dw = sw * s;
var dh = sh * s;
var dx = (_w - dw) * 0.5;
var dy = (_h - dh) * 0.5;

// If your sheet encodes additive flashes etc. you can tweak alpha here
draw_sprite_ext(sprite_index, floor(image_index), dx, dy, s, s, 0, c_white, 1);
