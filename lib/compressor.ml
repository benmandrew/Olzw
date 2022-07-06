let add_to_dictionary dict s pos match_len =
  if pos + match_len + 1 >= String.length s then dict
  else
    let substr = String.sub s pos (match_len + 1) in
    match Dictionary.Comp.insert dict substr with
    | None -> dict
    | Some dict -> dict

(* Tail recursive auxiliary function to avoid stack overflow *)
let rec compress_aux s dict pos b_aux =
  if pos + 1 >= String.length s then b_aux
  else
    let b, match_len = Dictionary.Comp.longest_match dict s pos in
    let dict' = add_to_dictionary dict s pos match_len in
    compress_aux s dict' (pos + match_len) (b :: b_aux)

let compress alphabet s =
  let dict = Dictionary.Comp.initialise alphabet in
  let open Stdlib in
  Bytes.concat Bytes.empty (List.rev (compress_aux s dict 0 []))
