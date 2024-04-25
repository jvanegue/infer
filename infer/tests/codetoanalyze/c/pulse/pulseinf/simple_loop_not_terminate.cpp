/* pulse inf works if x is a parameter */
/* pulse inf DOES NOT work (FN) if x is a local variable */

void simple_loop_not_terminate(int y) {
  int x = 1;
  while (x != 3)
    y++;
}
