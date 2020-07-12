# import karax, karaxdsl, vdom, kdom, jstrutils

import karax / [karax, karaxdsl, vdom, kdom, jstrutils,vstyles]
import jsffi except `&`
import jsconsole
import future
import ./najax

type AutocompleteComponent* = ref object of VComponent
  inp*:VNode

proc pos(ev: Event; n: VNode) = discard
  # document.getElementById("resultList").style.display = cstring"block"
  # document.getElementById("resultList").style.width = cstring cast[JsObject](result.dom).getBoundingClientRect().width.to(cstring) & "px"
  # document.getElementById("resultList").style.left = cstring cast[JsObject](result.dom).getBoundingClientRect().left.to(cstring) & "px"
  # document.getElementById("resultList").style.top = cstring cast[JsObject](result.dom.parentNode).getBoundingClientRect().height.to(cstring) & "px"
  # inp.removeEventListener(EventKind.onfocus,pos )


proc autocomplete*(choices: seq[JsObject]; inp:var VNode;onselection: proc(s: cstring)):  AutocompleteComponent =
  proc render(x: VComponent): VNode  =
    let self = AutocompleteComponent(x)
    console.log 233,self
    proc onblur(ev: Event; n: VNode) = 
      document.getElementById("resultList").style.display = "none"
    self.inp.addEventListener(EventKind.onfocus,pos )
    self.inp.addEventListener(EventKind.onblur,onblur )
    
    
    let style = style(
      (StyleAttr.display, cstring"inline-block"),
    )

    let style1 = style(
      (StyleAttr.position, cstring"fixed"),
    
      (StyleAttr.display, cstring"none"),
    )
    
    let noFloat = style(
      (StyleAttr.cssFloat, cstring"none"),
      (StyleAttr.width, cstring"100%"),
      (StyleAttr.display, cstring"block"),
    )
    let bg = style(
      (StyleAttr.background, cstring"#222222e3"),
    )

    result = buildHtml(span(style=style)):
      self.inp
      tdiv(style=style1,id="resultList"):
        tdiv(class="pure-menu"):
          ul(class="pure-menu-list",style=noFloat.merge(bg)):
            for name in choices:
              li(class="pure-menu-item",style=noFloat):
                a(class = "pure-menu-link"):
                  text name.to(cstring)
          
  result = newComponent(AutocompleteComponent, render)
  result.inp = inp
  
