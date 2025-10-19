/// oGame — Create  (persistent; no closures = no GM1049)

persistent = true;
if (instance_number(oGame) > 1) { instance_destroy(); exit; }

application_surface_enable(true);

// Init globals for pause/UI
if (!variable_global_exists("paused"))        global.paused = false;
if (!variable_global_exists("pause_menu_id")) global.pause_menu_id = noone;

can_toggle = true; // debounce for pause toggle


