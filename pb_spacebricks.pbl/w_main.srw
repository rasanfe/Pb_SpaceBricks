//objectcomments  
forward
global type w_main from window
end type
type wb_1 from webbrowser within w_main
end type
end forward

global type w_main from window
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
global w_main w_main

type variables
boolean ib_registered = false
end variables

forward prototypes
public function string wf_get_html ()
public subroutine wf_open_nativo ()
public subroutine wf_open_html ()
end prototypes

public function string wf_get_html ();string ls, q
q = "'"
ls = '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"/>'
ls = ls + '<style>'
ls = ls + '*{margin:0;padding:0;box-sizing:border-box}'
ls = ls + 'body{height:100vh;background:#000;color:#fff;font-family:Arial,sans-serif;display:flex;flex-direction:column;align-items:center;justify-content:center;overflow:hidden}'
ls = ls + '.title{font-size:48px;font-weight:700;margin-bottom:10px}'
ls = ls + '.sub{font-size:16px;color:#888;margin-bottom:50px}'
ls = ls + '.modes{display:flex;gap:30px}'
ls = ls + '.mode{width:180px;height:200px;border:2px solid #444;border-radius:12px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:12px;cursor:pointer;transition:all 0.2s}'
ls = ls + '.mode:hover{border-color:#fff;background:#111}'
ls = ls + '.mode .icon{font-size:48px}'
ls = ls + '.mode .label{font-size:16px;font-weight:700}'
ls = ls + '.mode .desc{font-size:11px;color:#888;text-align:center;padding:0 10px}'
ls = ls + '.footer{position:absolute;bottom:20px;font-size:12px;color:#555}'
ls = ls + '</style></head><body>'
ls = ls + '<div class="title">SPACE BRICKS</div>'
ls = ls + '<div class="sub">Selecciona la version</div>'
ls = ls + '<div class="modes">'
ls = ls + '<div class="mode" onclick="window.webBrowser.ue_nativo()">'
ls = ls + '<div class="icon">&#127918;</div>'
ls = ls + '<div class="label">Nativo PB</div>'
ls = ls + '<div class="desc">DataWindow + Timer<br>PowerBuilder nativo</div></div>'
ls = ls + '<div class="mode" onclick="window.webBrowser.ue_html()">'
ls = ls + '<div class="icon">&#127760;</div>'
ls = ls + '<div class="label">HTML</div>'
ls = ls + '<div class="desc">Canvas + JavaScript<br>WebBrowser integrado</div></div>'
ls = ls + '</div>'
ls = ls + '<div class="footer">PowerBuilder 2025</div>'
ls = ls + '</body></html>'
return ls
end function

public subroutine wf_open_nativo ();open(w_spacebricks)
close(this)
end subroutine

public subroutine wf_open_html ();open(w_spacebricks_html)
close(this)
end subroutine

on w_main.create
this.wb_1=create wb_1
this.Control[]={this.wb_1}
end on

on w_main.destroy
destroy(this.wb_1)
end on

event open;String ls_html
ls_html = wf_get_html()
wb_1.NavigateToString(ls_html)
end event

type wb_1 from webbrowser within w_main
event ue_nativo ( )
event ue_html ( )
boolean visible = false
integer width = 1842
integer height = 2220
boolean border = false
end type

event ue_nativo();wf_open_nativo()

end event

event ue_html();wf_open_html()

end event

event navigationstart;if not ib_registered then
	if wb_1.RegisterEvent("ue_nativo") = 1 then
		wb_1.RegisterEvent("ue_html")
		ib_registered = true
	end if
end if  
end event

event navigationcompleted;this.visible=true
end event

