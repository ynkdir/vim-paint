let canvas = paint#canvas#new(128, 128)

call canvas.draw_rect([10, 10], [19, 19], [0, 0, 255], -1)
call canvas.draw_rect([10, 10], [19, 19], [255, 0, 0], 1)

call canvas.draw_rect([10, 25], [19, 34], [0, 0, 255], -1)
call canvas.draw_rect([10, 25], [19, 34], [255, 0, 0], 2)

call canvas.draw_rect([10, 40], [19, 49], [255, 0, 0], 1)

call canvas.draw_rect([10, 55], [19, 64], [255, 0, 0], 2)

call canvas.draw_rect([10, 70], [19, 79], [255, 255, 0], -1)

call canvas.draw_rect([10, 85], [19, 94], [0, 255, 255], -1)

call canvas.save('example_rect.bmp')
