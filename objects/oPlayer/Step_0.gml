/// oPlayer — Step  (movement, collisions, combat hooks, robust LEDGE grab/pull)

// ---------- one-frame guard ----------
if (!variable_instance_exists(id,"attack_just_started")) attack_just_started = false;
var _skip_overrides_this_frame = attack_just_started;

// ---------- hot-reload safety ----------
if (!variable_instance_exists(id,"state"))                   state = "idle";
if (!variable_instance_exists(id,"hsp"))                     hsp = 0;
if (!variable_instance_exists(id,"vsp"))                     vsp = 0;
if (!variable_instance_exists(id,"image_xscale"))            image_xscale = 1;

if (!variable_instance_exists(id,"move_speed"))              move_speed = 2.5;
if (!variable_instance_exists(id,"jump_speed"))              jump_speed = -4.0;
if (!variable_instance_exists(id,"gravity_amt"))             gravity_amt = 0.2;
if (!variable_instance_exists(id,"low_jump_multiplier"))     low_jump_multiplier = 1.7;
if (!variable_instance_exists(id,"fall_multiplier"))         fall_multiplier = 1.5;
if (!variable_instance_exists(id,"max_fall"))                max_fall = 8.0;

if (!variable_instance_exists(id,"air_attack_drift"))        air_attack_drift = 1.15;
if (!variable_instance_exists(id,"attack_cooldown"))         attack_cooldown = 0;
if (!variable_instance_exists(id,"attack_end_fired"))        attack_end_fired = false;
if (!variable_instance_exists(id,"pc_combo_active"))         pc_combo_active = false;
if (!variable_instance_exists(id,"attack_anim_speed"))       attack_anim_speed = 1;

if (!variable_instance_exists(id,"coyote_time_frames"))      coyote_time_frames = 6;
if (!variable_instance_exists(id,"jump_buffer_time_frames")) jump_buffer_time_frames = 6;
if (!variable_instance_exists(id,"coyote_timer"))            coyote_timer = 0;
if (!variable_instance_exists(id,"jump_buffer_timer"))       jump_buffer_timer = 0;

if (!variable_instance_exists(id,"drink_anim_speed"))        drink_anim_speed = 0.35;
if (!variable_instance_exists(id,"hurt_anim_speed"))         hurt_anim_speed  = 0.55;
if (!variable_instance_exists(id,"hurt_lock_frames_default"))hurt_lock_frames_default = 10;
if (!variable_instance_exists(id,"hurt_lock_timer"))         hurt_lock_timer  = 0;
if (!variable_instance_exists(id,"last_seen_hurt_pulse"))    last_seen_hurt_pulse = (variable_global_exists("_hurt_pulse_id") ? global._hurt_pulse_id : 0);
if (!variable_instance_exists(id,"attack_release_linger"))   attack_release_linger = 0;

// ledge/jump spam cooldown + pull watchdog
if (!variable_instance_exists(id,"ledge_nojump_frames"))     ledge_nojump_frames = 0;
if (!variable_instance_exists(id,"ledge_pull_watch"))        ledge_pull_watch = 0;
if (ledge_nojump_frames > 0) ledge_nojump_frames--;
if (ledge_pull_watch  > 0) ledge_pull_watch--;

// ---------- sprite locals (UNtyped, avoid GM1041 propagation) ----------
var sprIdle_step      = __spr("spritePlayerIdle");
var sprRun_step       = __spr("spritePlayerRun");
var sprJump_step      = __spr("spritePlayerJump");
var sprHurt_step      = __spr("spritePlayerHurt");
var sprDrink_step     = __spr("spritePlayerDrink");
var sprLedgeGrab_step = __spr("spritePlayerLedgeGrab");
var sprLedgePull_step = __spr("spritePlayerLedgePull");

