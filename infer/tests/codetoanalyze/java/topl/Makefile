# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

TESTS_DIR = ../../..

# NOTE: If you wish to deactivate a Topl test, simply remove it from this list
SUBDIRS = compareArgs hasnext immutableArray latent latentNonnull servlet slowIter strLiteral \
	  taint typeFilter validRange
# inactive: baos (reactivate when tests migrate to Java 11)

test-%:
	$(MAKE) -C $* test

test: $(SUBDIRS:%=test-%)

replace-%:
	$(MAKE) -C $* replace

replace: $(SUBDIRS:%=replace-%)

clean-%:
	$(MAKE) -C $* clean

clean: $(SUBDIRS:%=clean-%)
