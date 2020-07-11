{.experimental: "codeReordering".}
import strformat
include karax / prelude
import karax/[kdom,vdom]
import jsffi except setInterval
import jsconsole

proc querySelector(ele:any,q:cstring):Element {.importcpp:"#.querySelector(@)",nodecl.}

type Carousel* = ref object of VComponent
  classNameItem*:cstring
  carouselControlsContainer*:Vnode
  carouselControls:seq[cstring]
  controlsClassName:cstring
  textControls:seq[cstring]
  autoplay:bool
  displayControls:bool
  data*:seq[JsObject]
  autoplayTime:int


proc setInitialState*(self:Carousel) = 
  ## Assign initial css classes and attribute for each items
  var index = 0
  console.log self,"setInitialState"
  for item in self.expanded[0]:
    item.setAttr("data-index", kstring $index)
    case index
      of 0:
        cast[Element](item.dom).classList.add( fmt"{self.classNameItem}-first")
      of 1:
        cast[Element](item.dom).classList.add( fmt"{self.classNameItem}-previous")
      of 2:
        cast[Element](item.dom).classList.add( fmt"{self.classNameItem}-selected")
      of 3:
        cast[Element](item.dom).classList.add( fmt"{self.classNameItem}-next")
      of 4:
        cast[Element](item.dom).classList.add( fmt"{self.classNameItem}-last")
      else:
        discard
    inc index


proc render(x: VComponent): VNode =
  let self = Carousel(x)
  self.carouselControlsContainer = tree(VNodeKind.tdiv,attrs = @[ (kstring"class",kstring"slider__controls") ] )
  result = buildHtml(tdiv(class="slider")):
    tdiv(class="slider__inner"):
      var cls:cstring
      # power of 4
      if self.data.len > 0:
        for i in 0..7:
          case i
            of 0:
              cls = cstring fmt"{self.classNameItem}-first"
            of 1:
              cls = cstring fmt"{self.classNameItem}-previous"
            of 2:
              cls = cstring fmt"{self.classNameItem}-selected"
            of 3:
              cls = cstring fmt"{self.classNameItem}-next"
            of 4:
              cls = cstring fmt"{self.classNameItem}-last"
            else:
              discard
          tdiv(class=fmt"slider__item {cls}",data-index = $i):
            tdiv(class="slider__item-container"):
              img(class="slider__item-img",src=self.data[i].image.to(cstring))
            tdiv(class="slider__item-datas"):
              span:
                text self.data[i].name.to(cstring)
    self.carouselControlsContainer
 
  self.setControls()
  self.onTouch()
  if self.displayControls:
    self.useControls()
  var play = proc() = 
    console.log "play",self.carouselControlsContainer
    self.setCurrentState( cast[Element](self.carouselControlsContainer[1].dom), self.getCurrentState())
  if self.autoplay:
    discard window.setInterval(play,self.autoplayTime)

proc initCarousel*(self:Carousel,autoplay=true,autoplayTime = 3500,classNameItem="slider__item", displayControls=true,controlsClassName="slider__controls",carouselControls = defaultCarouselControls,textControls = defaultTextControls) = 
  self.controlsClassName = controlsClassName
  self.displayControls = displayControls
  self.carouselControls = carouselControls
  self.classNameItem = classNameItem
  self.textControls = textControls
  self.autoplay = autoplay
  self.autoplayTime = autoplayTime

proc onAttach(x: VComponent) =
  let self = Carousel(x)
  initCarousel self
  
proc carousel*(nref:var Carousel): Carousel =
  nref = newComponent(Carousel, render,onAttach)
  nref

const defaultTextControls = @[cstring"<i class='fas fa-chevron-left'></i>", cstring"<i class='fas fa-chevron-right'></i>"]
const defaultCarouselControls = @[cstring"previous",cstring"next"]



type 
  State = tuple[selectedItem: Element, previousSelectedItem: Element,nextSelectedItem:Element,firstCarouselItem:Element,lastCarouselItem:Element,downCommingCarouselItem:Element,upCommingCarouselItem:Element,downIndex:int,upIndex:int] 

