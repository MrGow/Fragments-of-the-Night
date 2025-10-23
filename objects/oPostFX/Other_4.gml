/// oPostFX: Room Start
if (!surface_exists(_surfA) || !surface_exists(_surfB)) {
    if (surface_exists(_surfA)) surface_free(_surfA);
    if (surface_exists(_surfB)) surface_free(_surfB);
    _surfA = surface_create(_sW, _sH);
    _surfB = surface_create(_sW, _sH);
}
