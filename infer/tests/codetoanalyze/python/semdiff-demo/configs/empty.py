# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
# An empty configuration file with no rules.
# Used to demonstrate what happens when semdiff has no rules:
# any structural difference is reported.
from ast import *
from infer_semdiff import var, ignore, rewrite, accept, null
