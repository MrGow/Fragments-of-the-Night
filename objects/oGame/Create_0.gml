// No texture filtering (no blur)
gpu_set_texfilter(false);

// Optional: turn off color interpolation if you haven’t globally
texture_set_interpolation(false);

// Set GUI space to base resolution so HUD is easy to place
display_set_gui_size(640, 360);

// Resize window to the largest integer multiple that fits the monitor
var dw = display_get_width();
var dh = display_get_height();
var scale = max(1, min(floor(dw/640), floor(dh/360)));
window_set_size(640*scale, 360*scale);
