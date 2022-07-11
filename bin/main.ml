open Olzw

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

let compress infile outfile codeword_size =
  let s = Core.In_channel.read_all infile in
  let start = Unix.gettimeofday () in
  let codes = Compressor.compress alphabet codeword_size s in
  let stop = Unix.gettimeofday () in
  Printf.printf "Compression time: %fs\n%!" (stop -. start);
  Pack.pack outfile codeword_size codes

let decompress infile outfile codeword_size =
  let codes = Pack.unpack infile codeword_size in
  let s = Decompressor.decompress alphabet codeword_size codes in
  Core.Out_channel.write_all outfile ~data:s

let usage_msg =
  "olzw compress -c <level> -i <input> -o <output>\n\
   olzw decompress -c <level> -i <input> -o <output>"

let codeword_size = ref 0
let infile = ref ""
let outfile = ref ""
let do_compression = ref true

exception Exception of string

let anon_fun s =
  match s with
  | "compress" -> do_compression := true
  | "decompress" -> do_compression := false
  | s ->
      raise (Exception (String.concat " " [ "Unrecognisable parameter:"; s ]))

let speclist =
  [
    ("-c", Arg.Set_int codeword_size, "Set compression level: 9 to 16 inclusive");
    ("-i", Arg.Set_string infile, "Set input file name");
    ("-o", Arg.Set_string outfile, "Set output file name");
  ]

let () =
  Arg.parse speclist anon_fun usage_msg;
  if !codeword_size < 9 || !codeword_size > 16 then
    raise (Exception "Compression level not in range [9,16]")
  else if !do_compression then compress !infile !outfile !codeword_size
  else decompress !infile !outfile !codeword_size