// ---------- tilemap access ----------
if (!variable_global_exists("tm_solids")) global.tm_solids = undefined;
function __ensure_tm_solids() {
    if (is_undefined(global.tm_solids)) {
        var _lid = layer_get_id("Solids"); // collision layer name
        global.tm_solids = (_lid != -1) ? layer_tilemap_get_id(_lid) : undefined;
    }
}
__ensure_tm_solids();

// ---------- collision helpers ----------
function __tile_solid_at(_x,_y) {
    return (!is_undefined(global.tm_solids)) && (tilemap_get_at_pixel(global.tm_solids,_x,_y)!=0);
}
function __rect_hits_solid(_dx,_dy) {
    var l=bbox_left+_dx, r=bbox_right+_dx, t=bbox_top+_dy, b=bbox_bottom+_dy, e=0.1;
    return __tile_solid_at(l+e,t+e) || __tile_solid_at(r-e,t+e) || __tile_solid_at(l+e,b-e) || __tile_solid_at(r-e,b-e);
}
function __on_ground_check() {
    var e=0.1; return __tile_solid_at(bbox_left+e,bbox_bottom+1)||__tile_solid_at(bbox_right-e,bbox_bottom+1);
}

// ---------- sprite switch (keep feet) ----------
/**
 * @param {Asset.GMSprite} _spr
 * @param {real} [_speed]
 */
function __set_sprite_keep_feet(_spr,_speed){
    if (_spr == -1) return;
    var cur_yoff=sprite_get_yoffset(sprite_index), cur_bot=sprite_get_bbox_bottom(sprite_index);
    var feet_y=y - cur_yoff + cur_bot;
    sprite_index=_spr; if (!is_undefined(_speed)) image_speed=_speed;
    var new_yoff=sprite_get_yoffset(sprite_index), new_bot=sprite_get_bbox_bottom(sprite_index);
    y = feet_y - (new_bot - new_yoff);
}

// ---------- input (keyboard wins; then oInput) ----------
var kx = (keyboard_check(vk_right)||keyboard_check(ord("D"))) - (keyboard_check(vk_left)||keyboard_check(ord("A")));
kx = clamp(kx,-1,1);
var k_jump_p = keyboard_check_pressed(vk_space);
var k_jump_h = keyboard_check(vk_space);
var k_heal_p = keyboard_check_pressed(ord("E"));
var k_down   = keyboard_check(vk_down) || keyboard_check(ord("S"));

var move_x=kx, jump_p=k_jump_p, jump_h=k_jump_h;
if (variable_global_exists("input") && is_struct(global.input)) {
    if (move_x==0 && variable_struct_exists(global.input,"move_x")) move_x = clamp(global.input.move_x,-1,1);
    if (variable_struct_exists(global.input,"jump_pressed"))        jump_p = jump_p || global.input.jump_pressed;
    if (variable_struct_exists(global.input,"jump_down"))           jump_h = jump_h || global.input.jump_down;
}

if (attack_cooldown>0) attack_cooldown--;

// ---------- heal ----------
if (k_heal_p && (!variable_global_exists("paused") || !global.paused) && !_skip_overrides_this_frame) {
    script_health_use_flask();
}

// ---------- hurt pulse ----------
var _pulse_now = (variable_global_exists("_hurt_pulse_id") ? global._hurt_pulse_id : 0);
if (_pulse_now != last_seen_hurt_pulse && state!="drink") {
    last_seen_hurt_pulse = _pulse_now;
    pc_combo_active = false;
    if (state=="ledge"||state=="ledge_pull") vsp = max(vsp,1.5);
    state = "hurt";
    if (sprHurt_step != -1) { __set_sprite_keep_feet(sprHurt_step,hurt_anim_speed); image_index=0; }
    hsp=0;
    var frames = (sprite_index==sprHurt_step)? image_number : 0;
    if (sprHurt_step==-1 || frames<=1) hurt_lock_timer = max(1,hurt_lock_frames_default); else hurt_lock_timer = 0;
}

