" Adler 32 checksum
" ZLIB Compressed Data Format Specification version 3.3
" 9. Appendix: Sample code
" http://www.ietf.org/rfc/rfc1950.txt

function paint#adler32#import()
  return s:adler32
endfunction

let s:bitwise = paint#bitwise#import()

let s:adler32 = {}

"#define BASE 65521 /* largest prime smaller than 65536 */
let s:adler32.BASE = 65521

" unsigned long update_adler32(unsigned long adler,
"    unsigned char *buf, int len)
function s:adler32.update_adler32(adler, buf)
  let s1 = s:bitwise.and(a:adler, 0xffff)
  let s2 = s:bitwise.and(s:bitwise.rshift(a:adler, 16), 0xffff)
  for x in a:buf
    let s1 = (s1 + x) % self.BASE
    let s2 = (s2 + s1) % self.BASE
  endfor
  return (s2 * 0x10000) + s1
endfunction

" Return the adler32 of the bytes buf[0..len-1]
" unsigned long adler32(unsigned char *buf, int len)
function s:adler32.adler32(buf)
  return self.update_adler32(1, a:buf)
endfunction

