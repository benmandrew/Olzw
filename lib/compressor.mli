type comp_stream = Fin of int list | Cons of int list * (unit -> comp_stream)

val compress : string list -> int -> string -> comp_stream
