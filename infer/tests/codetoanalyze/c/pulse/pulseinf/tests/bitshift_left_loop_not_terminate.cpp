// Simple bitshift test - will not terminate as multipl
void bitshift_left_loop_not_terminate(int i, int val)
{
  while (val << 1)
    i++;
}
