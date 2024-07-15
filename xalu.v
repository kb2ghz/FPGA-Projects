// 4-bit ALU slice design
// Mike McCann 7/5/2024
// tested on  a Altera/Intel Cyclone II EP2C20F484C7 FPGA

module XALU
	( co_left,
	  co_right,
	  ci_left,
	  ci_right,
	  da0, da1, da2, da3,
	  db0, db1, db2, db3,
	  d0, d1, d2, d3,
	  ZERO, NEG_ZERO,
	  EQU,
	  COM,
	  F0, F1, F2
	);
	
output co_left;
output co_right;
input ci_left;
input ci_right;
input da0, da1, da2, da3;  // input port A
input db0, db1, db2, db3;  // input port B
output d0, d1, d2, d3;     // output port
output ZERO, NEG_ZERO;     // zero detector
output EQU;                // A = B
input COM;                 // 1's complement mode
input F0, F1, F2;          // function code input

wire bit0cy, bit1cy, bit2cy;  // carry signals between full adders

wire ADD, AND, OR, XOR, PASSA, PASSB, SHL, SHR;
wire d0int, d1int, d2int, d3int;

assign d0int = (ADD & (da0 ^ db0 ^ ci_right)) |
               (AND & da0 & db0)   |
               (OR & (da0 | db0))  |
               (XOR & (da0 ^ db0)) |
               (PASSA & da0) |
               (PASSB & db0) |
               (SHL & ci_right) |
               (SHR & da1);

assign d1int = (ADD & (da1 ^ db1 ^ bit0cy)) |
               (AND & da1 & db1)   |
               (OR & (da1 | db1))  |
               (XOR & (da1 ^ db1)) |
               (PASSA & da1) |
               (PASSB & db1) |
               (SHL & da0) |
               (SHR & da2);

assign d2int = (ADD & (da2 ^db2 ^ bit1cy)) |
               (AND & da2 & db2)   |
               (OR & (da2 | db2))  |
               (XOR & (da2 ^ db2)) |
               (PASSA & da2) |
               (PASSB & db2) |
               (SHL & da1) |
               (SHR & da3);

assign d3int = (ADD & (da3 ^db3 ^ bit2cy)) |
               (AND & da3 & db3)   |
               (OR & (da3 | db3))  |
               (XOR & (da3 ^ db3)) |
               (PASSA & da3) |
               (PASSB & db3) |
               (SHL & da2) |
               (SHR & ci_left);

assign bit0cy = da0 & db0 | ci_right & (da0 | db0);
assign bit1cy = da1 & db1 | bit0cy & (da1 | db1);
assign bit2cy = da2 & db2 | bit1cy & (da2 | db2);

// inverting output mode

assign d0 = COM ^ d0int;
assign d1 = COM ^ d1int;
assign d2 = COM ^ d2int;
assign d3 = COM ^ d3int;

// function code decode

assign ADD = ~F2 & ~F1 & ~F0;     // 0
assign AND = ~F2 & ~F1 & F0;      // 1
assign OR = ~F2 & F1 & ~F0;       // 2
assign XOR = ~F2 & F1 & F0;       // 3
assign PASSA = F2 & ~F1 & ~F0;    // 4
assign PASSB = F2 & ~F1 & F0;     // 5
assign SHR = F2 & F1 & ~F0;       // 6
assign SHL = F2 & F1 & F0;        // 7

// carry outputs

assign co_left = (SHL & da3) | (ADD & (da3 & db3 | bit2cy & (da3 | db3)));
assign co_right = SHR & da0;

// output status

assign ZERO = ~d0 & ~d1 & ~d2 & ~d3;
assign NEG_ZERO = d0 & d1 & d2 & d3;

assign EQU = ((da0 & db0) | (~da0 & ~db0)) &
             ((da1 & db1) | (~da1 & ~db1)) &
				 ((da2 & db2) | (~da2 & ~db2)) &
				 ((da3 & db3) | (~da3 & ~db3));
             
endmodule
