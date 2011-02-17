" http://en.wikipedia.org/wiki/Netpbm_format

function paint#ppm#save(canvas, filename, color_type)
  call s:save(a:canvas, a:filename)
endfunction

function s:save(canvas, filename)
  let lines = []
  " Magic Number
  call add(lines, 'P3')
  " Width Height
  call add(lines, printf('%d %d', a:canvas.width, a:canvas.height))
  " Max Value
  call add(lines, '255')
  " Pixel Data
  for y in range(a:canvas.height)
    let row = []
    for x in range(a:canvas.width)
      let pixel = a:canvas.get_pixel(x, y)
      call add(row, pixel[0])
      call add(row, pixel[1])
      call add(row, pixel[2])
    endfor
    call add(lines, join(row))
  endfor
  call writefile(lines, a:filename)
endfunction

