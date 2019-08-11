# A list of packages with errors which we chose to ignore. One reason could be Makefile instability.

BlackList = [
  ["coq-bdds.8.5.0", "Error: Could not find the .cmi file for interface parser.mli."],
  ["coq-bdds.8.7.0", "Error: Could not find the .cmi file for interface parser.mli."],
  ["coq-bignums.8.6.0", "Error: Corrupted compiled interface"],
  ["coq-bignums.8.7.0", "Error: Unable to locate library NMake_gen."],
  ["coq-coq2html.1.0", "Error: Unbound module Resources"],
  ["coq-coq2html.1.1", "Error: Unbound module Resources"],
  ["coq-cybele.1.3.0", "make inconsistent assumptions over interface CybeleConstants"],
  ["coq-hammer.1.1.1+8.9", "Error: Corrupted compiled interface"],
  ["coq-ltac2.0.3", "coq-ltac2 -> coq >= 8.10"],
  ["coq-string.8.5.0", "Error: Unbound module G_local_ascii_syntax"]
]
