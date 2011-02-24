
function! paint#syntax#render(...)
  let regular = get(a:000, 0, {})
  let bold = get(a:000, 1, {})
  let mode = get(a:000, 2, {})
  if empty(regular) && empty(bold)
    let regular = paint#bdf#loadfile(globpath(&rtp, 'font/mplus/mplus_f12r.bdf'))
    let bold = paint#bdf#loadfile(globpath(&rtp, 'font/mplus/mplus_f12b.bdf'))
  endif
  if empty(regular)
    let regular = paint#bdf#loadfile(globpath(&rtp, 'font/mplus/mplus_f12r.bdf'))
  endif
  if empty(bold)
    let bold = regular
  endif
  let s:.mode = mode
  return s:render(regular, bold)
endfunction

let s:mode = {}

function! s:render(regular, bold)
  let [font_width, font_height, font_baseline] = a:regular.get_text_size("mw")
  let font_width = font_width / 2

  let maxcol = max(map(range(1, line('$')), 'virtcol([v:val, "$"]) - 1'))

  let width = maxcol * font_width
  let height = line('$') * (font_height + font_baseline)

  let canvas = paint#canvas#new(width, height)

  let attr = s:synattr(hlID('Normal'))
  call canvas.draw_rect([0, 0], [width - 1, height - 1], attr.bg, -1)

  let [x, y] = [0, 0]

  for lnum in range(1, line('$'))
    let synline = s:synline(lnum)

    let x = 0
    for [str, attr] in synline
      let font = attr.bold ? a:bold : a:regular
      let color = attr.reverse ? attr.fg : attr.bg
      let [w, h, b] = font.get_text_size(str)
      call canvas.draw_rect([x, y], [x + w - 1, y + h + b - 1], color, -1)
      let x += w
    endfor

    let x = 0
    for [str, attr] in synline
      let font = attr.bold ? a:bold : a:regular
      let color = attr.reverse ? attr.bg : attr.fg
      let [w, h, b] = font.get_text_size(str)
      call canvas.draw_text(str, [x, y + h], font, color)
      if attr.undercurl && attr.name != 'Normal'
        let yofftable = [1, 0, 0, 0, 1, 2, 2, 2]
        for i in range(w)
          let yoff = yofftable[(x + i) % len(yofftable)]
          call canvas.set_pixel(x + i, y + h + b - 1 - yoff, attr.sp)
        endfor
      endif
      if attr.underline
        call canvas.draw_line([x, y + h], [x + w - 1, y + h], color, 1)
      endif
      let x += w
    endfor

    let y += font_height + font_baseline
  endfor

  return canvas
endfunction

function! s:synline(lnum)
  let res = []
  let col = 1
  let vcol = 0
  for c in split(getline(a:lnum), '\zs')
    let vw = strdisplaywidth(c, vcol)
    if c == "\t"
      if &list
        let attr = s:synattr(hlID('SpecialKey'))
        let m = matchlist(&listchars, 'tab:\(.\)\(.\)')
        if empty(m)
          call add(res, [strtrans(c), attr])
        else
          call add(res, [m[1] . repeat(m[2], vw - 1), attr])
        endif
      else
        let attr = s:synattr(hlID('Normal'))
        call add(res, [repeat(' ', vw), attr])
      endif
    elseif c =~ '[[:cntrl:]]'
      let attr = s:synattr(hlID('SpecialKey'))
      call add(res, [strtrans(c), attr])
    elseif c !~ '[[:print:]]'
      let attr = s:synattr(hlID('SpecialKey'))
      call add(res, [strtrans(c), attr])
    else
      let attr = s:synattr(synID(a:lnum, col, 1))
      call add(res, [c, attr])
    endif
    let col += len(c)
    let vcol += vw
  endfor
  return res
endfunction

function! s:synattr(synid)
  let id = synIDtrans(a:synid)
  let normal_fg = s:syncolor(hlID('Normal'), 'fg#', [0, 0, 0])
  let normal_bg = s:syncolor(hlID('Normal'), 'bg#', [255, 255, 255])
  let attr = {}
  let attr.name = s:synidattr(id, 'name')
  let attr.fg = s:syncolor(id, 'fg#', normal_fg)
  let attr.bg = s:syncolor(id, 'bg#', normal_bg)
  let attr.sp = s:syncolor(id, 'sp#', attr.fg)
  let attr.bold = s:synidattr(id, 'bold')
  let attr.italic = s:synidattr(id, 'italic')
  let attr.reverse = s:synidattr(id, 'reverse')
  let attr.inverse = s:synidattr(id, 'inverse')
  let attr.standout = s:synidattr(id, 'standout')
  let attr.underline = s:synidattr(id, 'underline')
  let attr.undercurl = s:synidattr(id, 'undercurl')
  return attr
