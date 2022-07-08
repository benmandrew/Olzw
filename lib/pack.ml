
external pack_c: string -> int -> int array -> int -> unit = "pack_c"

let pack filename codeword_size codewords =
  pack_c filename codeword_size (Array.of_list codewords) (List.length codewords)

external unpack_c: string -> int -> int array = "unpack_c"

let unpack filename codeword_size = unpack_c filename codeword_size
