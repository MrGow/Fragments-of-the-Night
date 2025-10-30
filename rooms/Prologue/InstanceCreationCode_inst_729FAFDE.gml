/// oLedge — Create
//
// Place this object roughly on/near a tile edge. You can tweak per instance in the Room Editor
// via Variables (anchor_corner, marker offsets, etc.).
//
// NOTE: Do NOT reset x/y here (e.g., x = xstart). That causes the "teleport back" issue.
//

// ---------------- Core behaviour ----------------
if (!variable_instance_exists(id, "facing"))    facing    = -1;   // 0=either, 1=grab facing right, -1=grab facing left
if (!variable_instance_exists(id, "autopull"))  autopull  = true;

// Where the HANDS hang relative to the anchor (in pixels)
// Positive hang_dy = lower hands (grab lower)
// hang_dx is mirrored automatically by facing when facing!=0
if (!variable_instance_exists(id, "hang_dx"))   hang_dx   = -5;
if (!variable_instance_exists(id, "hang_dy"))   hang_dy   =  6;

// Where the player will end up standing relative to the anchor
// Positive pull_dy = lower final stand point; negative = higher (up onto platform)
if (!variable_instance_exists(id, "pull_dx"))   pull_dx   =  6;
if (!variable_instance_exists(id, "pull_dy"))   pull_dy   = -12;

// ---------------- Cell-corner anchoring (recommended) ----------------
// If true, the anchor is snapped to a corner of the cell containing this instance.
// Corner index: 0=TopLeft, 1=TopRight, 2=BottomLeft, 3=BottomRight
if (!variable_instance_exists(id, "use_cell_corners")) use_cell_corners = true;
if (!variable_instance_exists(id, "cell_size"))        cell_size        = 32;
if (!variable_instance_exists(id, "anchor_corner"))    anchor_corner    = 1;   // default BR

// Fine nudges applied after corner snap (let you micro-align per instance)
if (!variable_instance_exists(id, "marker_x_offset"))  marker_x_offset  = 0;
if (!variable_instance_exists(id, "marker_y_offset"))  marker_y_offset  = 0;

// ---------------- Fallback (bottom-half anchor) ----------------
// Used only when use_cell_corners == false.
if (!variable_instance_exists(id, "grid_h"))             grid_h             = 32;
if (!variable_instance_exists(id, "anchor_bottom_half")) anchor_bottom_half = true; // shift anchor down by grid_h/2

// ---------------- Debug (optional) ----------------
// Turn these on temporarily if you want to see gizmos from oLedge Draw.
if (!variable_instance_exists(id, "debug_draw_hang"))  debug_draw_hang  = true;
if (!variable_instance_exists(id, "debug_draw_stand")) debug_draw_stand = true;
