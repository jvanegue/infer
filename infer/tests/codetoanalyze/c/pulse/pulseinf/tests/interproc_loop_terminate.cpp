typedef struct s_a {
  int num;
} A;
  
int func_terminate(A *a) {

  int i;
  int ret = 0;
  int v = a->num;
  for (i = 0; i < v; i++)
    ret++;
  return (ret);
}

void f() { int v = 42; func_terminate(v); }
void g() { int v = 43; func_terminate(v); }


