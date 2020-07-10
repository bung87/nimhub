include karax / prelude
import nimvideo/header
import nimvideo/carousel

proc createDom(): VNode =
  result = buildHtml(tdiv):
    theader()
    carousel()
    tdiv(class="content"):
      h2:
        text "h2"
      tdiv(class="pure-g"):
        tdiv(class="pure-u-8-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
      h2:
        text "h2"
      tdiv(class="pure-g"):
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
      h2:
        text "h2"
      tdiv(class="pure-g"):
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")
        tdiv(class="pure-u-4-24"):
          img(class="pure-img",src="https://picsum.photos/id/106/300/300")

setRenderer createDom