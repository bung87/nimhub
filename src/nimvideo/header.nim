include karax / prelude
import karax/[kdom,vdom,vstyles]
import ./autocomplete
import jsconsole
import ./najax
import jsffi except `&`

proc theader*():VNode =
  
  var onSelect = proc (s: cstring) = echo "now "

  var searchBox = buildHtml(input(type="text",class="pure-input-rounded",autocomplete="off"))
  var autocompleteRef = AutocompleteComponent()
 
  proc cb(httpStatus: int; response: cstring) =
    var data = fromJSON[seq[JsObject] ] response
    for item in data:
      autocompleteRef.choices.add item.show.name
    autocompleteRef.markDirty()
    redraw()

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
        autocomplete(searchBox, onSelect,nref=autocompleteRef)
        ul(class="pure-menu-list"):
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link"):
              text "Blog"
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link"):
              text "Blog"
      tdiv(class="menu-fade")