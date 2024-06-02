void bitmask_loop_terminate(unsigned int i)
{
  while (i % 2)
    i = (i << 1);
}
