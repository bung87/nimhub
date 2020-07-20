import karax / [karax, karaxdsl, vdom, kdom, compact]
import jsffi

proc renderVideoInfo(data:JsObject):VNode =
  result = buildHtml(tdiv(class="video-card-info")):
    p:
      text data.name.to(cstring)
    p:
      text data.genres.to(cstring)
    p:
      text data.premiered.to(cstring)
    p:
      text data.rating.average.to(cstring)

proc renderVideo*(item:JsObject):VNode =
  result = buildHtml(tdiv(class="video-card")):
    a(href=item.url.to(cstring) ):
      img(class="pure-img",src=item.image.to(cstring) )
    renderVideoInfo(item)