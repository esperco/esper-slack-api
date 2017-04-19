type t = [ `Good | `Warning | `Danger | `Other of string ]

let of_string s =
  match String.lowercase s with
  | "good"    -> `Good
  | "warning" -> `Warning
  | "danger"  -> `Danger
  | _         -> `Other s

let to_string c =
  match c with
  | `Good    -> "good"
  | `Warning -> "warning"
  | `Danger  -> "danger"
  | `Other s -> s

let wrap = of_string
let unwrap = to_string
