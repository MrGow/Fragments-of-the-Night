/// oParEnemy — Step  (death/i-frames, sticky-proof touch damage, optional patrol)

// ---------- Defensive defaults (covers children that skipped Create) ----------
if (!variable_instance_exists(id,"hp"))                hp = 3;
if (!variable_instance_exists(id,"is_dead"))           is_dead = false;
if (!variable_instance_exists(id,"death_sprite"))      death_sprite = -1;
if (!variable_instance_exists(id,"death_image_speed")) death_image_speed = 0.25;
if (!variable_instance_exists(id,"explosion_object"))  explosion_object = -1;

if (!variable_instance_exists(id,"invul_frames"))      invul_frames = 0;
if (!variable_instance_exists(id,"invincible"))        invincible = false;
if (!variable_instance_exists(id,"hurtbox_active"))    hurtbox_active = true;

if (!variable_instance_exists(id,"contact_damage"))    contact_damage = 1;
if (!variable_instance_exists(id,"knockback_px"))      knockback_px   = 5;
if (!variable_instance_exists(id,"_touch_cd_max"))     _touch_cd_max  = 30;
if (!variable_instance_exists(id,"_touch_cd"))         _touch_cd      = 0;

if (!variable_instance_exists(id,"patrol_enabled"))    patrol_enabled = false;
if (!variable_instance_exists(id,"dir"))               dir = choose(-1,1);
if (!variable_instance_exists(id,"patrol_speed"))      patrol_speed = 1.2;
if (!variable_instance_exists(id,"hsp"))               hsp = 0;
if (!variable_instance_exists(id,"vsp"))               vsp = 0;
if (!variable_instance_exists(id,"gravity_amt"))       gravity_amt = 0.20;
if (!variable_instance_exists(id,"max_fall"))          max_fall = 8.0;
if (!variable_instance_exists(id,"cliff_sense_dist"))  cliff_sense_dist = 6;
if (!variable_instance_exists(id,"wall_sense_dist"))   wall_sense_dist  = 1;
if (!variable_instance_exists(id,"turn_cooldown"))     turn_cooldown    = 8;
if (!variable_instance_exists(id,"_turn_cd"))          _turn_cd         = 0;

// Hurtbox shrink (defaults; children may override)
if (!variable_instance_exists(id,"contact_shrink_h"))      contact_shrink_h      = 8;
if (!variable_instance_exists(id,"contact_shrink_top"))    contact_shrink_top    = 10;
if (!variable_instance_exists(id,"contact_shrink_bottom")) contact_shrink_bottom = 4;

// ---------- i-frames tick ----------
if (invul_frames > 0) {
    invul_frames--;
    image_alpha = (invul_frames % 2 == 0) ? 0.6 : 1.0;
} else {
    image_alpha = 1.0;
}

// ---------- Death gate ----------
if (!is_dead && hp <= 0) {
    is_dead = true;
    if (death_sprite != -1) {
        sprite_index = death_sprite;
        image_index  = 0;
        image_speed  = death_image_speed;
    } else {
        if (explosion_object != -1 && object_exists(explosion_object)) {
            instance_create_layer(x, y, layer, explosion_object);
        }
        instance_destroy();
        exit;
    }
}

// While dead, keep death anim and exit so child AI can’t overwrite it
if (is_dead) {
    if (death_sprite != -1) {
        if (sprite_index != death_sprite) { sprite_index = death_sprite; image_index = 0; }
        image_speed = death_image_speed;
    } else {
        if (explosion_object != -1 && object_exists(explosion_object)) {
            instance_create_layer(x, y, layer, explosion_object);
        }
        instance_destroy();
    }
    exit;
}

// ================= BODY TOUCH DAMAGE — sticky-proof + small hurtbox =================
if (_touch_cd > 0) _touch_cd--;

if (!is_dead && contact_damage > 0 && _touch_cd <= 0 && hurtbox_active && !invincible) {

    // Build a smaller rectangle inside the enemy’s bbox
    var x1 = bbox_left   + contact_shrink_h;
    var x2 = bbox_right  - contact_shrink_h;
    var y1 = bbox_top    + contact_shrink_top;
    var y2 = bbox_bottom - contact_shrink_bottom;

    if (x2 > x1 && y2 > y1) {
        var victim = collision_rectangle(x1, y1, x2, y2, oPlayer, false, true);

        if (victim != noone) {
            var player_iframe = (variable_global_exists("_iframes_timer") ? max(0, global._iframes_timer) : 0);
            var player_hurt   = (variable_instance_exists(victim,"state") ? (victim.state == "hurt") : false);

            if (player_iframe <= 0 && !player_hurt) {
                if (script_health_take_damage(contact_damage, id)) {
                    var d = sign(victim.x - x); if (d == 0) d = choose(-1, 1);

                    if (variable_instance_exists(victim, "hsp")) victim.hsp = max(abs(victim.hsp), 2.4) * d; else victim.x += d * 2;
                    if (variable_instance_exists(victim, "vsp")) victim.vsp = min(victim.vsp, -2.0);

                    var tries = 0;
                    while (tries < 6 && collision_rectangle(x1, y1, x2, y2, oPlayer, false, true) != noone) { 
                        victim.x += d; 
                        tries++; 
                    }

                    x -= d * 1;
                    _touch_cd = max(_touch_cd_max, 18);
                }
            }
        }
    }
}
// ====================================================================


