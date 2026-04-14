//objectcomments  
forward
global type w_spacebricks from window
end type
type dw_1 from datawindow within w_spacebricks
end type
type st_title from statictext within w_spacebricks
end type
type st_prompt from statictext within w_spacebricks
end type
type st_score from statictext within w_spacebricks
end type
type st_lives from statictext within w_spacebricks
end type
type cb_start from commandbutton within w_spacebricks
end type
type st_info from statictext within w_spacebricks
end type
end forward

global type w_spacebricks from window
integer width = 1851
integer height = 2300
boolean titlebar = true
string title = "Space Bricks"
boolean controlmenu = true
boolean minbox = true
long backcolor = 0
string icon = "AppIcon!"
boolean center = true
dw_1 dw_1
st_title st_title
st_prompt st_prompt
st_score st_score
st_lives st_lives
cb_start cb_start
st_info st_info
end type
global w_spacebricks w_spacebricks

type variables
constant integer GW = 21
constant integer GH = 34
constant integer CELLW = 80
constant integer ROW_H = 55
constant integer PADDLE_W = 4
constant integer PADDLE_ROW = 33
constant integer BRICK_ROWS = 7
constant integer BRICK_TOP = 2
constant integer BRICKS_PER_ROW = 7
constant integer BALL_SIZE = 50
constant integer BALL_SPEED = 22
// ball in PBU (absolute position in the single big band)
long il_bx, il_by
integer il_dx, il_dy
// paddle in cell column
long il_px
// state
long il_score
integer ii_lives
boolean ib_alive
boolean ib_launched
boolean ib_running
boolean ib_intimer
boolean ib_space_prev
long il_bricks_left
end variables

forward prototypes
public subroutine wf_init_grid ()
public subroutine wf_reset ()
public subroutine wf_clear_brick (long ax, long ay)
public subroutine wf_lose_life ()
public subroutine wf_show_overlay (string as_msg)
public subroutine wf_hide_overlay ()
public subroutine wf_update_paddle ()
public subroutine wf_update_ball ()
public function string wf_get_cell (long ax, long ay)
public subroutine wf_set_cell (long ax, long ay, string ac)
end prototypes

public subroutine wf_init_grid ();long i, r, ll_bx, ll_by, ll_cell_mid, ll_pos
string ls_cmd, ls_pn, ls_color
dw_1.setredraw(false)

// --- BALL: single oval, moves freely via Modify x/y ---
ls_cmd = 'create oval(band=detail ' + &
	'x="0" y="0" width="' + string(BALL_SIZE) + '" height="' + string(BALL_SIZE) + '" ' + &
	'name=ball ' + &
	'visible="1" ' + &
	'brush.hatch="6" brush.color="16777215" ' + &
	'pen.style="0" pen.width="0" pen.color="0" ' + &
	'background.mode="1" background.color="0")'
dw_1.modify(ls_cmd)

// --- BRICKS: 7 per row x 7 rows = 49 rectangles at absolute positions ---
for r = BRICK_TOP to BRICK_TOP + BRICK_ROWS - 1
	ll_by = (r - 1) * ROW_H + 3
	for i = 0 to BRICKS_PER_ROW - 1
		ll_bx = i * 3 * CELLW + 3
		ll_cell_mid = i * 3 + 2
		ll_pos = (r - 1) * GW + ll_cell_mid
		ls_pn = string(ll_pos)
		ls_color = 'CASE(long(mid(cells,' + ls_pn + ',1)) WHEN 3 THEN 4456703 WHEN 4 THEN 26367 WHEN 5 THEN 52479 WHEN 6 THEN 4508672 WHEN 7 THEN 16750848 WHEN 8 THEN 16724872 WHEN 9 THEN 11154431 ELSE 0)'
		ls_cmd = 'create rectangle(band=detail ' + &
			'x="' + string(ll_bx) + '" y="' + string(ll_by) + '" ' + &
			'width="' + string(3 * CELLW - 6) + '" height="' + string(ROW_H - 6) + '" ' + &
			'name=brk_' + string(r) + '_' + string(i) + ' ' + &
			'visible="0~tIf(long(mid(cells,' + ls_pn + ',1))>2,1,0)" ' + &
			'brush.hatch="6" ' + &
			'brush.color="0~t' + ls_color + '" ' + &
			'pen.style="0" pen.width="0" pen.color="0" ' + &
			'background.mode="1" background.color="0")'
		dw_1.modify(ls_cmd)
	next
