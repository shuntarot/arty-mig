# Arty FPGA sample for MIG and JTAG-AXI

Vivado 2017.2 or higher is required.

## Build IP

Need IP generation before top-level synthesis or simulation.

- MIG
- JTAG-AXI
- MMCM

are generated.

```
cd ip
make build
```

## Build

Arty-7 35T FPGA image are built. It takes about 7 minutes on my machine.

```
cd syn
make build
```

## Program

Need USB connected Arty board.

```
cd syn
make program
```

## Run

Test DDR3 R/W via JTAG-AXI.

```
cd test/01_axi_rw
make
```

## Run RTL Simulation

DDR3 initialization and connection test only.

```
cd sim
make
```
