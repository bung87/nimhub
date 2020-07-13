{.experimental: "codeReordering".}
import strformat
include karax / prelude
import karax/[kdom,vdom,reactive]
import jsffi except setInterval
import jsconsole

proc querySelector(ele:any,q:cstring):Element {.importcpp:"#.querySelector(@)",nodecl.}

type Switch {.pure.} = enum 
  next,prev

type Carousel* = ref object of VComponent
  classNameItem*:cstring
  carouselControls:seq[cstring]
  controlsClassName:cstring
  textControls:seq[cstring]
  autoplay:bool
  classes:seq[string]
  displayControls:bool
  data*:seq[JsObject]
  autoplayTime:int
  trigger:string

proc setInitialState*(self:Carousel) = 
  ## Assign initial css self.classes and attribute for each items
  var index = 0
  for item in self.expanded[0]:
    item.setAttr("data-index", kstring $index)
    case index
      of 0:
        self.classes[index] = fmt"{self.classNameItem}-first"
      of 1:
        self.classes[index] =  fmt"{self.classNameItem}-previous"
      of 2:
        self.classes[index] = fmt"{self.classNameItem}-selected"
      of 3:
        self.classes[index] = fmt"{self.classNameItem}-next"
      of 4:
        self.classes[index] = fmt"{self.classNameItem}-last"
      else:
        discard
    inc index
  self.markDirty()
  redraw()


proc render(x: VComponent): VNode =
  
  let self = Carousel(x)
  proc itemRender(cls:string,index:int):VNode  = 
    result = buildHtml(tdiv(class=fmt"slider__item {self.trigger} {cls}", data-index= $index )):
      tdiv(class= "slider__item-container"):
        img(class= "slider__item-img",src = self.data[index].image.to(cstring))
      tdiv(class= "slider__item-datas"):
        span:
          text self.data[index].name.to(cstring)

  result = buildHtml(tdiv(class="slider")):
    # power of 4
    if self.data.len > 0:
      tdiv(class="slider__inner"):
        for i in 0..7:
          itemRender(self.classes[i],i)

    if self.displayControls:
      tdiv(class="slider__controls"):
        for index,ctrlClass in self.carouselControls:
          let cls:string = &"{self.controlsClassName}-{ctrlClass}"
          button(class = cls):
            verbatim self.textControls[index]


proc initCarousel*(self:Carousel,autoplay=true,autoplayTime = 3500,classNameItem="slider__item", displayControls=true,controlsClassName="slider__controls",carouselControls = defaultCarouselControls,textControls = defaultTextControls) = 
  self.controlsClassName = controlsClassName
  self.displayControls = displayControls
  self.carouselControls = carouselControls
  self.classNameItem = classNameItem
  self.textControls = textControls
  self.autoplay = autoplay
  self.autoplayTime = autoplayTime
  self.classes =  @[fmt"{self.classNameItem}-first",fmt"{self.classNameItem}-previous",fmt"{self.classNameItem}-selected",fmt"{self.classNameItem}-next",fmt"{self.classNameItem}-last","","",""]


proc onAttach(x: VComponent) =
  let self = Carousel(x)
  console.log "onAttach"
  self.onTouch()
  var play = proc() = 
    var state = self.getCurrentState()
    console.log "play"
    self.setCurrentState( Switch.next , state)
    redraw()
  if self.autoplay:
    discard window.setInterval(play,self.autoplayTime)
  
proc carousel*(nref:var Carousel): Carousel =
  nref = newComponent(Carousel, render,onAttach)
  initCarousel nref
  nref

const defaultTextControls = @[cstring"<i class='fas fa-chevron-left'></i>", cstring"<i class='fas fa-chevron-right'></i>"]
const defaultCarouselControls = @[cstring"previous",cstring"next"]


type 
  State = tuple[selectedItem: int, previousSelectedItem: int,nextSelectedItem:int,firstCarouselItem:int,lastCarouselItem:int,downIndex:int,upIndex:int] 

proc find*[T](a: RSeq[T], item: T): int {.inline.}=
  ## Returns the first index of `item` in `a` or -1 if not found. This requires
  ## appropriate `items` and `==` operations to work.
  result = 0
  for i in items(a.s):
    if i == item: return
    inc(result)
  result = -1

proc getCurrentState*(self:Carousel): State = 
  let inner = self.expanded[0]
  var selectedItem = self.classes.find( fmt"{self.classNameItem}-selected")
  var previousSelectedItem = self.classes.find( fmt"{self.classNameItem}-previous")
  var nextSelectedItem = self.classes.find( fmt"{self.classNameItem}-next")
  var firstCarouselItem = self.classes.find( fmt"{self.classNameItem}-first")
  var lastCarouselItem = self.classes.find( fmt"{self.classNameItem}-last")

  var indexLastCarouselItem = lastCarouselItem
  var indexFirstCarouselItem = firstCarouselItem
  var downIndex = indexFirstCarouselItem - 1
  var upIndex = indexLastCarouselItem + 1

  return (selectedItem,previousSelectedItem,nextSelectedItem,firstCarouselItem,lastCarouselItem,downIndex,upIndex)


