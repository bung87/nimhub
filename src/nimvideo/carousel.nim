{.experimental: "codeReordering".}
import strformat
include karax / prelude
import karax/[kdom,vdom,reactive]
import jsffi except setInterval
import jsconsole

proc querySelector(ele:any,q:cstring):Element {.importcpp:"#.querySelector(@)",nodecl.}

var classes:seq[string]

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
  trigger:string

proc setInitialState*(self:Carousel) = 
  ## Assign initial css classes and attribute for each items
  var index = 0
  for item in self.expanded[0]:
    item.setAttr("data-index", kstring $index)
    case index
      of 0:
        classes[index] = fmt"{self.classNameItem}-first"
      of 1:
        classes[index] =  fmt"{self.classNameItem}-previous"
      of 2:
        classes[index] = fmt"{self.classNameItem}-selected"
      of 3:
        classes[index] = fmt"{self.classNameItem}-next"
      of 4:
        classes[index] = fmt"{self.classNameItem}-last"
      else:
        discard
    inc index
  self.markDirty()
  redraw()


proc render(x: VComponent): VNode =
  console.log "render"
  let self = Carousel(x)
  self.carouselControlsContainer = tree(VNodeKind.tdiv,attrs = @[ (kstring"class",kstring"slider__controls") ] )
  result = buildHtml(tdiv(class="slider")):
    tdiv(class="slider__inner"):
      # power of 4
      if self.data.len > 0:
        for i in 0..7:
          tdiv(class=fmt"slider__item {self.trigger} {classes[i]}",data-index = $i):
            tdiv(class="slider__item-container"):
              img(class="slider__item-img",src=self.data[i].image.to(cstring))
            tdiv(class="slider__item-datas"):
              span:
                text self.data[i].name.to(cstring)
      else:
        tdiv()
    self.carouselControlsContainer
 
  self.setControls()
  self.onTouch()
  if self.displayControls:
    self.useControls()
  

proc initCarousel*(self:Carousel,autoplay=true,autoplayTime = 3500,classNameItem="slider__item", displayControls=true,controlsClassName="slider__controls",carouselControls = defaultCarouselControls,textControls = defaultTextControls) = 
  self.controlsClassName = controlsClassName
  self.displayControls = displayControls
  self.carouselControls = carouselControls
  self.classNameItem = classNameItem
  self.textControls = textControls
  self.autoplay = autoplay
  self.autoplayTime = autoplayTime
  classes = @[fmt"{self.classNameItem}-first",fmt"{self.classNameItem}-previous",fmt"{self.classNameItem}-selected",fmt"{self.classNameItem}-next",fmt"{self.classNameItem}-last","","",""]


proc onAttach(x: VComponent) =
  let self = Carousel(x)
  console.log "onAttach"
  var play = proc() = 
    var state = self.getCurrentState()
    console.log "play"
    self.setCurrentState( cast[Element](self.carouselControlsContainer[1].dom), state)
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

