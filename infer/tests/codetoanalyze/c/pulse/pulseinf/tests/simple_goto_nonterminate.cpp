/* Pulse-inf: false negative: no goto support */
void simple_goto_not_terminate(int y) {
 re:
  y++;
  goto re;
}
