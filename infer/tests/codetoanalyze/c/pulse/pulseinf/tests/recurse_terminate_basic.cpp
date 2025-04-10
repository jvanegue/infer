
int recurse_terminate(int k)
{
  if (k == 0)
    return;
  recurse_terminate(k - 1);
}
