
/* From: libpng */
/* Test from libpng with typedefs */
int	png_palette_terminate(int val)
{
  int	num;
  int	i;
  int	p = 0;
  
  if (val == 0)
    num = 1;
  else
    num = 256;

  for (i = 0; i < num; i++)
    p += val;

  return (p);
}
