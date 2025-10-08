/// oFade Create
alpha       = 0;
state       = 0;   // 0 idle, 1 fading out, 2 fading in
speed       = 0.2; // fade speed 0..1
callback_ok = false; // when true, tell camera to snap mid-fade-out

/// oFade method: start_fade_out_in
start_fade_out_in = function() {
    // Begin fade out only if idle
    if (state == 0) {
        state = 1;
        callback_ok = false;
    }
};
