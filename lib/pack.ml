external pack_c : string -> int -> int array -> int -> unit = "pack_c"

let rec pack filename codeword_size = function
  | Compressor.Fin codewords ->
      pack_c filename codeword_size (Array.of_list codewords)
        (List.length codewords)
  | Compressor.Cons (codewords, thunk) ->
      pack_c filename codeword_size (Array.of_list codewords)
        (List.length codewords);
      pack filename codeword_size (thunk ())

external unpack_c : string -> int -> int array = "unpack_c"

let unpack filename codeword_size = unpack_c filename codeword_size
