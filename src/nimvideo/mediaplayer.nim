import karax / [karax, karaxdsl, vdom, kdom, compact]

proc mplayer*(id, resource: cstring): VNode {.compact.} =
  
  result = buildHtml(tdiv):
    video(id=id,controls="controls"):
      source(src=resource, `type`="video/mp4"):
        text "Your browser does not support HTML5 video."