# import karax, karaxdsl, vdom, kdom, jstrutils

import karax / [karax, karaxdsl, vdom, kdom, jstrutils,vstyles]
import jsffi except `&`
import jsconsole
import future
import ./najax

type AutocompleteComponent* = ref object of VComponent
  inp*:VNode
  choices*: seq[JsObject]
  list*:VNode

let noFloat = style(
  (StyleAttr.cssFloat, cstring"none"),
  (StyleAttr.width, cstring"100%"),
  (StyleAttr.display, cstring"block"),
)
proc renderItem(item: JsObject): VNode =

  result = buildHtml(li(class="pure-menu-item",style=noFloat)):
    a(class = "pure-menu-link"):
      text item.to(cstring)

proc myList(self:AutocompleteComponent): VNode =
  
  let bg = style(
    (StyleAttr.background, cstring"#222222e3"),
  )
  result = buildHtml:
    ul(class="pure-menu-list",style=noFloat.merge(bg)):
      for index,item in self.choices:
        li(class="pure-menu-item",style=noFloat,id= $index):
          renderItem(item)


var listStyle = style(
    (StyleAttr.position, cstring"fixed"),
    
  )

proc render(x: VComponent): VNode  =
  
  let self = AutocompleteComponent(x)
  
  let style = style(
    (StyleAttr.marginTop,cstring"17px"),
    (StyleAttr.display, cstring"inline-block"),
  )

  
  if self.choices.len > 0:
    listStyle =  listStyle.merge style( (StyleAttr.display, cstring"block"),(StyleAttr.visibility, cstring"visible") )
  else:
    
    listStyle = listStyle.merge style( (StyleAttr.display, cstring"none"),(StyleAttr.visibility, cstring"hidden") )

  self.list = myList(self)
  result = buildHtml(span(style=style)):
    self.inp
    tdiv(style=listStyle,id="resultList"):
      tdiv(class="pure-menu"):
        self.list
        # vmapIt(self.choices, ul(class="pure-menu-list",style=noFloat.merge(bg)), renderItem(it))


proc runDiff*(self:AutocompleteComponent) = 
  if self.expanded != nil:
    runDiff(kxi,self.expanded,render(self))

proc onAttach(x:VComponent) = 
  let self = AutocompleteComponent(x)
  
  proc pos(ev: Event; n: VNode) = 

    var list = getVNodeById("resultList",kxi)
    if self.choices.len > 0:
      proc resetStyle() =
        listStyle = listStyle.merge style(  (StyleAttr.display, cstring"block"),(StyleAttr.visibility, cstring"visible"), )
        list.dom.applyStyle listStyle
        listStyle = listStyle.merge style( 
          (StyleAttr.width, cstring cast[JsObject](self.dom).getBoundingClientRect().width.to(cstring) & "px"),
          (StyleAttr.left, cstring cast[JsObject](self.dom).getBoundingClientRect().left.to(cstring) & "px") ,
          (StyleAttr.top, cstring cast[JsObject](self.dom.parentNode).getBoundingClientRect().height.to(cstring) & "px") ,
        )
        list.dom.applyStyle listStyle
      discard setTimeout( resetStyle,500)
    
  proc onblur(ev: Event; n: VNode) = 
    var list = getVNodeById("resultList",kxi)
    list.style = list.style.merge style( (StyleAttr.display, cstring"none"),(StyleAttr.visibility, cstring"hidden") )
    list.dom.applyStyle  list.style
  
  self.inp.addEventListener(EventKind.onfocus,pos )
  self.inp.addEventListener(EventKind.onblur,onblur )


proc autocomplete*(inp: var VNode;nref:var AutocompleteComponent): AutocompleteComponent =
  
  # inp.removeEventListener(EventKind.onfocus,pos )
  nref = newComponent(AutocompleteComponent, render,onAttach)
  nref.inp = inp
  nref.choices = newSeq[JsObject]()
  nref
 

