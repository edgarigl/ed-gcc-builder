# GNU Toolchain build-scripts

Makefile to build GCC toolchains.
Currently, it only builds bare-metal newlib based toolchains.

## Usage - Cloning

Once you've cloned the repo and before you start running things,
you'll need init the submodules:
```
git submodule update --init
```

This will clone the repos of the sub-modules, GCC, Binutils and Newlib.
If you want a secific version of any sub-module, you can either git
checkout/clone it manually or skip the submodule init step and copy
a sub directory of your own.

## Usage - Running

Examples:
```
make TARGET=microblaze-xilinx-elf PREFIX=${HOME}/dev
make TARGET=cris-axis-elf PREFIX=${HOME}/dev
make TARGET=riscv32-unknown-elf PREFIX=${HOME}/dev
```

Run make help to see more details.
