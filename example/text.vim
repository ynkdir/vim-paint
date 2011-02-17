let canvas = paint#canvas#new(128, 128)

let fixed = paint#bdf#loadfile(globpath(&rtp, 'font/mplus/mplus_f12r.bdf'))
let helvetica = paint#bdf#loadfile(globpath(&rtp, 'font/mplus/mplus_h12r.bdf'))

call canvas.draw_rect([30, 5], [80, 105], [128, 128, 0], -1)

let x = 10
let y = 10

let text = "hello, vim paint"

let [width, height, baseline] = canvas.get_text_size(text, fixed)

call canvas.draw_rect([x, y], [x + width - 1, y + height + baseline - 1], [255, 0, 0], -1)
call canvas.draw_text(text, [x, y + height], fixed, [0, 0, 0])
let y += height + baseline

call canvas.draw_rect([x, y], [x + width - 1, y + height + baseline - 1], [0, 255, 0], -1)
call canvas.draw_text(text, [x, y + height], fixed, [0, 0, 0])
let y += height + baseline

call canvas.draw_rect([x, y], [x + width - 1, y + height + baseline - 1], [0, 0, 255], -1)
call canvas.draw_text(text, [x, y + height], fixed, [0, 0, 0])
let y += height + baseline

let [width, height, baseline] = canvas.get_text_size(text, helvetica)

call canvas.draw_text(text, [x, y + height], helvetica, [255, 0, 0])
let y += height + baseline

call canvas.draw_text(text, [x, y + height], helvetica, [0, 255, 0])
let y += height + baseline

call canvas.draw_text(text, [x, y + height], helvetica, [0, 0, 255])
let y += height + baseline

call canvas.save('example_text.bmp')
