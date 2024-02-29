void simple_loop_equal_notterminate()
{
  int x = 42;
  while (x == x)
    x = x + 1;
}
