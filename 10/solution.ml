open Core
open Stdio

let read_input () = In_channel.read_lines "10/input.txt"

let parse_line line =
  let parts = String.split line ~on:' ' in
  let slights = List.hd_exn parts in
  let slights = String.sub slights ~pos:1 ~len:(String.length slights - 2) in

  (* lights to bitmask *)
  let lights =
    String.foldi slights ~init:0 ~f:(fun i acc c ->
        if Char.equal c '#' then acc lor (1 lsl i) else acc)
  in

  let sbuttons = List.slice parts 1 (List.length parts - 1) in
  let buttons =
    List.map sbuttons ~f:(fun s ->
        String.sub s ~pos:1 ~len:(String.length s - 2)
        |> String.split ~on:',' |> List.map ~f:Int.of_string)
  in

  (* buttons -> bitmasks *)
  let button_masks =
    List.map buttons ~f:(fun btn ->
        List.fold btn ~init:0 ~f:(fun acc i -> acc lor (1 lsl i)))
  in

  let sjolt = List.last_exn parts in
  let joltages =
    String.sub sjolt ~pos:1 ~len:(String.length sjolt - 2)
    |> String.split ~on:',' |> List.map ~f:Int.of_string
  in
  (lights, buttons, button_masks, joltages)

let min_presses target buttons =
  let memo = Hashtbl.create (module Int) in
  let queue = Queue.create () in
  Hashtbl.set memo ~key:0 ~data:0;
  Queue.enqueue queue 0;

  let rec bfs () =
    match Queue.dequeue queue with
    | None -> -1
    | Some state when state = target -> Hashtbl.find_exn memo state
    | Some state ->
        let presses = Hashtbl.find_exn memo state in
        List.iter buttons ~f:(fun btn ->
            let next = state lxor btn in
            if not (Hashtbl.mem memo next) then begin
              Hashtbl.set memo ~key:next ~data:(presses + 1);
              Queue.enqueue queue next
            end);
        bfs ()
  in
  bfs ()

let min_presses_ilp buttons joltages =
  let open Lp in
  let n_buttons = List.length buttons in

  (* x_i = press count for button i, integer >= 0 *)
  let vars =
    Array.init n_buttons ~f:(fun i ->
        var ~integer:true ~lb:0. (sprintf "x%d" i))
  in

  (* minimize total presses *)
  let objective =
    minimize (Array.fold vars ~init:(c 0.) ~f:(fun acc v -> acc ++ v))
  in

  (* each counter must equal its target  *)
  let constrs =
    List.mapi joltages ~f:(fun counter_idx target_val ->
        let lhs =
          Array.foldi vars ~init:(c 0.) ~f:(fun btn_idx acc v ->
              let btn = List.nth_exn buttons btn_idx in
              if List.mem btn counter_idx ~equal:Int.equal then acc ++ v
              else acc)
        in
        lhs =~ c (Float.of_int target_val))
  in

  let problem = make ~name:"joltage" objective constrs in
  match Lp_glpk.solve ~term_output:false problem with
  | Ok (obj, _) -> Float.iround_nearest_exn obj
  | Error _ -> -1

let part1 lines =
  List.fold lines ~init:0 ~f:(fun acc line ->
      let lights, _, button_masks, _ = parse_line line in
      acc + min_presses lights button_masks)

let part2 lines =
  List.fold lines ~init:0 ~f:(fun acc line ->
      let _, buttons, _, joltages = parse_line line in
      acc + min_presses_ilp buttons joltages)

let () =
  let lines = read_input () in
  printf "Part 1: %d\n" (part1 lines);
  printf "Part 2: %d\n" (part2 lines)
