import sets
import strutils

type Generator* = object
  ids: HashSet[string]

proc id*(g: var Generator): string =
  var i = g.ids.len
  while true:
    result = toHex(i)
    if not g.ids.contains(result):
      g.ids.incl(result)
      return
    i = i + 1

proc incl*(g: var Generator, id: string) =
  g.ids.incl(id)