proc setCurrentState*(self:Carousel, target:Switch,state:State): auto = 
  ## Update the order state of the carousel with css self.classes
  var i = 0
  while i < self.classes.len :
    self.classes[i] = ""
    inc i
 
  let inner = self.expanded[0]
  if target == Switch.next:
    self.trigger = fmt"{self.classNameItem}-trigger-next"
    
    if state.upIndex == inner.len:
      self.classes[0] = fmt"{self.classNameItem}-last"
      self.classes[state.previousSelectedItem] = fmt"{self.classNameItem}-first"
      self.classes[state.selectedItem] = fmt"{self.classNameItem}-previous"
      self.classes[state.nextSelectedItem] = fmt"{self.classNameItem}-selected"
      self.classes[state.lastCarouselItem] = fmt"{self.classNameItem}-next"
    elif state.upIndex == 1:
      self.classes[0] = fmt"{self.classNameItem}-next"
      self.classes[1] = fmt"{self.classNameItem}-last"
      self.classes[state.previousSelectedItem] = fmt"{self.classNameItem}-first"
      self.classes[state.selectedItem] = fmt"{self.classNameItem}-previous"
      self.classes[state.nextSelectedItem] = fmt"{self.classNameItem}-selected"
    elif state.upIndex == 2:
      self.classes[0] = fmt"{self.classNameItem}-selected"
      self.classes[1] = fmt"{self.classNameItem}-next"
      self.classes[2] = fmt"{self.classNameItem}-last"
      self.classes[state.previousSelectedItem] = fmt"{self.classNameItem}-first"
      self.classes[state.selectedItem] = fmt"{self.classNameItem}-previous"
    elif state.upIndex ==  3:
      self.classes[0] = fmt"{self.classNameItem}-previous"
      self.classes[1] = fmt"{self.classNameItem}-selected"
      self.classes[2] = fmt"{self.classNameItem}-next"
      self.classes[3] = fmt"{self.classNameItem}-last"
      self.classes[state.previousSelectedItem] = fmt"{self.classNameItem}-first"
    elif state.upIndex ==  4:
      self.setInitialState()
    else:
      self.classes[state.previousSelectedItem] = fmt"{self.classNameItem}-first"
      self.classes[state.selectedItem] = fmt"{self.classNameItem}-previous"
      self.classes[state.nextSelectedItem] = fmt"{self.classNameItem}-selected"
      self.classes[state.lastCarouselItem] = fmt"{self.classNameItem}-next"
      self.classes[state.upIndex] = fmt"{self.classNameItem}-last"
  else:
    self.trigger = fmt"{self.classNameItem}-trigger-previous"

    if state.downIndex == - 1:
        self.classes[self.classes.len - 1] = fmt"{self.classNameItem}-first"
        self.classes[state.firstCarouselItem] = fmt"{self.classNameItem}-previous"
        self.classes[state.previousSelectedItem] = fmt"{self.classNameItem}-selected"
        self.classes[state.selectedItem] = fmt"{self.classNameItem}-next"
        self.classes[state.nextSelectedItem] = fmt"{self.classNameItem}-last"
    elif state.downIndex == inner.len - 2:
        self.classes[self.classes.len - 1] = fmt"{self.classNameItem}-previous"
        self.classes[self.classes.len - 2] = fmt"{self.classNameItem}-first"
        self.classes[state.previousSelectedItem] = fmt"{self.classNameItem}-selected"
        self.classes[state.selectedItem] = fmt"{self.classNameItem}-next"
        self.classes[state.nextSelectedItem] = fmt"{self.classNameItem}-last"
    elif state.downIndex == inner.len - 3:
        self.classes[self.classes.len - 1] = fmt"{self.classNameItem}-selected"
        self.classes[self.classes.len - 2] = fmt"{self.classNameItem}-previous"
        self.classes[self.classes.len - 3] = fmt"{self.classNameItem}-first"
        self.classes[state.selectedItem] = fmt"{self.classNameItem}-next"
        self.classes[state.nextSelectedItem] = fmt"{self.classNameItem}-last"
    elif state.downIndex == inner.len - 4:
        self.classes[self.classes.len - 1] = fmt"{self.classNameItem}-next"
        self.classes[self.classes.len - 2] = fmt"{self.classNameItem}-selected"
        self.classes[self.classes.len - 3] = fmt"{self.classNameItem}-previous"
        self.classes[self.classes.len - 4] = fmt"{self.classNameItem}-first"
        self.classes[state.selectedItem] = fmt"{self.classNameItem}-next"
        self.classes[state.nextSelectedItem] = fmt"{self.classNameItem}-last"
    else:
      self.classes[state.downIndex] = fmt"{self.classNameItem}-first"
      self.classes[state.firstCarouselItem] = fmt"{self.classNameItem}-previous"
      self.classes[state.previousSelectedItem] = fmt"{self.classNameItem}-selected"
      self.classes[state.selectedItem] = fmt"{self.classNameItem}-next"
      self.classes[state.nextSelectedItem] = fmt"{self.classNameItem}-last"
  self.markDirty()
  runDiff(kxi,self.expanded,render(self))
  console.log self.classes

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
        self.setCurrentState( Switch.next, self.getCurrentState())
      elif (pageX > clickX) :
        self.setCurrentState( Switch.prev, self.getCurrentState())
  var touchstart = proc(event:Event,target: VNode) = 
    let ev = cast[JsObject](event)
    touchstartX = ev.changedTouches[0].screenX.to(float)
  var touchend = proc(event:Event,target: VNode) = 
    let ev = cast[JsObject](event)
    touchendX = ev.changedTouches[0].screenX.to(float)
    if (touchendX <= touchstartX) :
      self.setCurrentState( Switch.next, self.getCurrentState())
    
    elif (touchendX > touchstartX) :
      self.setCurrentState( Switch.prev, self.getCurrentState())

  self.addEventListener(EventKind.onmousedown,mousedown )
  self.addEventListener(EventKind.onmouseup,mouseup)
  # self.addEventListener(EventKind.ontouchstart,touchstart)
  # self.addEventListener(EventKind.ontouchend,touchend)

