# bootloader_snake
Snake game in a bootloader

Initial idea:
To represent the snake an array of (x, y) coordinates are used, and to save space each (x, y) pair will only take 4 bits. This allows for a 14 x 14 area for the snake to move in. 4 bits means 16 numbers, 2 are used for the borders and the rest for the game area. Collision with the walls is done by checking the position of the head, which is guaranteed to always be at the start of the array. As the snake grows positions are appended to the end of the array. To render the snake iterate over the array and write characters to the given (x, y) coordinates. When the snake grows simply update the head to its new value and shift all the values one index to the right in the array. When the snake is not growing do the same except remove the last element after the shift. Each (x, y) pair will take up 1 byte, which makes the shifting easier as 2 (x, y) pairs can be loaded into one 16 bit register and moved simultaneously.
