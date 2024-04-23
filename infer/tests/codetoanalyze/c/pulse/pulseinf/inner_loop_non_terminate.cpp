/* pulse-inf: works good! */
void inner_loop_non_terminate(int y, int x) {
  while (y < 100)
    {
      while (x == 0)
	y++;
      y++;
    }
}
