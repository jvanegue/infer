/* pulse inf works if x is a parameter */
/* pulse inf DOES NOT work (FN) if x is a local variable */
int simple_loop_not_terminate(int x, int y) {

  while (x != 3)
    y++;
  return (y);
}
