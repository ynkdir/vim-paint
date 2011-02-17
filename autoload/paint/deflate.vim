" DEFLATE Compressed Data Format Specification version 1.3
" http://www.ietf.org/rfc/rfc1951.txt

function paint#deflate#import()
  return s:deflate
endfunction

let s:deflate = {}

" no compression
function s:deflate.deflate(data)
  let MAXSIZE = 32768
  let out = []
  let i = 0
  while 1
  while i < len(a:data)
    if len(a:data) - i <= MAXSIZE
      " flag bits:
      "     1   final
      "    00   BTYPE_NO_COMPRESSION
      " xxxxx   padding
      let flag = 0x01
      let size = len(a:data) - i
    else
      let flag = 0x00
      let size = MAXSIZE
    endif
    call add(out, flag)
    " len
    call extend(out, self.int16bits(size))
    " nlen (one's complement of len)
    call extend(out, self.int16bits(0xffff - size))
    call extend(out, a:data[i : i + size - 1])
    let i += size
  endwhile
  return out
endfunction

function! s:deflate.int16bits(n)
  return [a:n % 0x100, a:n / 0x100]
endfunction

