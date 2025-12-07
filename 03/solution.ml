open Base
open Stdio

let read_input () = In_channel.read_lines "03/input.txt"

(* brute force *)
let part1 lines =
  lines
  |> List.sum
       (module Int)
       ~f:(fun line ->
         let bank = String.to_list line |> List.map ~f:Char.get_digit_exn in
         let indexed = List.mapi bank ~f:(fun i d -> (i, d)) in
         List.cartesian_product indexed indexed
         |> List.filter_map ~f:(fun ((i, a), (j, b)) ->
             if i < j then Some ((a * 10) + b) else None)
         |> List.max_elt ~compare:Int.compare
         |> Option.value ~default:0)

(* greedy pick largest digit while I still have room *)
let part2 lines =
  lines
  |> List.sum
       (module Int)
       ~f:(fun line ->
         let bank = String.to_array line |> Array.map ~f:Char.get_digit_exn in
         let n = Array.length bank in
         let rec pick start needed acc =
           if needed = 0 then acc
           else
             let end_ = n - needed in
             let best_i, best_d =
               List.range start (end_ + 1)
               |> List.map ~f:(fun i -> (i, bank.(i)))
               |> List.max_elt ~compare:(fun (_, a) (_, b) -> Int.compare a b)
               |> Option.value_exn
             in
             pick (best_i + 1) (needed - 1) ((acc * 10) + best_d)
         in
         pick 0 12 0)

let () =
  let lines = read_input () in
  printf "Part 1: %d\n" (part1 lines);
  printf "Part 2: %d\n" (part2 lines)
