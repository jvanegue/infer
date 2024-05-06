
/* Harris et al. "Alternation for Termination (SAS 2010) - Terminating program */

#include <stdlib.h>
int	nondet() { return (rand()); }

void	foo(int *x) {
  (*x)--;
}

/* Pulse-inf: FP */
void interproc_terminating_harris10(int x) {
  while (x > 0)
    if (nondet())
      foo(&x);
    else
      foo(&x);
}


/* Derived from Harris'10 - Pulse-inf: FP! */
/*
void interproc_terminating_harris10_cond(int x) {
  while (x > 0)
    {
      if (nondet()) foo(&x);
      else foo(&x);
    }
}
*/
