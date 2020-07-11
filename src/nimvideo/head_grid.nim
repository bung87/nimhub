import karax / [karax, karaxdsl, vdom, kdom, compact]
import jsffi
import jsconsole

type HeadGrid* = ref object of VComponent
  data*:seq[JsObject]

proc render(x: VComponent):VNode =
  let self = HeadGrid(x)
  result = buildHtml(tdiv(class="pure-g")):
    if self.data.len > 0:
      tdiv(class="pure-u-8-24"):
        img(class="pure-img",src=self.data[0].image.to(cstring) )
      for i in countup(1,8,2):
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src=self.data[i].image.to(cstring))
          img(class="pure-img",src=self.data[i+1].image.to(cstring))


proc headGrid*(nref:var HeadGrid): HeadGrid =
  nref = newComponent(HeadGrid, render)
  nref 