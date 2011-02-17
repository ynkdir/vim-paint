let canvas = paint#canvas#new(128, 128)

call canvas.draw_line([10, 10], [50, 10], [0, 0, 0], 1)
call canvas.draw_line([10, 20], [50, 20], [0, 0, 0], 2)
call canvas.draw_line([10, 30], [50, 30], [0, 0, 0], 3)
call canvas.draw_line([10, 40], [50, 40], [0, 0, 0], 4)
call canvas.draw_line([10, 50], [50, 50], [0, 0, 0], 5)

call canvas.draw_line([10, 80], [10, 120], [0, 0, 0], 1)
call canvas.draw_line([20, 80], [20, 120], [0, 0, 0], 2)
call canvas.draw_line([30, 80], [30, 120], [0, 0, 0], 3)
call canvas.draw_line([40, 80], [40, 120], [0, 0, 0], 4)
call canvas.draw_line([50, 80], [50, 120], [0, 0, 0], 5)

call canvas.draw_line([80,  80], [120, 40], [0, 0, 0], 1)
call canvas.draw_line([80,  90], [120, 50], [0, 0, 0], 2)
call canvas.draw_line([80, 100], [120, 60], [0, 0, 0], 3)
call canvas.draw_line([80, 110], [120, 70], [0, 0, 0], 4)
call canvas.draw_line([80, 120], [120, 80], [0, 0, 0], 5)

call canvas.save('example_line.bmp')
