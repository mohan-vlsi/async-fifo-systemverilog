  Asynchronous FIFO Design & Verification (SystemVerilog)
  
  Overview:
  
This project implements a parameterized Asynchronous FIFO (First-In-First-Out) buffer in SystemVerilog, supporting dual clock domains with safe Clock Domain Crossing (CDC). The design uses Gray-coded pointers and robust full/empty flag detection, ensuring reliable data transfer in high-performance SoCs.


 Key Features:

 ✅ Dual Clock Domain Support — Independent read/write clocks.
 
 ✅ Gray Code Pointer Logic — Eliminates metastability during pointer synchronization.
 
 ✅ Full/Empty Flags — Safe and accurate FIFO status detection.
 
 ✅ Parameterized Depth & Width — Flexible for various system requirements.
 
 ✅ Clean RTL — Synthesizable, modular, and reusable design.
 
 ---
 
 

Verification Methodology:

Developed a structured SystemVerilog testbench to validate the design under randomized and directed scenarios:

 Stimulus Generators — Directed + constrained-random tests.
 
 Bus Functional Models (BFMs) — Modeled read/write agents.
 
 Monitors & Scoreboard — Checked data integrity and ordering.
 
 Functional Coverage — Ensured complete scenario exploration.
 
 Assertions — Verified protocol rules and CDC safety.

 Verified successfully on Synopsys VCS and EDA Playground, achieving 100% correctness across multiple test scenarios.
 
 ---
 

Tools & Technologies:

Languages: SystemVerilog (RTL & TB)

EDA Tools: Synopsys VCS, Verdi, Cadence Xcelium, EDA Playground

Methodologies: UVM-style structured verification, CDC handling, constrained random testing.

---



Skills Demonstrated:

 RTL design for asynchronous systems
 
 Clock Domain Crossing (CDC) techniques
 
 Verification environment development (BFMs, agents, monitors, scoreboards)
 
 Debugging with industry tools (VCS, Verdi)
 
 Reusable and parameterized hardware design.
 
 ---


Why this matters:

Asynchronous FIFOs are fundamental in SoC design, enabling safe data transfer between subsystems with different clock frequencies. This project reflects industry-grade design and verification practices for CDC handling, making it highly relevant for ASIC/FPGA roles.

---

Author: [Mohan Meesala](https://linkedin.com/in/mohan-meesala-)

Explore more projects on [GitHub](https://github.com/mohan-vlsi)

