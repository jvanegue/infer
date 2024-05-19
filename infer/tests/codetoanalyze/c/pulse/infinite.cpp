/*
 * Copyright (c) Bloomberg L.P.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

// works - OK
void empty_function_terminate() {
  return;
}

// works - OK
void one_liner_terminate(int x) {
  x++;
}


// works - OK
void two_liner_terminate(int x) {
  x++;
  return;
}


/* Pulse-inf: false negative: no support for infinite goto loops */
void simple_goto_not_terminate(int y) {
 re:
  y++;
  goto re;
}

/* pulse-inf: works -- empty path condition, no bug */
void simple_loop_terminate() {
  int y = 0;
  while (y < 100)
    y++;
}


// pulse-inf ok no loop
void simple_goto_terminate(int y) {
  y++;
  goto end;
 end:
  return;
}

/* pulse-inf: Able to flag bug */
void conditional_goto_not_terminate(int y) {
 re:
  if (y == 100)
    goto re;
  else
    return;
}


/* pulse-inf: works good */
extern void fcall(int y);

void loop_call_not_terminate(int y) {
  while (y == 100)
    fcall(y);
  return;
}

/* pulse-inf: FALSE NEGATIVE (no goto support) */
void twovars_goto_not_terminate(int y) {
  int z = y;
  int x = 0;
 label:
  x = 42;
  goto label;
}


/* pulse-inf: works good */
void loop_pointer_terminate(int *x, int y) {
  int *z = x;
  //int y = 1;
  if (x != &y)
    while (y < 100) {
      y++;
      (*z)--;
    }
}


/* pulse-inf: works good */
void loop_pointer_non_terminate(int *x, int y) {
  int *z = x;
  //int y = 1;
  if (x == &y)
    while (y < 100) {
      y++;
      (*z)--;
    }
}



/* pulse-inf: works good */
void var_goto_terminates(int y) {
  int x = 42;
  goto end;
  x++;
 end:
  return;
}


/* pulse-inf: works good */
void loop_conditional_not_terminate(int y) {
  int x = 0;

  while (y < 100)
    if (y < 50)
      x++;
    else
      y++;
}



/* pulse-inf: works good */
/* NEW FALSE NEG??? */
void nested_loop_cond_not_terminate(int y) {
  int x = 42;
  while (y < 100) {
    while (x <= 100) {
      if (x == 10)
	x = 1;
      else
	x++;
    }
    y++;
  }
}


/* pulse inf works */
/* NEW FALSE NEG??? */
void simple_loop_not_terminate(int y) {
  int x = 1;
  while (x != 3)
    y++;
}



/* pulse-inf: works good */
/* NEW FALSE NEG??? */
void loop_alternating_not_terminate(int y, int x) {
  int turn = 0;
  while (x < 100) {
    if (turn)
      x++;
    else 
      x--;
    turn = (turn ? 0 : 1);
  }
}



/* NEW FALSE NEG??? */
/* pulse-inf: works good */
void nested_loop_not_terminate(int y, int x) {
  
  while (y < 100) {
    while (x <= 100) {
      if (x == 10)
	x = 1;
      else
	x++;
    }
    y++;
  }
}


/* pulse-inf: works good! */
void inner_loop_non_terminate(int y, int x) {
  while (y < 100)
    {
      while (x == 0)
	y++;
      y++;
    }
}


/* pulse-inf: works good */
void simple_dowhile_terminate(int y, int x) {
  do {
    y++;
    x++;
  } while (0);
}


/* pulse-inf: works good */

int conditional_goto_terminate(int x, int y) {
 re:
  x++;
  if (false)
    {
      int z1 = x * 2;
      goto re;
      return (z1);
    }
  else
    {
      int z2 = x + y;
      return z2;
    }
}


/* pulse-inf: FP due to Pulse computing arithmetic on Q rather than BV */
void loop_signedarith_terminate(int y) {
  while (y > 0x7fffffff) {
    y++;
    y--;
  }
  return;
}


/* pulse-inf: FP due to Pulse computing arithmetic on Q rather than BV */
void goto_signedarith_terminate(int y) {
 re:
  if (y > 0x7fffffffffffffff)
    goto re;
  else
    return;
}


/* pulse-inf: works good! no bug */
void loop_with_break_terminate(int y) {
  y = 0;
  while (y < 100)
    if (y == 50)
      break;
    else
      y++;
}

/* pulse-inf: works good! no bug */
void loop_with_break_terminate_var1(int y) {
  y = 0;
  while (y < 100)
    if (y == 50)
      {
	y--;
	break;
      }
    else
      y++;
}

