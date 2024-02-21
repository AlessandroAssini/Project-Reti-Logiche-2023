# Project-Reti-Logiche-2023

Project of Reti Logiche A.Y. 2022-2023 at Politecnico di Milano.

The goal is to implement an HW module in VHDL. 
This module interfaces with a memory having 16-bit addresses and 8-bit data. The module comprises four output channels, each having 8 bits, and two primary one-bit inputs: W and START. W represents the input data, consisting of 2 bits, that identify one of the four output channels, followed immediately by 0 to 16 bits representing the memory address from which to retrieve the data and then save it onto the previously identified channel. START, when at logical 1, indicates the validity of the input sequence on W. START can be at logic 1 for 2 to 18 consecutive clock cycles, with a minimum of two cycles to read the channel bits.

For more information read the report.
