import strformat
import json
import asyncdispatch

import ../model
import ./config
import ../jmap/resolver
import ../jmap/transport
import ../jmap/methods/core_echo

proc login*(config: Config, account: Account) {.async.} =
  let email = account.login
  echo &"Login {email}..."
  let jmap_url = email_to_jmap_url(email)

  echo &"Query {jmap_url}..."
  account.transport = newTransport(jmap_url)

  let resp = await account.transport.request(Request(
    methodCalls: @[
      newCoreEchoMethod(%*{"hello": "world"})
    ]
  ))

  echo resp
  # DONE: use asyncHttpClient (ok), store it in the model (todo)
  # .addCallback { refresh() } to trigger frame refresh on event


  config.account = ConfigAccount(account[])
  config.save()
