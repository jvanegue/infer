void hensel_tacas22_non_terminate(int x, int y)
{
  y = 0;
  while (x > 0)
    {
      x--;
      y++;
    }
  while (y > 1)
    y = y;
}
