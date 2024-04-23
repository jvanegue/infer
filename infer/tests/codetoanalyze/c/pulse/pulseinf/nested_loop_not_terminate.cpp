/* pulse-inf: works good */
void nested_loop_not_terminate(int y) {
  int x = 42;
  while (y < 100) {
    while (x <= 100) {
      if (x == 100)
	{
	  x = 1;
	  y = 0;
	}
      else
	x++;
    }
  }
}
