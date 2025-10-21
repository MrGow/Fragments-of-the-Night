/// oPlayer — Room Start  (assign only; no new declarations)

// Reset control flags on entry
stunned  = false;
can_move = true;

// (Optional) Ensure any per-instance legacy locks are cleared
if (variable_instance_exists(id,"input_locked")) input_locked = false;

// Clear any residual tint from prior room
image_blend = c_white;
