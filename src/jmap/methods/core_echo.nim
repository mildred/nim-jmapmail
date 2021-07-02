import json
import jsony
import ./base

type
  CoreEchoData* = ref object of MethodData
    data*: JsonNode

const MethodName* = "Core/echo"
registerMethod(Methodname) do() -> MethodData: new(CoreEchoData)

proc newCoreEchoMethod*(data: JsonNode, id: string = ""): Method =
  result = newBaseMethod(Methodname, CoreEchoData(data: data), id)

method dumpJson*(obj: CoreEchoData, s: var string) =
  jsony.dumpHook(s, obj.data)

method parseJson*(obj: var CoreEchoData, s: string, i: var int) =
  jsony.parseHook(s, i, obj.data)

