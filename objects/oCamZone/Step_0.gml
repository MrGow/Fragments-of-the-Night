/// oCamZone - Step
// Compute rect from sprite transform (works whether or not you scaled the instance)
var spr = sprite_index;
var sw  = (spr != -1) ? sprite_get_width(spr)  : 640; // fallback to one-screen
var sh  = (spr != -1) ? sprite_get_height(spr) : 360;
var ox  = (spr != -1) ? sprite_get_xoffset(spr) : 0;
var oy  = (spr != -1) ? sprite_get_yoffset(spr) : 0;

var tlx = x - ox * image_xscale;
var tly = y - oy * image_yscale;

left   = round(tlx);
top    = round(tly);
right  = round(tlx + sw * image_xscale);
bottom = round(tly + sh * image_yscale);