next

// --- PADDLE: single rectangle at fixed y ---
ls_cmd = 'create rectangle(band=detail ' + &
	'x="' + string(((GW - PADDLE_W) / 2) * CELLW) + '" ' + &
	'y="' + string((PADDLE_ROW - 1) * ROW_H + 3) + '" ' + &
	'width="' + string(PADDLE_W * CELLW) + '" height="' + string(ROW_H - 6) + '" ' + &
	'name=paddle ' + &
	'visible="1" ' + &
	'brush.hatch="6" brush.color="16755266" ' + &
	'pen.style="0" pen.width="0" pen.color="0" ' + &
	'background.mode="1" background.color="0")'
dw_1.modify(ls_cmd)

dw_1.setredraw(true)
end subroutine

public subroutine wf_reset ();long r, c
string ls_all, ls_row

dw_1.setredraw(false)

// build the full cells string: GW*GH characters
ls_all = ""
for r = 1 to GH
	if r >= BRICK_TOP and r <= BRICK_TOP + BRICK_ROWS - 1 then
		ls_all = ls_all + fill(string(r - BRICK_TOP + 3), GW)
	else
		ls_all = ls_all + fill("0", GW)
	end if
next
dw_1.object.cells[1] = ls_all

il_bricks_left = BRICKS_PER_ROW * BRICK_ROWS

il_px = (GW - PADDLE_W) / 2 + 1
wf_update_paddle()

// ball in PBU: centered above paddle
il_bx = (il_px - 1) * CELLW + PADDLE_W * CELLW / 2
il_by = (PADDLE_ROW - 2) * ROW_H + ROW_H / 2
randomize(0)
if rand(2) = 1 then
	il_dx = BALL_SPEED
else
	il_dx = BALL_SPEED * -1
end if
il_dy = BALL_SPEED * -1

il_score = 0
ii_lives = 3
ib_alive = true
ib_launched = false
ib_running = true
ib_space_prev = false

dw_1.setredraw(true)
wf_update_ball()
st_score.text = "Score: 0"
st_lives.text = "Lives: 3"
wf_show_overlay("Pulsa espacio para empezar")
end subroutine

public subroutine wf_clear_brick (long ax, long ay);long ll_start, i
string ls_val
ls_val = wf_get_cell(ax, ay)
if ls_val < "3" or ls_val > "9" then return
ll_start = ((ax - 1) / 3) * 3 + 1
for i = ll_start to ll_start + 2
	if i <= GW then wf_set_cell(i, ay, "0")
next
il_bricks_left = il_bricks_left - 1
il_score = il_score + 10
end subroutine

public subroutine wf_lose_life ();ii_lives = ii_lives - 1
st_lives.text = "Lives: " + string(ii_lives)
if ii_lives <= 0 then
	ib_alive = false
	timer(0)
	wf_show_overlay("Game Over - Pulsa Restart")
else
	il_px = (GW - PADDLE_W) / 2 + 1
	wf_update_paddle()
	il_bx = (il_px - 1) * CELLW + PADDLE_W * CELLW / 2
	il_by = (PADDLE_ROW - 2) * ROW_H + ROW_H / 2
	if rand(2) = 1 then
		il_dx = BALL_SPEED
	else
		il_dx = BALL_SPEED * -1
	end if
	il_dy = BALL_SPEED * -1
	ib_launched = false
	wf_update_ball()
	wf_show_overlay("Pulsa espacio para continuar")
end if
end subroutine

public subroutine wf_show_overlay (string as_msg);st_prompt.text = as_msg
st_title.visible = true
st_prompt.visible = true
end subroutine

public subroutine wf_hide_overlay ();st_title.visible = false
st_prompt.visible = false
end subroutine

public subroutine wf_update_paddle ();dw_1.modify("paddle.x = '" + string((il_px - 1) * CELLW) + "'")
end subroutine

public subroutine wf_update_ball ();// just move x and y - 1 Modify, no visibility change, no redraw
dw_1.modify("ball.x = '" + string(il_bx - BALL_SIZE / 2) + "' ball.y = '" + string(il_by - BALL_SIZE / 2) + "'")
end subroutine

public function string wf_get_cell (long ax, long ay);// read one cell from the single-row string: pos = (ay-1)*GW + ax
long ll_pos
ll_pos = (ay - 1) * GW + ax
return mid(dw_1.object.cells[1], ll_pos, 1)
end function

