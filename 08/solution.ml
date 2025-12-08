open Core
open Stdio

let read_input () = In_channel.read_lines "08/input.txt"

type vec3 = { x : int; y : int; z : int }

let parse_vec3 s =
  match String.split s ~on:',' |> List.map ~f:Int.of_string with
  | [ x; y; z ] -> { x; y; z }
  | _ -> failwith "bad input"

let dist a b =
  let dx = Float.of_int (a.x - b.x) in
  let dy = Float.of_int (a.y - b.y) in
  let dz = Float.of_int (a.z - b.z) in
  Float.sqrt ((dx *. dx) +. (dy *. dy) +. (dz *. dz))

let parse_points lines = List.map lines ~f:parse_vec3 |> List.to_array
let make_uf points = Array.map points ~f:Union_find.create

let sorted_pairs points =
  let n = Array.length points in
  List.init n ~f:(fun i ->
      List.init
        (n - i - 1)
        ~f:(fun j ->
          let k = i + j + 1 in
          (dist points.(i) points.(k), i, k)))
  |> List.concat
  |> List.sort ~compare:(fun (d1, _, _) (d2, _, _) -> Float.compare d1 d2)

let group_sizes uf_nodes =
  let groups = Hashtbl.create (module Int) in
  Array.iteri uf_nodes ~f:(fun _ node ->
      let root_idx =
        Array.findi_exn uf_nodes ~f:(fun _ other ->
            Union_find.same_class node other)
        |> fst
      in
      Hashtbl.incr groups root_idx);
  Hashtbl.data groups

let part1 lines =
  let points = parse_points lines in
  let uf_nodes = make_uf points in
  let pairs = sorted_pairs points in

  List.take pairs 1000
  |> List.iter ~f:(fun (_, i, k) -> Union_find.union uf_nodes.(i) uf_nodes.(k));

  group_sizes uf_nodes
  |> List.sort ~compare:(fun a b -> Int.compare b a)
  |> Fn.flip List.take 3 |> List.fold ~init:1 ~f:( * )

let part2 lines =
  let points = parse_points lines in
  let uf_nodes = make_uf points in
  let pairs = sorted_pairs points in

  let rec go = function
    | [] -> 0
    | (_, i, k) :: rest ->
        let was_different =
          not (Union_find.same_class uf_nodes.(i) uf_nodes.(k))
        in
        Union_find.union uf_nodes.(i) uf_nodes.(k);
        if was_different && List.length (group_sizes uf_nodes) = 1 then
          points.(i).x * points.(k).x
        else go rest
  in
  go pairs

let () =
  let lines = read_input () in
  printf "Part 1: %d\n" (part1 lines);
  printf "Part 2: %d\n" (part2 lines)
