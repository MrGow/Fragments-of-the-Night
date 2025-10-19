

// (Optional) if you keep any player-specific temporary states that should reset per room,
// do it here, e.g.:
if (variable_instance_exists(id, "stunned")) stunned = false;
if (variable_instance_exists(id, "can_move")) can_move = true;

// Nothing else needed. Spawning and input are handled centrally by oGame.

