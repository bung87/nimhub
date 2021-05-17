import pkg/htmlparser
import pkg/htmlparser / xmltree
import macros,std/streams,os,uri,strutils,strtabs
import dotenv

let env = initDotEnv(currentSourcePath.parentDir, "static.env")
env.load()
let staticDir =  getEnv("staticDir") 
let publicUrl = getEnv("publicUrl") 

var s = newFileStream(currentSourcePath.parentDir / "app.html" )
var html = parseHtml(s)
var head = html.child("html").child("head")
# delete()
for x in head.mitems:
  if x.kind == xnElement:
    if x.tag == "link":
      let href  = x.attr("href")
      let u = parseUri(href)
      if u.scheme.len == 0:
        let nu = (normalizedPath("/" & u.path)).replace(parseUri("/" & publicUrl).path,staticDir)
        var attrs = x.attrs
        attrs["href"] = normalizedPath(nu)
        x.attrs = attrs
var body =  html.child("html").child("body")
var l = body.len - 1
while l != 0:
  var x = body[l]
  if x.kind == xnElement:
    if x.tag == "script":
      let src  = x.attr("src")
      if src.len == 0:
        delete(body,l)
  dec l
  
for x in body.mitems:
  if x.kind == xnElement:
    if x.tag == "script":
      let src  = x.attr("src")
      if src.len > 0:
        let u = parseUri(src)
        if u.scheme.len == 0:
          var nu = u.path
          removePrefix(nu,"/")
          var attrs = x.attrs
          attrs["src"] = normalizedPath(nu)
          x.attrs = attrs

createDir(currentSourcePath.parentDir / "ghpage")
copyFile(currentSourcePath.parentDir / "app.js" , currentSourcePath.parentDir / "ghpage" / "app.js")
copyDir(currentSourcePath.parentDir / staticDir , currentSourcePath.parentDir / "ghpage" / staticDir)
writeFile(currentSourcePath.parentDir / "ghpage" / "index.html",$html.child("html"))

