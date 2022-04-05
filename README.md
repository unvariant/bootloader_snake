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

Issues:<br>
A bitmap will not work because you cannot determine the position of the tail which is needed to simulate
the snakes movement. You still need to somehow efficiently store the snake.

Solution:<br>
store position of the snake head<br>
store the positions of the snake body relative to the head<br>
if the head is at 5,5<br>
then an example body might be down, right, right, down, left, etc<br>
there are 4 possible states: up, down, left, right<br>
each part of the snake body only needs 2 bits<br>
to simulate the movement get user input<br>
move the snake head and delete the snake tail unless the snake just ate an apple<br>

## Optimization
xchg when only accessing registers is one byte less than mov, but xchg is slower<br>

mov r16, #imm16 is one byte less than<br>
mov r8h, #imm8<br>
mov r8l, #imm8<br>

Issues:<br>
Unexpectly, this version (main-0.6.0) works well. The only problem I have with it is that in order to slow the game down to
a playable pace a delay was introduced by decrementing a counter a looping until it hit zero. This is inaccurate because
some ticks may take longer than others and some may take shorter than others. The solution to this is to use rdtsc
(ReaD TimeStampCounter) which returns the number of clock cycles since processor reset, to accurately simulate the delay.
Although the number of clocks per second would have to be known or else the delay would be shorter on faster computers
and longer on slower computers. Perhaps use int 0x15,ah=0x86?

New Idea:<br>
There is no need to store the snake at all, instead between each square of the snake add a single pixel width line that
seperates the squares. To determine the tail position take the head position and recursively or iteratively search for the
black line using the BIOS read pixel int 0x10,ah=0x0d. When none is found the tail is found. This would be slower than the
above approach but might use less space.