open Olzw

let infile = "hello.txt"
let outfile = "hello.bin"

let alphabet =
  let explode str =
    let rec exp a b = if a < 0 then b else exp (a - 1) (str.[a] :: b) in
    exp (String.length str - 1) []
  in
  List.map
    (fun c -> String.make 1 c)
    (explode
       "\n\
       \ \
        !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")

(* let rec print_ints = function
  | [] -> print_char '\n'
  | i::is -> print_int i; print_char ' '; print_ints is *)

(* let print_int_arr arr =
  let n = Array.length arr in
  for i = 0 to n - 1 do
    print_int arr.(i); print_char ' '
  done;
  print_char '\n' *)

let () =
  let input = Core.In_channel.read_all infile in
  (* let start = Unix.gettimeofday () in *)
  let vs = Compressor.compress alphabet input in
  (* let stop = Unix.gettimeofday () in
  Printf.printf "Compression time: %fs\n%!" (stop -. start); *)
  Pack.pack outfile 16 vs;

  let vs' = Pack.unpack outfile 16 in
  (* print_ints vs;
  print_int_arr vs' *)
  let s = Decompressor.decompress alphabet vs' in
  print_int (String.length s);
  print_char '\n';
  print_char '\n';

  print_string s;
  print_char '\n';

  (* write_bytes outfile b;
  Printf.printf "Original size: %d\n%!" (get_file_size infile);
  Printf.printf "Compressed size: %d\n%!" (get_file_size outfile);
  Printf.printf "Compression ratio: %f\n%!" (float_of_int (get_file_size infile) /. float_of_int (get_file_size outfile));
  let b' = read_bytes outfile in
  let start = Unix.gettimeofday () in
  let _ = Decompressor.decompress alphabet b' in
  let stop = Unix.gettimeofday () in
  Printf.printf "Decompression time: %fs\n%!" (stop -. start) *)
