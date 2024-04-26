/* pulse-inf: works good */
void nested_loop_not_terminate(int y) {
  int x = 1;
  while (y < 100) {
    while (x <= 100) {
      if (x == 10)
	x = 1;
      else
	x++;
    }
    y++;
  }
}
