#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void bin(char byte, char * buf) {
    for(int i = 0; i < 8; i++) {
        *(buf + 7 - i) = 0x30 + (byte & 1);
        byte >>= 1;
    }
}

int main(int argc, char* argv[]) {
    if(argc < 3) {
        printf("two arguments are needed");
        exit(0);
    }
    int rows = atoi(argv[1]);
    int cols = atoi(argv[2]);
    int bits = 2;

    int rowlen = cols * bits;
    int total = rowlen * rows;
    int bytes = total / 8 + (total % 8 != 0);

    char * board = (char *) malloc(bytes);

    memset(board, 0b10101010, rowlen / 8);
    *(board + rowlen / 8) = 0b10101010 << (8 - rowlen % 8);

    int b = rowlen;

    do {
        *(board + b / 8) = 0b00000010 << (6 - b % 8);
        *(board + (b + rowlen - bits) / 8) |= 0b00000010 << (6 - (b + rowlen - bits) % 8);
        b += rowlen;
    } while(b < total - rowlen);

    if(b % 8 != 0) {
        *(board + b / 8) |= 0b10101010 >> b % 8;
        b += 8 - b % 8;
    }

    memset(board + b / 8, 0b10101010, (b + rowlen) / 8);

    if((b + rowlen) % 8 != 0) {
        *(board + (b + rowlen) / 8) |= 0b10101010 << (8 - (b + rowlen) % 8);
    }

    char * buf = (char *) malloc(9);
    buf[8] = 0;
    printf("db");
    for(int i = 0; i < bytes; i++) {
        bin(*(board + i), buf);
        printf(" 0b%s", buf);
        if(i < bytes - 1) {
            printf(",");
            if((i + 1) % 8 == 0) {
                printf("\ndb");
            }
        }
    }

    return 0;
}
