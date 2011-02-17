
function paint#canvas#new(width, height)
  return s:canvas.new(a:width, a:height)
endfunction

let s:canvas = {}

let s:canvas.width = 0
let s:canvas.height = 0
let s:canvas.screen = []

function s:canvas.new(width, height)
  let obj = deepcopy(self)
  call obj.__init__(a:width, a:height)
  return obj
endfunction

function s:canvas.__init__(width, height)
  let self.width = a:width
  let self.height = a:height
  let self.screen = []
  for y in range(a:height)
    let row = []
    for x in range(a:width)
      call add(row, [255, 255, 255])
    endfor
    call add(self.screen, row)
  endfor
endfunction

function s:canvas.get_pixel(x, y)
  if a:x < 0 || self.width <= a:x || a:y < 0 || self.height <= a:y
    return [0, 0, 0, 0]
  endif
  return self.screen[a:y][a:x]
endfunction

function s:canvas.set_pixel(x, y, color)
  if a:x < 0 || self.width <= a:x || a:y < 0 || self.height <= a:y
    return
  endif
  let self.screen[a:y][a:x] = copy(a:color)
endfunction

function s:canvas.draw_point(x, y, color, thickness)
  if a:thickness == 1
    call self.set_pixel(a:x, a:y, a:color)
  elseif a:thickness == 2
    " 2
    " xx
    " xo
    call self.set_pixel(a:x, a:y, a:color)
    call self.set_pixel(a:x - 1, a:y, a:color)
    call self.set_pixel(a:x - 1, a:y - 1, a:color)
    call self.set_pixel(a:x, a:y - 1, a:color)
  elseif a:thickness > 2
    "  3    4      5
    "  x    xx    xxx
    " xox  xxxx  xxxxx
    "  x   xxox  xxoxx
    "       xx   xxxxx
    "             xxx
    for xi in range(a:thickness)
      for yi in range(a:thickness)
        if (xi == 0 && yi == 0)
              \ || (xi == 0 && yi == a:thickness - 1)
              \ || (xi == a:thickness - 1 && yi == 0)
              \ || (xi == a:thickness - 1 && yi == a:thickness - 1)
          continue
        endif
        let xx = a:x - (a:thickness / 2) + xi
        let yy = a:y - (a:thickness / 2) + yi
        call self.set_pixel(xx, yy, a:color)
      endfor
    endfor
  endif
endfunction

" http://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
function s:canvas.draw_line(pt1, pt2, color, thickness)
  let dx = abs(a:pt2[0] - a:pt1[0])
  let dy = abs(a:pt2[1] - a:pt1[1])
  let sx = a:pt1[0] < a:pt2[0] ? 1 : -1
  let sy = a:pt1[1] < a:pt2[1] ? 1 : -1

  let err = dx - dy

  let x = a:pt1[0]
  let y = a:pt1[1]

  while 1
    call self.draw_point(x, y, a:color, a:thickness)
    if x == a:pt2[0] && y == a:pt2[1]
      break
    endif
    let e2 = 2 * err
    if e2 > -dy
      let err = err - dy
      let x = x + sx
    endif
    if e2 < dx
      let err = err + dx
      let y = y + sy
    endif
  endwhile
endfunction

function s:canvas.draw_rect(pt1, pt2, color, thickness)
  let [left, top, right, bottom] = self._rect(a:pt1, a:pt2)
  for x in range(left, right)
    for y in range(top, bottom)
      if a:thickness < 0
        call self.set_pixel(x, y, a:color)
      else
        if x < left + a:thickness
              \ || x > right - a:thickness
              \ || y < top + a:thickness
              \ || y > bottom - a:thickness
          call self.set_pixel(x, y, a:color)
        endif
      endif
    endfor
  endfor
endfunction

function s:canvas.draw_ellipse(pt1, pt2, color, thickness)
  let [left, top, right, bottom] = self._rect(a:pt1, a:pt2)
  let cx = (left + right) / 2
  let cy = (top + bottom) / 2
  let xradius = (right - left) / 2
  let yradius = (bottom - top) / 2
  call self._plot_ellipse(cx, cy, xradius, yradius, a:color, a:thickness)
endfunction

