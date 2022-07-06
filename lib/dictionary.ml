open Base

let max_dict_size = 65536

let uint16_of_int v =
  let b = Stdlib.Bytes.create 2 in
  Stdlib.Bytes.set_uint16_be b 0 v;
  b

module Comp = struct
  type t = { d : (string, bytes) Core.Hashtbl.t; n : int }

  let insert dict str =
    let b = uint16_of_int dict.n in
    if dict.n < max_dict_size then (
      Core.Hashtbl.add_exn dict.d ~key:str ~data:b;
      Some { d = dict.d; n = dict.n + 1 })
    else None

  let initialise (alphabet : string list) : t =
    let dict = { d = Core.Hashtbl.create (module String); n = 0 } in
    List.fold_left alphabet ~init:dict ~f:(fun d' str ->
        match insert d' str with
        | None -> raise (Core.Arg.Bad "Alphabet is too large")
        | Some d -> d)

  let get_bytes dict key = Core.Hashtbl.find dict.d key

  let get dict key =
    match get_bytes dict key with
    | None -> None
    | Some b -> Some (Stdlib.Bytes.get_uint16_be b 0)

  let longest_match dict s pos =
    let rec longest_match_aux len prev =
      if pos + len >= String.length s then (prev, len - 1)
      else
        let substr = String.sub s ~pos ~len in
        match get_bytes dict substr with
        | None -> (prev, len - 1)
        | Some v -> longest_match_aux (len + 1) v
    in
    longest_match_aux 1 Stdlib.Bytes.empty
end

module Decomp = struct
  type t = { d : (int, string) Core.Hashtbl.t; n : int }

  let insert dict str =
    if dict.n < max_dict_size then (
      Core.Hashtbl.add_exn dict.d ~key:dict.n ~data:str;
      Some { d = dict.d; n = dict.n + 1 })
    else None

  let initialise (alphabet : string list) : t =
    let dict = { d = Core.Hashtbl.create (module Int); n = 0 } in
    List.fold_left alphabet ~init:dict ~f:(fun d' str ->
        match insert d' str with
        | None -> raise (Core.Arg.Bad "Alphabet is too large")
        | Some d -> d)

  let get dict key = Core.Hashtbl.find dict.d key
end
