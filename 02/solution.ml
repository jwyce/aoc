open Base
open Stdio

let read_input () = In_channel.read_all "02/input.txt" |> String.rstrip

(* e.g. dbg [%sexp_of: int list] *)
(* let dbg sexp_of x = *)
(*   print_s (sexp_of x); *)
(*   x *)

let num_digits n = n |> Int.abs |> Int.to_string |> String.length

let first_half_digits n =
  let s = n |> Int.abs |> Int.to_string in
  String.prefix s (String.length s / 2) |> Int.of_string

let next_even_digit n =
  let len = num_digits n in
  if len % 2 = 0 then n else 10 ** len

let last_even_digit n =
  let len = num_digits n in
  if len % 2 = 0 then n else (10 ** (len - 1)) - 1

let part1 input =
  input |> String.split ~on:','
  |> List.sum
       (module Int)
       ~f:(fun range ->
         match String.lsplit2 range ~on:'-' with
         | Some (s, e) ->
             let start, end_ = (Int.of_string s, Int.of_string e) in
             let probe_start = next_even_digit start |> first_half_digits in
             let probe_end = last_even_digit end_ |> first_half_digits in
             List.range probe_start (probe_end + 1)
             |> List.filter_map ~f:(fun x ->
                 let id =
                   Int.of_string
                     (String.concat [ Int.to_string x; Int.to_string x ])
                 in
                 if id >= start && id <= end_ then Some id else None)
             |> List.sum (module Int) ~f:Fn.id
         | None -> 0)

let factors n =
  List.range 1 (Int.of_float (Float.sqrt (Float.of_int n)) + 1)
  |> List.concat_map ~f:(fun i ->
      if n % i = 0 then
        [ i ] @ if i <> n / i && n / i <> n then [ n / i ] else []
      else [])

let part2 input =
  input |> String.split ~on:','
  |> List.sum
       (module Int)
       ~f:(fun range ->
         match String.lsplit2 range ~on:'-' with
         | Some (s, e) ->
             let lo, hi = (Int.of_string s, Int.of_string e) in
             let len_lo, len_hi = (num_digits lo, num_digits hi) in
             List.range len_lo (len_hi + 1)
             |> List.concat_map ~f:(fun len ->
                 factors len
                 |> List.filter ~f:(fun f -> len / f >= 2)
                 |> List.concat_map ~f:(fun f ->
                     let repeats = len / f in
                     List.range (10 ** (f - 1)) (10 ** f)
                     |> List.filter_map ~f:(fun i ->
                         let id =
                           Int.of_string
                             (String.concat
                                (List.init repeats ~f:(fun _ -> Int.to_string i)))
                         in
                         if id >= lo && id <= hi then Some id else None)))
             |> Set.of_list (module Int)
             |> Set.sum (module Int) ~f:Fn.id
         | None -> 0)

let () =
  let input = read_input () in
  printf "Part 2: %d\n" (part1 input);
  printf "Part 2: %d\n" (part2 input)
