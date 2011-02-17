
function paint#bytes#import()
  return s:bytes
endfunction

let s:bytes = {}

function! s:bytes.writefile(bytes, filename)
  let lines = self.bytes2lines(a:bytes)
  if writefile(lines, a:filename, 'b') != 0
    throw "Can't write file"
  endif
endfunction

function! s:bytes.bytes2lines(bytes)
  let table = map(range(256), 'printf(''\x%02x'', v:val == 0 ? 10 : v:val)')
  let lines = []
  let start = 0
  while start < len(a:bytes)
    let end = index(a:bytes, 10, start)
    if end == -1
      let end = len(a:bytes)
    endif
    let line = eval('"' . join(map(range(start, end - 1), 'table[a:bytes[v:val]]'), '') . '"')
    call add(lines, line)
    if end == len(a:bytes) - 1
      call add(lines, '')
    endif
    let start = end + 1
  endwhile
  return lines
endfunction