endfunction

function! s:syncolor(id, what, default)
  let c = s:synidattr(synIDtrans(a:id), a:what)
  if c =~ '^\d'
    let c = s:cterm_color[c]
  endif
  if c != '-1' && c != ''
    return [str2nr(c[1:2], 16), str2nr(c[3:4], 16), str2nr(c[5:6], 16)]
  endif
  return a:default
endfunction

function! s:synidattr(id, what)
  if empty(s:mode)
    return synIDattr(a:id, a:what)
  else
    return synIDattr(a:id, a:what, s:mode)
  endif
endfunction

" copied from runtime/syntax/2html.vim
let s:cterm_color = {0: "#000000", 1: "#c00000", 2: "#008000", 3: "#804000", 4: "#0000c0", 5: "#c000c0", 6: "#008080", 7: "#c0c0c0", 8: "#808080", 9: "#ff6060", 10: "#00ff00", 11: "#ffff00", 12: "#8080ff", 13: "#ff40ff", 14: "#00ffff", 15: "#ffffff"}

" Colors for 88 and 256 come from xterm.
call extend(s:cterm_color, {16: "#000000", 17: "#00008b", 18: "#0000cd", 19: "#0000ff", 20: "#008b00", 21: "#008b8b", 22: "#008bcd", 23: "#008bff", 24: "#00cd00", 25: "#00cd8b", 26: "#00cdcd", 27: "#00cdff", 28: "#00ff00", 29: "#00ff8b", 30: "#00ffcd", 31: "#00ffff", 32: "#8b0000", 33: "#8b008b", 34: "#8b00cd", 35: "#8b00ff", 36: "#8b8b00", 37: "#8b8b8b", 38: "#8b8bcd", 39: "#8b8bff", 40: "#8bcd00", 41: "#8bcd8b", 42: "#8bcdcd", 43: "#8bcdff", 44: "#8bff00", 45: "#8bff8b", 46: "#8bffcd", 47: "#8bffff", 48: "#cd0000", 49: "#cd008b", 50: "#cd00cd", 51: "#cd00ff", 52: "#cd8b00", 53: "#cd8b8b", 54: "#cd8bcd", 55: "#cd8bff", 56: "#cdcd00", 57: "#cdcd8b", 58: "#cdcdcd", 59: "#cdcdff", 60: "#cdff00", 61: "#cdff8b", 62: "#cdffcd", 63: "#cdffff", 64: "#ff0000"})
call extend(s:cterm_color, {65: "#ff008b", 66: "#ff00cd", 67: "#ff00ff", 68: "#ff8b00", 69: "#ff8b8b", 70: "#ff8bcd", 71: "#ff8bff", 72: "#ffcd00", 73: "#ffcd8b", 74: "#ffcdcd", 75: "#ffcdff", 76: "#ffff00", 77: "#ffff8b", 78: "#ffffcd", 79: "#ffffff", 80: "#2e2e2e", 81: "#5c5c5c", 82: "#737373", 83: "#8b8b8b", 84: "#a2a2a2", 85: "#b9b9b9", 86: "#d0d0d0", 87: "#e7e7e7"})

