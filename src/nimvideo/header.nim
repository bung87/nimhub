import karax / [karax, karaxdsl, vdom, kdom, compact]

proc theader*():VNode {.compact.} =
  result = buildHtml(header):
    nav(class="pure-menu pure-menu-horizontal pure-menu-scrollable"):
      tdiv(class="nav-content"):
        a(href="/",class="pure-menu-heading pure-menu-link site-logo-container"):
          img(class="site-logo",src="src/assets/images/logo.svg",height="28",alt="Nim")
        ul(class="pure-menu-list"):
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link "):
              text "Blog"
          li(class="pure-menu-item"):
            a(href="/blog.html",class="pure-menu-link "):
              text "Blog"