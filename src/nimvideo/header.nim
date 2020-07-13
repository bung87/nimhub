include karax / prelude
import karax/[kdom,vdom,vstyles,reactive]
import ./autocomplete
import jsconsole
import ./najax
import jsffi except `&`

type Thead* = ref object of VComponent
  searchBox*:VNode
  

var onSelect = proc (s: cstring) = echo "now "
var autoRef=AutocompleteComponent()

proc render(x:VComponent):VNode = 
  let self = Thead(x)
  let style1 = style(
    (StyleAttr.overflowy, cstring"visible"),
  )
  result = buildHtml(header(class="site-header")):
    nav(class="pure-menu pure-menu-horizontal pure-menu-scrollable",style = style1):
      tdiv(class="nav-content",style = style1):
        a(href="/",class="pure-menu-heading pure-menu-link site-logo-container"):
          img(class="site-logo",src="/images/logo.svg",height="28",alt="Nim")
        autocomplete(self.searchBox, onSelect,nref=autoRef)
        ul(class="pure-menu-list"):
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link"):
              text "Blog"
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link"):
              text "Blog"
      tdiv(class="menu-fade")

proc onAttach(x:VComponent) = 
  console.log "onAttach"
  let self = Thead(x)
  proc cb(httpStatus: int; response: cstring) =
    var data = fromJSON[seq[JsObject] ] response
    console.log data
    var i = 0

    while i < autoRef.choices.len:
      try:
        autoRef.choices.delete(i)
      except:
        discard
      inc i

    var j = 0
    while j < data.len:
      autoRef.choices.add(data[j].show.name)
      console.log  555,data[j].show.name
      inc j
    # autoRef.runDiff()
    console.log "abc"
    autoRef.markDirty()
    redraw(kxi)


  proc onkeyuplater(ev: kdom.Event; n: VNode) =
    console.log ev,n
    ajax(cstring"get",cstring"http://api.tvmaze.com/search/shows?" & cstring"q=" & ev.target.value,cb)
  self.searchBox = buildHtml(input(type="text",class="pure-input-rounded",autocomplete="off"))
  self.searchBox.addEventListener(EventKind.onkeyuplater,onkeyuplater )


proc theader*():Thead =
  result = newComponent(Thead, render,onAttach)
  