// ---------- attack sprite detection ----------
var _sprA = __spr("spriteSwordAttackA");
var _sprB = __spr("spriteSwordAttackB");
var _sprC = __spr("spriteSwordAttackC");
var _sprU = __spr("spriteSwordAttackUp");

var _is_attack_sprite =
    (_sprA != -1 && sprite_index == _sprA) ||
    (_sprB != -1 && sprite_index == _sprB) ||
    (_sprC != -1 && sprite_index == _sprC) ||
    (_sprU != -1 && sprite_index == _sprU);

if (_is_attack_sprite) {
    state="attack";
    var _frames=max(1,image_number);
    var at_last=(image_index>=_frames-1.0);
    if (!pc_combo_active && at_last) { attack_release_linger++; if (attack_release_linger>=2) attack_release_linger=0; }
    else attack_release_linger=0;
} else attack_release_linger=0;

// ---------- env pre-check ----------
var on_ground = __on_ground_check();


// ======================================================================
// ================ L E D G E   G R A B / P U L L =======================
// ======================================================================

// guards for ledge vars (Create set them; hot-reload safe)
if (!variable_instance_exists(id,"ledge_enabled"))           ledge_enabled  = true;
if (!variable_instance_exists(id,"ledge_dir"))               ledge_dir      = 1;
if (!variable_instance_exists(id,"ledge_t"))                 ledge_t        = 0;
if (!variable_instance_exists(id,"ledge_pull_time"))         ledge_pull_time= 0.30;
if (!variable_instance_exists(id,"ledge_start_x"))           ledge_start_x  = x;
if (!variable_instance_exists(id,"ledge_start_y"))           ledge_start_y  = y;
if (!variable_instance_exists(id,"ledge_target_x"))          ledge_target_x = x;
if (!variable_instance_exists(id,"ledge_target_y"))          ledge_target_y = y;
if (!variable_instance_exists(id,"ledge_snap_y"))            ledge_snap_y   = y;
if (!variable_instance_exists(id,"ledge_regrab_cd"))         ledge_regrab_cd= 0;
if (!variable_instance_exists(id,"ledge_autopull"))          ledge_autopull = true;
if (!variable_instance_exists(id,"ledge_grab_grace"))        ledge_grab_grace = 0;
if (!variable_instance_exists(id,"ledge_lip_y"))             ledge_lip_y = y; // NEW: remember grabbed lip Y

// Lower hand anchor (~hands height for 30×46 mask)
function __grab_anchor_y() {
    var h = bbox_bottom - bbox_top;
    return bbox_top + clamp(round(h * 0.44), 18, 22);
}
function __nearest_wall_gap(_dir,_probe_y,_gap_max){
    if (_dir>0){ for(var dx=0; dx<=_gap_max; dx++) if(__tile_solid_at(bbox_right+dx,_probe_y)) return dx; }
    else       { for(var dn=0; dn<=_gap_max; dn++) if(__tile_solid_at(bbox_left-dn,_probe_y))  return dn; }
    return -1;
}
function __find_lip_y(_wall_x,_base_y,_search_px){
    for(var oy=-_search_px; oy<=_search_px; oy++){
        var yy=_base_y+oy; if(!__tile_solid_at(_wall_x,yy) && __tile_solid_at(_wall_x,yy+1)) return yy;
    }
    return undefined;
}
// Hang slightly BELOW the lip so hands sit right
function __snap_hang_to_lip(_lip_y) {
    var anchor = __grab_anchor_y();
    var HANG_Y_ADJUST = 18; // tweakable
    var target_y = _lip_y - (anchor - y) + HANG_Y_ADJUST;

    var dy = target_y - y, st = sign(dy);
    while (dy != 0) {
        if (!__rect_hits_solid(0, st)) { y += st; dy -= st; }
        else break;
    }
    ledge_snap_y = y;
}
// Compute a safe landing away from the wall
function __compute_pull_target(_wall_x, _lip_y, _dir) {
    var half_w = (bbox_right - bbox_left) * 0.5;
    var away   = 3;
    var tx     = (_dir > 0) ? (_wall_x + away + half_w) : (_wall_x - away - half_w);

    var rise   = 26; // crest the lip
    var ty     = _lip_y - rise;

    var sy     = __solve_standing_y(tx, rise);
    if (!__rect_hits_solid(tx - x, sy - y)) ty = sy;
    return [tx, ty];
}
// Find a collision-safe standing Y near target X
function __solve_standing_y(_tx,_rise){
    var yy = y - max(0,_rise) - 1;
    for (var up=0; up<8; up++) if (!__rect_hits_solid(_tx-x,(yy-up)-y)) { yy -= up; break; }
    var guard=48, d=0; while (d<guard) { if (__rect_hits_solid(_tx-x,(yy+1)-y)) break; yy++; d++; }
    return yy;
}
function __resolve_small_embed(){ var tries=6; while(__rect_hits_solid(0,0) && tries-- >0) y-=1; }

