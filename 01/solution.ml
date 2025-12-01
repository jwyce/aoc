let read_input () =
  let ic = open_in "01/input.txt" in
  let rec read_lines acc =
    try
      let line = input_line ic in
      read_lines (line :: acc)
    with End_of_file ->
      close_in ic;
      List.rev acc
  in
  read_lines []

type direction = Left | Right

let rotations =
  List.map (fun s ->
      Scanf.sscanf s "%c%d" (fun c n ->
          let dir =
            match c with
            | 'R' -> Right
            | 'L' -> Left
            | _ -> failwith "Expected R or L"
          in
          (dir, n)))

let num_zeros rotations =
  let count, _ =
    List.fold_left
      (fun (acc, dial) (dir, n) ->
        let delta = match dir with Left -> -n | Right -> n in
        let new_pos = (dial + delta) mod 100 in
        let new_pos = if new_pos < 0 then new_pos + 100 else new_pos in
        let acc = if new_pos = 0 then acc + 1 else acc in
        (acc, new_pos))
      (0, 50) rotations
  in
  count

let num_clicks rotations =
  let count, _ =
    List.fold_left
      (fun (acc, dial) (dir, n) ->
        let delta = match dir with Left -> -n | Right -> n in
        let new_pos = (dial + delta) mod 100 in
        let new_pos = if new_pos < 0 then new_pos + 100 else new_pos in
        let first_zero =
          if dial = 0 then 100 else if dir = Right then 100 - dial else dial
        in
        let acc =
          if first_zero <= n then acc + (((n - first_zero) / 100) + 1) else acc
        in
        (acc, new_pos))
      (0, 50) rotations
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
  Printf.printf "Part 1: %d\n" (part1 lines);
  Printf.printf "Part 2: %d\n" (part2 lines)
