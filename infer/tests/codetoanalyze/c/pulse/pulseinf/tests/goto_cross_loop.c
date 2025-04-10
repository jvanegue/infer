/* Goto in loop */
/* Pulseinf: FN */
void FN_goto_cross_loop_bad()
{
  int i = 0;

 retry:
  while (i < 10)
    {
      if (i == 5)
	goto retry;
      i++;
    }
}
