// Simple bitshift test - will not terminate as multipl
void bitshift_left_loop_not_terminate(int i)
{
  while (i)
    i = i << 1;
}
