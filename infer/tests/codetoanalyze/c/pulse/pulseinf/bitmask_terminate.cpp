// Simple bitmask test
void bitmask_terminate(int i)
{
  while (i % 2)
    i = (i << 1);
}
