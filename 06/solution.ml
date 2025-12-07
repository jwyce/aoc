open Base
open Stdio

let read_input () = In_channel.read_lines "06/input.txt"

let transpose matrix =
  let rows = List.length matrix in
  let cols = List.length (List.hd_exn matrix) in
  List.init cols ~f:(fun c ->
      List.init rows ~f:(fun r -> List.nth_exn (List.nth_exn matrix r) c))

let solve op operands =
  match op with
  | "*" -> List.fold operands ~init:1 ~f:( * )
  | "+" -> List.fold operands ~init:0 ~f:( + )
  | _ -> 0

let part1 lines =
  let normalized =
    lines
    |> List.map ~f:(fun l ->
        l |> String.split ~on:' ' |> List.filter ~f:(Fn.non String.is_empty))
  in
  let ops = List.last_exn normalized in
  let problems =
    List.drop_last_exn normalized |> List.map ~f:(List.map ~f:Int.of_string)
  in
  transpose problems
  |> List.mapi ~f:(fun i operands -> solve (List.nth_exn ops i) operands)
  |> List.sum (module Int) ~f:Fn.id

let part2 lines =
  let ops =
    List.last_exn lines |> String.split ~on:' '
    |> List.filter ~f:(Fn.non String.is_empty)
  in
  let pad_len =
    List.map lines ~f:String.length
    |> List.max_elt ~compare:Int.compare
    |> Option.value_exn
  in
  let padded =
    List.drop_last_exn lines
    |> List.map ~f:(fun l ->
        let padding = String.make (pad_len - String.length l) ' ' in
        String.to_list (l ^ padding))
  in
  let transposed = transpose padded in
  (* group columns: all space columns are separators *)
  let all_space col = List.for_all col ~f:(Char.equal ' ') in
  let groups =
    transposed
    |> List.group ~break:(fun a b -> Bool.( <> ) (all_space a) (all_space b))
    |> fun gs ->
    gs |> List.filter ~f:(fun g -> not (all_space (List.hd_exn g))) |> fun gs ->
    gs
    |> List.map ~f:(fun cols ->
        cols
        |> List.map ~f:(fun row ->
            row |> String.of_char_list |> String.strip |> Int.of_string))
  in
  groups
  |> List.mapi ~f:(fun i operands -> solve (List.nth_exn ops i) operands)
  |> List.sum (module Int) ~f:Fn.id

let () =
  let lines = read_input () in
  printf "Part 1: %d\n" (part1 lines);
  printf "Part 2: %d\n" (part2 lines)
