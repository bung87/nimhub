import karax / [karax, karaxdsl, vdom, kdom, compact,reactive]
import jsffi
import jsconsole

type TwoRowGrid* = ref object of VComponent
  data*:RSeq[JsObject]

proc renderItem(x: TwoRowGrid,i:int):VNode = 
  result = buildHtml(tdiv(class="pure-u-4-24")):
    img(class="pure-img",src=x.data[i].image.to(cstring))
    img(class="pure-img",src=x.data[i+1].image.to(cstring))

proc render*(x: VComponent):VNode =
  let self = TwoRowGrid(x)
  result = buildHtml(tdiv(class="pure-g")):
    if self.data.len > 0:
      for i in countup(0,11,2):
        renderItem(self,i)
    else:
      tdiv()

proc twoRowGrid*(nref:var TwoRowGrid): TwoRowGrid =
  nref = newComponent(TwoRowGrid, render)
  nref.data = newRSeq[JsObject]()
  nref