" http://homepage.smc.edu/kennedy_john/belipse.pdf
" A Fast Bresenham Type Algorithm For Drawing Ellipses by John Kennedy
function s:canvas._plot_ellipse(cx, cy, xradius, yradius, color, thickness)
  let two_a_square = 2 * a:xradius * a:xradius
  let two_b_square = 2 * a:yradius * a:yradius
  let x = a:xradius
  let y = 0
  let x_change = a:yradius * a:yradius * (1 - 2 * a:xradius)
  let y_change = a:xradius * a:xradius
  let ellipse_error = 0
  let stopping_x = two_b_square * a:xradius
  let stopping_y = 0
  while stopping_x >= stopping_y
    call self._plot4_ellipse_points(a:cx, a:cy, x, y, a:color, a:thickness)
    let y += 1
    let stopping_y += two_a_square
    let ellipse_error += y_change
    let y_change += two_a_square
    if 2 * ellipse_error + x_change > 0
      let x -= 1
      let stopping_x -= two_b_square
      let ellipse_error += x_change
      let x_change += two_b_square
    endif
  endwhile

  let x = 0
  let y = a:yradius
  let x_change = a:yradius * a:yradius
  let y_change = a:xradius * a:xradius * (1 - 2 * a:yradius)
  let ellipse_error = 0
  let stopping_x = 0
  let stopping_y = two_a_square * a:yradius
  while stopping_x <= stopping_y
    call self._plot4_ellipse_points(a:cx, a:cy, x, y, a:color, a:thickness)
    let x += 1
    let stopping_x += two_b_square
    let ellipse_error += x_change
    let x_change += two_b_square
    if 2 * ellipse_error + y_change > 0
      let y -= 1
      let stopping_y -= two_a_square
      let ellipse_error += y_change
      let y_change += two_a_square
    endif
  endwhile
endfunction

function s:canvas._plot4_ellipse_points(cx, cy, x, y, color, thickness)
  if a:thickness < 0
    for i in range(a:x)
      call self.set_pixel(a:cx + i, a:cy + a:y, a:color)
      call self.set_pixel(a:cx - i, a:cy + a:y, a:color)
      call self.set_pixel(a:cx + i, a:cy - a:y, a:color)
      call self.set_pixel(a:cx - i, a:cy - a:y, a:color)
    endfor
  else
    call self.draw_point(a:cx + a:x, a:cy + a:y, a:color, a:thickness)
    call self.draw_point(a:cx - a:x, a:cy + a:y, a:color, a:thickness)
    call self.draw_point(a:cx - a:x, a:cy - a:y, a:color, a:thickness)
    call self.draw_point(a:cx + a:x, a:cy - a:y, a:color, a:thickness)
  endif
endfunction

function s:canvas.draw_text(text, org, font, color)
  call a:font.draw_text(self, a:text, a:org, a:color)
endfunction

function s:canvas.get_text_size(text, font)
  return a:font.get_text_size(a:text)
endfunction

function s:canvas.save(filename, ...)
  let color_type = get(a:000, 0, 'RGB')
  if a:filename =~ '\.ppm$'
    call self.save_ppm(a:filename, color_type)
  elseif a:filename =~ '\.png$'
    call self.save_png(a:filename, color_type)
  elseif a:filename =~ '\.bmp$'
    call self.save_bmp(a:filename, color_type)
  else
    throw printf('"%s" format not supported', a:filename)
  endif
endfunction

function s:canvas.save_ppm(filename, ...)
  let color_type = get(a:000, 0, 'RGB')
  call paint#ppm#save(self, a:filename, color_type)
endfunction

function s:canvas.save_png(filename, ...)
  let color_type = get(a:000, 0, 'RGB')
  call paint#png#save(self, a:filename, color_type)
endfunction

function s:canvas.save_bmp(filename, ...)
  let color_type = get(a:000, 0, 'RGB')
  call paint#bmp#save(self, a:filename, color_type)
endfunction

function s:canvas._rect(pt1, pt2)
  let left = min([a:pt1[0], a:pt2[0]])
  let top = min([a:pt1[1], a:pt2[1]])
  let right = max([a:pt1[0], a:pt2[0]])
  let bottom = max([a:pt1[1], a:pt2[1]])
  return [left, top, right, bottom]
endfunction

