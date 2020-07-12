# import karax, karaxdsl, vdom, kdom, jstrutils

import karax / [karax, karaxdsl, vdom, kdom, jstrutils,vstyles]
import jsffi except `&`
import jsconsole
import future


type AutocompleteComponent* = ref object of VComponent
  # state*:AutocompleteState
  choices*:seq[JsObject]
  inp*:VNode

# proc newAutocomplete*(choices:var seq[JsObject]; maxMatches = 5): AutocompleteState =
#   ## Creates a new state for the autocomplete widget. ``maxMatches`` is the maximum
#   ## number of elements to show.

#   AutocompleteState(choices: choices, candidates: @[],
#     selected: -1, maxMatches: maxMatches, showCandidates: false,
#     controlPressed: false)

proc render(x: VComponent): VNode  =
  let self = AutocompleteComponent(x)
  console.log 233,self
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
          for name in self.choices:
            li(class="pure-menu-item",style=noFloat):
              a(class = "pure-menu-link"):
                text name.to(cstring)
       
                
proc autocomplete*( inp:var VNode;onselection: proc(s: cstring),nref:var AutocompleteComponent):  AutocompleteComponent =

  proc pos(ev: Event; n: VNode) =
    document.getElementById("resultList").style.display = cstring"block"
    document.getElementById("resultList").style.width = cstring cast[JsObject](nref.dom).getBoundingClientRect().width.to(cstring) & "px"
    document.getElementById("resultList").style.left = cstring cast[JsObject](nref.dom).getBoundingClientRect().left.to(cstring) & "px"
    document.getElementById("resultList").style.top = cstring cast[JsObject](nref.dom.parentNode).getBoundingClientRect().height.to(cstring) & "px"
    # inp.removeEventListener(EventKind.onfocus,pos )
 
  proc onblur(ev: Event; n: VNode) = 
    document.getElementById("resultList").style.display = "none"
  inp.addEventListener(EventKind.onfocus,pos )
  inp.addEventListener(EventKind.onblur,onblur )
  nref = newComponent(AutocompleteComponent, render)
  # nref.choices = s
  nref.inp = inp
  nref
