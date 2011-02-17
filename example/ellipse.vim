let canvas = paint#canvas#new(128, 128)

call canvas.draw_ellipse([32, 32], [96, 96], [128, 128, 128], -1)

call canvas.draw_ellipse([10, 10], [60, 60], [128, 0, 128], -1)
call canvas.draw_ellipse([10, 10], [60, 60], [0, 0, 0], 1)

call canvas.draw_ellipse([10, 70], [60, 100], [0, 0, 0], 1)

call canvas.draw_ellipse([70, 10], [100, 60], [128, 128, 0], -1)

call canvas.draw_ellipse([70, 70], [110, 110], [0, 0, 0], 2)

call canvas.save('example_ellipse.bmp')
