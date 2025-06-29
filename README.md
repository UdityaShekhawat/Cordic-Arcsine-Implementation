# Cordic-Arcsine-Implementation

This project implements a CORDIC (COordinate Rotation DIgital Computer) algorithm in Verilog to compute the arcsine (sin⁻¹) function using an ASMD (Algorithmic State Machine with Data Path) design.

📌 Features
Computes arcsin(x) using the iterative CORDIC method.

Designed using ASMD-style FSM for modular and structured hardware implementation.

Handles input validation with a dedicated ERROR state.

Uses fixed-point arithmetic suitable for FPGA/ASIC integration.



 Algorithm Overview
CORDIC (in vectoring mode) rotates a vector toward the x-axis, accumulating angle values to compute inverse trigonometric functions.

This implementation uses an ASMD architecture, which cleanly separates the control logic (FSM) from the datapath.

⚙️ FSM States
State	Description
IDLE	Waits for the start signal to begin computation.
INIT	Initializes all internal variables and sets up the input vector.
ROTATE	Iteratively performs CORDIC rotations to converge on the arcsin value.
DONE	Indicates completion and sets the output.
ERROR	Activated if input is out of the valid range [-1,1].



🧾 Input & Output
Input:
Fixed-point representation of a value in the range [-1,1].
Output:
Fixed-point representation of arcsin(input) in radians.
