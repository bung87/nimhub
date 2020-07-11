
import os, strutils, browsers,times, tables 
import osproc
import jester

const html = """
<!DOCTYPE html>
<html>
<head>
  <meta content="width=device-width, initial-scale=1" name="viewport" />
  <title>$1</title>
  $2
</head>
<body id="body" class="site">
<div id="ROOT" />
<script type="text/javascript" src="/app.js"></script>
</body>
</html>
"""

const name = "nimvideo"

# <link rel="stylesheet" href="src/assets/styles/normalize.css">
# <link rel="stylesheet" href="src/assets/styles/skeletal.css">
const selectedCss = """
<link rel="stylesheet" href="/styles/pure.min.css">
<link rel="stylesheet" href="/styles/pure-grids-responsive.min.css">
<link rel="stylesheet" href="/styles/main.css">
<link rel="stylesheet" href="/styles/carousel.css">
"""

proc build(name: string, selectedCss: string, run: bool) =
  echo("Building...")
  discard execCmd("nim js -d:release --out:" & name & ".js " & "src/" & name & ".nim")
  let dest = name & ".html"
  writeFile(dest, html % [name, selectedCss])
  if run: openDefaultBrowser("http://localhost:5000")

proc watchBuild(){.thread.} = 
  var files: Table[string, Time] = {"path": getLastModificationTime(".")}.toTable
  while true:
    sleep(300)
    for path in walkDirRec("."):
      if ".git" in path:
        continue

      if files.hasKey(path):
        if files[path] != getLastModificationTime(path):
          echo("File changed: " & path)
          echo path,absolutePath(name & ".html")
          build(name,  selectedCss, true)
          files[path] = getLastModificationTime(path)
      else:
        if absolutePath(path) in [absolutePath(name & ".js"),absolutePath(name & ".html")]:
          continue
        files[path] = getLastModificationTime(path)

const js = name & ".js"
proc serve(){.thread.} =
  settings:
    # port = Port(5454)
    # appName = "/foo"
    # bindAddr = "127.0.0.1"
    staticDir = "./src/assets"

  routes:
    get "/":
      resp readFile(name & ".html")
    get "/app.js":
      resp readFile(name & ".js")

when isMainModule:
  {.experimental.}
  import threadpool
  parallel:
    spawn serve()
    spawn watchBuild()
    build(name,  selectedCss, true)
  