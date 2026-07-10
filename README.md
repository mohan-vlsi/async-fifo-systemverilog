# Asynchronous FIFO Design and Verification

An industry-style implementation of an **Asynchronous FIFO** in SystemVerilog, designed for reliable data transfer between independent clock domains (CDC). The project includes RTL design, a layered verification environment, SystemVerilog Assertions (SVA), and Functional Coverage.

---

## Project Overview

Asynchronous FIFOs are widely used in SoC and FPGA designs to safely transfer data between modules operating on different clock domains. This project demonstrates a complete FIFO implementation using Gray-code pointer synchronization along with a self-checking verification environment.

---

## Features

- Parameterized FIFO Design
- Independent Read and Write Clocks
- Gray-Code Pointer Synchronization
- Dual Flip-Flop CDC Synchronizers
- Full and Empty Flag Generation
- Layered SystemVerilog Verification Environment
- SystemVerilog Assertions (SVA)
- Functional Coverage
- Self-Checking Scoreboard
- Modular and Reusable RTL

---

## Repository Structure

```
async-fifo-systemverilog
│
├── rtl/
│   ├── async_fifo.sv
│   ├── fifo_mem.sv
│   ├── sync_ff.sv
│   ├── reset_sync.sv
│   ├── wptr_full.sv
│   ├── rptr_empty.sv
│   └── bin2gray.sv
│
├── tb/
│   ├── interface.sv
│   ├── transaction.sv
│   ├── generator.sv
│   ├── driver.sv
│   ├── monitor.sv
│   ├── scoreboard.sv
│   ├── environment.sv
│   ├── test.sv
│   └── top_tb.sv
│
├── assertions/
│   └── fifo_assertions.sv
│
├── coverage/
│   └── fifo_coverage.sv
│
├── docs/
│
├── sim/
│
└── README.md
```

---

## RTL Architecture

The RTL consists of the following major modules:

| Module | Description |
|---------|-------------|
| async_fifo.sv | Top-level FIFO module |
| fifo_mem.sv | Dual-port memory |
| wptr_full.sv | Write pointer and Full flag logic |
| rptr_empty.sv | Read pointer and Empty flag logic |
| sync_ff.sv | Two-stage synchronizer for CDC |
| reset_sync.sv | Reset synchronizer |
| bin2gray.sv | Binary-to-Gray code conversion |

---

## Verification Environment

The verification environment is built using SystemVerilog and follows a layered architecture.

```
Generator
    │
Mailbox
    │
Driver
    │
FIFO DUT
    │
Monitor
    │
Mailbox
    │
Scoreboard
```

Verification Components

- Interface
- Transaction
- Generator
- Driver
- Monitor
- Scoreboard
- Environment
- Test

---

## Assertions

Implemented SystemVerilog Assertions for:

- No Write when FIFO is Full
- No Read when FIFO is Empty
- FIFO Empty after Reset
- FIFO Not Full after Reset

---

## Functional Coverage

Coverage includes:

- Write Operations
- Read Operations
- Full Condition
- Empty Condition
- Cross Coverage:
  - Write × Full
  - Read × Empty

---

## Simulation

Simulation scripts can be added under the `sim/` directory.

Typical flow:

1. Compile RTL
2. Compile Testbench
3. Run Simulation
4. View Waveforms
5. Analyze Assertions
6. Check Functional Coverage

---

## Future Improvements

- UVM-based Verification Environment
- Constrained Random Verification
- Overflow and Underflow Detection
- Almost Full and Almost Empty Flags
- Coverage-Driven Verification
- CI/CD Integration using GitHub Actions

---

## Skills Demonstrated

- Verilog
- SystemVerilog
- RTL Design
- Clock Domain Crossing (CDC)
- Asynchronous FIFO Design
- Gray-Code Synchronization
- SystemVerilog Assertions (SVA)
- Functional Coverage
- Verification Methodology
- Self-Checking Testbench

---

## Author

**Mohan Meesala**

Electrical Engineering | VLSI | RTL Design | Design Verification
