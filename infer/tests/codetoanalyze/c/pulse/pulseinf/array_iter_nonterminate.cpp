// Example with array and non-termination
/* Pulse-inf: unable to find bug (with default widen threshold=3) */
void array_iter_nonterminate(int array[], int len)
{
  int i = 0;
  while (i < len) {
    array[i] = 42;
    if (i > 10)
      i = 0;
    i++;
  }
}

