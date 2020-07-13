# import karax, karaxdsl, vdom, kdom, jstrutils

import karax / [karax, karaxdsl, vdom, kdom, jstrutils,vstyles,reactive]
import jsffi except `&`
import jsconsole
import future
import ./najax

type AutocompleteComponent* = ref object of VComponent
  inp*:VNode
  choices*: RSeq[JsObject]

let noFloat = style(
  (StyleAttr.cssFloat, cstring"none"),
  (StyleAttr.width, cstring"100%"),
  (StyleAttr.display, cstring"block"),
)
proc renderItem(item: JsObject): VNode {.track.} =

  result = buildHtml(li(class="pure-menu-item",style=noFloat)):
    a(class = "pure-menu-link"):
      text item.to(cstring)

proc render(x: VComponent): VNode  =
  
  let self = AutocompleteComponent(x)
  
  let style = style(
    (StyleAttr.display, cstring"inline-block"),
  )

  let style1 = style(
    (StyleAttr.position, cstring"fixed"),
    (StyleAttr.display, cstring"none"),
  )
  
 
  let bg = style(
    (StyleAttr.background, cstring"#222222e3"),
  )

  result = buildHtml(span(style=style)):
    self.inp
    tdiv(style=style1,id="resultList"):
      tdiv(class="pure-menu"):
        vmapIt(self.choices, ul(class="pure-menu-list",style=noFloat.merge(bg)), renderItem(it))
        # ul(class="pure-menu-list",style=noFloat.merge(bg)):
        #   for index,item in self.choices:
        #     li(class="pure-menu-item",style=noFloat,id= $index):
        #       renderItem(item)
        #   # vmapIt(self.choices, li(class="pure-menu-item",style=noFloat), renderItem(it))

proc runDiff*(self:AutocompleteComponent) = 
  runDiff(kxi,self.expanded,render(self))

proc onAttach(x:VComponent) = 
  let self = AutocompleteComponent(x)
  
  
  proc pos(ev: Event; n: VNode) = 
    document.getElementById("resultList").style.display = cstring"block"
    document.getElementById("resultList").style.width = cstring cast[JsObject](self.dom).getBoundingClientRect().width.to(cstring) & "px"
    document.getElementById("resultList").style.left = cstring cast[JsObject](self.dom).getBoundingClientRect().left.to(cstring) & "px"
    document.getElementById("resultList").style.top = cstring cast[JsObject](self.dom.parentNode).getBoundingClientRect().height.to(cstring) & "px"

  proc onblur(ev: Event; n: VNode) = 
    document.getElementById("resultList").style.display = "none"

  self.inp.addEventListener(EventKind.onfocus,pos )
  self.inp.addEventListener(EventKind.onblur,onblur )


proc autocomplete*(inp: var VNode;onselection: proc(s: cstring),nref:var AutocompleteComponent): AutocompleteComponent =
  
  # inp.removeEventListener(EventKind.onfocus,pos )
  nref = newComponent(AutocompleteComponent, render,onAttach)
  nref.inp = inp
  nref.choices = newRSeq[JsObject]()
  nref
 

