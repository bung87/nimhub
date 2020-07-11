import karax / [karax, karaxdsl, vdom, kdom,vstyles, compact]
import ./autocomplete
import jsconsole

proc theader*():VNode {.compact.} =
  const suggestions = @[cstring"ActionScript",
    "AppleScript",
    "Asp",
    "BASIC",
    "C",
    "C++",
    "Clojure",
    "COBOL",
    "Erlang",
    "Fortran",
    "Groovy",
    "Haskell",
    "Java",
    "JavaScript",
    "Lisp",
    "Nim",
    "Perl",
    "PHP",
    "Python",
    "Ruby",
    "Scala",
    "Scheme"]
  var s = newAutocomplete(suggestions)
  
  var onSelect = proc (s: cstring) = echo "now "
  var searchBox = buildHtml(input(type="text",class="pure-input-rounded",autocomplete="off"))
  var autocompleteRef = autocomplete(s,searchBox, onSelect)

  proc onkeyuplater(ev: kdom.Event; n: VNode) =
    console.log autocompleteRef.dom.parentNode
  
  searchBox.addEventListener(EventKind.onkeyuplater,onkeyuplater )
  let style1 = style(
    (StyleAttr.overflowy, cstring"visible"),

  )
  result = buildHtml(header(class="site-header")):
    nav(class="pure-menu pure-menu-horizontal pure-menu-scrollable",style = style1):
      tdiv(class="nav-content",style = style1):
        a(href="/",class="pure-menu-heading pure-menu-link site-logo-container"):
          img(class="site-logo",src="/images/logo.svg",height="28",alt="Nim")
        # input(type="text",class="pure-input-rounded")
        autocompleteRef
        ul(class="pure-menu-list"):
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link"):
              text "Blog"
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link"):
              text "Blog"
      tdiv(class="menu-fade")