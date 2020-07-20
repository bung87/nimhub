
import karax/[kbase,vdom,jstrutils]
import jsconsole
import jsffi 
type RegExp* {.importc.} = JsObject
proc newRegExp*(r:cstring): RegExp {.importcpp: "new RegExp(#)".}
proc newRegExp*(r:cstring,m:cstring): RegExp {.importcpp: "new RegExp(#,#)".}

proc split*(s:cstring, sep: RegExp): seq[cstring] {.importcpp, nodecl.}
proc replace*(s:cstring, r: RegExp,to:cstring): cstring {.importcpp, nodecl.}
proc replace*(s:cstring, r: cstring,to:cstring): cstring {.importcpp, nodecl.}

proc hasClass*(obj:VNode, cls:string):bool = 
  if obj.class == nil:return false
  var origin = obj.class
  var clsList = origin.split(newRegExp(cstring"\s+",cstring"g") )
  for x in clsList:
    if(x == cstring cls):
      return true
  return false

proc addClass*(e:VNode,cls:string) = 
  if e.class == kstring"" or e.class == nil:
    e.class = kstring(cls)
  else:
    if not e.hasClass(cls):
      let pre = $e.class & " "
      e.class = kstring pre & cls

proc removeClass*(e:VNode,cls:string) = 
  var origin = " " & $e.class & " "
  var norm = origin.replace(newRegExp(cstring"(\s+)",cstring"g"), cstring" " )
  var removed = norm.replace(cstring " " & cls & " ", cstring" ")
  var replaced = removed.replace(newRegExp cstring"(^\s+)|(\s+$)", cstring"")
  e.class = replaced

proc getVNodeByClass*(n: VNode; cls: string): VNode =
  if n.hasClass(cls): return n
  for i in 0..<n.len:
    result = getVNodeByClass(n[i], cls)
    if result != nil: return result



