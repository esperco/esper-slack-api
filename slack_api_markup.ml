(*
   Encode special characters that should appear verbatim in a Slack message.

   See https://api.slack.com/docs/message-formatting
*)

open Printf

(*
   For now, only `<` `>` `&` are escaped.

   Other elements of Slack's markup such as bold-faced phrases (`*bold text*`)
   or emojis (`:joy:`) are preserved and will be rendered by Slack.
   We might want to escape them in some cases in the future,
   perhaps optionally.
*)
let encode s =
  let buf = Buffer.create (2 * String.length s) in
  for i = 0 to String.length s - 1 do
    match s.[i] with
    | '&' -> Buffer.add_string buf "&amp;"
    | '<' -> Buffer.add_string buf "&lt;"
    | '>' -> Buffer.add_string buf "&gt;"
    | c -> Buffer.add_char buf c
  done;
  Buffer.contents buf

let test_encode s =
  assert (encode "" = "");
  assert (encode "a" = "a");
  assert (encode "&" = "&amp;");
  assert (encode "a < b & b > c*" = "a &lt; b &amp; b &gt; c*");
  assert (encode "*a*" = "*a*");
  assert (encode "_a_" = "_a_");
  assert (encode "~a~" = "~a~");
  assert (encode ":joy:" = ":joy:");
  true

let link ~text ~url () =
  sprintf "<%s|%s>"
  (encode url) (encode text)

let tests = [
  "encode", test_encode;
]
