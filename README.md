# bootloader_snake
Snake game in a bootloader

Initial idea:<br>
To represent the snake an array of (x, y) coordinates are used, and to save space each (x, y) pair will only take 4 bits. This allows for a 14 x 14 area for the snake to move in. 4 bits means 16 numbers, 2 are used for the borders and the rest for the game area. Collision with the walls is done by checking the position of the head, which is guaranteed to always be at the start of the array. As the snake grows positions are appended to the end of the array. To render the snake iterate over the array and write characters to the given (x, y) coordinates. When the snake grows simply update the head to its new value and shift all the values one index to the right in the array. When the snake is not growing do the same except remove the last element after the shift. Each (x, y) pair will take up 1 byte, which makes the shifting easier as 2 (x, y) pairs can be loaded into one 16 bit register and moved simultaneously.

Issues:<br>
My program quickly ran out of memory as storing the coordinates for the snake took around 200 of the 512 available bytes. Still need to implement collision detection with the borders and when the snake hits itself. Found out that the rdrand and rdseed instructions are not availible, need to figure out some other method to randomly generate positions for the apple. One possible optimiztion to reduce the amount of space the snake takes up would be to only store the start and end points of the lines that make up the snake. Updating the snake becomes somewhat more complicated because decreasing the snakes size cannot be achieved by deleting the last coordinate.

More Issues:<br>
Ran out of memory AGAIN, this is getting annoying.

Solution:<br>
Instead of storing the snakes coordinates just use a bitmap (why didn't I think of this before). Each element of the bitmap is two bits which stores the color of the corresponding area of the screen.