/* pulse-inf: works good! no bug */
void loop_with_break_terminate_var2(int y) {
  while (y < 100)
    if (y == 50)
      {
	y--;
	break;
      }
    else
      y++;
}

/* pulse-inf: works! no bug */
void loop_with_break_terminate_var3(int y) {
  while (y < 100)
    if (y == 50)
      break;
    else
      y++;
}

/* pulse-inf: works! no bug */
void loop_with_return_terminate(int y) {
  while (y < 100)
    if (y == 50)
      {
	y--;
	return;
      }
    else
      y++;
}

/* pulse-inf: works! no bug */
void loop_with_return_terminate_var1(int y) {
  while (y < 100)
    if (y == 50)
      return;
    else
      y++;
}


/* pulse-inf: works good! no bug */
void loop_with_return_terminate_var2(int y) {
  y = 0;
  while (y < 100)
    if (y == 50)
      {
	y--;
	return;
      }
    else
      y++;
}

/* pulse-inf: works good! no bug */
void loop_with_return_terminate_var3(int y) {
  y = 0;
  while (y < 100)
    if (y == 50)
      return;
    else
      y++;
}

/* pulse-inf: False negative -- maybe augment the numiters in pulseinf config */
// From: Gupta POPL 2008 - "Proving non-termination"
int bsearch_non_terminate_gupta08(int a[], int k,
				  unsigned int lo,
				  unsigned int hi) {
  unsigned int mid;
  
  while (lo < hi) {
    mid = (lo + hi) / 2;
    if (a[mid] < k) {
      lo = mid + 1;
    } else if (a[mid] > k) {
      hi = mid - 1;
    } else {
      return mid;
    }
  }
  return -1;
}


/* pulseinf: works fine - no bug detected */
// Cook et al. 2006 - TERMINATOR fails to prove termination
typedef struct  s_list{
  int		value;
  struct s_list *next;
}		list_t;

/* pulse-inf: works good, no bug */
static void
list_iter_terminate_cook06(list_t *p) {
  int tot = 0;
  do {
    tot += p->value;
    p = p->next;
  }
  while (p != 0);
}


/* pulse-inf: works good, no bug */
static void
list_iter_terminate_cook06_variant(list_t *p) {
  int tot = 0;
  while (p != 0) {
    tot += p->value;
    p = p->next;
  }
}

/* pulse-inf: works good - no bug */
static void
list_iter_terminate_cook06_variant2(list_t *p) {
  int tot;
  for (tot = 0; p != 0; p = p->next) {
    tot += p->value;
  }
} 

/* pulse-inf: works good - no bug */
// Cook et al. 2006 - TERMINATOR proves termination
void two_ints_loop_terminate_cook06(int x, int y)
{
  if (y >= 1) 
    while (x >= 0)
      x = x + y;
}



/* Cook et al. 2006 - Prove termination with non-determinism involved */
int Ack(int x, int y)
{
  if (x>0) {
    int n;
    if (y>0) {
      y--;
      n = Ack(x,y);
    } else {
      n = 1;
    }
    x--;
    return Ack(x,n);
  } else {
    return y+1;
  }
}

#include <stdlib.h>

/* pulse-inf: works good! no bug */
int nondet() { return (rand()); }
int benchmark_terminate_nondet_cook06()
{
  int x = nondet();
  int y = nondet();

  int * p = &y;
  int * q = &x;
  bool b = true;
  
  while (x<100 && 100<y && b)
    {
      if (p==q) {
	int k = Ack(nondet(),nondet());
	(*p)++;
	while((k--)>100)
	  {
	    if (nondet()) {p = &y;}
	    if (nondet()) {p = &x;}
	    if (!b) {k++;}
	  }
      } else {
	(*q)--;
	(*p)--;
	if (nondet()) {p = &y;}
	if (nondet()) {p = &x;}
      }
      b = nondet();
    }
  return (0);
}


/* pulseinf: works good - no bug detected */
// Cook et al. 2006 - termination with non determinism 
//#include <stdlib.h>
//int nondet() { return (rand()); }
int npc = 0;
int nx, ny, nz;
void benchmark_terminate_cook06()
{
  int x = nondet(), y = nondet(), z = nondet();
  if (y>0) {
    do {
      if (npc == 5) {
	if (!( (y < z && z <= nz)
	       || (x < y && x >= nx)
	       || 0))
	  ;
      }
      if (npc == 0) {
	if (nondet()) {
	  nx = x;
	  ny = y;
	  nz = z;
	  npc = 5;
	}
      }
      if (nondet()) {
	x = x + y;
      } else {
	z = x - y;
      }
    } while (x < y && y < z);
  }
}


