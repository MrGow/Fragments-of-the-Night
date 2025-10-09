/// oCamZone - Step
var spr = sprite_index;
var sw  = (spr != -1) ? sprite_get_width(spr)  : view_w;
var sh  = (spr != -1) ? sprite_get_height(spr) : view_h;

left   = round(x);
top    = round(y);
right  = round(x + sw * image_xscale);
bottom = round(y + sh * image_yscale);
