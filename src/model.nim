
type Account* = object
  login*: string
  password*: string

type View* = ref object
  account*: Account
  login*: bool
  login_progress*: bool
