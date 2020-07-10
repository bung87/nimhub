import karax / [karax, karaxdsl, vdom, kdom, compact]
import jsconsole
import asyncjs
# import jsffi
const
  Play = 0


proc paused(n: Node): bool {.importcpp: "#.paused".}
proc play(n: Node) {.importcpp.}
proc pause(n: Node) {.importcpp.}
proc `width=`(n: Node, w: int) {.importcpp: "#.width = #".}

proc mplayer*(id, resource: cstring): VNode {.compact.} =
  
  result = buildHtml(tdiv):
    video(id=id,controls="controls"):
      source(src=resource, `type`="video/mp4"):
        text "Your browser does not support HTML5 video."