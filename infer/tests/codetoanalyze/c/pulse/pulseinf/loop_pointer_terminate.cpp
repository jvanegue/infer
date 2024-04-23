/* pulse-inf: works good */
void loop_pointer_terminate(int *x, int y) {
  int *z = x;
  //int y = 1;
  if (x != &y)
    while (y < 100) {
      y++;
      (*z)--;
    }
}
