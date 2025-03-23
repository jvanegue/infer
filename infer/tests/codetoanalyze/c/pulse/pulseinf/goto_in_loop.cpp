void goto_in_loop()
{
  int i = 0;

  while (i < 100)
    {
    retry:
      if (i == 50)
	goto retry;
      i++;
    }
}
