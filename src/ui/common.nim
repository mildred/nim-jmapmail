import fidget, vmath
import ./style

proc labelText*() =
  font fSans, 12, fNormalWeight, 0, hCenter, vCenter
  fill cBlack
  strokeWeight 1

proc entry*(textVar: var string, placeholder: string, password: bool = false, enabled: bool = true) =
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

proc button*(btnText: string) =
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


