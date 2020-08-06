include karax / prelude
import karax/[kdom,vdom,vstyles]
import ./autocomplete
import jsconsole
import ./najax
import jsffi except `&`
import json

# genres 剧情喜剧动作爱情科幻动画悬疑惊悚恐怖犯罪同性音乐歌舞传记历史战争西部奇幻冒险灾难武侠情色
# region 中国大陆美国中国香港中国台湾日本韩国英国法国德国意大利西班牙印度泰国俄罗斯伊朗加拿大澳大利亚爱尔兰瑞典巴西丹麦
type NavMenu* = ref object of VComponent

type NavMenuItem = object
  name:string
  url:string
  children:seq[NavMenuItem]

proc render(x:VComponent):VNode =
  let self = NavMenu(x)
  const js = staticRead("navmenu.json")
  let j = parseJson(js)
  let root = j.to(NavMenuItem)
  console.log root
  var currentLevel = 0

  proc travse(node:NavMenuItem,level: int):VNode = 
    var cls = if level == 0 : "pure-menu-list" else: "pure-menu-children" 
    cls = cls & " item-level-" & $level
    
    result = buildHtml(ul(class=cls)):
      var nodeCls = "pure-menu-item fl"
      if node.children.len > 0:
        nodeCls = nodeCls & " pure-menu-has-children pure-menu-allow-hover pure-menu-has-children-level-" & $level
      li(class=nodeCls):
        a(href="#",class="pure-menu-link"):
          text node.name.cstring
        for n in node.children:
          # if n.children.len > 0:
          travse(n,level + 1)
      inc currentLevel
  let divStyle = style(
    # (StyleAttr.display, cstring"block"),
    (StyleAttr.fontSize, cstring"0"),
    (StyleAttr.cssFloat, cstring"left"),
  )
  result = buildHtml(tdiv(style = divStyle)):
    travse(root,currentLevel)

proc navMenu*():NavMenu =
  result = newComponent(NavMenu,render)