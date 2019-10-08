# A list of packages with errors which we chose to ignore (for now). It
# contains an exact package name together with a string which should be
# included in the error message.

BlackList = [
  ["coq-compcert.3.1.0", "Error: Corrupted compiled interface"], # flaky Makefile
  ["coq-compcert.3.3.0", "Error: Corrupted compiled interface"], # flaky Makefile
  ["coq-ltac2.0.3", "coq-ltac2 -> coq >= 8.10"], # Coq 8.10 not released yet
  ["coq-ltac2.0.3", "While removing coq"] # Coq 8.10 not released yet
]