/* pulseinf: works good - no bug */
// Cook et al. 2006 proves termination with non determinism 
//#include <stdlib.h>
//int	nondet() { return (rand()); }
void	benchmark_simple_terminate_cook06()
{
  int x = nondet(), y = nondet(), z=nondet();
  if (y > 0) {
    do {
      if (nondet()) {
	x = x + y;
      }
      else
	{
	  z = x - y;
	}
    } while (x < y && y < z);
  }
}



/* Simple non-det benchmark for non-terminate */
/* Inspired by cook'06 by flipping existing test benchmark_simple_terminate_cook06 */
/* pulse-inf: works good! flag the bug */
//#include <stdlib.h>
//int	nondet() { return (rand()); }
void	nondet_loop_non_terminate(int z)
{
  int x = 1;
  while (x < z)
    if (nondet())
      x++;
}


/* From: AProVE: Non-termination proving for C Programs (Hensel et al. TACAS 2022)*/
/* pulse-inf: Works good! (flag bug) */
/* NEW FALSE NEG??? */
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


/* Harris et al. "Alternation for Termination (SAS 2010) - Terminating program */
//#include <stdlib.h>
//int	nondet() { return (rand()); }
void	foo(int *x) {
  (*x)--;
}

/* Pulse-inf: FP */
void interproc_terminating_harris10(int x) {
  while (x > 0)
    foo(&x);
}

/* Derived from Harris'10 - Pulse-inf: FP! */
void interproc_terminating_harris10_cond(int x) {
  while (x > 0)
    {
      if (nondet()) foo(&x);
      else foo(&x);
    }
}


/* Harris et al. "Alternation for Termination (SAS 2010) - Non Terminating program */
/* TERMINATOR unable to find bug */
/* TREX find bug in 5sec */
/* pulse-inf: works good! Detect the bug! */
void loop_non_terminating_harris10(int x, int d, int z)
{
  d = 0;
  z = 0;
  while (x > 0) {
    z++;
    x = x - d;
  }
}

  
/*** Chen et al. TACAS 2014 */
// TNT proves non-termination with non determinism
/* Pulse-inf: works good (also flag the bug) */
/* TO me: there is no bug here! problem in chen14 paper - the nondet() should eventually make it break */
//#include <stdlib.h>
//int	nondet() { return (rand()); }
void nondet_nonterminate_chen14(int k, int i) {
  if (k >= 0)
    ;
  else
    i = -1;
  while (i >= 0)
    i = nondet();
  i = 2;
}

// TNT fails to prove non-termination
/* pulse-inf says there is no bug */
/* To me: this will terminate because k >= 0 will eventually be false due to integer wrap */
void nestedloop2_nonterminate_chen14(int k, int j) {
  while (k >= 0) {
    k++;
    j = k;
    while (j >= 1)
      j--;
  }
}


/* pulse-inf: works good! finds bug */
// TNT proves non-termination
/* NEW FALSE NEG??? */
void nestedloop_nonterminate_chen14(int i) {
  if (i == 10) {
    while (i > 0) {
      i = i - 1;
      while (i == 0)
	;
    }
  }
}


/****** Tests that reflect present in cryptographic libraries ********/


// Example with array - no manifest bug
void array_iter_terminate(int array[])
{
  unsigned int i = 0;
  while (array[i] != 0) {
    array[i] = 42;
    i++;
  }
}


// Example with two arrays - no manifest bug
void array2_iter_terminate(int array1[], int array2[])
{
  unsigned int i = 0;
  while (array1[i] != 0) {
    array2[i] = 42;
    i++;
  }
}

// Example with array and non-termination
/* Pulse-inf: unable to find bug (with default widen threshold=3) */
void array_iter_nonterminate(int array[], int len)
{
  int i = 0;
  while (i < len) {
    array[i] = 42;
    if (i > 10)
      i = 0;
    i++;
  }
}

// Iterate over an array - no bug
/* Pulse-Inf: works good */
void iterate_arraysize_terminate(int array[256])
{
  unsigned int i = 0;
  while (i < (sizeof(*array) / sizeof(array[0]))) {
    array[i] = i;
    i++;
  }  
}

// Iterate over an array using a bitmask to compute array value
/* Pulse-Inf: no bug - works good */
void iterate_bitmask_terminate(int array[256], int len)
{
  unsigned int i = 0;
  while (i < len) {
    array[i] = (i & (~7));
    i++;
  }  
}

