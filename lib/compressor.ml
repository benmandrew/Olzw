let add_to_dictionary dict s pos match_len =
  if pos + match_len + 1 >= String.length s then dict
  else
    let substr = String.sub s pos (match_len + 1) in
    match Dictionary.Comp.insert dict substr with
    | None -> dict
    | Some dict -> dict

exception Exception of string

type comp_stream = Fin of int list | Cons of int list * (unit -> comp_stream)

let rec compress_aux s dict pos v_aux thunk_i =
  if pos + 1 >= String.length s then
    (* Edge case to add final character to the output *)
    match Dictionary.Comp.get dict (String.sub s pos 1) with
    | None -> raise (Exception "Final character not found in dictionary")
    | Some v -> Fin (List.rev (v :: v_aux))
  else if thunk_i >= 720_000 then
    (* thunks must be on byte boundaries, 720 is the lowest
       common multiple of the numbers 9 through 16.
       Must also be large enough to satisfy file append
       boundaries, 72_000 and above work well *)
    let v, match_len = Dictionary.Comp.longest_match dict s pos in
    let dict' = add_to_dictionary dict s pos match_len in
    (* Tail recursion avoids stack overflow *)
    Cons
      ( List.rev (v :: v_aux),
        fun () -> compress_aux s dict' (pos + match_len) [] 0 )
  else
    let v, match_len = Dictionary.Comp.longest_match dict s pos in
    let dict' = add_to_dictionary dict s pos match_len in
    compress_aux s dict' (pos + match_len) (v :: v_aux) (thunk_i + 1)

let compress alphabet codeword_size s =
  let dict = Dictionary.Comp.initialise alphabet codeword_size in
  compress_aux s dict 0 [] 0