proc getCurrentState*(self:Carousel): State = 
  let inner = self.expanded[0]
  var selectedItem = classes.find( fmt"{self.classNameItem}-selected")
  var previousSelectedItem = classes.find( fmt"{self.classNameItem}-previous")
  var nextSelectedItem = classes.find( fmt"{self.classNameItem}-next")
  var firstCarouselItem = classes.find( fmt"{self.classNameItem}-first")
  var lastCarouselItem = classes.find( fmt"{self.classNameItem}-last")

  var indexLastCarouselItem = lastCarouselItem
  var indexFirstCarouselItem = firstCarouselItem
  var downIndex = indexFirstCarouselItem - 1
  var upIndex = indexLastCarouselItem + 1

  return (selectedItem,previousSelectedItem,nextSelectedItem,firstCarouselItem,lastCarouselItem,downIndex,upIndex)

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

  for item in classes.mitems:
    item = ""
 
  let inner = self.expanded[0]
  if target.className ==  fmt"{self.controlsClassName}-{self.carouselControls[1]}":
    self.trigger = fmt"{self.classNameItem}-trigger-next"
    
    if state.upIndex == inner.len:
      classes[0] = fmt"{self.classNameItem}-last"
      classes[state.previousSelectedItem] = fmt"{self.classNameItem}-first"
      classes[state.selectedItem] = fmt"{self.classNameItem}-previous"
      classes[state.nextSelectedItem] = fmt"{self.classNameItem}-selected"
      classes[state.lastCarouselItem] = fmt"{self.classNameItem}-next"
    elif state.upIndex == 1:
      classes[0] = fmt"{self.classNameItem}-next"
      classes[1] = fmt"{self.classNameItem}-last"
      classes[state.previousSelectedItem] = fmt"{self.classNameItem}-first"
      classes[state.selectedItem] = fmt"{self.classNameItem}-previous"
      classes[state.nextSelectedItem] = fmt"{self.classNameItem}-selected"
    elif state.upIndex == 2:
      classes[0] = fmt"{self.classNameItem}-selected"
      classes[1] = fmt"{self.classNameItem}-next"
      classes[2] = fmt"{self.classNameItem}-last"
      classes[state.previousSelectedItem] = fmt"{self.classNameItem}-first"
      classes[state.selectedItem] = fmt"{self.classNameItem}-previous"
    elif state.upIndex ==  3:
      classes[0] = fmt"{self.classNameItem}-previous"
      classes[1] = fmt"{self.classNameItem}-selected"
      classes[2] = fmt"{self.classNameItem}-next"
      classes[3] = fmt"{self.classNameItem}-last"
      classes[state.previousSelectedItem] = fmt"{self.classNameItem}-first"
    elif state.upIndex ==  4:
      self.setInitialState()
    else:
      classes[state.previousSelectedItem] = fmt"{self.classNameItem}-first"
      classes[state.selectedItem] = fmt"{self.classNameItem}-previous"
      classes[state.nextSelectedItem] = fmt"{self.classNameItem}-selected"
      classes[state.lastCarouselItem] = fmt"{self.classNameItem}-next"
      classes[state.upIndex] = fmt"{self.classNameItem}-last"
  else:
    self.trigger = fmt"{self.classNameItem}-trigger-previous"

    if state.downIndex == - 1:
        classes[classes.len - 1] = fmt"{self.classNameItem}-first"
        classes[state.firstCarouselItem] = fmt"{self.classNameItem}-previous"
        classes[state.previousSelectedItem] = fmt"{self.classNameItem}-selected"
        classes[state.selectedItem] = fmt"{self.classNameItem}-next"
        classes[state.nextSelectedItem] = fmt"{self.classNameItem}-last"
    elif state.downIndex == inner.len - 2:
        classes[classes.len - 1] = fmt"{self.classNameItem}-previous"
        classes[classes.len - 2] = fmt"{self.classNameItem}-first"
        classes[state.previousSelectedItem] = fmt"{self.classNameItem}-selected"
        classes[state.selectedItem] = fmt"{self.classNameItem}-next"
        classes[state.nextSelectedItem] = fmt"{self.classNameItem}-last"
    elif state.downIndex == inner.len - 3:
        classes[classes.len - 1] = fmt"{self.classNameItem}-selected"
        classes[classes.len - 2] = fmt"{self.classNameItem}-previous"
        classes[classes.len - 3] = fmt"{self.classNameItem}-first"
        classes[state.selectedItem] = fmt"{self.classNameItem}-next"
        classes[state.nextSelectedItem] = fmt"{self.classNameItem}-last"
    elif state.downIndex == inner.len - 4:
        classes[classes.len - 1] = fmt"{self.classNameItem}-next"
        classes[classes.len - 2] = fmt"{self.classNameItem}-selected"
        classes[classes.len - 3] = fmt"{self.classNameItem}-previous"
        classes[classes.len - 4] = fmt"{self.classNameItem}-first"
        classes[state.selectedItem] = fmt"{self.classNameItem}-next"
        classes[state.nextSelectedItem] = fmt"{self.classNameItem}-last"
    else:
      classes[state.downIndex] = fmt"{self.classNameItem}-first"
      classes[state.firstCarouselItem] = fmt"{self.classNameItem}-previous"
      classes[state.previousSelectedItem] = fmt"{self.classNameItem}-selected"
      classes[state.selectedItem] = fmt"{self.classNameItem}-next"
      classes[state.nextSelectedItem] = fmt"{self.classNameItem}-last"
  self.markDirty()
  console.log $classes

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

