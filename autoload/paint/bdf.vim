" http://en.wikipedia.org/wiki/Glyph_Bitmap_Distribution_Format

function paint#bdf#loadfile(bdffile)
  let font = s:font.new()
  call font.loadfile(a:bdffile)
  return font
endfunction

let s:font = {}
let s:font.fontboundingbox = [0, 0, 0, 0]
let s:font.default_char = 0
let s:font.glyphs = {}

function s:font.new()
  let obj = deepcopy(self)
  call obj.__init__()
  return obj
endfunction

function s:font.__init__()
  " pass
endfunction

function s:font.loadfile(bdffile)
  let lines = readfile(a:bdffile)
  let i = 0
  while lines[i] != 'ENDFONT'
    if lines[i] =~ '^FONTBOUNDINGBOX '
      " FONTBOUNDINGBOX FBBx FBBy Xoff Yoff
      let cols = split(lines[i])
      let self.fontboundingbox[0] = str2nr(cols[1])
      let self.fontboundingbox[1] = str2nr(cols[2])
      let self.fontboundingbox[2] = str2nr(cols[3])
      let self.fontboundingbox[3] = str2nr(cols[4])
    elseif lines[i] =~ '^DEFAULT_CHAR '
      " DEFAULT_CHAR char
      let cols = split(lines[i])
      let self.default_char = str2nr(cols[1])
    elseif lines[i] =~ '^STARTCHAR '
      let glyph = self.readchar(lines, i)
      let self.glyphs[glyph.encoding] = glyph
      while lines[i] != 'ENDCHAR'
        let i += 1
      endwhile
    endif
    let i += 1
  endwhile
endfunction

function s:font.readchar(lines, i)
  let i = a:i

  let glyph = {}
  let glyph.encoding = 0
  let glyph.width = 0
  let glyph.swidth = [0, 0]
  let glyph.dwidth = [0, 0]
  let glyph.swidth1 = [0, 0]
  let glyph.dwidth1 = [0, 0]
  let glyph.vvector = [0, 0]
  let glyph.bbx = [0, 0, 0, 0]
  " bitmap[y][x] = 0|1
  let glyph.bitmap = []

  while a:lines[i] != 'ENDCHAR'
    if a:lines[i] =~ '^ENCODING '
      " ENCODING integer (integer)
      let cols = split(a:lines[i])
      let glyph.encoding = str2nr(cols[1])
    elseif a:lines[i] =~ '^SWIDTH '
      " SWIDTH swx0 swy0
      let cols = split(a:lines[i])
      let glyph.swidth[0] = str2nr(cols[1])
      let glyph.swidth[1] = str2nr(cols[2])
    elseif a:lines[i] =~ '^DWIDTH '
      " DWIDTH dwx0 dwy0
      let cols = split(a:lines[i])
      let glyph.dwidth[0] = str2nr(cols[1])
      let glyph.dwidth[1] = str2nr(cols[2])
    elseif a:lines[i] =~ '^SWIDTH1 '
      " SWIDTH1 swx1 swy1
      let cols = split(a:lines[i])
      let glyph.swidth1[0] = str2nr(cols[1])
      let glyph.swidth1[1] = str2nr(cols[2])
    elseif a:lines[i] =~ '^DWIDTH1 '
      " DWIDTH1 dwx1 dwy1
      let cols = split(a:lines[i])
      let glyph.dwidth1[0] = str2nr(cols[1])
      let glyph.dwidth1[1] = str2nr(cols[2])
    elseif a:lines[i] =~ '^VVECTOR '
      " VVECTOR xoff yoff
      let cols = split(a:lines[i])
      let glyph.vvector[0] = str2nr(cols[1])
      let glyph.vvector[1] = str2nr(cols[2])
    elseif a:lines[i] =~ '^BBX '
      " BBX BBw BBh BBxoff0x BByoff0y
      let cols = split(a:lines[i])
      let glyph.bbx[0] = str2nr(cols[1])
      let glyph.bbx[1] = str2nr(cols[2])
      let glyph.bbx[2] = str2nr(cols[3])
      let glyph.bbx[3] = str2nr(cols[4])
    elseif a:lines[i] =~ 'BITMAP'
      while a:lines[i + 1] != 'ENDCHAR'
        let bits = self.hex2bits(a:lines[i + 1], glyph.bbx[0])
        call add(glyph.bitmap, bits)
        let i += 1
      endwhile
    endif
    let i += 1
  endwhile

  return glyph
endfunction

function s:font.hex2bits(hex, len)
  let bits = []
  for x in split(a:hex, '\zs')
    call extend(bits, self.hexbits[str2nr(x, 16)])
  endfor
  return bits[0 : a:len - 1]
endfunction

let s:font.hexbits = [
      \ [0, 0, 0, 0],
      \ [0, 0, 0, 1],
      \ [0, 0, 1, 0],
      \ [0, 0, 1, 1],
      \ [0, 1, 0, 0],
      \ [0, 1, 0, 1],
      \ [0, 1, 1, 0],
      \ [0, 1, 1, 1],
      \ [1, 0, 0, 0],
      \ [1, 0, 0, 1],
      \ [1, 0, 1, 0],
      \ [1, 0, 1, 1],
      \ [1, 1, 0, 0],
      \ [1, 1, 0, 1],
      \ [1, 1, 1, 0],
      \ [1, 1, 1, 1],
      \ ]

"
" |hello, world
" +------------
" ^
" origin
function s:font.draw_text(canvas, text, org, color)
  let [ox, oy] = a:org
  for c in map(split(a:text, '\zs'), 'char2nr(v:val)')
    if !has_key(self.glyphs, c)
      let c = self.default_char
    endif
    let glyph = self.glyphs[c]
    let [BBw, BBh, BBxoff, BByoff] = glyph.bbx
    for bx in range(BBw)
      for by in range(BBh)
        let x = ox + bx + BBxoff
        let y = oy + by - BBh - BByoff
        if glyph.bitmap[by][bx]
          call a:canvas.set_pixel(x, y, a:color)
        endif
      endfor
    endfor
    let [dwx0, dwy0] = glyph.dwidth
    let ox += dwx0
    let oy += dwy0
  endfor
endfunction

" @return [width, height, baseline]
" textSize: Resultant size of the text string. Height of the text does
"           not include the height of character parts that are below the
"           baseline.
" baselne: y-coordinate of the baseline relative to the bottom-most text point
function s:font.get_text_size(text)
  let width = 0
  for c in map(split(a:text, '\zs'), 'char2nr(v:val)')
    if !has_key(self.glyphs, c)
      let c = self.default_char
    endif
    let glyph = self.glyphs[c]
    let [dwx0, dwy0] = glyph.dwidth
    let width += dwx0
  endfor
  let [FBBx, FBBy, Xoff, Yoff] = self.fontboundingbox
  let height = FBBy + Yoff
  let baseline = -Yoff
  return [width, height, baseline]
endfunction

