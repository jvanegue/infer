# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
from ast import *
from infer_semdiff import var, ignore, rewrite, accept, null

L = var("L")
M = var("M")
N = var("N")

# Ignore all import statements: both "import X" and "from X import Y"
ignore(ImportFrom(level=L, module=M, names=N))
ignore(Import(names=N))
