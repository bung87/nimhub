{.experimental: "codeReordering".}
include karax / prelude
import nimvideo/header
import nimvideo/carousel
import nimvideo/mediaplayer
import jsconsole
import nimvideo/najax
import asyncjs
import jsffi
import nimvideo/head_grid
import nimvideo/two_row_grid
import nimvideo/one_row_grid
import karax / [reactive,kdom]
import future
const url = "https://videos.ctfassets.net/b4k16c7lw5ut/zjYyNNL2B4P1jfhmAnwcv/e5805a1615e68abd4384827ae323bcf1/Hero_Video.mp4"

# ------------------ Init handling -----------------------------------

proc replaceById*(id: cstring = "ROOT";newTree: VNode; ) =

  let x = getElementById(id)
  newTree.id = id
  x.parentNode.replaceChild(newTree.toDom true, x)

proc setWindowOnload(h: EventHandler) {.importcpp: "window.onload = #".}
proc setInitializer*(initializer: proc (data: RouterData): VNode;
                     root: cstring = "ROOT") =
  var onhashChange {.importc: "window.onhashchange".}: proc()
  var hashPart {.importc: "window.location.hash".}: cstring

  # setWindowOnload proc (ev: Event;target: VNode) =
  #   replaceById root, initializer(RouterData(hashPart:hashPart) )
  onhashchange = proc () =
    replaceById root, initializer(RouterData(hashPart:hashPart) )

# proc slice(e: JsObject, startindex: int = 0, endindex: int = e.size):JsObject{.importcpp: "#.slice(#,#)".}

var refA:HeadGrid
var refB:TwoRowGrid
var refC:OneRowGrid
var refCarousel:Carousel

proc post (routerData: RouterData)  =
  proc cb(httpStatus: int; response: cstring) =
    var data = fromJSON[seq[JsObject] ] response
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
      refA.data.add obj
      refB.data.add obj
      refC.data.add obj
      refCarousel.data.add obj
    refA.markDirty()
    refB.markDirty()
    refC.markDirty()
    console.log refC
    refCarousel.markDirty()
    redraw()
    # replaceById "ROOT",createDom(routerData )

  ajax(cstring"get",cstring"http://api.tvmaze.com/shows").then proc(r:XMLHttpRequest) =
    console.log r


proc createDom(data: RouterData): VNode =
  console.log data.hashPart
  # document.addEventListener("click", (ev: Event) => redraw())
  if data.hashPart == "":
    console.log "post"
    post(data)
  result = buildHtml(tdiv):
    theader()
    
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

when isMainModule:
  setRenderer createDom#,clientPostRenderCallback=post
  setInitializer proc(data: RouterData):VNode =
    result = createDom(data )
    
    
    # runDiff(kxi,result.expanded,result)
    
    