// Iterate over an array using a bitmask to compute array index
/* Pulse-Inf: no bug - works good */
void iterate_bitmask2_terminate(int array[256], int len)
{
  unsigned int i = 0;
  unsigned int j = 0;
  while (i < len) {
    j = (i & (~7));
    array[j] = i;
    i++;
  }  
}

// Iterate over an array using a bitmask leading to a non-termination
/* Pulse-inf: able to find bug */
void iterate_bitmask_nonterminate(int array[256], unsigned int len)
{
  unsigned int i = 0;
  while (i < len) {
    i = (i & (~7));
    array[i] = i;
    i++;
  }  
}



// Simple bitshift test - will terminate as i will eventually reach 0
void bitshift_right_loop_terminate(int i)
{
  while (i)
    i = i >> 1;
}


// Simple bitshift test - will not terminate as multipl
void bitshift_left_loop_not_terminate(int i)
{
  while (i)
    i = i << 1;
}


// Simple bitmask test
void bitmask_terminate(int i)
{
  while (i % 2)
    i = (i << 1);
}



// Iterate over an array using a bitshift to compute array index leading to a non-termination
/* Pulse-inf: false negative. Unable to reason about bitshift */
/* FALSE NEGATIVE */
void iterate_bitshift_nonterminate(int array[256])
{
  unsigned int i = 1;
  while (i != 0)
    {
      array[i] = i;
      i = i << 1;
    }  
}

// Iterate over an array using a bitshift to compute array index
/* Pulse-inf: no bug - good */
void iterate_bitshift_terminate(int array[256], int len)
{
  unsigned int i = 1;
  while (i < len) {
    array[i] = i;
    i = i << 1;
  }  
}

// Iterate over an array using a bitshift to compute array index
/* Pulse-inf: no bug - good */
void iterate_bitshift_terminate(int array[256], unsigned char i)
{
  while (i != 0) {
    array[i] = i;
    i = i >> 1;
  }  
}

// Integer test computing a condition that will never be true
/* Pulse-Inf: false negative: unable to reason about integer underflow */
/* FALSE NEGATIVE */
void iterate_intoverflow_nonterminate(int len)
{
  unsigned int i = 0xFFFFFFFF;
  while (i != 0)
    i -= 2;
}


// Iterate over an array using a modulo arithmetic leading to a bug
/* Pulse-infinite: false negative: unable to reason about unbounded index stuttering in the loop */
/* To verify: this should work even with low widen threshold */
/* FALSE NEGATIVE */
void iterate_modulus_nonterminate(int array[256], unsigned int len, unsigned int i)
{
  //unsigned int i = 0;
  while (i < len) {
    i = i % 2;
    array[i] = i;
    i++;
  }  
}


/* From: zlib */
/* Iterate computing a crc value - terminates no bug */
/* Pulse-inf: no bug - good */
#define W 8
#define N 5

static unsigned int crc_braid_table[W][256];
static unsigned int crc_braid_big_table[W][256];

void iterate_crc_terminate()
{
  unsigned int k;
  unsigned long crc0 = 0xFFFFFFFF, crc1 = 0, crc2 = 0, crc3 = 0, crc4 = 0, crc5 = 0;
  unsigned short word0 = 6, word1 = 1, word2 = 2, word3 = 3, word4 = 4, word5 = 5;
  
  for (k = 1; k < W; k++) {
    crc0 ^= crc_braid_table[k][(word0 >> (k << 3)) & 0xff];
    crc1 ^= crc_braid_table[k][(word1 >> (k << 3)) & 0xff];
    crc2 ^= crc_braid_table[k][(word2 >> (k << 3)) & 0xff];
    crc3 ^= crc_braid_table[k][(word3 >> (k << 3)) & 0xff];
    crc4 ^= crc_braid_table[k][(word4 >> (k << 3)) & 0xff];
    crc5 ^= crc_braid_table[k][(word5 >> (k << 3)) & 0xff];
  }
}




/* From: libpng */
/* Test from libpng with typedefs */
void	png_palette_terminate(int val)
{
  int	num;
  int	i;
  int   p = 0;
  
  if (val == 0)
    num = 1;
  else
    num = 256;

  for (i = 0; i < num; i++)
    p += val;
  
}

/* Peter O'Hearn's test - not terminate */
/* Pulse-Inf: OK! */
void simple_loop_equal_notterminate()
{
  int x = 42;
  while (x == x)
    x = x + 1;
}
