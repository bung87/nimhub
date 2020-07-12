include karax / prelude
import karax/[kdom,vdom,vstyles]
import ./autocomplete
import jsconsole
import ./najax
import jsffi except `&`

type Thead* = ref object of VComponent

proc render(x:VComponent):VNode = 
  let self = Thead(x)
  var onSelect = proc (s: cstring) = echo "now "
  var choices = @[toJs"1111",toJs"22222"]
  var searchBox = buildHtml(input(type="text",class="pure-input-rounded",autocomplete="off"))
  var autoRef = autocomplete(choices,searchBox, onSelect)
  proc cb(httpStatus: int; response: cstring) =
    var data = fromJSON[seq[JsObject] ] response
    for item in data:
      choices.add item.show.name
    autoRef.markDirty()
    redraw()
    console.log "cb"

  proc onkeyuplater(ev: kdom.Event; n: VNode) =
    ajax(cstring"get",cstring"http://api.tvmaze.com/search/shows?" & cstring"q=" & n.dom.value,cb)
    
  searchBox.addEventListener(EventKind.onkeyuplater,onkeyuplater )
  let style1 = style(
    (StyleAttr.overflowy, cstring"visible"),
  )
  result = buildHtml(header(class="site-header")):
    nav(class="pure-menu pure-menu-horizontal pure-menu-scrollable",style = style1):
      tdiv(class="nav-content",style = style1):
        a(href="/",class="pure-menu-heading pure-menu-link site-logo-container"):
          img(class="site-logo",src="/images/logo.svg",height="28",alt="Nim")
        autoRef
        ul(class="pure-menu-list"):
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link"):
              text "Blog"
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link"):
              text "Blog"
      tdiv(class="menu-fade")

proc theader*():Thead =
  result = newComponent(Thead, render)
  