// --- pixelwise movers for 3-phase pull ---
function __move_axis_pixelwise(_dx, _dy, _spd) {
    var moved = 0;
    var sx = sign(_dx);
    var sy = sign(_dy);
    var ax = abs(_dx);
    var ay = abs(_dy);

    if (ax > 0) {
        var mx = min(ax, _spd);
        repeat (floor(mx)) { if (!__rect_hits_solid(sx, 0)) { x += sx; moved++; } else return moved; }
        var fx = mx - floor(mx);
        if (fx > 0 && !__rect_hits_solid(sx*fx, 0)) { x += sx*fx; moved += fx; }
        return moved;
    }
    if (ay > 0) {
        var my = min(ay, _spd);
        repeat (floor(my)) { if (!__rect_hits_solid(0, sy)) { y += sy; moved++; } else return moved; }
        var fy = my - floor(my);
        if (fy > 0 && !__rect_hits_solid(0, sy*fy)) { y += sy*fy; moved += fy; }
        return moved;
    }
    return 0;
}
function __pull_phase_step(_tx, _ty, _prefer_axis) {
    var px = _tx - x;
    var py = _ty - y;

    var frames_left = max(1, round(ledge_pull_time * room_speed * 0.90));
    var _spd = max(1.0, (abs(px) + abs(py)) / frames_left);
    _spd = min(_spd, 6);

    if (_prefer_axis == "y") {
        if (abs(py) > 0.001) __move_axis_pixelwise(0,  py, _spd);
        if (abs(px) > 0.001) __move_axis_pixelwise(px, 0,  _spd);
    } else {
        if (abs(px) > 0.001) __move_axis_pixelwise(px, 0,  _spd);
        if (abs(py) > 0.001) __move_axis_pixelwise(0,  py, _spd);
    }
    return (point_distance(x, y, _tx, _ty) <= 1.0);
}

