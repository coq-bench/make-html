# A list of packages with errors which we chose to ignore (for now). It
# contains an exact package name together with a string which should be
# included in the error message.
# Most of errors randomly occur durring parallel builds.

BlackList = [
  ["coq-compcert.3.3.0", "Error: Corrupted compiled interface"],
  ["coq-hammer.1.0.8+8.7", "Error: Corrupted compiled interface"],
  ["coq-hammer.1.0.8+8.7", "make inconsistent assumptions over interface Hhlib"],
  ["coq-hammer.1.1.1+8.9", "Error: Corrupted compiled interface"],
  ["coq-ltac2.0.3", "coq-ltac2 -> coq >= 8.10"],
  ["coq-plugin-utils.1.1.0", "Error: Corrupted compiled interface"],
  ["coq-plugin-utils.1.3.0", "Error: Corrupted compiled interface"],
  ["coq-string.8.5.0", "Error: Unbound module G_local_ascii_syntax"],
  ["coq-string.8.5.0", "Error: Corrupted compiled interface"]
]
