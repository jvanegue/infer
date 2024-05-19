/* pulse inf works if x is a parameter */
/* pulse inf DOES NOT work (FN) if x is a local variable */

//int f();

void simple_loop_not_terminate(int y, int x) {
  //int x = 1;
  while (x != 3)
    y++;
}
