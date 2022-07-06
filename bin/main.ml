open Olzw

let infile = "bible.txt"
let outfile = "compressed.bin"

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

let write_bytes file b =
  let outc = open_out_bin file in
  output_bytes outc b;
  close_out outc

(* Big-endian *)
let uint16_from_chars c0 c1 =
  let i0 = int_of_char c0 in
  let i1 = int_of_char c1 in
  i0 + (i1 * 256)

exception Exception of string

let read_bytes fn =
  let inc = open_in_bin fn in
  let rec go sofar =
    match input_char inc with
    | b0 -> (
        match input_char inc with
        | b1 -> go (uint16_from_chars b0 b1 :: sofar)
        | exception End_of_file -> raise (Exception "Odd number of bytes"))
    | exception End_of_file -> List.rev sofar
  in
  let res = go [] in
  close_in inc;
  let b = Bytes.make (2 * List.length res) ' ' in
  List.iteri (fun i c -> Bytes.set_int16_le b (2 * i) c) res;
  b

let get_file_size file =
  let ic = open_in file in
  let size = in_channel_length ic in
  close_in ic;
  size

let () =
  let input = Core.In_channel.read_all infile in
  let start = Unix.gettimeofday () in
  let b = Compressor.compress alphabet input in
  let stop = Unix.gettimeofday () in
  Printf.printf "Compression time: %fs\n%!" (stop -. start);
  write_bytes outfile b;
  Printf.printf "Original size: %d\n%!" (get_file_size infile);
  Printf.printf "Compressed size: %d\n%!" (get_file_size outfile);
  Printf.printf "Compression ratio: %f\n%!" (float_of_int (get_file_size infile) /. float_of_int (get_file_size outfile));
  let b' = read_bytes outfile in
  let start = Unix.gettimeofday () in
  let _ = Decompressor.decompress alphabet b' in
  let stop = Unix.gettimeofday () in
  Printf.printf "Decompression time: %fs\n%!" (stop -. start)
