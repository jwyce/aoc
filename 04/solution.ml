open Base
open Stdio

let read_input () = In_channel.read_lines "04/input.txt"

let neighbors grid (x, y) =
  let rows = Array.length grid in
  let cols = Array.length grid.(0) in
  [
    (x - 1, y);
    (x + 1, y);
    (x, y - 1);
    (x, y + 1);
    (x - 1, y - 1);
    (x - 1, y + 1);
    (x + 1, y - 1);
    (x + 1, y + 1);
  ]
  |> List.filter ~f:(fun (x, y) -> x >= 0 && x < rows && y >= 0 && y < cols)

let part1 lines =
  let grid = lines |> List.map ~f:String.to_array |> List.to_array in
  let rows = Array.length grid in
  let cols = Array.length grid.(0) in
  List.range 0 rows
  |> List.sum
       (module Int)
       ~f:(fun x ->
         List.range 0 cols
         |> List.count ~f:(fun y ->
             Char.(grid.(x).(y) = '@')
             && neighbors grid (x, y)
                |> List.count ~f:(fun (nx, ny) -> Char.(grid.(nx).(ny) = '@'))
                |> fun n -> n < 4))

let part2 lines =
  let grid = lines |> List.map ~f:String.to_array |> List.to_array in
  let rows = Array.length grid in
  let cols = Array.length grid.(0) in
  let rec loop sum =
    let accessible =
      List.range 0 rows
      |> List.concat_map ~f:(fun x ->
          List.range 0 cols
          |> List.filter_map ~f:(fun y ->
              if
                Char.(grid.(x).(y) = '@')
                && neighbors grid (x, y)
                   |> List.count ~f:(fun (nx, ny) ->
                       Char.(grid.(nx).(ny) = '@'))
                   |> fun n -> n < 4
              then Some (x, y)
              else None))
    in
    match accessible with
    | [] -> sum
    | pts ->
        List.iter pts ~f:(fun (x, y) -> grid.(x).(y) <- '.');
        loop (sum + List.length pts)
  in
  loop 0

let () =
  let lines = read_input () in
  printf "Part 1: %d\n" (part1 lines);
  printf "Part 2: %d\n" (part2 lines)
