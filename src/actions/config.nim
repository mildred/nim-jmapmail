import strformat
import parsecfg
import os

import ../model

const appName = "jmapmail"

proc configFilename(appName: string, configFile: string = "config.ini"): string =
  result = joinPath(getEnv("XDG_CONFIG_HOME", joinPath(getEnv("HOME"), ".config")), appName, configFile)

proc save*(cfg: model.Config) =
  var filename = configFilename(appName)
  var dict = newConfig()

  dict.setSectionKey("account", "login", cfg.account.login)
  dict.setSectionKey("account", "password", cfg.account.password)

  createDir(splitFile(filename).dir)
  echo &"Save config to {filename}"
  dict.writeConfig(filename)

proc read*(cfg: model.Config) =
  var filename = configFilename(appName)
  var dict: parsecfg.Config

  try:
    echo &"Read config from {filename}"
    dict = loadConfig(filename)
  except IOError: return

  cfg.account.login     = dict.getSectionValue("account", "login")
  cfg.account.password  = dict.getSectionValue("account", "password")
