import strformat
import resolv
import random

proc query_dns_jmap*(domain: string) : RDataSRV =
  echo &"Query _jmap._tcp.{domain} SRV..."
  let rmsg = resolv.query(&"_jmap._tcp.{domain}", QType.SRV, QClass.IN)
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

