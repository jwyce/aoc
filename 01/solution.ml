open Base
open Stdio

let read_input () = In_channel.read_lines "01/input.txt"

type direction = Left | Right

let rotations lines =
  List.map lines ~f:(fun s ->
      Stdlib.Scanf.sscanf s "%c%d" (fun c n ->
          let dir =
            match c with
            | 'R' -> Right
            | 'L' -> Left
            | _ -> failwith "Expected R or L"
          in
          (dir, n)))

let num_zeros rotations =
  let count, _ =
    List.fold rotations ~init:(0, 50) ~f:(fun (acc, dial) (dir, n) ->
        let delta = match dir with Left -> -n | Right -> n in
        let new_pos = (dial + delta) % 100 in
        let new_pos = if new_pos < 0 then new_pos + 100 else new_pos in
        let acc = if new_pos = 0 then acc + 1 else acc in
        (acc, new_pos))
  in
  count

let num_clicks rotations =
  let count, _ =
    List.fold rotations ~init:(0, 50) ~f:(fun (acc, dial) (dir, n) ->
        let delta = match dir with Left -> -n | Right -> n in
        let new_pos = (dial + delta) % 100 in
        let new_pos = if new_pos < 0 then new_pos + 100 else new_pos in
        let first_zero = match dir with Right -> 100 - dial | Left -> dial in
        let first_zero = if dial = 0 then 100 else first_zero in
        let acc =
          if first_zero <= n then acc + (((n - first_zero) / 100) + 1) else acc
        in
        (acc, new_pos))
  in
  count

let part1 _lines =
  let rotations = rotations _lines in
  num_zeros rotations

let part2 _lines =
  let rotations = rotations _lines in
  num_clicks rotations

let () =
  let lines = read_input () in
  printf "Part 1: %d\n" (part1 lines);
  printf "Part 2: %d\n" (part2 lines)
