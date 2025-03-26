#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

void assign_paren_bad() {
  bool* b = (bool*)malloc(sizeof(bool));
  int x = 42, y = 42;
  if (b) {
    *b = false;
    *b = (x == y);
    if (*b) {
      int* p = 0;
      *p = 5;
    }
    free(b);
  }
}
