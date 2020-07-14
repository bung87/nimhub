include karax / prelude
import karax/[kdom,vdom,vstyles,reactive]
import ./autocomplete
import jsconsole
import ./najax
import jsffi except `&`

type Thead* = ref object of VComponent
  searchBox*:VNode
  autoRef*:AutocompleteComponent

var onSelect = proc (s: cstring) = echo "now "


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
        autocomplete(self.searchBox, onSelect,nref=self.autoRef)
        ul(class="pure-menu-list"):
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link"):
              text "Blog"
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link"):
              text "Blog"
      tdiv(class="menu-fade")

proc onAttach(x:VComponent) = 
  let self = Thead(x)
  proc cb(httpStatus: int; response: cstring) =
    var data = fromJSON[seq[JsObject] ] response
    self.autoRef.choices.setLen 0

    for item in data:
      self.autoRef.choices.add( item.show.name)
    self.autoRef.runDiff()


  proc onkeyuplater(ev: kdom.Event; n: VNode) =
    ajax(cstring"get",cstring"http://api.tvmaze.com/search/shows?" & cstring"q=" & ev.target.value,cb)
  self.searchBox = buildHtml(input(type="text",class="pure-input-rounded",autocomplete="off"))
  self.searchBox.addEventListener(EventKind.onkeyuplater,onkeyuplater )

proc onDetach(x:VComponent) = 
  let self = Thead(x)

proc theader*():Thead =
  result = newComponent(Thead, render,onAttach,onDetach)
  