// Try to begin a ledge grab
function __try_ledge_grab(_dir){
    if (!ledge_enabled || ledge_regrab_cd>0) return false;
    if (state=="ledge"||state=="ledge_pull") return false;
    if (vsp<=0.25 || __on_ground_check()) return false;

    // block while attacking
    var __atkA = __spr("spriteSwordAttackA");
    var __atkB = __spr("spriteSwordAttackB");
    var __atkC = __spr("spriteSwordAttackC");
    var __atkU = __spr("spriteSwordAttackUp");
    var is_attacking =
        (__atkA!=-1 && sprite_index==__atkA) ||
        (__atkB!=-1 && sprite_index==__atkB) ||
        (__atkC!=-1 && sprite_index==__atkC) ||
        (__atkU!=-1 && sprite_index==__atkU) ||
        pc_combo_active;
    if (is_attacking) return false;

    var anchor = __grab_anchor_y();
    var gap    = __nearest_wall_gap(_dir, anchor, 1); if (gap<0) return false;
    var wall_x = (_dir>0)? (bbox_right+gap) : (bbox_left-gap);
    var lip_y  = __find_lip_y(wall_x, anchor, 16);   if (is_undefined(lip_y)) return false;

    var dY = lip_y - anchor;
    if (dY >  3)  return false;
    if (dY < -14) return false;
    if (__tile_solid_at(wall_x, anchor - 9))   return false;
    if (__tile_solid_at(wall_x, bbox_bottom+1))return false;

    // Snap flush to wall then adjust Y for a believable hang
    var dx = (_dir>0)? (wall_x-1)-bbox_right : (wall_x+1)-bbox_left;
    if (!__rect_hits_solid(dx,0)) x += dx;

    state="ledge"; ledge_dir=_dir; hsp=0; vsp=0;
    __snap_hang_to_lip(lip_y);
    ledge_lip_y = lip_y; // remember exact lip we grabbed

    var sprGrab = __spr("spritePlayerLedgeGrab");
    if (sprGrab != -1) { __set_sprite_keep_feet(sprGrab, 0.65); image_index = 0; }

    ledge_start_x = x;  ledge_start_y = y;
    ledge_target_x = x; ledge_target_y = y;
    ledge_t = 0; ledge_pull_time = 0.30;
    ledge_regrab_cd = 10;
    ledge_grab_grace = 6;
    return true;
}

