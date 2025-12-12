open Core
open Stdio

let read_input () = In_channel.read_all "12/input.txt"

type region = { width : int; heght : int; counts : int list }

let parse_shape lines =
  List.concat_mapi lines ~f:(fun r line ->
      String.to_list line
      |> List.filter_mapi ~f:(fun c ch ->
          Option.some_if (Char.equal ch '#') (r, c)))

let parse_region line =
  match String.lsplit2 line ~on:':' with
  | None -> None
  | Some (dims, rest) -> (
      match String.lsplit2 dims ~on:'x' with
      | None -> None
      | Some (w, h) ->
          Some
            {
              width = Int.of_string w;
              heght = Int.of_string h;
              counts =
                String.split (String.strip rest) ~on:' '
                |> List.map ~f:Int.of_string;
            })

let parse input =
  let blocks =
    String.split_lines input
    |> List.group ~break:(fun a _ -> String.is_empty a)
    |> List.map ~f:(List.filter ~f:(Fn.non String.is_empty))
    |> List.filter ~f:(Fn.non List.is_empty)
  in
  List.partition_map blocks ~f:(fun lines ->
      match lines with
      | first :: rest
        when String.is_suffix first ~suffix:":"
             && not (String.is_substring first ~substring:"x") ->
          First (parse_shape rest)
      | lines when List.exists lines ~f:(String.is_substring ~substring:"x") ->
          Second (List.filter_map lines ~f:parse_region)
      | _ -> Second [])
  |> fun (shapes, region_lists) -> (shapes, List.concat region_lists)

let orientations shape =
  let transforms =
    [
      (fun (r, c) -> (r, c));
      (fun (r, c) -> (c, -r));
      (fun (r, c) -> (-r, -c));
      (fun (r, c) -> (-c, r));
      (fun (r, c) -> (r, -c));
      (fun (r, c) -> (-r, c));
      (fun (r, c) -> (c, r));
      (fun (r, c) -> (-c, -r));
    ]
  in
  let normalize cells =
    let min_r =
      List.fold cells ~init:Int.max_value ~f:(fun acc (r, _) -> min acc r)
    in
    let min_c =
      List.fold cells ~init:Int.max_value ~f:(fun acc (_, c) -> min acc c)
    in
    List.map cells ~f:(fun (r, c) -> (r - min_r, c - min_c))
    |> List.sort ~compare:[%compare: int * int]
  in
  List.fold transforms
    ~init:(Set.empty (module String), [])
    ~f:(fun (seen, results) t ->
      let transformed = List.map shape ~f:t |> normalize in
      let key = [%sexp_of: (int * int) list] transformed |> Sexp.to_string in
      if Set.mem seen key then (seen, results)
      else (Set.add seen key, transformed :: results))
  |> snd

let fits grid shape r c h w =
  List.for_all shape ~f:(fun (dr, dc) ->
      let nr, nc = (r + dr, c + dc) in
      nr >= 0 && nr < h && nc >= 0 && nc < w && not grid.(nr).(nc))

let place grid shape r c value =
  List.iter shape ~f:(fun (dr, dc) -> grid.(r + dr).(c + dc) <- value)

let rec can_place grid pieces remaining h w =
  if List.for_all remaining ~f:(( = ) 0) then true
  else
    let rec try_piece_types pieces remaining =
      match (pieces, remaining) with
      | [], [] -> false
      | p :: ps, rem :: rems ->
          if rem = 0 then try_piece_types ps rems
          else
            let found =
              List.exists p ~f:(fun orient ->
                  List.exists (List.range 0 h) ~f:(fun r ->
                      List.exists (List.range 0 w) ~f:(fun c ->
                          if fits grid orient r c h w then begin
                            place grid orient r c true;
                            let new_remaining =
                              List.mapi remaining ~f:(fun i x ->
                                  if
                                    i
                                    = List.length remaining
                                      - List.length (rem :: rems)
                                  then x - 1
                                  else x)
                            in
                            let result =
                              can_place grid pieces new_remaining h w
                            in
                            place grid orient r c false;
                            result
                          end
                          else false)))
            in
            found
      | _ -> false
    in
    try_piece_types pieces remaining

let solve shapes width height counts =
  let total_cells =
    List.fold2_exn counts shapes ~init:0 ~f:(fun acc c s ->
        acc + (c * List.length s))
  in
  if total_cells > width * height then false
  else
    let grid = Array.make_matrix ~dimx:height ~dimy:width false in
    let pieces = List.map shapes ~f:orientations in
    can_place grid pieces counts height width

let part1 input =
  let shapes, regions = parse input in
  List.count regions ~f:(fun r -> solve shapes r.width r.heght r.counts)

let () =
  let input = read_input () in
  printf "Part 1: %d\n" (part1 input)
