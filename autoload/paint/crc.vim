" PNG (Portable Network Graphics) Specification, Version 1.2
" 15. Appendix: Sample CRC Code
" http://www.libpng.org/pub/png/spec/1.2/PNG-CRCAppendix.html

function paint#crc#import()
  return s:crc
endfunction

let s:bitwise = paint#bitwise#import()

let s:crc = {}

" Table of CRCs of all 8-bit messages.
" unsigned long crc_table[256];
let s:crc.crc_table = repeat([0], 256)

" Flag: has the table been computed? Initially false.
" int crc_table_computed = 0;
let s:crc.crc_table_computed = 0

" Make the table for a fast CRC.
" void make_crc_table(void)
function s:crc.make_crc_table()
  for n in range(256)
    let c = n
    for k in range(8)
      if s:bitwise.and(c, 1)
        let c = s:bitwise.xor(0xedb88320, s:bitwise.rshift(c, 1))
      else
        let c = s:bitwise.rshift(c, 1)
      endif
    endfor
    let self.crc_table[n] = c
  endfor
  let self.crc_table_computed = 1
endfunction

" Update a running CRC with the bytes buf[0..len-1]--the CRC
" should be initialized to all 1's, and the transmitted value
" is the 1's complement of the final running CRC (see the
" crc() routine below)).

" unsigned long update_crc(unsigned long crc, unsigned char *buf,
"                         int len)
function s:crc.update_crc(crc, buf)
  if !self.crc_table_computed
    call self.make_crc_table()
  endif
  let c = a:crc
  for x in a:buf
    let i = s:bitwise.and(s:bitwise.xor(c, x), 0xff)
    let c = s:bitwise.xor(self.crc_table[i], s:bitwise.rshift(c, 8))
  endfor
  return c
endfunction

" Return the CRC of the bytes buf[0..len-1].
" unsigned long crc(unsigned char *buf, int len)
function s:crc.crc(buf)
  return s:bitwise.xor(self.update_crc(0xffffffff, a:buf), 0xffffffff)
endfunction