proc getCurrentState*(self:Carousel): State = 
  let inner = self.expanded[0]
  defer:
    var selectedItem = inner.dom.querySelector( fmt".{self.classNameItem}-selected")
    var previousSelectedItem = inner.dom.querySelector( fmt".{self.classNameItem}-previous")
    var nextSelectedItem = inner.dom.querySelector( fmt".{self.classNameItem}-next")
    var firstCarouselItem = inner.dom.querySelector( fmt".{self.classNameItem}-first")
    var lastCarouselItem = inner.dom.querySelector( fmt".{self.classNameItem}-last")
    var indexLastCarouselItem = parseInt(lastCarouselItem.getAttribute(cstring"data-index"))
    var indexFirstCarouselItem = parseInt(firstCarouselItem.getAttribute(cstring"data-index"))
    var downIndex = indexFirstCarouselItem - 1
    var upIndex = indexLastCarouselItem + 1
    var downCommingCarouselItem = inner.dom.querySelector(fmt".{self.classNameItem}[data-index='{downIndex}']")
    var upCommingCarouselItem = inner.dom.querySelector(fmt".{self.classNameItem}[data-index='{upIndex}']")
    return (selectedItem,previousSelectedItem,nextSelectedItem,firstCarouselItem,lastCarouselItem,downCommingCarouselItem,upCommingCarouselItem,downIndex,upIndex)



proc setControls*(self:Carousel): auto = 
  ## Construct the carousel controls

  if self.displayControls:
    var index = 0
    for ctrlClass in self.carouselControls:
      let cls:string = &"{self.controlsClassName}-{ctrlClass}"
      self.carouselControlsContainer.add tree(VNodeKind.button, attrs = @[(kstring"class",kstring(cls) )]  ,verbatim(self.textControls[index]))
      inc index

proc setCurrentState*(self:Carousel, target:Element,state:State): auto = 
  ## Update the order state of the carousel with css classes
  defer:
    state.selectedItem.classList.remove( fmt"{self.classNameItem}-selected")
    state.previousSelectedItem.classList.remove( fmt"{self.classNameItem}-previous")
    state.nextSelectedItem.classList.remove( fmt"{self.classNameItem}-next")
    state.firstCarouselItem.classList.remove( fmt"{self.classNameItem}-first")
    state.lastCarouselItem.classList.remove( fmt"{self.classNameItem}-last")
  let inner = self.expanded[0]
  if target.className ==  fmt"{self.controlsClassName}-{self.carouselControls[1]}":
    for item in inner:
      cast[Element](item.dom).classList.remove( fmt"{self.classNameItem}-trigger-previous")
      cast[Element](item.dom).classList.add( fmt"{self.classNameItem}-trigger-next")
    
    if state.upIndex == inner.len:
      cast[Element](inner[0].dom).classList.add( fmt"{self.classNameItem}-last")
      state.previousSelectedItem.classList.add( fmt"{self.classNameItem}-first")
      state.selectedItem.classList.add( fmt"{self.classNameItem}-previous")
      state.nextSelectedItem.classList.add( fmt"{self.classNameItem}-selected")
      state.lastCarouselItem.classList.add( fmt"{self.classNameItem}-next")
    elif state.upIndex == 1:
      cast[Element](inner[0].dom).classList.add( fmt"{self.classNameItem}-next")
      cast[Element](inner[1].dom).classList.add( fmt"{self.classNameItem}-last")
      state.previousSelectedItem.classList.add( fmt"{self.classNameItem}-first")
      state.selectedItem.classList.add( fmt"{self.classNameItem}-previous")
      state.nextSelectedItem.classList.add( fmt"{self.classNameItem}-selected")
    elif state.upIndex ==  2:
      cast[Element](inner[0].dom).classList.add( fmt"{self.classNameItem}-selected")
      cast[Element](inner[1].dom).classList.add( fmt"{self.classNameItem}-next")
      cast[Element](inner[2].dom).classList.add( fmt"{self.classNameItem}-last")
      state.previousSelectedItem.classList.add( fmt"{self.classNameItem}-first")
      state.selectedItem.classList.add( fmt"{self.classNameItem}-previous")
    elif state.upIndex ==  3:
      cast[Element](inner[0].dom).classList.add( fmt"{self.classNameItem}-previous")
      cast[Element](inner[1].dom).classList.add( fmt"{self.classNameItem}-selected")
      cast[Element](inner[2].dom).classList.add( fmt"{self.classNameItem}-next")
      cast[Element](inner[3].dom).classList.add( fmt"{self.classNameItem}-last")
      state.previousSelectedItem.classList.add( fmt"{self.classNameItem}-first")
    elif state.upIndex ==  4:
      self.setInitialState()
    else:
      state.previousSelectedItem.classList.add( fmt"{self.classNameItem}-first")
      state.selectedItem.classList.add( fmt"{self.classNameItem}-previous")
      state.nextSelectedItem.classList.add( fmt"{self.classNameItem}-selected")
      state.lastCarouselItem.classList.add( fmt"{self.classNameItem}-next")
      state.upCommingCarouselItem.classList.add( fmt"{self.classNameItem}-last")
  else:
    for item in inner: 
      cast[Element](item.dom).classList.remove( fmt"{self.classNameItem}-trigger-next")
      cast[Element](item.dom).classList.add( fmt"{self.classNameItem}-trigger-previous")

    if state.downIndex == - 1:
        cast[Element](inner[inner.len - 1].dom).classList.add( fmt"{self.classNameItem}-first")
        state.firstCarouselItem.classList.add( fmt"{self.classNameItem}-previous")
        state.previousSelectedItem.classList.add( fmt"{self.classNameItem}-selected")
        state.selectedItem.classList.add( fmt"{self.classNameItem}-next")
        state.nextSelectedItem.classList.add( fmt"{self.classNameItem}-last")
    elif state.downIndex == inner.len - 2:
        cast[Element](inner[inner.len - 1].dom).classList.add( fmt"{self.classNameItem}-previous")
        cast[Element](inner[inner.len - 2].dom).classList.add( fmt"{self.classNameItem}-first")
        state.previousSelectedItem.classList.add( fmt"{self.classNameItem}-selected")
        state.selectedItem.classList.add( fmt"{self.classNameItem}-next")
        state.nextSelectedItem.classList.add( fmt"{self.classNameItem}-last")
    elif state.downIndex == inner.len - 3:
        cast[Element](inner[inner.len - 1].dom).classList.add( fmt"{self.classNameItem}-selected")
        cast[Element](inner[inner.len - 2].dom).classList.add( fmt"{self.classNameItem}-previous")
        cast[Element](inner[inner.len - 3].dom).classList.add( fmt"{self.classNameItem}-first")
        state.selectedItem.classList.add( fmt"{self.classNameItem}-next")
        state.nextSelectedItem.classList.add( fmt"{self.classNameItem}-last")
    elif state.downIndex == inner.len - 4:
        cast[Element](inner[inner.len - 1].dom).classList.add( fmt"{self.classNameItem}-next")
        cast[Element](inner[inner.len - 2].dom).classList.add( fmt"{self.classNameItem}-selected")
        cast[Element](inner[inner.len - 3].dom).classList.add( fmt"{self.classNameItem}-previous")
        cast[Element](inner[inner.len - 4].dom).classList.add( fmt"{self.classNameItem}-first")
        state.selectedItem.classList.add( fmt"{self.classNameItem}-next")
        state.nextSelectedItem.classList.add( fmt"{self.classNameItem}-last")
    else:
      state.downCommingCarouselItem.classList.add( fmt"{self.classNameItem}-first")
      state.firstCarouselItem.classList.add( fmt"{self.classNameItem}-previous")
      state.previousSelectedItem.classList.add( fmt"{self.classNameItem}-selected")
      state.selectedItem.classList.add( fmt"{self.classNameItem}-next")
      state.nextSelectedItem.classList.add( fmt"{self.classNameItem}-last")

