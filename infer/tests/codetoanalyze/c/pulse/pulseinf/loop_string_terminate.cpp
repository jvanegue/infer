int loop_string_terminate(char *str)
{
  int i = 0;
  while (*str)
    {
      str++;
      i++;
    }
  return i;
}

int f(char **argv)
{
  loop_string_terminate(argv[1]);
  return (0);
}


int main(int argc, char **argv)
{
  loop_string_terminate(argv[0]);
  f(argv);
  return 0;
}

