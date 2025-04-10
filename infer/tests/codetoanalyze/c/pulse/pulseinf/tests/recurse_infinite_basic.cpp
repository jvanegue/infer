int recurse_infinite_basic(int k)
{
  if (k % 2)
    k--;
  recurse_infinite_basic(k);
}
