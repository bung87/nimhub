import karax / [karax, karaxdsl, vdom, kdom, compact,reactive]
import jsffi
import jsconsole

type HeadGrid* = ref object of VComponent
  data*:RSeq[JsObject]

proc render(x: VComponent):VNode =
  let self = HeadGrid(x)
  result = buildHtml(tdiv(class="pure-g stretch")):
    if self.data.len > 0:
      tdiv(class="pure-u-8-24 "):
        a(href=self.data[0].url.to(cstring) ):
          img(class="pure-img",src=self.data[0].image.to(cstring) )
      for i in countup(1,8,2):
        tdiv(class="pure-u-4-24"):
          a(href=self.data[i].url.to(cstring) ):
            img(class="pure-img half",src=self.data[i].image.to(cstring))
          a(href=self.data[i+1].url.to(cstring) ):
            img(class="pure-img half",src=self.data[i+1].image.to(cstring))
    else:
      tdiv()


proc headGrid*(nref:var HeadGrid): HeadGrid =
  nref = newComponent(HeadGrid, render)
  nref.data = newRSeq[JsObject]()
  nref