


if (!variable_instance_exists(id,"prompt_text")) prompt_text = "Press \u2191 to leave";
if (!variable_instance_exists(id,"use_fade"))    use_fade    = true;

hovering = false;

up_pressed = function() {
    if (keyboard_check_pressed(vk_up) || keyboard_check(vk_up)) return true;
    for (var dev = 0; dev < 8; dev++) {
        if (!gamepad_is_connected(dev)) continue;
        if (gamepad_button_check_pressed(dev, gp_padu) || gamepad_button_check(dev, gp_padu)) return true;
    }
    return false;
};
