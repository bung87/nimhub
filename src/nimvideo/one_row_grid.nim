import karax / [karax, karaxdsl, vdom, kdom, compact,reactive]
import jsffi
import jsconsole

type OneRowGrid* = ref object of VComponent
  data*:RSeq[JsObject]

proc render(x: VComponent):VNode =
  let self = OneRowGrid(x)
  result = buildHtml(tdiv(class="pure-g")):
    if self.data.len > 0:
      for i in countup(0,5):
        tdiv(class="pure-u-4-24"):
          a(href=self.data[i].url.to(cstring)):
            img(class="pure-img",src=self.data[i].image.to(cstring))
    else:
      tdiv()

proc oneRowGrid*(nref:var OneRowGrid): OneRowGrid =
  nref = newComponent(OneRowGrid, render)
  nref.data = newRSeq[JsObject]()
  nref