// Simple bitmask test
void bitmask_terminate(int i)
{
  while ((i << 1) & 2)
    i++;
  return (i + 1);    
}
