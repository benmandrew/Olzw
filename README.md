# Olzw

**Lempel-Ziv-Welch** (LZW) compressor and decompressor for ASCII text files.

## Running

```bash
dune build
dune exec olzw
```

## Example Compression Ratios

File | Compression Ratio | Original Size (Mb) | Compressed Size (Mb) | Compression Time (s) | Decompression Time (s)
--- | --- | --- | --- | --- | ---
`t8.shakespeare.txt` | 2.41 | 5.46 | 2.26 | 1.46 | 0.524
`e.coli.txt` | 3.80 | 4.64 | 1.22 | 1.07 | 0.292
`bible.txt` | 2.84 | 4.05 | 1.43 | 0.982 | 0.344
`pi.txt` | 2.15 | 1.00 | 0.464 | 0.296 | 0.115

---

- `t8.shakespeare.txt` is the complete works of Willam Shakespeare ([link](https://ocw.mit.edu/ans7870/6/6.006/s08/lecturenotes/files/t8.shakespeare.txt)).
- `e.coli.txt` is the complete genome of the E. Coli bacterium ([link](https://corpus.canterbury.ac.nz/descriptions/#large)).
- `bible.txt` is the King James version of the bible ([link](https://corpus.canterbury.ac.nz/descriptions/#large)).
- `pi.txt` is the first million digits of pi ([link](https://corpus.canterbury.ac.nz/descriptions/#misc)).
