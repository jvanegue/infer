# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
from pathlib import Path

def lookup(table: str, key: str) -> int:
    value: int = table.get(key)
    return value

def format_entry(name: str) -> str:
    if name is None:
        return "<unknown>"
    return name.upper()
