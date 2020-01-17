# A list of packages with errors which we chose to ignore (for now). It
# contains an exact package name together with a string which should be
# included in the error message.

BlackList = [
  ["coq-compcert.2.7.1", "Error: Corrupted compiled interface"], # flaky Makefile
  ["coq-compcert.3.1.0", "Error: Corrupted compiled interface"], # flaky Makefile
  ["coq-compcert.3.2.0", "Error: Corrupted compiled interface"], # flaky Makefile
  ["coq-compcert.3.3.0", "Error: Corrupted compiled interface"], # flaky Makefile
  ["coq-compcert.3.5", "Error: Corrupted compiled interface"], # flaky Makefile
  ["coq-metacoq-erasure.1.0~alpha+8.8", "make inconsistent assumptions over interface Quoter"],
  ["coq-stalmarck.8.5.0", "Error: Could not find the .cmi file for interface stal.mli."], # flaky Makefile
  ["coq-vst.2.2", "Error: Corrupted compiled interface"]
]
