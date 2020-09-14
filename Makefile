#
# ed-gcc-builder. A Makefile to build GCC toolchains.
#
# Copyright (C) 2020 Xilinx Inc.
# Written by Edgar E. Iglesias <edgar.iglesias@gmail.com>
#
# SPDX-License-Identifier: GPL-2.0-or-later
#

define USAGE
ed-gcc-builder

Targets:
help		Show help
install		Build and install the toolchain
all		Alias for install
clean		Runs make clean in each build-dir, removing temporary files
distclean	Same as clean + delete all build directories

To operate on individual targets/steps you can use the following targets:
config-%	Run configure for the sub-project
build-%		Build the sub-project
install-%	Install the sub-project
bootstrap-%	Bootstrap the sub-project (only for GCC)
clean-%		Clean the sub-project build directory

Available sub-projects:
$(ALL)

Examples:
make TARGET=riscv32-unknown-elf PREFIX=$(HOME)/dev
make TARGET=microblaze-xilinx-elf PREFIX=$(HOME)/dev
make TARGET=cris-axis-elf PREFIX=$(HOME)/dev

make config-$(SRC_BINUTILS)
make install-$(SRC_BINUTILS)
make bootstrap-$(SRC_GCC)
make clean-$(SRC_BINUTILS)
endef

SRC_GCC ?= gcc
SRC_BINUTILS ?= binutils-gdb
SRC_NEWLIB ?= newlib-cygwin
PREFIX ?=/opt/riscv/dev
TARGET ?=riscv32-unknown-elf

# Per sub-project configure options.
CFG_$(SRC_BINUTILS)=--enable-multilib --with-sysroot
CFG_$(SRC_GCC)=--enable-languages=c,c++ --enable-multilib --with-newlib
CFG_bootstrap/$(SRC_GCC)=--enable-languages=c,c++
CFG_$(SRC_NEWLIB)=--enable-multilib

BUILD=build/$(TARGET)

# All sub-projects
ALL=$(SRC_BINUTILS) $(SRC_GCC) bootstrap/$(SRC_GCC) $(SRC_NEWLIB)

all: install

# Some steps depend on being able to access the installed
# artefacts via PATH
export PATH := $(PREFIX)/bin:$(PATH)

.PHONY: help
.SILENT: help
help:
	$(info $(USAGE))
	@echo

config-%: $(BUILD)/%/config.log
	@#

build-%: $(BUILD)/%/config.log
	$(MAKE) -C $(BUILD)/$(*)

install-%: build-%
	$(MAKE) -C $(BUILD)/$(*) $(subst -$(*), , $(@))

clean-%:
	$(MAKE) -C $(BUILD)/$(*) $(subst -$(*), , $(@))

bootstrap-%: $(BUILD)/bootstrap/%/config.log
	$(MAKE) -C $(BUILD)/bootstrap/$(*) all-gcc
	$(MAKE) -C $(BUILD)/bootstrap/$(*) all-target-libgcc
	$(MAKE) -C $(BUILD)/bootstrap/$(*) install-gcc
	$(MAKE) -C $(BUILD)/bootstrap/$(*) install-target-libgcc

# Do not delete config.log if we fail the build mid-way.
# This tells make that the config.log intermediate should not be deleted.
.PRECIOUS: $(BUILD)/%/config.log
$(BUILD)/%/config.log:
	mkdir -p $(@D)
	cd $(@D);				\
	$(PWD)/$$(basename $$(dirname $@))/configure	\
		--prefix=$(PREFIX)			\
		--target=$(TARGET)			\
		--program-prefix=$(TARGET)-		\
		$(CFG_$(*))

clean: $(addprefix clean-, $(ALL))

binutils: install-$(SRC_BINUTILS)
newlib: install-$(SRC_NEWLIB)
gcc: install-$(SRC_GCC)

.PHONY: install
install:
	$(MAKE) binutils
	$(MAKE) bootstrap-gcc
	$(MAKE) newlib
	$(MAKE) gcc

distclean:
	$(RM) -fr build
