void asmb(unsigned long *a, unsigned long *b, unsigned long c, unsigned long n)
{
  unsigned long longs=c>>6;
  unsigned long bits = c & 63;
  unsigned long i;
  if (bits == 0)
    for (i=0; i<n; i++)
      b[i] = a[(i-longs)%n];
  else
    for (i=0; i<n; i++)
      b[i] = (a[(i-longs)%n]<<bits)|(a[(i-longs-1)%n]>>-bits);
}

