open Base
open Stdio

let read_input () = In_channel.read_lines "09/input.txt"

let parse_point line =
  let x, y = String.lsplit2_exn line ~on:',' in
  (Int.of_string x, Int.of_string y)

let part1 points =
  List.cartesian_product points points
  |> List.map ~f:(fun ((ax, ay), (bx, by)) ->
      (Int.abs (ax - bx) + 1) * (Int.abs (ay - by) + 1))
  |> List.fold ~init:0 ~f:Int.max

let is_inside_or_on_boundary polygon_arr n (px, py) =
  let crossings = ref 0 in
  let on_edge = ref false in
  for i = 0 to n - 1 do
    let ax, ay = polygon_arr.(i) in
    let bx, by = polygon_arr.((i + 1) % n) in
    let min_x, max_x = (min ax bx, max ax bx) in
    let min_y, max_y = (min ay by, max ay by) in
    if ax = bx && px = ax && py >= min_y && py <= max_y then on_edge := true;
    if ay = by && py = ay && px >= min_x && px <= max_x then on_edge := true;
    if ax = bx && ax > px && py > min_y && py <= max_y then Int.incr crossings
  done;
  !on_edge || !crossings % 2 = 1

let rectangle_fully_inside polygon_arr n (ax, ay) (bx, by) =
  let min_x, max_x = (min ax bx, max ax bx) in
  let min_y, max_y = (min ay by, max ay by) in
  if not (is_inside_or_on_boundary polygon_arr n (min_x, max_y)) then false
  else if not (is_inside_or_on_boundary polygon_arr n (max_x, min_y)) then false
  else
    let cuts_through = ref false in
    for i = 0 to n - 1 do
      let x1, y1 = polygon_arr.(i) in
      let x2, y2 = polygon_arr.((i + 1) % n) in
      if
        y1 = y2 && y1 > min_y && y1 < max_y
        && min x1 x2 < max_x
        && max x1 x2 > min_x
      then cuts_through := true;
      if
        x1 = x2 && x1 > min_x && x1 < max_x
        && min y1 y2 < max_y
        && max y1 y2 > min_y
      then cuts_through := true
    done;
    not !cuts_through

let part2 points =
  let polygon_arr = Array.of_list points in
  let n = Array.length polygon_arr in
  List.cartesian_product points points
  |> List.filter ~f:(fun (p1, p2) -> rectangle_fully_inside polygon_arr n p1 p2)
  |> List.map ~f:(fun ((ax, ay), (bx, by)) ->
      (Int.abs (ax - bx) + 1) * (Int.abs (ay - by) + 1))
  |> List.fold ~init:0 ~f:Int.max

let () =
  let points = read_input () |> List.map ~f:parse_point in
  printf "Part 1: %d\n" (part1 points);
  printf "Part 2: %d\n" (part2 points)
