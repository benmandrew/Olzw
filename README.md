# Olzw

**Lempel-Ziv-Welch** (LZW) compressor and decompressor for ASCII text files.

## Running

```bash
dune build
dune exec olzw
```

## Example Compression Ratios

File | Compression Ratio | Original Size (Mb) | Compressed Size (Mb) | Compression Time (s) | Compression Level
--- | --- | --- | --- | --- | ---
`t8.shakespeare.txt` | 2.42 | 5.46 | 2.26 | 1.25 | 16
`e.coli.txt` | 3.80 | 4.64 | 1.22 | 0.552 | 12
`bible.txt` | 2.89 | 4.05 | 1.40 | 0.891 | 16
`pi.txt` | 2.18 | 1.00 | 0.458 | 0.170 | 14
`all.txt` | 1.31 | 15.1 | 11.5 | 3.37 | 9
`all10.txt` | 1.31 | 151 | 115 | 30.5 | 13

---

- `t8.shakespeare.txt` is the complete works of William Shakespeare ([link](https://ocw.mit.edu/ans7870/6/6.006/s08/lecturenotes/files/t8.shakespeare.txt)).
- `e.coli.txt` is the complete genome of the E. Coli bacterium ([link](https://corpus.canterbury.ac.nz/descriptions/#large)).
- `bible.txt` is the King James version of the bible ([link](https://corpus.canterbury.ac.nz/descriptions/#large)).
- `pi.txt` is the first million digits of pi ([link](https://corpus.canterbury.ac.nz/descriptions/#misc)).
- `all.txt` is all of the above concatenated together.
- `all10.txt` is `all.txt` repeated 10 times.
