module Comp : sig
  type t

  val insert : t -> string -> t option
  val initialise : string list -> t
  val get : t -> string -> int option
  val longest_match : t -> string -> int -> int * int
end

module Decomp : sig
  type t

  val insert : t -> string -> t option
  val initialise : string list -> t
  val get : t -> int -> string option
end
