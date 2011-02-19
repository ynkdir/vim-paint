" http://oku.edu.mie-u.ac.jp/~okumura/algo/
" P245 image compression using fractals

let s:fern = {
      \ 'left': -5.0,
      \ 'bottom': 0.0,
      \ 'right': 5.0,
      \ 'top': 10.0,
      \ 'a': [ 0.0,  0.85,  0.2,  -0.15],
      \ 'b': [ 0.0,  0.04, -0.26,  0.28],
      \ 'c': [ 0.0, -0.04,  0.23,  0.26],
      \ 'd': [ 0.16, 0.85,  0.22,  0.24],
      \ 'e': [ 0.0,  0.0,   0.0,   0.0],
      \ 'f': [ 0.0,  1.6,   1.6,   0.44],
      \ }

let s:triangle = {
      \ 'left': 0.0,
      \ 'bottom': 0.0,
      \ 'right': 1.0,
      \ 'top': 1.0,
      \ 'a': [0.5, 0.5, 0.5],
      \ 'b': [0.0, 0.0, 0.0],
      \ 'c': [0.0, 0.0, 0.0],
      \ 'd': [0.5, 0.5, 0.5],
      \ 'e': [0.0, 1.0, 0.5],
      \ 'f': [0.0, 0.0, 0.5],
      \ }

let s:simpletree = {
      \ 'left': -1.0,
      \ 'bottom': 0.0,
      \ 'right': 1.0,
      \ 'top': 1.0,
      \ 'a': [0.0, 0.1,  0.42,  0.42],
      \ 'b': [0.0, 0.0, -0.42,  0.42],
      \ 'c': [0.0, 0.0,  0.42, -0.42],
      \ 'd': [0.5, 0.1,  0.42,  0.42],
      \ 'e': [0.0, 0.0,  0.0,   0.0],
      \ 'f': [0.0, 0.2,  0.2,   0.2],
      \ }

let s:complextree = {
      \ 'left': -1.0,
      \ 'bottom': 0.0,
      \ 'right': 1.0,
      \ 'top': 2.0,
      \ 'a': [0.05, 0.05, 0.46,  0.47,  0.43,  0.42],
      \ 'b': [0.0,  0.0, -0.32, -0.15,  0.28,  0.26],
      \ 'c': [0.0,  0.0,  0.39,  0.17, -0.25, -0.35],
      \ 'd': [0.6, -0.5,  0.38,  0.42,  0.45,  0.31],
      \ 'e': [0.0,  0.0,  0.0,   0.0,   0.0,   0.0],
      \ 'f': [0.0,  1.0,  0.6,   1.1,   1.0,   0.7],
      \ }

function! s:ifs(data, width, height, filename)
  let left = a:data.left
  let bottom = a:data.bottom
  let right = a:data.right
  let top = a:data.top
  let a = a:data.a
  let b = a:data.b
  let c = a:data.c
  let d = a:data.d
  let e = a:data.e
  let f = a:data.f

  let N = len(a)
  let M = 25 * N

  let ip = repeat([0], N)
  let table = repeat([0], M)
  let p = repeat([0.0], N)

  let s = 0
  for i in range(N)
    let p[i] = abs(a[i] * d[i] - b[i] * c[i])
    let s += p[i]
    let ip[i] = i
  endfor
  for i in range(N - 1)
    let k = i
    for j in range(i + 1, N - 1)
      if p[j] < p[k]
        let k = j
      endif
    endfor
    let [p[i], p[k]] = [p[k], p[i]]
    let [ip[i], ip[k]] = [ip[k], ip[i]]
  endfor
  let r = M
  for i in range(N)
    let k = float2nr(r * p[i] / s + 0.5)
    let s -= p[i]
    while 1
      let r -= 1
      let table[r] = ip[i]
      let k -= 1
      if k > 0
        continue
      endif
      break
    endwhile
  endfor
  let canvas = paint#canvas#new(a:width, a:height)
  let x = 0
  let y = 0
  if a:data is s:complextree
    let u = 0
  endif
  for i in range(30000)
    let j = table[s:rand() / (s:RAND_MAX / M + 1)]
    let t = a[j] * x + b[j] * y + e[j]
    let y = c[j] * x + d[j] * y + f[j]
    let x = t
    if a:data is s:complextree
      if j == 0 || j == 1
        let u = 4
      else
        let u -= 1
      endif
    endif
    if i >= 10
      let sx = canvas.width / (right - left)
      let sy = canvas.height / (top - bottom)
      let scale = sx < sy ? sx : sy
      let px = (x * scale) - (left * scale)
      let py = (y * scale) - (bottom * scale)
      let py = canvas.height - py
      if a:data is s:complextree
        if u > 0
          call canvas.set_pixel(float2nr(px), float2nr(py), [153, 76, 0])
        else
          call canvas.set_pixel(float2nr(px), float2nr(py), [0, 255, 0])
        endif
      else
        call canvas.set_pixel(float2nr(px), float2nr(py), [0, 0, 0])
      endif
    endif
  endfor
  call canvas.save(a:filename)
endfunction

let s:RAND_MAX = 32767
let s:seed = float2nr(fmod(str2float(reltimestr(reltime())) * 256, 2147483648.0))
function! s:rand()
  let s:seed = s:seed * 214013 + 2531011
  return (s:seed < 0 ? s:seed - 0x80000000 : s:seed) / 0x10000 % 0x8000
endfunction

function! s:main()
  echo "rendering ifs_fern.bmp"
  call s:ifs(s:fern, 320, 200, "ifs_fern.bmp")
  echo "rendering ifs_triangle.bmp"
  call s:ifs(s:triangle, 320, 200, "ifs_triangle.bmp")
  echo "rendering ifs_simpletree.bmp"
  call s:ifs(s:simpletree, 320, 200, "ifs_simpletree.bmp")
  echo "rendering ifs_complextree.bmp"
  call s:ifs(s:complextree, 320, 200, "ifs_complextree.bmp")
endfunction

try
  call s:main()
endtry

