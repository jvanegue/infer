int compute_increment(int k)
{
  return (k % 2 ? 1 : 0);
}

void loop_fcall_add_inductive_nonterminate()
{
  int i;
  int incr;
  for (i = 0; i < 10; i += incr)
    incr = compute_increment(i);
  
}
