/// oFade - Step
switch (state) {
    case 0:
        if (alpha >= 1) state = 2;
        break;

    case 1: // fade OUT
        alpha = min(1, alpha + speed);
        if (alpha >= 1) {
            if (pending_switch) {
                pending_switch = false;
                state       = 3;
                transit_ttl = 12;         // watchdog
                var rm = target_room;     // Room-typed
                room_goto(rm);
            } else {
                state = 2;
            }
        }
        break;

    case 2: // fade IN
        alpha = max(0, alpha - speed);
        if (alpha <= 0) state = 0;
        break;

    case 3: // waiting in the new room
        if (transit_ttl > 0) {
            transit_ttl--;
            if (transit_ttl == 0) state = 2;
        }
        break;
}

