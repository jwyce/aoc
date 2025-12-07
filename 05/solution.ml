open Core
open Stdio

let read_input () =
  In_channel.read_lines "05/input.txt"
  |> List.split_while ~f:(fun s -> not (String.is_empty s))
  |> fun (a, b) -> (a, List.tl_exn b)

let parse_range s =
  match String.lsplit2 s ~on:'-' with
  | Some (a, b) -> (Int.of_string a, Int.of_string b)
  | None -> failwith "bad range"

let in_range (lo, hi) d = d >= lo && d <= hi

let reduce_ranges ranges =
  ranges
  |> List.sort ~compare:(fun (a, _) (b, _) -> Int.compare a b)
  |> List.fold ~init:[] ~f:(fun acc (start, end_) ->
      match acc with
      | (lo, hi) :: rest when start <= hi + 1 -> (lo, Int.max hi end_) :: rest
      | _ -> (start, end_) :: acc)

let part1 sranges sdata =
  let ranges = List.map sranges ~f:parse_range in
  let data = List.map sdata ~f:Int.of_string in
  data |> List.count ~f:(fun d -> List.exists ranges ~f:(fun r -> in_range r d))

let part2 sranges _sdata =
  let ranges =
    sranges
    |> List.map ~f:(fun s ->
        String.lsplit2_exn s ~on:'-' |> Tuple2.map ~f:Int.of_string)
  in
  reduce_ranges ranges |> List.sum (module Int) ~f:(fun (lo, hi) -> hi - lo + 1)

let () =
  let sranges, sdata = read_input () in
  printf "Part 1: %d\n" (part1 sranges sdata);
  printf "Part 2: %d\n" (part2 sranges sdata)
