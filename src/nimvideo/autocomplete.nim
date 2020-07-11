# import karax, karaxdsl, vdom, kdom, jstrutils

import karax / [karax, karaxdsl, vdom, kdom, jstrutils,vstyles]
import jsffi except `&`
import jsconsole
import future

type
  AutocompleteState* = ref object
    choices, candidates: seq[cstring]
    selected, maxMatches: int
    showCandidates, controlPressed: bool

proc newAutocomplete*(choices: seq[cstring]; maxMatches = 5): AutocompleteState =
  ## Creates a new state for the autocomplete widget. ``maxMatches`` is the maximum
  ## number of elements to show.
  AutocompleteState(choices: choices, candidates: @[],
    selected: -1, maxMatches: maxMatches, showCandidates: false,
    controlPressed: false)

proc autocomplete*(s: AutocompleteState; inp:VNode;onselection: proc(s: cstring)): VNode =

  proc commit(ev: Event) =
    s.showCandidates = false
    onselection(inp.dom.value)
    when false:
      if inp.dom != nil:
        echo "setting to A ", inp.dom.value.isNil
        result.text = inp.dom.value
      else:
        echo "setting to B ", inp.text.isNil
        result.text = inp.text
      for e in result.events:
        if e[0] == EventKind.onchange:
          e[1](ev, result)

  proc onkeyuplater(ev: kdom.Event; n: VNode) =
    if not s.controlPressed:
      let v = n.value
      s.candidates.setLen 0
      for c in s.choices:
        if v.len == 0 or c.containsIgnoreCase(v): s.candidates.add(c)

  proc onkeydown(ev: Event; n: VNode) =
    const
      LEFT = 37
      UP = 38
      RIGHT = 39
      DOWN = 40
      TAB = 9
      ESC = 27
      ENTER = 13
    # UP: Move focus to the previous item. If on first item, move focus to the input.
    #     If on the input, move focus to last item.
    # DOWN: Move focus to the next item. If on last item, move focus to the input.
    #       If on the input, move focus to the first item.
    # ESCAPE: Close the menu.
    # ENTER: Select the currently focused item and close the menu.
    # TAB: Select the currently focused item, close the menu, and
    #      move focus to the next focusable element
    s.controlPressed = false
    case kdom.KeyboardEvent(ev).keyCode
    of UP:
      s.controlPressed = true
      s.showCandidates = true
      if s.selected > 0:
        dec s.selected
        n.setInputText s.candidates[s.selected]
    of DOWN:
      s.controlPressed = true
      s.showCandidates = true
      if s.selected < s.candidates.len - 1:
        inc s.selected
        n.setInputText s.candidates[s.selected]
    of ESC:
      s.showCandidates = false
      s.controlPressed = true
    of ENTER:
      s.controlPressed = true
#      inp.setInputText s.choices[i]
      commit(ev)
    else:
      discard

  proc window(s: AutocompleteState): (int, int) =
    var first, last: int
    if s.selected >= 0:
      first = s.selected - (s.maxMatches div 2)
      last = s.selected + (s.maxMatches div 2)
      if first < 0: first = 0
      # too few because we had to trim first?
      if (last - first + 1) < s.maxMatches: last = first + s.maxMatches - 1
    else:
      first = 0
      last = s.maxMatches - 1
    if last > high(s.candidates): last = high(s.candidates)
    # still too few because we're at the end?
    if (last - first + 1) < s.maxMatches:
      first = last - s.maxMatches + 1
      if first < 0: first = 0

    result = (first, last)
  
  var onfocus = proc (ev: Event; n: VNode) =
    onkeyuplater(ev, n)
    s.showCandidates = true
  inp.addEventListener(EventKind.onkeyuplater,onkeyuplater )
  inp.addEventListener(EventKind.onkeydown,onkeydown )
  inp.addEventListener(EventKind.onfocus,onfocus )
  
  # inp = buildHtml:
  #   input(onkeyuplater = onkeyuplater,
  #     onkeydown = onkeydown,
  #     # onblur = proc (ev: Event; n: VNode) = commit(ev),
  #     onfocus = proc (ev: Event; n: VNode) =
  #       onkeyuplater(ev, n)
  #       s.showCandidates = true)

  proc select(i: int): proc(ev: Event; n: VNode) =
    result = proc(ev: Event; n: VNode) =
      s.selected = i
      s.showCandidates = false
      inp.setInputText s.choices[i]
      commit(ev)
  let style1 = style(
    (StyleAttr.position, cstring"fixed"),
    (StyleAttr.height, cstring"20px"),
    (StyleAttr.display, cstring"none"),
   
  )
  let noFloat = style(
    (StyleAttr.cssFloat, cstring"none"),
    (StyleAttr.width, cstring"100%"),
    (StyleAttr.display, cstring"block"),
  )
  let bg = style(
     (StyleAttr.background, cstring"#222222e3"),
  )
  var resultList = buildHtml(tdiv(style=style1) ):
    let (first, last) = window(s)
    tdiv(class="pure-menu"):
      ul(class="pure-menu-list",style=noFloat.merge(bg)):
        li(class="pure-menu-item",style=noFloat):
          a(class = "pure-menu-link"):
            text "1"
        li(class="pure-menu-item",style=noFloat):
          a(class = "pure-menu-link"):
            text "2"
        for i in first..last:
          li(class="pure-menu-item"):
            a(onclick = select(i), class = "pure-menu-link"):
              text s.candidates[i]
  proc pos(ev: Event; n: VNode) =
    console.log "pos",cast[JsObject](result.dom).getBoundingClientRect().left.to(cstring)
    resultList.dom.style.display = cstring"block"
    resultList.dom.style.width = cstring cast[JsObject](result.dom).getBoundingClientRect().width.to(cstring) & "px"
    resultList.dom.style.left = cstring cast[JsObject](result.dom).getBoundingClientRect().left.to(cstring) & "px"
    resultList.dom.style.top = cstring cast[JsObject](result.dom.parentNode).getBoundingClientRect().height.to(cstring) & "px"
    # inp.removeEventListener(EventKind.onfocus,pos )
  let style = style(
    (StyleAttr.display, cstring"inline-block"),
  )

  proc onblur(ev: Event; n: VNode) = 
    resultList.dom.style.display = "none"
  inp.addEventListener(EventKind.onfocus,pos )
  inp.addEventListener(EventKind.onblur,onblur )
  result = buildHtml(span(style=style)):
    inp
    # if s.showCandidates:
    resultList