if (ledge_enabled) {
    if (state=="ledge") {
        y = ledge_snap_y; hsp=0; vsp=0; image_xscale=(ledge_dir>0)?1:-1;
        if (sprLedgeGrab_step != -1 && sprite_index != sprLedgeGrab_step) __set_sprite_keep_feet(sprLedgeGrab_step, 0.25);

        if (ledge_grab_grace>0) ledge_grab_grace--;

        var want_drop = k_down && (ledge_grab_grace<=0);
        if (want_drop) { state="jump"; vsp=1.5; ledge_regrab_cd=10; ledge_nojump_frames=6; }
        else {
            ledge_t += 1/room_speed;
            var grab_anim_done = (sprLedgeGrab_step!=-1 && sprite_index==sprLedgeGrab_step) ? (image_index >= image_number-1.0) : (ledge_t >= 0.10);
            var jump_now = k_jump_p;

            if (jump_now || ((ledge_grab_grace<=0) && (grab_anim_done || (ledge_autopull && ledge_t>=0.12)))) {
                // --- begin pull with conservative L-path (up → across → settle) ---
                var wall_x = (ledge_dir > 0) ? (bbox_right + 1) : (bbox_left - 1);
                var anchor = __grab_anchor_y();
                var lip_y  = __find_lip_y(wall_x, anchor, 16);
                if (is_undefined(lip_y)) lip_y = anchor;

                // Step away from the wall first (avoid scraping)
                var pre_dx = ledge_dir * 4;
                if (!__rect_hits_solid(pre_dx, 0)) x += pre_dx;

                // Compute landing (clear of wall)
                var tgt   = __compute_pull_target(wall_x, lip_y, ledge_dir);
                var tx    = tgt[0];
                var landY = tgt[1];

                // Phase targets: 0=UP, 1=ACROSS, 2=DOWN/SETTLE
                ledge_phase      = 0;
                phase0_tx        = x;
                phase0_ty        = lip_y - max(18, 26); // rise above lip
                phase1_tx        = tx;
                phase1_ty        = phase0_ty;
                phase2_tx        = tx;
                phase2_ty        = landY;

                // Switch sprite, enter pull
                if (sprLedgePull_step != -1) { sprite_index=sprLedgePull_step; image_index=0; image_speed=0.90; }
                state="ledge_pull";

                ledge_t       = 0;
                ledge_start_x = x; ledge_start_y = y;
                ledge_target_x= tx; ledge_target_y = landY;

                if (sprLedgePull_step!=-1 && image_speed>0) {
                    ledge_pull_time = max(0.22, image_number / (image_speed*room_speed));
                } else {
                    ledge_pull_time = max(0.22, 0.30);
                }
                ledge_regrab_cd     = 10;
                ledge_nojump_frames = 0;
                ledge_pull_watch    = ceil(room_speed * 1.20); // ~1.2s max to complete pull
            }
        }
    }
    else if (state=="ledge_pull") {
        if (ledge_regrab_cd>0) ledge_regrab_cd--;
        if (ledge_pull_watch > 0) ledge_pull_watch--;

        // Drive phases: 0 (up), 1 (across), 2 (down/settle)
        var reached = false;
        if (ledge_phase == 0) {
            reached = __pull_phase_step(phase0_tx, phase0_ty, "y");
            if (reached) ledge_phase = 1;
        }
        if (ledge_phase == 1) {
            reached = __pull_phase_step(phase1_tx, phase1_ty, "x");
            if (reached) ledge_phase = 2;
        }
        if (ledge_phase == 2) {
            reached = __pull_phase_step(phase2_tx, phase2_ty, "y");
        }

        // Freeze the pull sprite on its last frame (no looping)
        if (sprLedgePull_step != -1 && sprite_index == sprLedgePull_step && image_number > 0 && image_index >= image_number - 1.0) {
            image_index = image_number - 1.0;
            image_speed = 0;
        }

        // Consider the anim "finished" if we’re frozen on its last frame
        var finished_anim = (sprLedgePull_step != -1) && (sprite_index == sprLedgePull_step) && (image_speed == 0) && (image_index >= image_number - 1.0);

        // More forgiving proximity check
        var close_enough = (abs(x - phase2_tx) <= 3) && (abs(y - phase2_ty) <= 3);

        // Exit if reached / close / anim finished / watchdog expired
        if (reached || close_enough || finished_anim || (ledge_pull_watch <= 0)) {

            // --- robust finish using remembered lip height ---
            var surface_y = ledge_lip_y; // air pixel directly above solid (solid at surface_y+1)

            // Place so that bbox_bottom rests on the surface (incremental to avoid tunneling)
            var desired_y = surface_y - (bbox_bottom - y);
            var dy = desired_y - y;
            var step = sign(dy);
            while (dy != 0) {
                if (!__rect_hits_solid(0, step)) { y += step; dy -= step; }
                else break;
            }

            // Small settle: ensure grounded then back off 1px
            var settle = 0;
            while (settle < 8 && !__rect_hits_solid(0, 1)) { y += 1; settle++; }
            if (__rect_hits_solid(0, 1)) y -= 1;

            __resolve_small_embed();

            state="idle";
            if (sprIdle_step != -1) __set_sprite_keep_feet(sprIdle_step,0.4);
            ledge_regrab_cd     = 10;
            ledge_nojump_frames = 6; // prevent buffered jump right after the pull
            hsp=0; vsp=0;

        } else {
            // While we’re in pull, kill physics so they don’t fight the phases
            hsp = 0; 
            vsp = 0;
        }
    }
    else {
        if (ledge_regrab_cd>0) ledge_regrab_cd--;
        var wish_dir = (abs(move_x)>0.001)? sign(move_x) : (sign(image_xscale)==0?1:sign(image_xscale));
        __try_ledge_grab(wish_dir);
    }
}
// ========================= END LEDGE =========================

// ---------- update lock flags ----------
var ledge_now = (state=="ledge") || (state=="ledge_pull");
var in_lock_state = (state=="drink") || (state=="hurt") || ledge_now;

// ---------- coyote / buffer ----------
if (on_ground) coyote_timer = coyote_time_frames; else if (coyote_timer>0) coyote_timer--;
if (jump_p)    jump_buffer_timer = jump_buffer_time_frames; else if (jump_buffer_timer>0) jump_buffer_timer--;

