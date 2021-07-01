import fidget, vmath

import ui/login
import model

var v: View = View(login: false, login_progress: false)

proc drawMain() =
  frame "main":
    box 0, 0, parent.box.w, parent.box.h
    if not v.login:
      loginForm(v)

windowFrame = vec2(620, 140)
startFidget(drawMain)