public subroutine wf_set_cell (long ax, long ay, string ac);// write one cell in the single-row string
long ll_pos
string ls_all
ll_pos = (ay - 1) * GW + ax
ls_all = dw_1.object.cells[1]
ls_all = replace(ls_all, ll_pos, 1, ac)
dw_1.object.cells[1] = ls_all
end subroutine

on w_spacebricks.create
this.dw_1=create dw_1
this.st_title=create st_title
this.st_prompt=create st_prompt
this.st_score=create st_score
this.st_lives=create st_lives
this.cb_start=create cb_start
this.st_info=create st_info
this.Control[]={this.dw_1,&
this.st_title,&
this.st_prompt,&
this.st_score,&
this.st_lives,&
this.cb_start,&
this.st_info}
end on

on w_spacebricks.destroy
destroy(this.dw_1)
destroy(this.st_title)
destroy(this.st_prompt)
destroy(this.st_score)
destroy(this.st_lives)
destroy(this.cb_start)
destroy(this.st_info)
end on

event open;// only 1 row - the entire game is in one big detail band
dw_1.insertrow(0)
dw_1.object.cells[1] = fill("0", GW * GH)
wf_init_grid()
wf_reset()
this.setfocus()
timer(0.04)
end event

event timer;long ll_grid_w, ll_paddle_top, ll_cx, ll_cy
long ll_pad_left, ll_pad_right, ll_hit_pct
string ls_cell

if not ib_alive then return
if ib_intimer then return
ib_intimer = true

// === Space bar ===
if keydown(keyspacebar!) then
	if not ib_space_prev then
		if not ib_launched then
			ib_launched = true
			wf_hide_overlay()
		else
			ib_running = not ib_running
			if not ib_running then
				wf_show_overlay("PAUSA")
			else
				wf_hide_overlay()
			end if
		end if
	end if
	ib_space_prev = true
else
	ib_space_prev = false
end if

if not ib_launched then
	ib_intimer = false
	return
end if

// === Paddle ===
if keydown(keyleftarrow!) then
	if il_px > 1 then
		il_px = il_px - 1
		wf_update_paddle()
	end if
end if
if keydown(keyrightarrow!) then
	if il_px + PADDLE_W <= GW then
		il_px = il_px + 1
		wf_update_paddle()
	end if
end if

if not ib_running then
	ib_intimer = false
	return
end if

// === Move ball ===
il_bx = il_bx + il_dx
il_by = il_by + il_dy

ll_grid_w = GW * CELLW
ll_paddle_top = (PADDLE_ROW - 1) * ROW_H

// === Walls ===
if il_bx - BALL_SIZE / 2 < 0 then
	il_bx = BALL_SIZE / 2
	il_dx = abs(il_dx)
end if
if il_bx + BALL_SIZE / 2 > ll_grid_w then
	il_bx = ll_grid_w - BALL_SIZE / 2
	il_dx = abs(il_dx) * -1
end if
if il_by - BALL_SIZE / 2 < 0 then
	il_by = BALL_SIZE / 2
	il_dy = abs(il_dy)
end if

// === Brick collision: web-style AABB + min-overlap bounce, 1 brick per tick ===
long ll_r, ll_c, ll_mid, ll_bk_x, ll_bk_y, ll_bk_w, ll_bk_h
long ll_ovl_l, ll_ovl_r, ll_ovl_t, ll_ovl_b, ll_min_x, ll_min_y
boolean lb_brick_hit
string ls_all

ll_bk_w = 3 * CELLW - 6
ll_bk_h = ROW_H - 6
lb_brick_hit = false
ls_all = dw_1.object.cells[1]

