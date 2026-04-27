# UART VIP Verification using UVM

###  Overview
This project focuses on **developing a UART Verification IP (VIP)** and using it to verify UART functionality based on the UVM methodology.

The VIP is designed to be **reusable and configurable**, supporting different UART configurations such as baud rate, data length, parity, and stop bits.

The verification environment validates:
- UART transmission (TX)
- UART reception (RX)
- Protocol correctness
- Error scenarios (parity, framing)



###  Objectives
- Build a reusable UART VIP
- Apply UVM methodology in a real verification environment
- Verify UART protocol with multiple test scenarios
- Implement checking using scoreboard and monitor



###  Testbench Architecture

The verification environment follows standard UVM architecture:
<img width="1052" height="593" alt="image" src="https://github.com/user-attachments/assets/2651dbfa-214e-4959-9b4a-a33a1fcb8416" />
