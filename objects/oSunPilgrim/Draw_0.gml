/// oSunPilgrim — Draw (visual oblique centering for oblique tiles)

var inset = oblique_draw_inset;

if (oblique_only_when_grounded) {
    var tm  = global.tm_solids;
    var eps = 0.1;
    var on_ground =
        (!is_undefined(tm)) &&
        ( tilemap_get_at_pixel(tm, bbox_left  + eps, bbox_bottom + 1) != 0
       || tilemap_get_at_pixel(tm, bbox_right - eps, bbox_bottom + 1) != 0 );
    if (!on_ground) inset = 0;
}

draw_sprite_ext(
    sprite_index, image_index,
    x, y + inset,
    image_xscale, image_yscale, image_angle,
    image_blend, image_alpha
);
