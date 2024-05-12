// Simple bitshift test - will terminate as i will eventually reach 0
void bitshift_right_loop_terminate(int i)
{
  while (i)
    i = i >> 1;
}
