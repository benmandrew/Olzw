open Base

(* let max_dict_size = 2 ** 16 *)

module Comp = struct
  type t = { d : (string, int) Core.Hashtbl.t; n : int; max_dict_size : int }

  let insert dict str =
    Stdlib.Printf.printf "%S %d\n" str dict.n;
    if dict.n < dict.max_dict_size then (
      Core.Hashtbl.add_exn dict.d ~key:str ~data:dict.n;
      Some { d = dict.d; n = dict.n + 1; max_dict_size = dict.max_dict_size })
    else None

  let initialise (alphabet : string list) codeword_size : t =
    let dict =
      {
        d = Core.Hashtbl.create (module String);
        n = 0;
        max_dict_size = 2 ** codeword_size;
      }
    in
    List.fold_left alphabet ~init:dict ~f:(fun d' str ->
        match insert d' str with
        | None -> raise (Core.Arg.Bad "Alphabet is too large")
        | Some d -> d)

  let get dict key = Core.Hashtbl.find dict.d key

  let longest_match dict s pos =
    let rec longest_match_aux len prev =
      if pos + len >= String.length s then (prev, len - 1)
      else
        let substr = String.sub s ~pos ~len in
        match get dict substr with
        | None -> (prev, len - 1)
        | Some v -> longest_match_aux (len + 1) v
    in
    longest_match_aux 1 0
end

module Decomp = struct
  type t = { d : (int, string) Core.Hashtbl.t; n : int; max_dict_size : int }

  let insert dict str =
    Stdlib.Printf.printf "%S %d\n" str dict.n;
    if dict.n < dict.max_dict_size then (
      Core.Hashtbl.add_exn dict.d ~key:dict.n ~data:str;
      Some { d = dict.d; n = dict.n + 1; max_dict_size = dict.max_dict_size })
    else None

  let initialise (alphabet : string list) codeword_size : t =
    let dict =
      {
        d = Core.Hashtbl.create (module Int);
        n = 0;
        max_dict_size = 2 ** codeword_size;
      }
    in
    List.fold_left alphabet ~init:dict ~f:(fun d' str ->
        match insert d' str with
        | None -> raise (Core.Arg.Bad "Alphabet is too large")
        | Some d -> d)

  let get dict key = Core.Hashtbl.find dict.d key
end
