exception Exception of string

let first s = String.make 1 s.[0]

let decode_symbol dict symbol prev_str =
  let write, out =
    match Dictionary.Decomp.get dict symbol with
    | None ->
        let new_str = prev_str ^ first prev_str in
        (new_str, new_str)
    | Some curr_str -> (prev_str ^ first curr_str, curr_str)
  in
  let dict' =
    match Dictionary.Decomp.insert dict write with
    | None -> dict
    | Some dict' -> dict'
  in
  let new_str =
    match Dictionary.Decomp.get dict' symbol with
    | None -> raise (Exception "Newly added symbol not found")
    | Some s -> s
  in
  (out, new_str, dict')

(* Tail recursive auxiliary function to avoid stack overflow *)
let rec decompress_aux dict b i prev_str out_aux =
  if i >= Bytes.length b then out_aux
  else
    let symbol = Stdlib.Bytes.get_uint16_be b i in
    let out, write, dict' = decode_symbol dict symbol prev_str in
    decompress_aux dict' b (i + 2) write (out :: out_aux)

let decompress alphabet b =
  let dict = Dictionary.Decomp.initialise alphabet in
  let first_char =
    match Dictionary.Decomp.get dict (Stdlib.Bytes.get_uint16_be b 0) with
    | None -> raise (Exception "Initial symbol not in dictionary")
    | Some s -> s
  in
  String.concat ""
    (List.rev (first_char :: decompress_aux dict b 2 first_char []))
