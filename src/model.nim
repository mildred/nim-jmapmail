import jmap/transport

type
  Config* = ref object
    account*: ConfigAccount

  ConfigAccount* = object of RootObj
    login*: string
    password*: string

  Account* = ref object of ConfigAccount
    transport*: Transport

  View* = ref object
    config*: Config
    account*: Account
    login*: bool
    login_progress*: bool
