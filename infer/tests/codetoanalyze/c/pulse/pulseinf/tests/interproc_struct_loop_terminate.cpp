typedef struct s_a {
  int num;
  int off;
} A;
  
int func_terminate(A *a) {

  int i;
  int ret = 0;
  int v = a->num;
  for (i = 0; i < v; i++)
    ret++;
  return (ret);
}

void f() { A a; a.num = 42; a.off = 0; func_terminate(&a); }
void g() { A a; a.num = 43; a.off = 1; func_terminate(&a); }


