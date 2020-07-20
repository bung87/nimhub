import karax / [karax, karaxdsl, vdom, kdom, compact]
import jsffi
import jsconsole
import ./video

type TwoRowGrid* = ref object of VComponent
  data*:seq[JsObject]

proc renderItem(x: TwoRowGrid,i:int):VNode = 
  result = buildHtml(tdiv(class="pure-u-4-24")):
    renderVideo(x.data[i])
    renderVideo(x.data[i + 1])

proc render*(x: VComponent):VNode =
  let self = TwoRowGrid(x)
  result = buildHtml(tdiv(class="pure-g stretch")):
    if self.data.len > 0:
      for i in countup(0,11,2):
        renderItem(self,i)
    else:
      tdiv()

proc twoRowGrid*(nref:var TwoRowGrid): TwoRowGrid =
  if nref == nil:
    nref = newComponent(TwoRowGrid, render)
    nref.data = newSeq[JsObject]()
    nref
  else:
    nref