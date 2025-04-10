/* pulse-inf: works good */
void fcall(int y) { y++; }

void FN_loop_call_bad(int y) {
  while (y == 100)
    fcall(y);
  return;
}
