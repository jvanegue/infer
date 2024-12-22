void external_call(int &k);

int iterate_loop_short()
{
  int k;
  for (k = 0; k < 2; k++)
    external_call(k);
  return (k);
}
