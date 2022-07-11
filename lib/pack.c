
#include "stdio.h"

#define CAML_NAME_SPACE
#include "caml/alloc.h"
#include "caml/memory.h"
#include "caml/mlvalues.h"

void write_bin(const char *filename, uint8_t *buffer, size_t n) {
  FILE *fptr = fopen(filename, "wb");
  fwrite(buffer, n, 1, fptr);
  fclose(fptr);
}

void read_bin(const char *filename, uint8_t **buffer, size_t *size) {
  FILE *fptr = fopen(filename, "rb");
  fseek(fptr, 0, SEEK_END);
  *size = ftell(fptr);
  fseek(fptr, 0, SEEK_SET);
  // Add extra buffer space as unpacking can read over the edge
  *buffer = malloc(*size + 32);
  fread(*buffer, *size, 1, fptr);
  fclose(fptr);
}

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)                                \
  (byte & 0x80 ? '1' : '0'), (byte & 0x40 ? '1' : '0'),     \
      (byte & 0x20 ? '1' : '0'), (byte & 0x10 ? '1' : '0'), \
      (byte & 0x08 ? '1' : '0'), (byte & 0x04 ? '1' : '0'), \
      (byte & 0x02 ? '1' : '0'), (byte & 0x01 ? '1' : '0')

/* d = -------- --------
 *     0      7 8      15
 * from_i is an index into d, left-to-right
 * we take n_bits from d, and shift them to
 * align with the index to_i in a byte
 *
 * n_bits <= 8
 * from_i + n_bits <= 16
 * to_i + n_bits <= 8
 */
uint8_t pack_byte(uint16_t d, size_t from_i, size_t n_bits, size_t to_i) {
  uint8_t mask = 0;
  for (int i = 0; i < n_bits; i++) {
    mask |= (1u << i);
  }
  uint8_t v = d >> (16 - (from_i + n_bits));
  uint8_t masked = mask & v;
  return masked << (8 - (to_i + n_bits));
}

/* A codeword of length 9-16 bits can stretch over up to three bytes
 * We thus split the codeword into three substrings:
 *   s_0 s_1 s_2
 * such that the substrings are separated over the byte boundaries
 */
size_t pack_codeword(size_t codeword_size, uint16_t codeword, size_t i_bit,
                     uint8_t *packed) {
  size_t i_byte = i_bit / 8;
  size_t offset = i_bit % 8;
  // Computing s_0
  size_t i_cw = 16 - codeword_size;
  size_t s_0 = 8 - offset;
  packed[i_byte] |= pack_byte(codeword, i_cw, s_0, offset);
  i_bit += s_0;
  if (s_0 >= codeword_size) return i_bit;
  // Computing s_1
  i_cw += s_0;
  size_t s_1 = codeword_size - s_0;
  if (s_1 <= 8) {
    packed[i_byte + 1] |= pack_byte(codeword, i_cw, s_1, 0);
    return i_bit + s_1;
  }
  s_1 = 8;
  packed[i_byte + 1] |= pack_byte(codeword, i_cw, s_1, 0);
  i_bit += s_1;
  // Computing s_2
  i_cw += s_1;
  size_t s_2 = (codeword_size - s_0 - s_1);
  packed[i_byte + 2] |= pack_byte(codeword, i_cw, s_2, 0);
  return i_bit + s_2;
}

uint8_t *pack(size_t codeword_size, value *codewords, size_t n_codewords,
              size_t *n_bytes) {
  // Number of bytes needed, rounding up
  *n_bytes = (n_codewords * codeword_size + 7) / 8;
  // printf("n_b = %llu\n", *n_bytes);
  // printf("n_cw = %llu\n", n_codewords);
  uint8_t *packed = (uint8_t *)malloc(*n_bytes);
  for (int i = 0; i < *n_bytes; i++) packed[i] = 0;

  size_t i_bit = 0;
  for (size_t i = 0; i < n_codewords; i++) {
    uint16_t codeword = (uint16_t)Long_val(codewords[i]);
    i_bit = pack_codeword(codeword_size, codeword, i_bit, packed);
  }
  return packed;
}

CAMLprim value pack_c(value filename, value codeword_size, value codewords,
                      value n_codewords) {
  CAMLparam4(filename, codeword_size, codewords, n_codewords);
  size_t n_bytes;
  uint16_t *packed = pack((size_t)Long_val(codeword_size), (value *)codewords,
                          (size_t)Long_val(n_codewords), &n_bytes);
  write_bin(String_val(filename), (char *)packed, n_bytes);
  free(packed);
  CAMLreturn0;
}

/* d = --------
 *     0      7
 * from_i is an index into d, left-to-right
 * we take n_bits from d, and shift them to
 * align with the index to_i in a 2-byte block
 *
 * n_bits <= 8
 * from_i + n_bits <= 8
 * to_i + n_bits <= 16
 */
uint16_t unpack_byte(uint8_t d, size_t from_i, size_t n_bits, size_t to_i) {
  uint8_t mask = 0;
  for (int i = 0; i < n_bits; i++) {
    mask |= (1u << i);
  }
  uint8_t v = d >> (8 - (from_i + n_bits));
  uint16_t masked = (uint16_t)(mask & v);
  return masked << (16 - (to_i + n_bits));
}

uint16_t unpack_codeword(size_t codeword_size, size_t i_bit, uint8_t *packed) {
  size_t i_byte = i_bit / 8;
  size_t offset = i_bit % 8;
  // Computing s_0
  size_t s_0 = 8 - offset;
  size_t i_cw = 16 - codeword_size;
  uint16_t v = unpack_byte(packed[i_byte], offset, s_0, i_cw);
  if (s_0 >= codeword_size) return v;
  // Computing s_1
  i_cw += s_0;
  size_t s_1 = codeword_size - s_0;
  if (s_1 <= 8) {
    v |= unpack_byte(packed[i_byte + 1], 0, s_1, i_cw);
    return v;
  }
  s_1 = 8;
  v |= unpack_byte(packed[i_byte + 1], 0, s_1, i_cw);
  // Computing s_2
  i_cw += s_1;
  size_t s_2 = (codeword_size - s_0 - s_1);
  v |= unpack_byte(packed[i_byte + 2], 0, s_2, i_cw);
  return v;
}

uint16_t *unpack(size_t codeword_size, uint8_t *packed, size_t n_bytes,
                 size_t *n_codewords) {
  *n_codewords = (8 * n_bytes) / codeword_size;
  // printf("n_b = %llu\n", n_bytes);
  // printf("n_cw = %llu\n", *n_codewords);
  uint16_t *unpacked = (uint16_t *)malloc(n_bytes * sizeof(uint16_t));
  for (size_t i = 0; i < *n_codewords; i++) {
    size_t i_bit = i * codeword_size;
    uint16_t v = unpack_codeword(codeword_size, i_bit, packed);
    unpacked[i] = v;
  }
  return unpacked;
}

CAMLprim value unpack_c(value filename, value codeword_size) {
  CAMLparam2(filename, codeword_size);
  size_t n_bytes;
  uint8_t *packed;
  size_t n_codewords;
  read_bin(String_val(filename), (uint8_t **)&packed, &n_bytes);
  uint16_t *unpacked =
      unpack(Long_val(codeword_size), packed, n_bytes, &n_codewords);
  value arr = caml_alloc_tuple((mlsize_t)(n_codewords));
  for (int i = 0; i < n_codewords; i++) {
    uint16_t v = unpacked[i];
    caml_modify(&Field(arr, i), Val_long((long)v));
  }
  free(unpacked);
  CAMLreturn(arr);
}
