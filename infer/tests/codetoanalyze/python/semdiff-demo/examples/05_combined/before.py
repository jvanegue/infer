# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
import os

def lookup(table, key):
    value = table.get(key)
    return value

def format_entry(name):
    if name is None:
        return "<unknown>"
    return name.upper()
