{.experimental: "codeReordering".}
include karax / prelude
import nimvideo/header
import nimvideo/carousel
import nimvideo/mediaplayer
import jsconsole
import nimvideo/najax
import jsffi
import nimvideo/head_grid
import nimvideo/two_row_grid
import nimvideo/one_row_grid
import karax / [kdom]

const url = "https://videos.ctfassets.net/b4k16c7lw5ut/zjYyNNL2B4P1jfhmAnwcv/e5805a1615e68abd4384827ae323bcf1/Hero_Video.mp4"


proc replaceById*(id: cstring = "ROOT";newTree: VNode; ) =
  let x = getElementById(id)
  newTree.id = id
  x.parentNode.replaceChild(newTree.toDom true, x)

proc setWindowOnload(h: EventHandler) {.importcpp: "window.onload = #".}
proc setInitializer*(initializer: proc (data: RouterData): VNode;
                     root: cstring = "ROOT") =
  var onhashChange {.importc: "window.onhashchange".}: proc()
  var hashPart {.importc: "window.location.hash".}: cstring

  onhashchange = proc () =
    replaceById root, initializer(RouterData(hashPart:hashPart) )

var refA:HeadGrid
var refB:TwoRowGrid
var refC:OneRowGrid
var refCarousel:Carousel
var refHead:Thead

proc post (routerData: RouterData)  =
  proc cb(r:XMLHttpRequest) =
    var data = fromJSON[seq[JsObject] ] r.response
    for index,item in data:
      var obj = newJsObject()
      if index != 0:
        obj.image = item.image.medium
        obj.name = item.name
        obj.url = toJs "/#/video"
      else:
        obj.image = item.image.original
        obj.name = item.name
        obj.url = toJs "/#/video"
      obj.genres = item.genres
      obj.premiered = item.premiered
      obj.rating = item.rating
      refA.data.add obj
      refB.data.add obj
      refC.data.add obj
      if refCarousel != nil:
        refCarousel.data.add obj
        refCarousel.markDirty()
    refA.markDirty()
    refB.markDirty()
    refC.markDirty()
    console.log data
    
    redraw()
  if routerData.hashPart == "":
    ajax(cstring"get",cstring"http://api.tvmaze.com/shows").then cb


proc createDom(data: RouterData): VNode =
  result = buildHtml(tdiv):
    theader(nref = refHead)
    if data.hashPart == "#/video":
      tdiv(class="content"):
        tdiv(class="pure-g"):
          tdiv(class="pure-u-18-24"):
            mplayer(cstring"vid2", url)
          tdiv(class="pure-u-6-24")
    else:
      carousel(nref = refCarousel)
      tdiv(class="content"):
        h2:
          text "h2"
        headGrid(nref = refA)
        h2:
          text "h2"
        twoRowGrid(nref = refB)
        h2:
          text "h2"
        oneRowGrid(nref = refC)
    footer:
      section(class="content"):
        tdiv(class="pure-g"):
          tdiv(class="copyright pure-u-2-3"):
            p:
              text "This website proudly writing in "
              a(href="https://nim-lang.org/"):
                text "Nim"
              text " (Nim is a statically typed compiled systems programming language.) "
              text " and source code is available on "
              a(href="#"):
                text "GitHub"
              text " and contributions are welcome."
 

when isMainModule:
  setRenderer createDom,clientPostRenderCallback=post
  setInitializer proc(data: RouterData):VNode =
    result = createDom(data )

