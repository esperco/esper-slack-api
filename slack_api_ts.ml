type t = {
  id: string;
  float: float;
  time: Util_time.t;
}

let of_string s =
  let t = float_of_string s in
  {
    id = s;
    float = t;
    time = Util_time.of_float t
  }

let to_string x = x.id
let to_time x = x.time
let to_float x = x.float

let wrap = of_string
let unwrap = to_string
