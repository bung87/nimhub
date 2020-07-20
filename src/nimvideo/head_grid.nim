import karax / [karax, karaxdsl, vdom, kdom, compact]
import jsffi
import jsconsole
import ./video
type HeadGrid* = ref object of VComponent
  data*:seq[JsObject]

    
proc render(x: VComponent):VNode =
  let self = HeadGrid(x)
  result = buildHtml(tdiv(class="pure-g stretch")):
    if self.data.len > 0:
      tdiv(class="pure-u-8-24 "):
        renderVideo(self.data[0])
      for i in countup(1,8,2):
        tdiv(class="pure-u-4-24 half"):
          renderVideo(self.data[i])
          renderVideo(self.data[i+1])
    else:
      tdiv()


proc headGrid*(nref:var HeadGrid): HeadGrid =
  if nref == nil:
    nref = newComponent(HeadGrid, render)
    nref.data = newSeq[JsObject]()
    nref
  else:
    nref