// ========================= PATROL (opt-in) =========================
if (patrol_enabled) {

    // --- tile helpers (FLOOR vs ANY-SOLID) ---
    if (!variable_global_exists("tm_solids")) global.tm_solids = undefined;
    if (!variable_global_exists("tm_walls"))  global.tm_walls  = undefined;

    function __tile_floor_at(_x,_y) {
        return (!is_undefined(global.tm_solids)) && (tilemap_get_at_pixel(global.tm_solids,_x,_y) != 0);
    }
    function __tile_any_solid_at(_x,_y) {
        if (!is_undefined(global.tm_solids) && tilemap_get_at_pixel(global.tm_solids,_x,_y) != 0) return true;
        if (!is_undefined(global.tm_walls)  && tilemap_get_at_pixel(global.tm_walls ,_x,_y) != 0) return true;
        return false;
    }
    function __on_ground_check_enemy() {
        var l = bbox_left, r = bbox_right, b = bbox_bottom;
        var e = 0.1, step = 4, xx = l + e;
        while (xx <= r - e + 0.0001) { if (__tile_floor_at(xx, b + 1)) return true; xx += step; }
        return __tile_floor_at(r - e, b + 1);
    }
    function __rect_hits_solid_enemy(_dx,_dy) {
        var l = bbox_left  + _dx;
        var r = bbox_right + _dx;
        var t = bbox_top   + _dy;
        var b = bbox_bottom+ _dy;

        var e = 0.1, sv = 4, sh = 4;

        var yy = t + e;
        while (yy <= b - e + 0.0001) {
            if (__tile_any_solid_at(l + e, yy)) return true;
            if (__tile_any_solid_at(r - e, yy)) return true;
            yy += sv;
        }
        if (__tile_any_solid_at(l + e, b - e)) return true;
        if (__tile_any_solid_at(r - e, b - e)) return true;

        var xx = l + e;
        while (xx <= r - e + 0.0001) {
            if (__tile_any_solid_at(xx, t + e)) return true;
            if (__tile_any_solid_at(xx, b - e)) return true;
            xx += sh;
        }
        if (__tile_any_solid_at(r - e, t + e)) return true;
        if (__tile_any_solid_at(r - e, b - e)) return true;

        return false;
    }
    function __move_h(_spd) {
        if (_spd == 0) return;
        var sx = sign(_spd), mx = abs(_spd);
        repeat (floor(mx))  { if (!__rect_hits_solid_enemy(sx,0)) x += sx; else break; }
        var fx = mx - floor(mx);
        if (fx > 0) { if (!__rect_hits_solid_enemy(sx*fx,0)) x += sx*fx; }
    }
    function __ahead_wall(_dir) {
        var px = (_dir > 0) ? (bbox_right + wall_sense_dist) : (bbox_left - wall_sense_dist);
        return __tile_any_solid_at(px, bbox_bottom - 4) || __tile_any_solid_at(px, bbox_top + 8);
    }
    function __ground_ahead(_dir) {
        var px = (_dir > 0) ? (bbox_right + cliff_sense_dist) : (bbox_left - cliff_sense_dist);
        return __tile_floor_at(px, bbox_bottom + 1);
    }

    // --- gravity ---
    var on_ground = __on_ground_check_enemy();
    if (!on_ground) {
        vsp += gravity_amt;
        if (vsp > max_fall) vsp = max_fall;
    }

    // apply V with collisions
    if (vsp != 0) {
        var sy = sign(vsp);
        var my = abs(vsp);
        repeat (floor(my)) { if (!__rect_hits_solid_enemy(0, sy)) y += sy; else { vsp = 0; break; } }
        var fy = my - floor(my);
        if (fy > 0 && vsp != 0) { if (!__rect_hits_solid_enemy(0, sy*fy)) y += sy*fy; else vsp = 0; }
    }

    // --- turn logic (walls/chasms) ---
    if (_turn_cd > 0) _turn_cd--;

    var ahead_x_wall = (dir > 0) ? (bbox_right + wall_sense_dist) : (bbox_left - wall_sense_dist);
    var ahead_x_foot = (dir > 0) ? (bbox_right + cliff_sense_dist) : (bbox_left - cliff_sense_dist);

    var wall_hit     = __tile_any_solid_at(ahead_x_wall, bbox_bottom - 4) || __tile_any_solid_at(ahead_x_wall, bbox_top + 8);
    var ground_ahead = __tile_floor_at(ahead_x_foot, bbox_bottom + 1);

    var must_turn = (wall_hit || (!ground_ahead && on_ground));
    if (must_turn && _turn_cd <= 0) {
        dir = -dir;
        _turn_cd = turn_cooldown;
    }

    // --- horizontal movement ---
    hsp = dir * patrol_speed;
    __move_h(hsp);

    // --- facing ---
    if (dir != 0) image_xscale = (dir > 0) ? 1 : -1;
}
// ======================= end patrol =======================
