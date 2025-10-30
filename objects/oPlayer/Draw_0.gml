/// oPlayer — Draw (integer-snap render + oblique floor visual centering)

// --- Integer snap (render only; physics x/y remain untouched) ---
var ox = x, oy = y;
var ix = round(ox), iy = round(oy);
var mw = matrix_get(matrix_world);

// pure translation: (tx, ty, tz, rx, ry, rz, sx, sy, sz)
var snap = matrix_build(ix - ox, iy - oy, 0,  0, 0, 0,  1, 1, 1);
matrix_set(matrix_world, matrix_multiply(mw, snap));

// --- Oblique visual inset (draw the sprite slightly lower for isometric-ish floors) ---
var inset = (variable_instance_exists(id, "oblique_draw_inset"))
           ? oblique_draw_inset
           : (variable_global_exists("FLOOR_BASE_FROM_TOP") ? floor(global.FLOOR_BASE_FROM_TOP * 0.5) : 16);

// If you only want the inset when on the ground, you need a ground flag set in Step.
// Example pattern (set a boolean in Step): render_grounded = __on_ground_check();
// Then here you could do: if (!render_grounded) inset = 0;

// Draw exactly like draw_self, but shifted down by `inset`
draw_sprite_ext(
    sprite_index,
    image_index,
    x,                 // physics x (matrix made it integer on-screen)
    y + inset,         // visual drop for oblique tiles
    image_xscale,
    image_yscale,
    image_angle,
    image_blend,
    image_alpha
);

// --- Restore matrix ---
matrix_set(matrix_world, mw);

