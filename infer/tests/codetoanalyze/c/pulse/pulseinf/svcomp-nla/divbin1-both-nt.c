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
extern unsigned int __VERIFIER_nondet_unsigned_int(void);
int main() {
  unsigned A, B;
  unsigned q, r, b;
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
    /*
    while (r >= b) {
      //if (!(r >= b)) break;
      b = 2 * b;
    }
    */
    if (r < b) {
    while (A == q * b + r) {
      // __VERIFIER_assert(A == q * b + r);
        //if (!(b != B)) break;

        if (2 * (b / 2) == b) {
            q = 2 * q;
            b = b / 2;
            if (r >= b) {
                q = q + 1;
                r = r - b;
            }
        }
    }
    }
    //__VERIFIER_assert(A == q * b + r);
    return 0;
}
