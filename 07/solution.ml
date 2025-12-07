open Base
open Stdio

let read_input () = In_channel.read_lines "07/input.txt"

let neighbors grid (x, y) =
  let rows = Array.length grid in
  let cols = Array.length grid.(0) in
  let cell =
    if y >= 0 && y < rows && x >= 0 && x < cols then Some grid.(y).(x) else None
  in
  let deltas =
    match cell with
    | Some '.' | Some 'S' -> [ (0, 1) ]
    | Some '^' -> [ (1, 1); (-1, 1) ]
    | _ -> []
  in
  deltas
  |> List.map ~f:(fun (dx, dy) -> (x + dx, y + dy))
  |> List.filter ~f:(fun (nx, ny) ->
      nx >= 0 && nx < cols && ny >= 0 && ny < rows)

let bfs grid start =
  let to_key (x, y) = Printf.sprintf "%d,%d" x y in
  let visited = Hash_set.create (module String) in
  Hash_set.add visited (to_key start);
  let rec go queue splitters =
    match queue with
    | [] -> splitters
    | current :: rest ->
        let ns = neighbors grid current in
        let s' = if List.length ns = 2 then splitters + 1 else splitters in
        let new_ns =
          List.filter ns ~f:(fun n -> not (Hash_set.mem visited (to_key n)))
        in
        List.iter new_ns ~f:(fun n -> Hash_set.add visited (to_key n));
        go (rest @ new_ns) s'
  in
  go [ start ] 0

let count_paths grid start =
  let to_key (x, y) = Printf.sprintf "%d,%d" x y in
  let memo = Hashtbl.create (module String) in
  let rec dfs pos =
    let key = to_key pos in
    match Hashtbl.find memo key with
    | Some count -> count
    | None ->
        let ns = neighbors grid pos in
        let count =
          match ns with [] -> 1 | _ -> List.sum (module Int) ns ~f:dfs
        in
        Hashtbl.set memo ~key ~data:count;
        count
  in
  dfs start

let part1 lines =
  let grid = lines |> List.map ~f:String.to_array |> List.to_array in
  let start_x =
    Array.findi grid.(0) ~f:(fun _ c -> Char.equal c 'S')
    |> Option.value_exn |> fst
  in
  bfs grid (start_x, 0)

let part2 lines =
  let grid = lines |> List.map ~f:String.to_array |> List.to_array in
  let start_x =
    Array.findi grid.(0) ~f:(fun _ c -> Char.equal c 'S')
    |> Option.value_exn |> fst
  in
  count_paths grid (start_x, 0)

let () =
  let lines = read_input () in
  printf "Part 1: %d\n" (part1 lines);
  printf "Part 2: %d\n" (part2 lines)