for ll_r = BRICK_TOP to BRICK_TOP + BRICK_ROWS - 1
	if lb_brick_hit then exit
	for ll_c = 0 to BRICKS_PER_ROW - 1
		ll_mid = ll_c * 3 + 2
		ls_cell = mid(ls_all, (ll_r - 1) * GW + ll_mid, 1)
		if ls_cell >= "3" and ls_cell <= "9" then
			ll_bk_x = ll_c * 3 * CELLW + 3
			ll_bk_y = (ll_r - 1) * ROW_H + 3
			// AABB overlap: ball vs brick
			if il_bx + BALL_SIZE / 2 > ll_bk_x and il_bx - BALL_SIZE / 2 < ll_bk_x + ll_bk_w and il_by + BALL_SIZE / 2 > ll_bk_y and il_by - BALL_SIZE / 2 < ll_bk_y + ll_bk_h then
				wf_clear_brick(ll_mid, ll_r)
				// min-overlap determines bounce axis
				ll_ovl_l = il_bx + BALL_SIZE / 2 - ll_bk_x
				ll_ovl_r = ll_bk_x + ll_bk_w - il_bx + BALL_SIZE / 2
				ll_ovl_t = il_by + BALL_SIZE / 2 - ll_bk_y
				ll_ovl_b = ll_bk_y + ll_bk_h - il_by + BALL_SIZE / 2
				ll_min_x = ll_ovl_l
				if ll_ovl_r < ll_min_x then ll_min_x = ll_ovl_r
				ll_min_y = ll_ovl_t
				if ll_ovl_b < ll_min_y then ll_min_y = ll_ovl_b
				if ll_min_x < ll_min_y then
					il_dx = il_dx * -1
				else
					il_dy = il_dy * -1
				end if
				lb_brick_hit = true
				exit
			end if
		end if
	next
next

// === Paddle ===
if il_dy > 0 and il_by + BALL_SIZE / 2 >= ll_paddle_top then
	ll_pad_left = (il_px - 1) * CELLW
	ll_pad_right = ll_pad_left + PADDLE_W * CELLW
	if il_bx >= ll_pad_left and il_bx <= ll_pad_right then
		il_by = ll_paddle_top - BALL_SIZE / 2
		il_dy = abs(il_dy) * -1
		ll_hit_pct = ((il_bx - ll_pad_left) * 100) / (ll_pad_right - ll_pad_left)
		if ll_hit_pct < 25 then
			il_dx = (BALL_SPEED + 3) * -1
		elseif ll_hit_pct < 45 then
			il_dx = BALL_SPEED * -1
		elseif ll_hit_pct > 75 then
			il_dx = BALL_SPEED + 3
		elseif ll_hit_pct > 55 then
			il_dx = BALL_SPEED
		end if
	end if
end if

// === Death ===
if il_by > ll_paddle_top + ROW_H then
	wf_lose_life()
	ib_intimer = false
	return
end if

// === Render ball: just 1 Modify for x+y ===
wf_update_ball()

st_score.text = "Score: " + string(il_score)

if il_bricks_left <= 0 then
	ib_alive = false
	timer(0)
	ib_intimer = false
	wf_show_overlay("Has ganado! Pulsa Restart")
	return
end if

ib_intimer = false
end event

event close;timer(0)
end event

event closequery;Open(w_main)
end event

type dw_1 from datawindow within w_spacebricks
integer x = 41
integer y = 40
integer width = 1719
integer height = 1912
string dataobject = "dw_spacebricks"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type st_title from statictext within w_spacebricks
integer x = 172
integer y = 700
integer width = 1500
integer height = 252
integer textsize = -28
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16777215
long backcolor = 553648127
string text = "SPACE BRICKS"
alignment alignment = center!
boolean focusrectangle = false
end type

type st_prompt from statictext within w_spacebricks
integer x = 302
integer y = 1000
integer width = 1202
integer height = 152
integer textsize = -14
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 11184810
long backcolor = 553648127
string text = "Pulsa espacio para empezar"
alignment alignment = center!
boolean focusrectangle = false
end type

type st_score from statictext within w_spacebricks
integer x = 41
integer y = 1992
integer width = 599
integer height = 92
integer textsize = -12
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16777215
long backcolor = 0
string text = "Score: 0"
boolean focusrectangle = false
end type

type st_lives from statictext within w_spacebricks
integer x = 699
integer y = 1992
integer width = 402
integer height = 92
integer textsize = -12
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16777215
long backcolor = 0
string text = "Lives: 3"
boolean focusrectangle = false
end type

type cb_start from commandbutton within w_spacebricks
integer x = 1349
integer y = 1984
integer width = 402
integer height = 112
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Restart"
end type

event clicked;wf_reset()
timer(0.04)
parent.setfocus()
end event

type st_info from statictext within w_spacebricks
integer x = 41
integer y = 2112
integer width = 1701
integer height = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 12632256
long backcolor = 0
string text = "Flechas = mover pala, Espacio = lanzar / pausa"
boolean focusrectangle = false
end type

