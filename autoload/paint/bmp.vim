" http://en.wikipedia.org/wiki/BMP_file_format

function paint#bmp#save(canvas, filename, color_type)
  let bmp = s:bmp.new(a:canvas, a:color_type)
  call bmp.save(a:filename)
endfunction

let s:bytes = paint#bytes#import()

let s:bmp = {}

function s:bmp.new(canvas, color_type)
  let obj = deepcopy(self)
  call obj.__init__(a:canvas, a:color_type)
  return obj
endfunction

function s:bmp.__init__(canvas, color_type)
  let self.canvas = a:canvas
  let self.color_type = a:color_type
  let self.out = []
endfunction

function s:bmp.save(filename)
  let self.out = []
  call self.bitmap_file_header()
  call self.bitmap_info_header()
  call self.imgdata()
  call s:bytes.writefile(self.out, a:filename)
endfunction

function s:bmp.bitmap_file_header()
  " Magic Number
  call extend(self.out, [char2nr('B'), char2nr('M')])
  " file size
  call extend(self.out, self.int32le(14 + 40 + self.imgsize()))
  " reserved
  call extend(self.out, self.int16le(0))
  " reserved
  call extend(self.out, self.int16le(0))
  " offset of image data
  " sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER)
  call extend(self.out, self.int32le(14 + 40))
endfunction

function s:bmp.bitmap_info_header()
  " header size
  call extend(self.out, self.int32le(40))
  " width
  call extend(self.out, self.int32le(self.canvas.width))
  " height
  call extend(self.out, self.int32le(self.canvas.height))
  " plane
  call extend(self.out, self.int16le(1))
  " bit count
  if self.color_type == "RGBA"
    call extend(self.out, self.int16le(32))
  elseif self.color_type == "RGB"
    call extend(self.out, self.int16le(24))
  endif
  " compression   0=none
  call extend(self.out, self.int32le(0))
  " bmp_bytesz
  call extend(self.out, self.int32le(self.imgsize()))
  " hres
  call extend(self.out, self.int32le(0))
  " vres
  call extend(self.out, self.int32le(0))
  " ncolors
  call extend(self.out, self.int32le(0))
  " nimpcolors
  call extend(self.out, self.int32le(0))
endfunction

function s:bmp.imgdata()
  let rowsize = self.rowsize()
  for y in range(self.canvas.height - 1, 0, -1)
    let n = 0
    for x in range(self.canvas.width)
      let pixel = self.canvas.get_pixel(x, y)
      if self.color_type == "RGBA"
        call add(self.out, pixel[2])
        call add(self.out, pixel[1])
        call add(self.out, pixel[0])
        call add(self.out, get(pixel, 3, 255))
        let n += 4
      elseif self.color_type == "RGB"
        call add(self.out, pixel[2])
        call add(self.out, pixel[1])
        call add(self.out, pixel[0])
        let n += 3
      endif
    endfor
    " padding
    for i in range(n, rowsize - 1)
      call add(self.out, 0)
    endfor
  endfor
endfunction

function s:bmp.rowsize()
  if self.color_type == "RGBA"
    let bpp = 32
  elseif self.color_type == "RGB"
    let bpp = 24
  endif
  return float2nr(ceil((1.0 * self.canvas.width) * bpp / 32) * 4)
endfunction

function s:bmp.imgsize()
  return self.rowsize() * self.canvas.height
endfunction

function s:bmp.int32le(n)
  let n = a:n < 0 ? a:n - 0x80000000 : a:n
  return [
        \ n % 0x100,
        \ n / 0x100 % 0x100,
        \ n / 0x10000 % 0x100,
        \ (n / 0x1000000 % 0x100) + (a:n < 0 ? 0x80 : 0),
        \ ]
endfunction

function s:bmp.int16le(n)
  return [
        \ a:n % 0x100,
        \ a:n / 0x100 % 0x100,
        \ ]
endfunction

