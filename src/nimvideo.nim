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

const url = "https://videos.ctfassets.net/b4k16c7lw5ut/zjYyNNL2B4P1jfhmAnwcv/e5805a1615e68abd4384827ae323bcf1/Hero_Video.mp4"

# proc slice(e: JsObject, startindex: int = 0, endindex: int = e.size):JsObject{.importcpp: "#.slice(#,#)".}

var refA:HeadGrid
var refB:TwoRowGrid
var refC:OneRowGrid
var refCarousel:Carousel

proc post (data: RouterData)  =
  proc cb(httpStatus: int; response: cstring) =
    var data = fromJSON[seq[JsObject] ] response
    for index,item in data:
      var obj = newJsObject()
      if index != 0:
        obj.image = item.image.medium
        obj.name = item.name
      else:
        obj.image = item.image.original
        obj.name = item.name
      refA.data.add obj
      refB.data.add obj
      refC.data.add obj
      refCarousel.data.add obj
    refA.markDirty()
    refB.markDirty()
    refC.markDirty()
    refCarousel.markDirty()
    redraw()
   
  ajax(cstring"get",cstring"http://api.tvmaze.com/shows",cb)

proc createDom(data: RouterData): VNode =


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

setRenderer createDom,clientPostRenderCallback=post