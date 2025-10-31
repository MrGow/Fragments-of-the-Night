/// oGame — Draw End (integer fullscreen scaler with letterbox + publish scale)

var surf = application_surface;
if (!surface_exists(surf)) exit;

var sw = surface_get_width(surf);
var sh = surface_get_height(surf);

var dw = display_get_width();
var dh = display_get_height();

// Largest *integer* scale that fits the monitor/window
var scale = floor(min(dw / sw, dh / sh));
if (scale < 1) scale = 1;

var ww = sw * scale;
var hh = sh * scale;

// Center it (letterboxed)
var dst_x = (dw - ww) div 2;
var dst_y = (dh - hh) div 2;

// Clear backbuffer (letterbox color)
draw_clear_alpha(c_black, 1);

// Draw the app surface crisp and centered
draw_surface_ext(surf, dst_x, dst_y, scale, scale, 0, c_white, 1);

// ---- Publish for anyone who cares (HUD will read fullscreen/window) ----
global._appsurf_scale = scale;
global._appsurf_x     = dst_x;
global._appsurf_y     = dst_y;
