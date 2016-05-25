type t = private {
  id: string;
    (* "1355517523.000005"
       Timestamp with microsecond precision, identifying a unique
       event per Slack channel.
       We treat it as a string and assume that it is formatted consistently
       to make alphabetic sort compatible with numeric sort. *)

  float: float;
    (* id, parsed as into a float without any rounding *)

  time: Util_time.t;
    (* cached time derived from the id string.
       This is rounded to the nearest millisecond, so the original
       id cannot be recovered from it. *)
}

val of_string : string -> t
val to_string : t -> string

val wrap : string -> t
val unwrap : t -> string

val to_time : t -> Util_time.t
  (* rounded to the nearest millisecond *)

val to_float : t -> float
  (* directly parsed from the ts string without rounding *)
