# 64DD H8 ROM

This repository contains a disassembly of the ROM found in the H8/3292 (retail, mask ROM variant) or H8/3294 (dev, programmable ROM variant) microcontroller in the N64 Disk Drive. This controls the disk drive and services commands sent over the `ASIC_CMD`/`ASIC_DATA` registers mapped into the N64 PI address space.

So far this repository only targets the development version `GS01A02 (97/07/17)`, other versions may be added in the future.

## Building

To build you will need:
- The target binary in the root of this repository, named `64DD_Dev_H8_3294_970717.rom`
- A binutils toolchain targeting `h8300-none-elf` (instructions below)

### Building the toolchain

Execute the following commands in an empty directory, replacing `$(PREFIX)` with the location to install the toolchain to (e.g. `/opt/h8300`)

```
wget https://ftp.gnu.org/gnu/binutils/binutils-2.43.tar.gz
tar xf binutils-2.43.tar.gz
mkdir -p build
cd build
../binutils-2.43/configure --prefix=$(PREFIX) --target=h8300-none-elf
make all-gas all-binutils all-ld
make install-gas install-binutils install-ld
```

Depending on your choice of installation prefix you may need to prepend `sudo` to the final command.

Once installed, add the `$(PREFIX)/bin` directory (e.g. `/opt/h8300/bin`) to your PATH.
