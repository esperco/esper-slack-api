type t = [ `Default | `Primary | `Danger | `Other of string ]

val of_string: string -> t
val to_string: t -> string
val wrap: string -> t
val unwrap: t -> string
