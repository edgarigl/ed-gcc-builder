# GNU Toolchain build-scripts

Makefile to build GCC toolchains.
Currently, it only builds bare-metal newlib based toolchains.

Example:
```
make TARGET=riscv32-unknown-elf PREFIX=$(HOME)/dev
```

Run make help to see more details.