// ---------- horizontal motion ----------
var hsp_target = in_lock_state ? 0 : (move_x * move_speed);
if (!in_lock_state && on_ground && (pc_combo_active || ledge_now)) hsp_target = 0;
if (!on_ground && pc_combo_active) hsp_target *= air_attack_drift;
hsp = ledge_now ? 0 : hsp_target;

// ---------- jump (blocked for a few frames after ledge) ----------
var can_jump_buffer = (!in_lock_state && !pc_combo_active && !ledge_now && jump_buffer_timer>0 && coyote_timer>0 && !_skip_overrides_this_frame && (ledge_nojump_frames<=0));
var can_jump_ground = (!in_lock_state && !pc_combo_active && !ledge_now && on_ground && k_jump_p && !_skip_overrides_this_frame && (ledge_nojump_frames<=0));
if (can_jump_buffer || can_jump_ground) { vsp = jump_speed; jump_buffer_timer=0; coyote_timer=0; }

// ---------- gravity ----------
var g = gravity_amt;
if (!on_ground && !ledge_now) {
    if (vsp<0) { if (!k_jump_h) g += gravity_amt*(low_jump_multiplier-1.0); }
    else       { g += gravity_amt*(fall_multiplier-1.0); }
}
vsp += ledge_now ? 0 : g;
if (vsp > max_fall) vsp = max_fall;

// ---------- collisions (H) ----------
if (hsp != 0) {
    var sx=sign(hsp), mx=abs(hsp);
    repeat (floor(mx)) { if (!__rect_hits_solid(sx,0)) x+=sx; else { hsp=0; break; } }
    var fx = mx - floor(mx);
    if (fx>0 && hsp!=0) { if (!__rect_hits_solid(sx*fx,0)) x+=sx*fx; else hsp=0; }
}

// ---------- collisions (V) ----------
if (!ledge_now && vsp != 0) {
    var sy=sign(vsp), my=abs(vsp);
    repeat (floor(my)) { if (!__rect_hits_solid(0,sy)) y+=sy; else { vsp=0; break; } }
    var fy = my - floor(my);
    if (fy>0 && vsp!=0) { if (!__rect_hits_solid(0,sy*fy)) y+=sy*fy; else vsp=0; }
}

// ---------- ground recheck ----------
on_ground = __on_ground_check();

// ---------- facing ----------
if (!in_lock_state && !pc_combo_active && !ledge_now && abs(move_x)>0.001 && !_skip_overrides_this_frame) {
    image_xscale = (move_x>0)? 1 : -1;
}

// ---------- locomotion state ----------
if (!pc_combo_active && !ledge_now && !_skip_overrides_this_frame) {
    if (!in_lock_state) {
        if (!on_ground) {
            if (sprJump_step != -1) { __set_sprite_keep_feet(sprJump_step,0.3); state="jump"; }
            else state="jump";
        } else if (abs(move_x)>0.001) {
            if (sprRun_step  != -1) { __set_sprite_keep_feet(sprRun_step ,1.2); state="run";  }
            else state="run";
        } else {
            if (sprIdle_step != -1) { __set_sprite_keep_feet(sprIdle_step,0.4); state="idle"; }
            else state="idle";
        }
    }
}

// ---------- hurt auto-exit ----------
if (state=="hurt" && hurt_lock_timer>0 && !_skip_overrides_this_frame) {
    hurt_lock_timer--;
    if (hurt_lock_timer<=0) {
        if (!on_ground) {
            if (sprJump_step != -1) { __set_sprite_keep_feet(sprJump_step,0.3); state="jump"; }
            else state="jump";
        } else if (abs(move_x)>0.001) {
            if (sprRun_step  != -1) { __set_sprite_keep_feet(sprRun_step ,1.2); state="run";  }
            else state="run";
        } else {
            if (sprIdle_step != -1) { __set_sprite_keep_feet(sprIdle_step,0.4); state="idle"; }
            else state="idle";
        }
    }
}

// ---------- clear guard ----------
if (attack_just_started) attack_just_started = false;