call extend(s:cterm_color, {16: "#000000", 17: "#00005f", 18: "#000087", 19: "#0000af", 20: "#0000d7", 21: "#0000ff", 22: "#005f00", 23: "#005f5f", 24: "#005f87", 25: "#005faf", 26: "#005fd7", 27: "#005fff", 28: "#008700", 29: "#00875f", 30: "#008787", 31: "#0087af", 32: "#0087d7", 33: "#0087ff", 34: "#00af00", 35: "#00af5f", 36: "#00af87", 37: "#00afaf", 38: "#00afd7", 39: "#00afff", 40: "#00d700", 41: "#00d75f", 42: "#00d787", 43: "#00d7af", 44: "#00d7d7", 45: "#00d7ff", 46: "#00ff00", 47: "#00ff5f", 48: "#00ff87", 49: "#00ffaf", 50: "#00ffd7", 51: "#00ffff", 52: "#5f0000", 53: "#5f005f", 54: "#5f0087", 55: "#5f00af", 56: "#5f00d7", 57: "#5f00ff", 58: "#5f5f00", 59: "#5f5f5f", 60: "#5f5f87", 61: "#5f5faf", 62: "#5f5fd7", 63: "#5f5fff", 64: "#5f8700"})
call extend(s:cterm_color, {65: "#5f875f", 66: "#5f8787", 67: "#5f87af", 68: "#5f87d7", 69: "#5f87ff", 70: "#5faf00", 71: "#5faf5f", 72: "#5faf87", 73: "#5fafaf", 74: "#5fafd7", 75: "#5fafff", 76: "#5fd700", 77: "#5fd75f", 78: "#5fd787", 79: "#5fd7af", 80: "#5fd7d7", 81: "#5fd7ff", 82: "#5fff00", 83: "#5fff5f", 84: "#5fff87", 85: "#5fffaf", 86: "#5fffd7", 87: "#5fffff", 88: "#870000", 89: "#87005f", 90: "#870087", 91: "#8700af", 92: "#8700d7", 93: "#8700ff", 94: "#875f00", 95: "#875f5f", 96: "#875f87", 97: "#875faf", 98: "#875fd7", 99: "#875fff", 100: "#878700", 101: "#87875f", 102: "#878787", 103: "#8787af", 104: "#8787d7", 105: "#8787ff", 106: "#87af00", 107: "#87af5f", 108: "#87af87", 109: "#87afaf", 110: "#87afd7", 111: "#87afff", 112: "#87d700"})
call extend(s:cterm_color, {113: "#87d75f", 114: "#87d787", 115: "#87d7af", 116: "#87d7d7", 117: "#87d7ff", 118: "#87ff00", 119: "#87ff5f", 120: "#87ff87", 121: "#87ffaf", 122: "#87ffd7", 123: "#87ffff", 124: "#af0000", 125: "#af005f", 126: "#af0087", 127: "#af00af", 128: "#af00d7", 129: "#af00ff", 130: "#af5f00", 131: "#af5f5f", 132: "#af5f87", 133: "#af5faf", 134: "#af5fd7", 135: "#af5fff", 136: "#af8700", 137: "#af875f", 138: "#af8787", 139: "#af87af", 140: "#af87d7", 141: "#af87ff", 142: "#afaf00", 143: "#afaf5f", 144: "#afaf87", 145: "#afafaf", 146: "#afafd7", 147: "#afafff", 148: "#afd700", 149: "#afd75f", 150: "#afd787", 151: "#afd7af", 152: "#afd7d7", 153: "#afd7ff", 154: "#afff00", 155: "#afff5f", 156: "#afff87", 157: "#afffaf", 158: "#afffd7"})
call extend(s:cterm_color, {159: "#afffff", 160: "#d70000", 161: "#d7005f", 162: "#d70087", 163: "#d700af", 164: "#d700d7", 165: "#d700ff", 166: "#d75f00", 167: "#d75f5f", 168: "#d75f87", 169: "#d75faf", 170: "#d75fd7", 171: "#d75fff", 172: "#d78700", 173: "#d7875f", 174: "#d78787", 175: "#d787af", 176: "#d787d7", 177: "#d787ff", 178: "#d7af00", 179: "#d7af5f", 180: "#d7af87", 181: "#d7afaf", 182: "#d7afd7", 183: "#d7afff", 184: "#d7d700", 185: "#d7d75f", 186: "#d7d787", 187: "#d7d7af", 188: "#d7d7d7", 189: "#d7d7ff", 190: "#d7ff00", 191: "#d7ff5f", 192: "#d7ff87", 193: "#d7ffaf", 194: "#d7ffd7", 195: "#d7ffff", 196: "#ff0000", 197: "#ff005f", 198: "#ff0087", 199: "#ff00af", 200: "#ff00d7", 201: "#ff00ff", 202: "#ff5f00", 203: "#ff5f5f", 204: "#ff5f87"})
call extend(s:cterm_color, {205: "#ff5faf", 206: "#ff5fd7", 207: "#ff5fff", 208: "#ff8700", 209: "#ff875f", 210: "#ff8787", 211: "#ff87af", 212: "#ff87d7", 213: "#ff87ff", 214: "#ffaf00", 215: "#ffaf5f", 216: "#ffaf87", 217: "#ffafaf", 218: "#ffafd7", 219: "#ffafff", 220: "#ffd700", 221: "#ffd75f", 222: "#ffd787", 223: "#ffd7af", 224: "#ffd7d7", 225: "#ffd7ff", 226: "#ffff00", 227: "#ffff5f", 228: "#ffff87", 229: "#ffffaf", 230: "#ffffd7", 231: "#ffffff", 232: "#080808", 233: "#121212", 234: "#1c1c1c", 235: "#262626", 236: "#303030", 237: "#3a3a3a", 238: "#444444", 239: "#4e4e4e", 240: "#585858", 241: "#626262", 242: "#6c6c6c", 243: "#767676", 244: "#808080", 245: "#8a8a8a", 246: "#949494", 247: "#9e9e9e", 248: "#a8a8a8", 249: "#b2b2b2", 250: "#bcbcbc", 251: "#c6c6c6", 252: "#d0d0d0", 253: "#dadada", 254: "#e4e4e4", 255: "#eeeeee"})

