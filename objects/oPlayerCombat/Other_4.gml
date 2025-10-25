/// oPlayerCombat — Room Start
if (!instance_exists(owner) && instance_exists(oPlayer)) {
    owner = instance_nearest(x, y, oPlayer);
}
/// oPlayerCombat — Begin Step
// (Intentionally minimal; logic lives in Step.)
