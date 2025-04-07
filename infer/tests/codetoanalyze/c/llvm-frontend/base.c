/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
#include "my_lib.h"
#include <stdlib.h>

int main() { return 0; }
int* test() { return NULL; }

int add(int n1, int n2) { return n1 + n2; }

int test2() {
  int n1;
  int n2;
  return n1 + n2;
}

int test3(int* ptr) { return *ptr; }

int foo();

int test4() { return foo(); }

int test5() { return bar(); }

int call_add() { return add(1, 2); }

int test6() {
  int* ptr = NULL;
  if (call_add() == 3) {
    return *ptr;
  } else
    return 0;
}

int test7() {
  int* ptr = NULL;
  if (call_add() == 5) {
    return *ptr;
  } else
    return 0;
}

int call_add1(int* ptr, int y) { return add(*ptr, y); }

int test8(int* ptr) {
  *ptr = 1;
  int* null_ptr = NULL;
  int ret = call_add1(ptr, 2);
  if (ret == 3) {
    return *null_ptr;
  } else
    return 0;
}

int test9() {
  int* ptr = malloc(sizeof(int));
  *ptr = 42;
  int ret = *ptr;
  free(ptr);
  return ret;
}
