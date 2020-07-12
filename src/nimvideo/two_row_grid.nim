import karax / [karax, karaxdsl, vdom, kdom, compact]
import jsffi
import jsconsole

type TwoRowGrid* = ref object of VComponent
  data*:seq[JsObject]

proc render(x: VComponent):VNode =
  let self = TwoRowGrid(x)
  result = buildHtml(tdiv(class="pure-g")):
    if self.data.len > 0:
      for i in countup(0,11,2):
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src=self.data[i].image.to(cstring))
          img(class="pure-img",src=self.data[i+1].image.to(cstring))
    else:
      tdiv()

proc twoRowGrid*(nref:var TwoRowGrid): TwoRowGrid =
  nref = newComponent(TwoRowGrid, render)
  nref 