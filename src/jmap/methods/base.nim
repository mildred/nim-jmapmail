import jsony
import tables

type
  NotImplementedDefect = object of Defect
  MethodData* = ref object of RootObj
  Method* = ref object
    name*: string
    data*: MethodData
    id*:   string
    src*:  Method
  RegisterFunc* = proc(): MethodData

var methods: Table[string,RegisterFunc]

proc registerMethod*(name: string, creator: RegisterFunc) =
  methods[name] = creator

method dumpJson*(obj: MethodData, s: var string) {.base.} =
  jsony.dumpHook(s, obj)

proc dumpHook*(s: var string, obj: MethodData) =
  dumpJson(obj, s)

method parseJson*(obj: var MethodData, s: string, i: var int) {.base.} =
  jsony.parseHook(s, i, obj)

proc parseHook*(s: string, i: var int, obj: var MethodData) =
  parseJson(obj, s, i)

proc dumpHook*(s: var string, m: Method) =
  s.add '['
  jsony.dumpHook(s, m.name)
  s.add ','
  jsony.dumpHook(s, m.data)
  s.add ','
  jsony.dumpHook(s, m.id)
  s.add ']'

type MethodParserHelper = object
  m: ref (string, MethodParserHelper, string)
  data: MethodData

proc parseHook*(s: string, i: var int, obj: var MethodParserHelper) =
  obj.data = methods[obj.m[0]]()
  parseHook(s, i, obj.data)

proc parseHook*(s: string, i: var int, obj: var Method) =
  var parsed: (string, MethodParserHelper, string)
  jsony.parseHook(s, i, parsed)
  obj.name = parsed[0]
  obj.data = parsed[1].data
  obj.id   = parsed[2]

proc newBaseMethod*(name: string, data: MethodData, id: string = ""): Method =
  result = Method(name: name, data: data, id: id)
