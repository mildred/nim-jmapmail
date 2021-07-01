import strformat, strutils
import uri

import ../jmap/resolver

proc login*(email: string) =
  echo &"Login {email}..."
  let parts = rsplit(email, '@')
  let domain = parts[1]
  echo domain
  let srv = query_dns_jmap(domain)
  let jmap_url = &"https://{srv.target}:{srv.port}/.well-known/jmap"
  echo &"Query {jmap_url}..."
  # use asyncHttpClient, store it in the model
  # .addCallback { refresh() } to trigger frame refresh on event
