include karax / prelude
import nimvideo/header
import nimvideo/carousel
import nimvideo/mediaplayer

const url = "https://videos.ctfassets.net/b4k16c7lw5ut/zjYyNNL2B4P1jfhmAnwcv/e5805a1615e68abd4384827ae323bcf1/Hero_Video.mp4"


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