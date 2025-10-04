// Camera/view size
cam_w = 640;
cam_h = 360;

// Create + enable
cam = camera_create_view(0, 0, cam_w, cam_h, false, -1, -1, cam_w, cam_h);
view_camera[0] = cam;
view_visible[0] = true;

// Who to follow
follow = oPlayer;

// Framing (player slightly low to see more above)
anchor_x = 0.50;
anchor_y_ground = 0.65;
anchor_y_air    = 0.58;

// Smoothing / look-ahead / pixel snap
smooth     = 0.12;
look_x_max = 32;
la_x       = 0;
snap       = 1; // integer pixel snapping

