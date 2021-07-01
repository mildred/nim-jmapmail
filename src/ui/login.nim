import fidget, vmath

import style
import common

import ../model
import ../actions/login

proc loginForm*(v: View) =
  group "login":
    box 0, 0, parent.box.w, parent.box.h
    let width = 250
    let height = 150
    box (int(parent.box.w) - width) / 2, (int(parent.box.h) - height) / 2, width, height
    fill "#eeeeee"
    text "title":
      fill cBlack
      strokeWeight 1
      box 10, 10, parent.box.w - 20, parent.box.h - 20
      font fSans, 16, fNormalWeight, 16, hCenter, vTop
      characters "Login"
    group "input":
      box 10, 30, parent.box.w - 20, 30
      entry(v.account.login, "e-mail", enabled = not v.login_progress)
    group "input":
      box 10, 70, parent.box.w - 20, 30
      entry(v.account.password, "password", enabled = not v.login_progress, password = true)
    if v.login_progress:
      text "progress":
        box 140, 110, 100, 30
        characters "Please wait..."
        labelText()
    else:
      group "button":
        box 140, 110, 100, 30
        button("Login")
        onClick:
          login(v.account.login)
          v.login_progress = true
