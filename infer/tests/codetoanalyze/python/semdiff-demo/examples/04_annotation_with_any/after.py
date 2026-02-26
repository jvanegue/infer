# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
from typing import Any

def fetch(url: str) -> Any:
    return download(url)

def parse(data: str) -> list[str]:
    return data.split(",")
