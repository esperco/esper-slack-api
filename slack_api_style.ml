type t = Default | Primary | Danger | Other of string

let of_string s =
  match String.lowercase s with
  | "default" -> Default
  | "primary" -> Primary
  | "danger"  -> Danger
  | _         -> Other s

let to_string c =
  match c with
  | Default -> "default"
  | Primary -> "primary"
  | Danger  -> "danger"
  | Other s -> s

let wrap = of_string
let unwrap = to_string
