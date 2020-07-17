# Package

version       = "0.1.0"
author        = "bung87"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"



# Dependencies

requires "nim >= 1.3.5"
requires "https://github.com/bung87/karax#static_server"


task watch,"watch":
  exec "karun -r -w --css:src/css.html src/nimvideo.nim"
