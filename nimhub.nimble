# Package

version       = "0.1.0"
author        = "bung87"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"



# Dependencies

requires "nim >= 1.3.5"
requires "karax"
requires "https://github.com/bung87/web_preprocessor"
requires "https://github.com/bung87/htmlparser"
requires "dotenv >= 1.1.0"

task watch,"watch":
  exec "karun -r -w --css:src/css.html src/nimhub.nim"
task preprocess,"preprocess":
  exec "web_preprocessor -s src/assets -d dest/assets"

task ghpage,"gh page":
  exec "karun --css:src/css.html src/nimhub.nim"
  exec "nim c -r buildgh.nim"
  cd "ghpage" 
  exec "git init"
  exec "git add ."
  exec "git config user.name \"bung87\""
  exec "git config user.email \"crc32@qq.com\""
  exec "git commit -m \"docs(docs): update gh-pages\" -n"
  let url = "\"https://bung87@github.com/bung87/nimhub.git\""
  exec "git push --force --quiet " & url & " master:gh-pages"