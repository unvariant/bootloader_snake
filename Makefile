run: main.bin
	qemu-system-x86_64 main.bin

main.bin: main.asm
	nasm -f bin main.asm -o main.bin

clean:
	rm main.bin