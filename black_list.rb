# A list of packages with errors which we chose to ignore (for now). It
# contains an exact package name together with a string which should be
# included in the error message. The errors are mostly due to flaky Makefiles.

BlackList = [
  ["coq-chick-blog.1.0.0", "[ERROR] Sorry, resolution of the request timed out."],
  ["coq-chick-blog.1.0.1", "[ERROR] Sorry, resolution of the request timed out."],
  ["coq-compcert.2.5.0", "Error: Corrupted compiled interface"],
  ["coq-compcert.2.7.1", "Error: Corrupted compiled interface"],
  ["coq-compcert.3.0.0", "Error: Corrupted compiled interface"],
  ["coq-compcert.3.0.1", "Error: Corrupted compiled interface"],
  ["coq-compcert.3.1.0", "Error: Corrupted compiled interface"],
  ["coq-compcert.3.2.0", "Error: Corrupted compiled interface"],
  ["coq-compcert.3.3.0", "Error: Corrupted compiled interface"],
  ["coq-compcert.3.4", "Error: Corrupted compiled interface"],
  ["coq-compcert.3.5", "Error: Corrupted compiled interface"],
  ["coq-hardware.8.5.0", "make inconsistent assumptions over interface Comp"],
  ["coq-metacoq-erasure.1.0~alpha+8.8", "make inconsistent assumptions over interface Quoter"],
  ["coq-metacoq-pcuic.1.0~alpha1+8.9", "make inconsistent assumptions over interface Quoter"],
  ["coq-stalmarck.8.5.0", "Error: Could not find the .cmi file for interface stal.mli."],
  ["coq-stalmarck.8.12.0", "coq-stalmarck -> coq >= 8.12"],
  ["coq-vst.2.2", "Error: Corrupted compiled interface"]
]
