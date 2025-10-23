/// oPostFX: Draw GUI — present processed frame on top of auto-draw
var surf_to_present = surface_exists(_lastGood) ? _lastGood : application_surface;
if (!surface_exists(surf_to_present)) exit;

var gw = display_get_gui_width();
var gh = display_get_gui_height();

// Present processed frame (covers the auto-drawn one; looks identical but with FX)
draw_surface_stretched(surf_to_present, 0, 0, gw, gh);