proc useControls*(self:Carousel) = 
  for item in self.carouselControlsContainer:
    item.addEventListener(EventKind.onclick,proc (ev: Event; target: VNode) = 
        self.setCurrentState(cast[Element](target.dom),self.getCurrentState())
    )

proc onTouch*(self:Carousel): auto = 
  ## touch action
  var touchstartX = 0.0
  var touchendX = 0.0
  var clickX = 0.0
  var drag = false
  var mousedown = proc (event:Event,target: VNode) = 
    clickX = cast[JsObject](event).pageX.to(float)
    drag = true
  var mouseup = proc(event:Event,target: VNode) =
    let ev = cast[JsObject](event)
    if drag:
      let pageX = ev.pageX.to(float)
      if(pageX < clickX) :
        self.setCurrentState( cast[Element](self.carouselControlsContainer[1].dom), self.getCurrentState())
      elif (pageX > clickX) :
        self.setCurrentState( cast[Element](self.carouselControlsContainer[0].dom), self.getCurrentState())
  var touchstart = proc(event:Event,target: VNode) = 
    let ev = cast[JsObject](event)
    touchstartX = ev.changedTouches[0].screenX.to(float)
  var touchend = proc(event:Event,target: VNode) = 
    let ev = cast[JsObject](event)
    touchendX = ev.changedTouches[0].screenX.to(float)
    if (touchendX <= touchstartX) :
      self.setCurrentState( cast[Element](self.carouselControlsContainer[1].dom), self.getCurrentState())
    
    elif (touchendX > touchstartX) :
      self.setCurrentState( cast[Element](self.carouselControlsContainer[0].dom), self.getCurrentState())

  self.addEventListener(EventKind.onmousedown,mousedown )
  self.addEventListener(EventKind.onmouseup,mouseup)
  # self.addEventListener(EventKind.ontouchstart,touchstart)
  # self.addEventListener(EventKind.ontouchend,touchend)

