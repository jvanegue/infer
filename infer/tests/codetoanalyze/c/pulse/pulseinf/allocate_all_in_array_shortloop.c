void allocate_all_in_array(int* array[]) {
  for (int i = 0; i < 1; i++) {
    array[i] = malloc(sizeof(int));
  }
}
