include karax / prelude
import nimvideo/header
import nimvideo/carousel

proc createDom(): VNode =
  result = buildHtml(tdiv):
    theader()
    carousel()

setRenderer createDom