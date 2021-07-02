import strformat
import httpclient
import asyncdispatch
import tables
import jsony

import ./methods/base
import ./unique_id

type Transport* = ref object
  http: AsyncHttpClient
  url: string

proc newTransport*(url: string, http: AsyncHttpClient = nil): Transport =
  new(result)
  result.url  = url
  result.http = http
  if result.http == nil:
    result.http = newAsyncHttpClient()
  result.http.headers = newHttpHeaders({ "Content-Type": "application/json" })

proc close*(t: Transport) =
  t.http.close()

type
  Request* = object
    methodCalls*: seq[Method]

  RequestMethod* = object

  RequestDumpHelper = object
    `using`*: seq[string]
    methodCalls*: seq[Method]

proc dumpHook*(s: var string, req: Request) =
  s.add(RequestDumpHelper(
    `using`: @["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail"],
    methodCalls: req.methodCalls
  ).toJson)

type
  Response* = object
    request*: Request
    methodResponses*: seq[Method]
    createdIds*: Table[string,string]
    sessionState*: string

proc request*(t: Transport, req: sink Request): Future[Response] {.async.} =
  var gen: Generator
  for meth in items(req.methodCalls):
    if meth.id != "": gen.incl(meth.id)
  for meth in items(req.methodCalls):
    if meth.id == "": meth.id = gen.id()

  let body = req.toJson
  echo &"request body = {body}"
  let fut = t.http.post(t.url, body = body)
  fut.addCallback do():
    echo "callback ok"
  let resp = await fut
  echo "got response headers"
  let json = await(resp.body)
  echo &"got response body = {json}"

  var response: Response = json.fromJson(Response)
  response.request = req

  for i, meth in pairs(response.methodResponses):
    meth.src = req.methodCalls[i]

  return response

