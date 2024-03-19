// This file is part of the SV-Benchmarks collection of verification tasks:
// https://gitlab.com/sosy-lab/benchmarking/sv-benchmarks
//
// SPDX-FileCopyrightText: 2021 DynamiTe team <https://github.com/letonchanh/dynamite>
//
// SPDX-License-Identifier: Apache-2.0

/*
  A nonlinear termination benchmark program from the OOPSLA'20 paper 
  "DynamiTe: Dynamic termination and non-termination proofs"
  by Ton Chanh Le, Timos Antonopoulos, Parisa Fathololumi, Eric Koskinen, ThanhVu Nguyen.
  Adapted from the original nonlinear benchmark nla-digbench. 
*/

/*
  A division algorithm, by Kaldewaij
  returns A//B
*/

#include <limits.h>
/*
extern unsigned __VERIFIER_nondet_unsigned_int(void);
*/

extern int __VERIFIER_nondet_int(void);
extern unsigned __VERIFIER_nondet_unsigned_int(void);

int main() {
  unsigned A, B;
  unsigned q, r, b;
  int c = 0, k = __VERIFIER_nondet_int();
  A = __VERIFIER_nondet_unsigned_int();
  B = __VERIFIER_nondet_unsigned_int();
  // if (! (B < UINT_MAX/2) ) { abort(); }
  if (B >= UINT_MAX/2) return 0;
  // if (! (B >= 1) ) { abort(); }
  if ( B < 1 ) return 0;

  if (A >= UINT_MAX/2) return 0;

    q = 0;
    r = A;
    b = B;

    while (r >= b) {
      //if (!(r >= b)) break;
      b = 2 * b;
    }

    while (q * b + r - A + c <=k) {
      // __VERIFIER_assert(A == q * b + r);
        //if (!(b != B)) break;

        q = 2 * q;
        b = b / 2;
        if (r >= b) {
            q = q + 1;
            r = r - b;
        }
        c++;
    }

    //__VERIFIER_assert(A == q * b + r);
    return 0;
}
