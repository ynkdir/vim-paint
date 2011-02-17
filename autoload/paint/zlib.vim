" ZLIB Compressed Data Format Specification version 3.3
" http://www.ietf.org/rfc/rfc1950.txt

function paint#zlib#import()
  return s:zlib
endfunction

let s:deflate = paint#deflate#import()
let s:adler32 = paint#adler32#import()

let s:zlib = {}

function s:zlib.compress(data)
  let cmf = 0x78
  let flg = 0x01
  let compressed_data = s:deflate.deflate(a:data)
  let checksum = s:long2bytes(s:adler32.adler32(a:data))
  return [cmf, flg] + compressed_data + checksum
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

