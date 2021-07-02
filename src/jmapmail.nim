import fidget, vmath

import ui/login
import actions/config
import model

var cfg: Config
cfg = new(Config)
cfg.read()

var v: View = View(config: cfg, login: false, login_progress: false)
v.account = Account(login: cfg.account.login, password: cfg.account.password)

proc drawMain() =
  frame "main":
    box 0, 0, parent.box.w, parent.box.h
    if not v.login:
      loginForm(v)

windowFrame = vec2(620, 140)
startFidget(drawMain)
