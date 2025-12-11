open Base
open Stdio

let read_input () = In_channel.read_lines "11/input.txt"

let parse_graph lines =
  List.fold lines
    ~init:(Map.empty (module String))
    ~f:(fun acc line ->
      match String.lsplit2 line ~on:':' with
      | Some (node, neighbors) ->
          let neighbors = neighbors |> String.strip |> String.split ~on:' ' in
          Map.set acc ~key:node ~data:neighbors
      | None -> acc)

let count_paths ~start graph =
  let memo = Hashtbl.create (module String) in
  let rec dfs device =
    match Hashtbl.find memo device with
    | Some count -> count
    | None ->
        let count =
          match Map.find graph device with
          | None -> 1 (* reached "out" or terminal *)
          | Some neighbors -> List.sum (module Int) neighbors ~f:dfs
        in
        Hashtbl.set memo ~key:device ~data:count;
        count
  in
  dfs start

let count_paths2 ~start graph =
  let module Key = struct
    type t = string * bool * bool [@@deriving sexp, compare, hash]
  end in
  let memo = Hashtbl.create (module Key) in
  let rec dfs device has_dac has_fft =
    let seen_dac = has_dac || String.equal device "dac" in
    let seen_fft = has_fft || String.equal device "fft" in
    if String.equal device "out" then if seen_dac && seen_fft then 1 else 0
    else
      let key = (device, seen_dac, seen_fft) in
      match Hashtbl.find memo key with
      | Some count -> count
      | None ->
          let count =
            match Map.find graph device with
            | None -> 0 (* dead end, not "out" *)
            | Some neighbors ->
                List.sum
                  (module Int)
                  neighbors
                  ~f:(fun n -> dfs n seen_dac seen_fft)
          in
          Hashtbl.set memo ~key ~data:count;
          count
  in
  dfs start false false

let part1 lines = lines |> parse_graph |> count_paths ~start:"you"
let part2 lines = lines |> parse_graph |> count_paths2 ~start:"svr"

let () =
  let lines = read_input () in
  printf "Part 1: %d\n" (part1 lines);
  printf "Part 2: %d\n" (part2 lines)
