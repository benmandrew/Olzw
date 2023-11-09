(lang dune 3.0)

(name olzw)

(generate_opam_files true)

(source
 (github benmandrew/Olzw))

(authors "Ben Andrew <benmandrew@gmail.com>")

(maintainers "Ben Andrew <benmandrew@gmail.com>")

(license MIT)

(package
 (name olzw)
 (synopsis "Lempel-Ziv-Welch (LZW) streaming compressor and decompressor for ASCII text files")
 (description "Lempel-Ziv-Welch (LZW) streaming compressor and decompressor for ASCII text files")
 (depends ocaml dune ctypes core))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
