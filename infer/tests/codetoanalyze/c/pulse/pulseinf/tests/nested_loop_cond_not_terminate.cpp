/* pulse-inf: works good */
void nested_loop_cond_not_terminate(int y, int x) {
  
  while (y < 3) {
    while (x <= 3) {
      if (x == 2)
	x = 1;
      else
	x++;
    }
    y++;
  }
}
