
import os, strutils, browsers,times, tables 
import osproc

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
<script type="text/javascript" src="$1.js"></script>
</body>
</html>
"""

const name = "nimvideo"

# <link rel="stylesheet" href="src/assets/styles/normalize.css">
# <link rel="stylesheet" href="src/assets/styles/skeletal.css">
const selectedCss = """
<link rel="stylesheet" href="src/assets/styles/pure.min.css">
<link rel="stylesheet" href="src/assets/styles/pure-grids-responsive.min.css">
<link rel="stylesheet" href="src/assets/styles/main.css">
<link rel="stylesheet" href="src/assets/styles/carousel.css">
"""




proc build(name: string, selectedCss: string, run: bool) =
  echo("Building...")
  discard execCmd("nim js --out:" & name & ".js " & "src/" & name & ".nim")
  let dest = name & ".html"
  writeFile(dest, html % [name, selectedCss])
  if run: openDefaultBrowser(dest)


when isMainModule:
  build(name,  selectedCss, true)
  var files: Table[string, Time] = {"path": getLastModificationTime(".")}.toTable
  while true:
      sleep(300)
      for path in walkDirRec("."):
        if ".git" in path:
          continue
        if files.hasKey(path):
          if files[path] != getLastModificationTime(path):
            echo("File changed: " & path)
            build(name,  selectedCss, true)
            files[path] = getLastModificationTime(path)
        else:
          files[path] = getLastModificationTime(path)