//objectcomments  
forward
global type w_spacebricks_html from window
end type
type wb_1 from webbrowser within w_spacebricks_html
end type
end forward

global type w_spacebricks_html from window
integer width = 1851
integer height = 2300
boolean titlebar = true
string title = "Space Bricks"
boolean controlmenu = true
boolean minbox = true
long backcolor = 0
string icon = "AppIcon!"
boolean center = true
wb_1 wb_1
end type
global w_spacebricks_html w_spacebricks_html

forward prototypes
public function string wf_get_html ()
end prototypes

public function string wf_get_html ();string ls, q, n
q = "'"
n = "~n"
ls = '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"/>'
ls = ls + '<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no"/>'
ls = ls + '<title>Space Bricks</title>'
ls = ls + '<style>'
ls = ls + '*{box-sizing:border-box;margin:0;padding:0}'
ls = ls + 'html,body{height:100%;background:#000;color:#fff;font-family:Arial,sans-serif;overflow:hidden}'
ls = ls + '.app{height:100vh;display:flex;flex-direction:column;align-items:center;padding:0;gap:0}'
ls = ls + '.canvas-wrap{flex:1;display:flex;align-items:center;justify-content:center}'
ls = ls + 'canvas{display:block;border:1px solid #fff;margin-left:10px;margin-right:16px}'
ls = ls + '.footer{width:100%;display:flex;justify-content:space-between;align-items:center;padding:0 8px;font-weight:700;font-size:16px}'
ls = ls + '.footer .scores{flex:1;display:flex;gap:30px}'
ls = ls + '.footer button{background:#eee;color:#000;border:1px solid #aaa;width:80px;height:28px;border-radius:6px;font-weight:400;cursor:pointer;font-size:13px;font-family:Arial,sans-serif}'
ls = ls + '.info{font-size:13px;color:#888;text-align:left;padding:2px 8px 8px 8px;font-family:Arial,sans-serif;width:100%;align-self:flex-start}'
ls = ls + '.overlay{position:fixed;top:0;left:0;right:0;bottom:25%;background:none;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:40px;z-index:10;text-align:center}'
ls = ls + '.overlay h2{font-size:36px;width:100%;font-weight:700;font-family:Arial,sans-serif}'
ls = ls + '.overlay .sub{font-size:18px;color:#ccc;width:100%}'
ls = ls + '.overlay button{background:#00aa33;color:#fff;border:none;padding:12px 24px;font-size:18px;border-radius:8px;font-weight:700;cursor:pointer}'
ls = ls + '</style></head><body tabindex="0" autofocus><div id="root"></div>'
ls = ls + '<script>' + n
// game code in plain JS (no React, no Babel needed)
ls = ls + 'var COLS=7,ROWS=7,BRICK_PAD=3,BRICK_TOP=15,PADDLE_H=10,BALL_R=5,SPEED=210,PAD_SPEED=500;' + n
ls = ls + 'var COLORS=["#ff0044","#ff6600","#ffcc00","#00cc44","#0099ff","#8833ff","#ff33aa"];' + n
ls = ls + 'var cw=0,ch=0,canvas,ctx,game,overlay,scoreEl,livesEl,lastTime=0,spaceDown=false,paused=false;' + n
// init
ls = ls + 'function init(){' + n
ls = ls + 'var wrap=document.querySelector(".canvas-wrap");' + n
ls = ls + 'var maxW=window.innerWidth-28;var maxH=window.innerHeight-80;' + n
ls = ls + 'cw=maxW;ch=maxH;' + n
ls = ls + 'cw=Math.floor(cw);ch=Math.floor(ch);' + n
ls = ls + 'canvas=document.getElementById("gc");canvas.width=cw;canvas.height=ch;ctx=canvas.getContext("2d");' + n
ls = ls + 'scoreEl=document.getElementById("sc");livesEl=document.getElementById("lv");' + n
ls = ls + 'resetGame();requestAnimationFrame(loop);document.body.focus()}' + n
// bricks
ls = ls + 'function makeBricks(){var m=2,b=[],bw=(cw-m*2-BRICK_PAD*(COLS-1))/COLS,bh=10;' + n
ls = ls + 'for(var r=0;r<ROWS;r++)for(var c=0;c<COLS;c++)b.push({x:m+c*(bw+BRICK_PAD),y:BRICK_TOP+r*(bh+BRICK_PAD+1),w:bw,h:bh,color:COLORS[r],alive:true});' + n
ls = ls + 'return b}' + n
// reset
ls = ls + 'function resetGame(){var pw=cw*0.20;' + n
ls = ls + 'game={px:cw/2-pw/2,pw:pw,bx:cw/2,by:ch-40,dx:SPEED*0.5,dy:-SPEED*0.86,bricks:makeBricks(),score:0,lives:3,alive:true,won:false,launched:false};' + n
ls = ls + 'scoreEl.textContent="Score: 0";livesEl.textContent="Lives: 3";showOverlay("SPACE BRICKS","Pulsa espacio para empezar")}' + n
// reset ball
ls = ls + 'function resetBall(){game.px=cw/2-game.pw/2;game.bx=cw/2;game.by=ch-40;' + n
ls = ls + 'game.dx=SPEED*(Math.random()>0.5?0.5:-0.5);game.dy=-SPEED*0.86;game.launched=false;' + n
ls = ls + 'showOverlay("SPACE BRICKS","Pulsa espacio para continuar")}' + n
// overlay
ls = ls + 'var ovEl;function showOverlay(t,s){ovEl=document.getElementById("ov");' + n
ls = ls + 'ovEl.innerHTML="<h2>"+t+"</h2><div class=sub>"+s+"</div>";ovEl.style.display="flex"}' + n
ls = ls + 'function hideOverlay(){ovEl.style.display="none"}' + n
// keys
ls = ls + 'var keys={left:false,right:false};' + n
ls = ls + 'document.addEventListener("keydown",function(e){' + n
ls = ls + 'if(e.key==="ArrowLeft")keys.left=true;if(e.key==="ArrowRight")keys.right=true;' + n
ls = ls + 'if(e.key===" "&&!spaceDown){spaceDown=true;e.preventDefault();' + n
ls = ls + 'if(!game.alive||game.won){resetGame()}' + n
ls = ls + 'else if(!game.launched){game.launched=true;hideOverlay()}' + n
ls = ls + 'else{paused=!paused;if(paused){showOverlay("SPACE BRICKS","PAUSA")}else{hideOverlay()}}}});' + n
ls = ls + 'document.addEventListener("keyup",function(e){' + n
ls = ls + 'if(e.key==="ArrowLeft")keys.left=false;if(e.key==="ArrowRight")keys.right=false;' + n
ls = ls + 'if(e.key===" ")spaceDown=false});' + n
// loop
ls = ls + 'function loop(ts){requestAnimationFrame(loop);var g=game;' + n
ls = ls + 'var dt=lastTime?Math.min((ts-lastTime)/1000,0.05):1/60;lastTime=ts;' + n
ls = ls + 'if(g.launched&&g.alive&&!g.won&&!paused){' + n
// paddle
ls = ls + 'if(keys.left)g.px-=PAD_SPEED*dt;if(keys.right)g.px+=PAD_SPEED*dt;' + n
ls = ls + 'if(g.px<0)g.px=0;if(g.px+g.pw>cw)g.px=cw-g.pw;' + n
// ball move
ls = ls + 'g.bx+=g.dx*dt;g.by+=g.dy*dt;' + n
// walls
ls = ls + 'if(g.bx-BALL_R<=0){g.bx=BALL_R;g.dx=Math.abs(g.dx)}' + n
ls = ls + 'if(g.bx+BALL_R>=cw){g.bx=cw-BALL_R;g.dx=-Math.abs(g.dx)}' + n
ls = ls + 'if(g.by-BALL_R<=0){g.by=BALL_R;g.dy=Math.abs(g.dy)}' + n
// bottom
ls = ls + 'if(g.by+BALL_R>=ch){g.lives--;livesEl.textContent="Lives: "+g.lives;' + n
ls = ls + 'if(g.lives<=0){g.alive=false;showOverlay("SPACE BRICKS","Game Over - Pulsa Restart")}else{resetBall()}}' + n
// paddle collision
ls = ls + 'var py=ch-28;if(g.dy>0&&g.by+BALL_R>=py&&g.by+BALL_R<=py+PADDLE_H&&g.bx>=g.px&&g.bx<=g.px+g.pw){' + n
ls = ls + 'var hit=(g.bx-g.px)/g.pw,ang=(hit-0.5)*2.8,spd=Math.sqrt(g.dx*g.dx+g.dy*g.dy);' + n
ls = ls + 'g.dx=spd*Math.sin(ang);g.dy=-spd*Math.cos(ang);g.by=py-BALL_R}' + n
// bricks
ls = ls + 'for(var i=0;i<g.bricks.length;i++){var b=g.bricks[i];if(!b.alive)continue;' + n
ls = ls + 'if(g.bx+BALL_R>b.x&&g.bx-BALL_R<b.x+b.w&&g.by+BALL_R>b.y&&g.by-BALL_R<b.y+b.h){' + n
ls = ls + 'b.alive=false;g.score+=10;scoreEl.textContent="Score: "+g.score;' + n
ls = ls + 'var ol=g.bx+BALL_R-b.x,or2=b.x+b.w-(g.bx-BALL_R),ot=g.by+BALL_R-b.y,ob=b.y+b.h-(g.by-BALL_R);' + n
ls = ls + 'if(Math.min(ol,or2)<Math.min(ot,ob))g.dx=-g.dx;else g.dy=-g.dy;break}}' + n
// win
ls = ls + 'if(g.bricks.every(function(b){return!b.alive})){g.won=true;showOverlay("SPACE BRICKS","Has ganado! - Pulsa Restart")}}' + n
// draw
ls = ls + 'ctx.fillStyle="#000";ctx.fillRect(0,0,cw,ch);' + n
// bricks
ls = ls + 'for(var i=0;i<g.bricks.length;i++){var b=g.bricks[i];if(!b.alive)continue;' + n
ls = ls + 'ctx.fillStyle=b.color;ctx.beginPath();ctx.roundRect(b.x,b.y,b.w,b.h,3);ctx.fill();' + n
ls = ls + 'ctx.fillStyle="rgba(255,255,255,0.15)";ctx.fillRect(b.x+2,b.y+2,b.w-4,b.h/3)}' + n
// paddle
ls = ls + 'var py2=ch-28,grd=ctx.createLinearGradient(0,py2,0,py2+PADDLE_H);grd.addColorStop(0,"#66aaff");grd.addColorStop(1,"#2266cc");' + n
ls = ls + 'ctx.fillStyle=grd;ctx.beginPath();ctx.roundRect(g.px,py2,g.pw,PADDLE_H,4);ctx.fill();' + n
// ball
ls = ls + 'ctx.fillStyle="#fff";ctx.shadowColor="#fff";ctx.shadowBlur=8;ctx.beginPath();ctx.arc(g.bx,g.by,BALL_R,0,Math.PI*2);ctx.fill();ctx.shadowBlur=0}' + n
// html
ls = ls + 'document.getElementById("root").innerHTML=' + q
ls = ls + '<div class="app">'
ls = ls + '<div class="canvas-wrap"><canvas id="gc"></canvas></div>'
ls = ls + '<div class="footer"><span id="sc">Score: 0</span><span id="lv" style="flex:1;text-align:center">Lives: 3</span>'
ls = ls + '<button onclick="resetGame()">Restart</button></div>'
ls = ls + '<div class="info">Flechas = mover pala, Espacio = lanzar / pausa</div>'
ls = ls + '<div id="ov" class="overlay"><h2>SPACE BRICKS</h2><div class="sub">Pulsa espacio para empezar</div></div>'
ls = ls + '</div>' + q + ';init();'
ls = ls + '</script></body></html>'
return ls
end function

on w_spacebricks_html.create
this.wb_1=create wb_1
this.Control[]={this.wb_1}
end on

on w_spacebricks_html.destroy
destroy(this.wb_1)
end on

event open;String ls_html

ls_html=wf_get_html()

wb_1.NavigateToString(ls_html)
timer(0.5)
end event

event timer;timer(0)
wb_1.SetFocus()
wb_1.EvaluateJavascriptAsync("document.body.focus();")
end event

event closequery;Open(w_main)
end event

type wb_1 from webbrowser within w_spacebricks_html
boolean visible = false
integer width = 1842
integer height = 2220
integer taborder = 10
boolean border = false
end type

event navigationcompleted;this.visible=true
end event

