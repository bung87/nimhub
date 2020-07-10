# Package

version       = "0.1.0"
author        = "bung87"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"



# Dependencies

requires "nim >= 1.3.5"
requires "karax"

task watch,"watch":
  exec "nim c -r src/watch.nim"
  