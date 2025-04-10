void goto_in_loop()
{
  int i = 0;
  while (i < 10)
    {
      i++;
    retry:
      if (i == 5)
	goto retry;
    }
}
