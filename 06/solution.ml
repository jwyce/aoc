let read_input () =
  let ic = open_in "06/input.txt" in
  let rec read_lines acc =
    try
      let line = input_line ic in
      read_lines (line :: acc)
    with End_of_file ->
      close_in ic;
      List.rev acc
  in
  read_lines []

let part1 _lines = 0

let part2 _lines = 0

let () =
  let lines = read_input () in
  Printf.printf "Part 1: %d\n" (part1 lines);
  Printf.printf "Part 2: %d\n" (part2 lines)
