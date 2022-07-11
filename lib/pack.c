
#include "stdio.h"

#define CAML_NAME_SPACE
#include "caml/mlvalues.h"
#include "caml/alloc.h"
#include "caml/memory.h"

void write_bin(const char *filename, char *buffer, size_t n) {
  FILE *fptr = fopen(filename, "wb");
  fwrite(buffer, n, 1, fptr);
  fclose (fptr);
}

void read_bin(const char *filename, char **buffer, size_t *size) {
  FILE *fptr = fopen(filename, "rb");
  fseek(fptr, 0, SEEK_END);
  *size = ftell(fptr);
  fseek(fptr, 0, SEEK_SET);
  *buffer = malloc(*size);
  fread(*buffer, *size, 1, fptr);
  fclose(fptr);
}

uint16_t *pack(size_t codeword_size, value *codewords, size_t n_codewords) {
  // Number of bytes needed, rounding up
  size_t n_bytes = (n_codewords * codeword_size + 7) / 8;
  uint8_t *packed = (uint8_t *)malloc(n_bytes);
  for (size_t i = 0; i < n_codewords; i++) {
    size_t i_bit = i * codeword_size;
    uint16_t v = (uint16_t)Long_val(codewords[i]);
    
  }
  return packed;
}

CAMLprim value pack_c(value filename, value codeword_size, value codewords, value n_codewords) {
  CAMLparam4(filename, codeword_size, codewords, n_codewords);
  uint16_t *packed = pack(
    (size_t)Long_val(codeword_size),
    (value *)codewords,
    (size_t)Long_val(n_codewords));
  write_bin(String_val(filename), (char *)packed, (size_t)(Long_val(n_codewords) * 2));
  free(packed);
  CAMLreturn0;
}

uint16_t *unpack(size_t codeword_size, uint16_t *packed, size_t n_bytes) {
  return packed;
}

CAMLprim value unpack_c(value filename, value codeword_size) {
  CAMLparam2(filename, codeword_size);
  size_t n_bytes;
  uint16_t *packed;
  read_bin(String_val(filename), (char **)&packed, &n_bytes);
  uint16_t *unpacked = unpack(codeword_size, packed, n_bytes);
  value arr = caml_alloc_small((mlsize_t)(n_bytes / 2), (tag_t)0);
  for (int i = 0; i < n_bytes / 2; i++) {
    uint16_t v = unpacked[i];
    caml_modify(&Field(arr, i), Val_long((long)v));
  }
  free(unpacked);
  CAMLreturn(arr);
}


