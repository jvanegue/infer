#include "hdr.h"

int func_terminate()
{
  int i;
  int ret = 0;

  for (i = 0; i < BOUND; i++)
    ret++;

  return (ret);
}
