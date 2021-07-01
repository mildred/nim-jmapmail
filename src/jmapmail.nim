import fidget, vmath
import uri
import ndns
import strformat
import random
import strutils

# TODO: use system DNS servers
let dns = initDnsClient()

let fSans = "DejaVu Sans"
let fSansBold = "DejaVu Sans"
let fBold: float32 = 400
let fNormalWeight: float32 = 100
let cBlack = "#010101"
let cWhite = "#fefefe"

loadFont(fSans, "fonts/DejaVuSans.ttf")
loadFont(fSansBold, "fonts/DejaVuSans-Bold.ttf")

proc query_dns_jmap(dns: ndns.DnsClient, domain: string) : RDataSRV =
  echo &"Query _jmap._tcp.{domain} SRV..."
  let question = initQuestion(&"_jmap._tcp.{domain}", QType.SRV, QClass.IN)
  let msg = initMessage(initHeader(randId(), rd = true), @[question])
  var rmsg = dns.dnsQuery(msg)
  if rmsg.header.flags.rcode == RCode.NoError:
    # iterate to find best priority
    var prio: uint16 = 65535
    for ans in rmsg.answers:
      if ans.type != Type.SRV: continue
      if RDataSRV(ans.rdata).priority > prio: continue
      prio = RDataSRV(ans.rdata).priority
    # iterate to sum all the weights
    var weight_sum: int = 0
    for ans in rmsg.answers:
      if ans.type != Type.SRV: continue
      if RDataSRV(ans.rdata).priority != prio: continue
      weight_sum = weight_sum + int(RDataSRV(ans.rdata).weight)
    # iterate to select the correct result
    var selected: int = rand(weight_sum)
    for ans in rmsg.answers:
      if ans.type != Type.SRV: continue
      if RDataSRV(ans.rdata).priority != prio: continue
      result = RDataSRV(ans.rdata)
      selected = selected - int(RDataSRV(ans.rdata).weight)
      if selected <= 0: return

proc login(email: string) =
  echo &"Login {email}..."
  let parts = rsplit(email, '@')
  let domain = parts[1]
  echo domain
  let srv = query_dns_jmap(dns, domain)
  let jmap_url = &"https://{srv.target}:{srv.port}/.well-known/jmap"
  echo &"Query {jmap_url}..."
  # use asyncHttpClient, store it in the model
  # .addCallback { refresh() } to trigger frame refresh on event

proc labelText() =
  font fSans, 12, fNormalWeight, 0, hCenter, vCenter
  fill cBlack
  strokeWeight 1

proc entry(textVar: var string, placeholder: string, password: bool = false, enabled: bool = true) =
  text "text":
    box 9, 8, parent.box.w - 18, 15
    fill "#46607e"
    strokeWeight 1
    font fSans, 12, fNormalWeight, 0, hLeft, vCenter
    if enabled:
      binding textVar
    else:
      characters textVar
  text "textPlaceholder":
    box 9, 8, parent.box.w - 18, 15
    fill "#46607e", 0.5
    strokeWeight 1
    font fSans, 12, fNormalWeight, 0, hLeft, vCenter
    if textVar == "":
      characters placeholder
  rectangle "bg":
    box 0, 0, parent.box.w, 30
    stroke "#72bdd0"
    cornerRadius 5
    strokeWeight 1
    fill cWhite

proc button(btnText: string) =
  fill "#72bdd0"
  cornerRadius 5
  onHover:
    fill "#5C8F9C"
  onDown:
    fill "#3E656F"
  text "title":
    fill cBlack
    strokeWeight 1
    box 9, 8, parent.box.w - 18, 15
    font fSans, 12, fNormalWeight, 0, hCenter, vTop
    characters btnText

type Account = object
  login: string
  password: string

type View = ref object
  account: Account
  login: bool
  login_progress: bool


proc loginForm(v: View) =
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

var v: View = View(login: false, login_progress: false)

proc drawMain() =
  frame "main":
    box 0, 0, parent.box.w, parent.box.h
    if not v.login:
      loginForm(v)

windowFrame = vec2(620, 140)
startFidget(drawMain)
