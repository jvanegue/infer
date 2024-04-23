/* pulse-inf: works good */
void loop_alternating_not_terminate(int y, int x) {
  int turn = 0;
  while (x < 100) {
    if (turn)
      x++;
    else 
      x--;
    turn = (turn ? 0 : 1);
  }
}
