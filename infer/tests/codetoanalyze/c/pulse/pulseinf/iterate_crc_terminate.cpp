unsigned long iterate_crc_terminate()
{
  unsigned int k;
  unsigned long crc0 = 0;
  for (k = 0; k < 2; k++)
    crc0++;
  return (crc0);
}
