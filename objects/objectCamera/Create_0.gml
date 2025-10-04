// View size (match your game resolution)
cam_w = 700;
cam_h = 400;

// Create + enable camera
cam = camera_create_view(0, 0, cam_w, cam_h, 0, -1, -1, cam_w, cam_h);
view_camera[0] = cam;
view_visible[0] = true;

// Who to follow
follow = oPlayer;   // or instance id if you prefer

// Framing
anchor_x = 0.50;     // 0=left edge, 1=right edge (keep center horizontally)
anchor_y_ground = 0.65; // player sits ~65% down from top when grounded (more view above)
anchor_y_air    = 0.58; // slightly higher when in air so you see where you're landing

// Smoothing
smooth = 0.12;       // 0.05 smoother, 0.2 snappier

// Look-ahead (anticipation)
look_x_max = 32;     // pixels to lead in move direction
la_x = 0;            // current look-ahead (smoothed)

// Pixel snap (prevents subpixel jitter in pixel art)
snap = 1;            // set to 1 for integer snapping

// Room clamp padding (keep a bit of buffer off exact edges)
pad_left   = 0;
pad_right  = 0;
pad_top    = 0;
pad_bottom = 0;

