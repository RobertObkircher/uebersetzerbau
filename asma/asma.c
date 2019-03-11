// this was compiled with `gcc -O -S`
void asma(unsigned long *a, unsigned long *b, unsigned long c) {
    unsigned long longs = c >> 6;
    unsigned long bits = c & 63;

    // removed the if
    
    b[0] = (a[(0-longs)%2]<<bits)|(a[(-1-longs)%2]>>-bits);
    b[1] = (a[(1-longs)%2]<<bits)|(a[( 0-longs)%2]>>-bits);
}
