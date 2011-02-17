" PNG (Portable Network Graphics) Specification, Version 1.2
" http://www.libpng.org/pub/png/spec/1.2/PNG-Contents.html

function paint#png#save(canvas, filename, color_type)
  call s:save(a:canvas, a:filename, a:color_type)
endfunction

let s:bytes = paint#bytes#import()
let s:zlib = paint#zlib#import()
let s:crc = paint#crc#import()

function s:save(canvas, filename, color_type)
  let file_header = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]
  let out = []
  call extend(out, file_header)
  call extend(out, s:ihdr(a:canvas, a:color_type))
  call extend(out, s:idat(a:canvas, a:color_type))
  call extend(out, s:iend(a:canvas))
  call s:bytes.writefile(out, a:filename)
endfunction

function s:ihdr(canvas, color_type)
  let data = []
  " Width (4)
  call extend(data, s:long2bytes(a:canvas.width))
  " Height (4)
  call extend(data, s:long2bytes(a:canvas.height))
  " Bit depth (1)
  call add(data, 8)
  " Color type (1)  2=RGB 6=RGBA
  if a:color_type == "RGBA"
    call add(data, 6)
  elseif a:color_type == "RGB"
    call add(data, 2)
  endif
  " Compression method (1)  0=Deflate
  call add(data, 0)
  " Filter method (1)
  call add(data, 0)
  " Interface method (1)    0=NoInterlace
  call add(data, 0)
  let type = [char2nr('I'), char2nr('H'), char2nr('D'), char2nr('R')]
  let crc = s:crc.crc(type + data)
  return s:long2bytes(len(data)) + type + data + s:long2bytes(crc)
endfunction

function s:idat(canvas, color_type)
  let imgdata = []
  let filter = 0  " None
  for y in range(a:canvas.height)
    let row = [filter]
    for x in range(a:canvas.width)
      let pixel = a:canvas.get_pixel(x, y)
      call add(row, pixel[0])
      call add(row, pixel[1])
      call add(row, pixel[2])
      if a:color_type == "RGBA"
        call add(row, get(pixel, 3, 255))
      endif
    endfor
    call extend(imgdata, row)
  endfor
  let data = s:zlib.compress(imgdata)
  let type = [char2nr('I'), char2nr('D'), char2nr('A'), char2nr('T')]
  let crc = s:crc.crc(type + data)
  return s:long2bytes(len(data)) + type + data + s:long2bytes(crc)
endfunction

function s:iend(canvas)
  let data = []
  let type = [char2nr('I'), char2nr('E'), char2nr('N'), char2nr('D')]
  let crc = s:crc.crc(type + data)
  return s:long2bytes(len(data)) + type + data + s:long2bytes(crc)
endfunction

function! s:long2bytes(n)
  let n = a:n < 0 ? a:n - 0x80000000 : a:n
  return [
        \ (n / 0x1000000 % 0x100) + (a:n < 0 ? 0x80 : 0),
        \ n / 0x10000 % 0x100,
        \ n / 0x100 % 0x100,
        \ n % 0x100,
        \ ]
endfunction

