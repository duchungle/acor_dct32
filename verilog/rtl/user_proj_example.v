module user_proj_example (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
// Global Signals
    input		iClk,
    input		iRst_n,	// Synchronous Reset_n
// Inputs
// Control Signals
    input		iValid,
    input	[2:0]	iSize,	// 000->2p; 001->4p; 010->8p; 011->16p; 1xx->32p
// Data Signals
    input		iSVAL,
    input		iSDAT,
// Outputs
    output	reg	oSVAL,
    output	reg	oSDAT
);

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
 
 wire			Valid_n;
 reg	[2:0]	Size;
 
 // Input ShiftRegs
 wire	[255:0]	RegIn_w;
 reg	[255:0]	RegIn; // 32*8bit
 
 // Core Signals
	// Input Signals
 wire	[7:0]	X0,  X1,  X2,  X3,	X4,  X5,  X6,  X7,
	/* 8.0 */	X8,  X9,  X10, X11, X12, X13, X14, X15,
				X16, X17, X18, X19,	X20, X21, X22, X23,
				X24, X25, X26, X27,	X28, X29, X30, X31;
	// Output Signals
 wire	[12:0]	/*13.0*/  Y0, Y16;
 wire	[18:0]	/*14.5*/  Y8, Y24;
 wire	[19:0]	/*14.6*/  Y4, Y20, Y12, Y28;
 wire	[21:0]	/*14.8*/  Y2, Y18, Y10, Y26, Y6, Y22, Y14, Y30;
 wire	[23:0]	/*14.10*/ Y1, Y17, Y9,  Y25, Y5, Y21, Y13, Y29,
						  Y3, Y19, Y11, Y27, Y7, Y23, Y15, Y31;
 
 // Output ShiftRegs
 reg	[9:0]	CounterOut; // count 0 to 768
 wire	[9:0]	CounterOut_plus1;
 wire	[9:0]	CounterOut_w;
 wire			CounterOut_Rstn;
 wire			CounterEnd;
 wire			CounterEnd32, CounterEnd16, CounterEnd8, CounterEnd4, CounterEnd2;
 
 wire			ShiftCtrl;
 reg	[767:0]	RegOut;
 wire	[767:0]	RegOut_Sft;
 wire	[23:0]	RegOut0,  RegOut1,  RegOut2,  RegOut3,
				RegOut4,  RegOut5,  RegOut6,  RegOut7,
				RegOut8,  RegOut9,  RegOut10, RegOut11,
				RegOut12, RegOut13, RegOut14, RegOut15,
				RegOut16, RegOut17, RegOut18, RegOut19,
				RegOut20, RegOut21, RegOut22, RegOut23,
				RegOut24, RegOut25, RegOut26, RegOut27,
				RegOut28, RegOut29, RegOut30, RegOut31;
 
/*****************************************************************************
 *                               Input ShiftRegs                             *
 *****************************************************************************/
 
 assign RegIn_w = (iSVAL) ? {RegIn[254:0], iSDAT} : RegIn;
 always@(posedge iClk)
 begin
	RegIn <= {(256){iRst_n}} & RegIn_w;
 end
 
 assign X0  = RegIn[7:0];
 assign X1  = RegIn[15:8];
 assign X2  = RegIn[23:16];
 assign X3  = RegIn[31:24];
 assign X4  = RegIn[39:32];
 assign X5  = RegIn[47:40];
 assign X6  = RegIn[55:48];
 assign X7  = RegIn[63:56];
 assign X8  = RegIn[71:64];
 assign X9  = RegIn[79:72];
 assign X10 = RegIn[87:80];
 assign X11 = RegIn[95:88];
 assign X12 = RegIn[103:96];
 assign X13 = RegIn[111:104];
 assign X14 = RegIn[119:112];
 assign X15 = RegIn[127:120];
 assign X16 = RegIn[135:128];
 assign X17 = RegIn[143:136];
 assign X18 = RegIn[151:144];
 assign X19 = RegIn[159:152];
 assign X20 = RegIn[167:160];
 assign X21 = RegIn[175:168];
 assign X22 = RegIn[183:176];
 assign X23 = RegIn[191:184];
 assign X24 = RegIn[199:192];
 assign X25 = RegIn[207:200];
 assign X26 = RegIn[215:208];
 assign X27 = RegIn[223:216];
 assign X28 = RegIn[231:224];
 assign X29 = RegIn[239:232];
 assign X30 = RegIn[247:240];
 assign X31 = RegIn[255:248];

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
 
 ACor_DCT_32p DCT32p (
	// Input Signals
	.iX0  (X0),  .iX1  (X1),  .iX2  (X2),  .iX3  (X3),
	.iX4  (X4),  .iX5  (X5),  .iX6  (X6),  .iX7  (X7),
	.iX8  (X8),  .iX9  (X9),  .iX10 (X10), .iX11 (X11),
	.iX12 (X12), .iX13 (X13), .iX14 (X14), .iX15 (X15),
	.iX16 (X16), .iX17 (X17), .iX18 (X18), .iX19 (X19),
	.iX20 (X20), .iX21 (X21), .iX22 (X22), .iX23 (X23),
	.iX24 (X24), .iX25 (X25), .iX26 (X26), .iX27 (X27),
	.iX28 (X28), .iX29 (X29), .iX30 (X30), .iX31 (X31),
					
	// Output Signals
	.oY0  (Y0),  .oY1  (Y1),  .oY2  (Y2),  .oY3  (Y3),
	.oY4  (Y4),  .oY5  (Y5),  .oY6  (Y6),  .oY7  (Y7),
	.oY8  (Y8),  .oY9  (Y9),  .oY10 (Y10), .oY11 (Y11),
	.oY12 (Y12), .oY13 (Y13), .oY14 (Y14), .oY15 (Y15),
	.oY16 (Y16), .oY17 (Y17), .oY18 (Y18), .oY19 (Y19),
	.oY20 (Y20), .oY21 (Y21), .oY22 (Y22), .oY23 (Y23),
	.oY24 (Y24), .oY25 (Y25), .oY26 (Y26), .oY27 (Y27),
	.oY28 (Y28), .oY29 (Y29), .oY30 (Y30), .oY31 (Y31)
 );

/*****************************************************************************
 *                              Output ShiftRegs                             *
 *****************************************************************************/
 
 always@(posedge iClk)
 begin
	Size <= iSize;
 end
 
 // ShiftCtrl = (CounterOut!=0);
 assign ShiftCtrl = ((CounterOut[9]|CounterOut[8]) | (CounterOut[7]|CounterOut[6])) |
					((CounterOut[5]|CounterOut[4]) | (CounterOut[3]|CounterOut[2])) |
					 (CounterOut[1]|CounterOut[0]);
 
 // CounterEnd = (Size[2]) ? (CounterOut==768) :
 //				 (Size[1]) ? ( (Size[0]) ? (CounterOut==384) : (CounterOut==192) ) :
 //							 ( (Size[0]) ? (CounterOut== 96) : (CounterOut== 48) );
 assign CounterEnd32 = CounterOut[9] & CounterOut[8];
 assign CounterEnd16 = CounterOut[8] & CounterOut[7];
 assign CounterEnd8  = CounterOut[7] & CounterOut[6];
 assign CounterEnd4  = CounterOut[6] & CounterOut[5];
 assign CounterEnd2  = CounterOut[5] & CounterOut[4];
 assign CounterEnd = (Size[2]) ? CounterEnd32 :
					 (Size[1]) ? ( (Size[0]) ? CounterEnd16 : CounterEnd8 ) :
								 ( (Size[0]) ? CounterEnd4  : CounterEnd2 );
 
 /*always@(posedge iClk)
 begin
	if (~iRst_n|CounterEnd)
		CounterOut <= 10'b0;
	else if (iValid|ShiftCtrl)
		CounterOut <= CounterOut + 1'b1;
	else
		CounterOut <= CounterOut;
 end*/
 Ripple_Add_10bit_plus1 CounterPlus1 (.iA (CounterOut), .oS (CounterOut_plus1));
 assign CounterOut_w = (iValid|ShiftCtrl) ? CounterOut_plus1 : CounterOut;
 assign CounterOut_Rstn = iRst_n & ~CounterEnd;
 always@(posedge iClk)
 begin
	CounterOut <= {(10){CounterOut_Rstn}} & CounterOut_w;
 end

 always@(posedge iClk)
 begin
	oSVAL <= ShiftCtrl;
 end
 
 /*always@(posedge iClk)
 begin
	if (iValid)
		RegOut <= {	Y31, {Y30,2'b0}, Y29, {        Y28, 4'b0},
					Y27, {Y26,2'b0}, Y25, {        Y24, 5'b0},
					Y23, {Y22,2'b0}, Y21, {        Y20, 4'b0},
					Y19, {Y18,2'b0}, Y17, {Y16[12],Y16,10'b0},
					Y15, {Y14,2'b0}, Y13, {        Y12, 4'b0},
					Y11, {Y10,2'b0}, Y9,  {        Y8,  5'b0},
					Y7,  {Y6 ,2'b0}, Y5,  {        Y4,  4'b0},
					Y3,  {Y2 ,2'b0}, Y1,  {Y0[12], Y0, 10'b0}};
	else if (ShiftCtrl)
		RegOut <= {1'b0, RegOut[767:1]};
	else
		RegOut <= RegOut;
 end*/
 assign RegOut_Sft[766:0] = (ShiftCtrl) ? RegOut[767:1] : RegOut[766:0];
 assign RegOut_Sft[767]   = ~ShiftCtrl & RegOut[767];
 
 assign Valid_n = ~iValid;
 
 assign RegOut0[9:0]    = {(10){Valid_n}} & RegOut_Sft[9:0];
 assign RegOut0[23:10]  = (iValid) ? {Y0[12], Y0} : RegOut_Sft[23:10];
 assign RegOut1         = (iValid) ? Y1   : RegOut_Sft[47:24];
 assign RegOut2[1:0]    = {(2){Valid_n}}  & RegOut_Sft[49:48];
 assign RegOut2[23:2]   = (iValid) ? Y2   : RegOut_Sft[71:50];
 assign RegOut3         = (iValid) ? Y3   : RegOut_Sft[95:72];
 assign RegOut4[3:0]    = {(4){Valid_n}}  & RegOut_Sft[99:96];
 assign RegOut4[23:4]   = (iValid) ? Y4   : RegOut_Sft[119:100];
 assign RegOut5         = (iValid) ? Y5   : RegOut_Sft[143:120];
 assign RegOut6[1:0]    = {(2){Valid_n}}  & RegOut_Sft[145:144];
 assign RegOut6[23:2]   = (iValid) ? Y6   : RegOut_Sft[167:146];
 assign RegOut7         = (iValid) ? Y7   : RegOut_Sft[191:168];
 assign RegOut8[4:0]    = {(5){Valid_n}}  & RegOut_Sft[196:192];
 assign RegOut8[23:5]   = (iValid) ? Y8   : RegOut_Sft[215:197];
 assign RegOut9         = (iValid) ? Y9   : RegOut_Sft[239:216];
 assign RegOut10[1:0]   = {(2){Valid_n}}  & RegOut_Sft[241:240];
 assign RegOut10[23:2]  = (iValid) ? Y10  : RegOut_Sft[263:242];
 assign RegOut11        = (iValid) ? Y11  : RegOut_Sft[287:264];
 assign RegOut12[3:0]   = {(4){Valid_n}}  & RegOut_Sft[291:288];
 assign RegOut12[23:4]  = (iValid) ? Y12  : RegOut_Sft[311:292];
 assign RegOut13        = (iValid) ? Y13  : RegOut_Sft[335:312];
 assign RegOut14[1:0]   = {(2){Valid_n}}  & RegOut_Sft[337:336];
 assign RegOut14[23:2]  = (iValid) ? Y14  : RegOut_Sft[359:338];
 assign RegOut15        = (iValid) ? Y15  : RegOut_Sft[383:360];
 assign RegOut16[9:0]   = {(10){Valid_n}} & RegOut_Sft[393:384];
 assign RegOut16[23:10] = (iValid) ? {Y16[12],Y16} : RegOut_Sft[407:394];
 assign RegOut17        = (iValid) ? Y17  : RegOut_Sft[431:408];
 assign RegOut18[1:0]   = {(2){Valid_n}}  & RegOut_Sft[433:432];
 assign RegOut18[23:2]  = (iValid) ? Y18  : RegOut_Sft[455:434];
 assign RegOut19        = (iValid) ? Y19  : RegOut_Sft[479:456];
 assign RegOut20[3:0]   = {(4){Valid_n}}  & RegOut_Sft[483:480];
 assign RegOut20[23:4]  = (iValid) ? Y20  : RegOut_Sft[503:484];
 assign RegOut21        = (iValid) ? Y21  : RegOut_Sft[527:504];
 assign RegOut22[1:0]   = {(2){Valid_n}}  & RegOut_Sft[529:528];
 assign RegOut22[23:2]  = (iValid) ? Y22  : RegOut_Sft[551:530];
 assign RegOut23        = (iValid) ? Y23  : RegOut_Sft[575:552];
 assign RegOut24[4:0]   = {(5){Valid_n}}  & RegOut_Sft[580:576];
 assign RegOut24[23:5]  = (iValid) ? Y24  : RegOut_Sft[599:581];
 assign RegOut25        = (iValid) ? Y25  : RegOut_Sft[623:600];
 assign RegOut26[1:0]   = {(2){Valid_n}}  & RegOut_Sft[625:624];
 assign RegOut26[23:2]  = (iValid) ? Y26  : RegOut_Sft[647:626];
 assign RegOut27        = (iValid) ? Y27  : RegOut_Sft[671:648];
 assign RegOut28[3:0]   = {(4){Valid_n}}  & RegOut_Sft[675:672];
 assign RegOut28[23:4]  = (iValid) ? Y28  : RegOut_Sft[695:676];
 assign RegOut29        = (iValid) ? Y29  : RegOut_Sft[719:696];
 assign RegOut30[1:0]   = {(2){Valid_n}}  & RegOut_Sft[721:720];
 assign RegOut30[23:2]  = (iValid) ? Y30  : RegOut_Sft[743:722];
 assign RegOut31        = (iValid) ? Y31  : RegOut_Sft[767:744];
 
 always@(posedge iClk)
 begin
	RegOut <= {RegOut31, RegOut30, RegOut29, RegOut28,
			   RegOut27, RegOut26, RegOut25, RegOut24,
			   RegOut23, RegOut22, RegOut21, RegOut20,
			   RegOut19, RegOut18, RegOut17, RegOut16,
			   RegOut15, RegOut14, RegOut13, RegOut12,
			   RegOut11, RegOut10, RegOut9,  RegOut8,
			   RegOut7,  RegOut6,  RegOut5,  RegOut4,
			   RegOut3,  RegOut2,  RegOut1,  RegOut0};
 end
 
 always@(posedge iClk)
 begin
	oSDAT <= RegOut[0];
 end
 
endmodule

module Ripple_Add_10bit_plus1 (
	// Input Signals
	input	[9:0]	iA,
	
	// Output Signals
	output	[9:0]	oS
);

wire	[7:0] C;

assign oS[0] = ~iA[0];
FA_Cir_Cin0 S1 (.iA (iA[1]), .iB (iA[0]), .oS (oS[1]), .oC (C[0]));
FA_Cir_Cin0 S2 (.iA (iA[2]), .iB (C[0]),  .oS (oS[2]), .oC (C[1]));
FA_Cir_Cin0 S3 (.iA (iA[3]), .iB (C[1]),  .oS (oS[3]), .oC (C[2]));
FA_Cir_Cin0 S4 (.iA (iA[4]), .iB (C[2]),  .oS (oS[4]), .oC (C[3]));
FA_Cir_Cin0 S5 (.iA (iA[5]), .iB (C[3]),  .oS (oS[5]), .oC (C[4]));
FA_Cir_Cin0 S6 (.iA (iA[6]), .iB (C[4]),  .oS (oS[6]), .oC (C[5]));
FA_Cir_Cin0 S7 (.iA (iA[7]), .iB (C[5]),  .oS (oS[7]), .oC (C[6]));
FA_Cir_Cin0 S8 (.iA (iA[8]), .iB (C[6]),  .oS (oS[8]), .oC (C[7]));
assign oS[9] = iA[9]^C[7];

endmodule

module ACor_DCT_32p (
	// Input Signals
	input	[7:0]	iX0,  iX1,  iX2,  iX3,	iX4,  iX5,  iX6,  iX7,
		/* 8.0 */	iX8,  iX9,  iX10, iX11, iX12, iX13, iX14, iX15,
					iX16, iX17, iX18, iX19,	iX20, iX21, iX22, iX23,
					iX24, iX25, iX26, iX27,	iX28, iX29, iX30, iX31,
					
	// Output Signals
	output	[12:0]	/*13.0*/  oY0, oY16,
	output	[18:0]	/*14.5*/  oY8, oY24,
	output	[19:0]	/*14.6*/  oY4, oY20, oY12, oY28,
	output	[21:0]	/*14.8*/  oY2, oY18, oY10, oY26,
							  oY6, oY22, oY14, oY30,
	output	[23:0]	/*14.10*/ oY1, oY17, oY9,  oY25,
							  oY5, oY21, oY13, oY29,
							  oY3, oY19, oY11, oY27,
							  oY7, oY23, oY15, oY31
 );
 
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
 
 // Stage1
 wire	[8:0]	A0,  A1,  A2,  A3,  A4,  A5,  A6,  A7,
	/* 9.0 */	A8,  A9,  A10, A11, A12, A13, A14, A15,
				A16, A17, A18, A19, A20, A21, A22, A23,
				A24, A25, A26, A27, A28, A29, A30, A31;
 
 // Stage2
 wire	[9:0]	B0,  B1,  B2,  B3,  B4,  B5,  B6,  B7,
	/*10. 0*/	B8,  B9,  B10, B11, B12, B13, B14, B15;
 
 wire	[20:0]	B16_0a, B16_0b, B17_4a, B17_4b, B18_6a, B18_6b, B19_3a, B19_3b,
	/*11.10*/	B20_3a, B20_3b, B21_6a, B21_6b, B22_4a, B22_4b, B23_0a, B23_0b;
 
 wire	[19:0]	B16_7a, B16_7b, B17_1a, B17_1b, B18_3a, B18_3b, B19_5a, B19_5b,
	/*11.9 */	B20_5a, B20_5b, B21_3a, B21_3b, B22_1a, B22_1b, B23_7a, B23_7b;
 
 wire	[20:0]	B16_4a, B16_4b, B17_3a, B17_3b, B18_0a, B18_0b, B19_7a, B19_7b,
	/*11.10*/	B20_7a, B20_7b, B21_0a, B21_0b, B22_3a, B22_3b, B23_4a, B23_4b;
 
 wire	[15:0]	B16_3a, B16_3b, B17_7a, B17_7b, B18_4a, B18_4b, B19_1a, B19_1b,
	/*11.5 */	B20_1a, B20_1b, B21_4a, B21_4b, B22_7a, B22_7b, B23_3a, B23_3b;
 
 wire	[17:0]	B16_2a, B16_2b, B17_6a, B17_6b, B18_5a, B18_5b, B19_0a, B19_0b,
	/*11.7 */	B20_0a, B20_0b, B21_5a, B21_5b, B22_6a, B22_6b, B23_2a, B23_2b;
 
 wire	[15:0]	B16_5a, B16_5b, B17_2a, B17_2b, B18_1a, B18_1b, B19_6a, B19_6b,
	/*11.5 */	B20_6a, B20_6b, B21_1a, B21_1b, B22_2a, B22_2b, B23_5a, B23_5b;
 
 wire	[13:0]	B16_6a, B16_6b, B17_0a, B17_0b, B18_2a, B18_2b, B19_4a, B19_4b,
	/*11.3 */	B20_4a, B20_4b, B21_2a, B21_2b, B22_0a, B22_0b, B23_6a, B23_6b;
 
 wire	[14:0]	B16_1a, B16_1b, B17_5a, B17_5b, B18_7a, B18_7b, B19_2a, B19_2b,
	/*11.4 */	B20_2a, B20_2b, B21_7a, B21_7b, B22_5a, B22_5b, B23_1a, B23_1b;
 
 // Stage3
 wire	[10:0]	/*11.0*/	C0, C1, C2, C3, C4, C5, C6, C7;
 
 wire	[19:0]	/*12.8 */	C8_0a,  C8_0b,  C9_3a,  C9_3b,
							C10_3a, C10_3b, C11_0a, C11_0b;
 wire	[17:0]	/*12.6 */	C8_3a,  C8_3b,  C9_1a,  C9_1b,
							C10_1a, C10_1b, C11_3a, C11_3b;
 wire	[17:0]	/*12.6 */	C8_2a,  C8_2b,  C9_0a,  C9_0b,
							C10_0a, C10_0b, C11_2a, C11_2b;
 wire	[14:0]	/*12.3 */	C8_1a,  C8_1b,  C9_2a,  C9_2b,
							C10_2a, C10_2b, C11_1a, C11_1b;

 wire	[21:0]	/*12.10*/	C12_0a, C12_0b, C12_1a, C12_1b;
 wire	[18:0]	/*12.7 */	C12_2a, C12_2b, C12_3a, C12_3b;
 wire	[21:0]	/*12.10*/	C12_4a, C12_4b, C12_5a, C12_5b;
 wire	[20:0]	/*12.9 */	C12_6a, C12_6b, C12_7a, C12_7b;

 wire	[21:0]	/*12.10*/	C13_0a, C13_0b, C13_1a, C13_1b;
 wire	[20:0]	/*12.9 */	C13_2a, C13_2b, C13_3a, C13_3b;
 wire	[18:0]	/*12.7 */	C13_4a, C13_4b, C13_5a, C13_5b;
 wire	[21:0]	/*12.10*/	C13_6a, C13_6b, C13_7a, C13_7b;

 wire	[18:0]	/*12.7 */	C14_0a, C14_0b, C14_1a, C14_1b;
 wire	[21:0]	/*12.10*/	C14_2a, C14_2b, C14_3a, C14_3b;
 wire	[20:0]	/*12.9 */	C14_4a, C14_4b, C14_5a, C14_5b;
 wire	[21:0]	/*12.10*/	C14_6a, C14_6b, C14_7a, C14_7b;

 wire	[20:0]	/*12.9 */	C15_0a, C15_0b, C15_1a, C15_1b;
 wire	[21:0]	/*12.10*/	C15_2a, C15_2b, C15_3a, C15_3b;
 wire	[21:0]	/*12.10*/	C15_4a, C15_4b, C15_5a, C15_5b;
 wire	[18:0]	/*12.7 */	C15_6a, C15_6b, C15_7a, C15_7b;
 
 // Stage4
 wire	[11:0]	/*12.0*/	D0, D1, D2, D3;
 
 wire	[18:0]	/*13.6 */	D4_0a, D4_0b, D5_1a, D5_1b;
 wire	[16:0]	/*13.4 */	D4_1a, D4_1b, D5_0a, D5_0b;
 
 wire	[20:0]	/*13.8 */	D6_0a, D6_0b, D6_1a, D6_1b;
 wire	[18:0]	/*13.6 */	D6_2a, D6_2b, D6_3a, D6_3b;

 wire	[18:0]	/*13.6 */	D7_0a, D7_0b, D7_1a, D7_1b;
 wire	[20:0]	/*13.8 */	D7_2a, D7_2b, D7_3a, D7_3b;

 wire	[22:0]	/*13.10*/	D8_0a, D8_0b, D8_1a, D8_1b,
							D8_2a, D8_2b, D8_3a, D8_3b,
							D8_4a, D8_4b, D8_5a, D8_5b,
							D8_6a, D8_6b, D8_7a, D8_7b;

 wire	[22:0]	/*13.10*/	D9_0a, D9_0b, D9_1a, D9_1b,
							D9_2a, D9_2b, D9_3a, D9_3b,
							D9_4a, D9_4b, D9_5a, D9_5b,
							D9_6a, D9_6b, D9_7a, D9_7b;
 
 // Stage5
 wire	[12:0]	/*13.0*/	E0, E1;
 
 wire	[18:0]	/*14.5 */	E2, E3;
 
 wire	[19:0]	/*14.6 */	E4, E5, E6, E7;
 
 wire	[21:0]	/*14.8 */	E8,  E9,  E10, E11,
							E12, E13, E14, E15;

 wire	[23:0]	/*14.10 */	E16, E17, E18, E19,
							E20, E21, E22, E23,
							E24, E25, E26, E27,
							E28, E29, E30, E31;
 
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
 
  // Stage1
  ACor_DCT_32p_S1 Stage1 (
	// Input Signals
	.iX0  (iX0),  .iX1  (iX1),  .iX2  (iX2),  .iX3  (iX3),
	.iX4  (iX4),  .iX5  (iX5),  .iX6  (iX6),  .iX7  (iX7),
	.iX8  (iX8),  .iX9  (iX9),  .iX10 (iX10), .iX11 (iX11),
	.iX12 (iX12), .iX13 (iX13), .iX14 (iX14), .iX15 (iX15),
	.iX16 (iX16), .iX17 (iX17), .iX18 (iX18), .iX19 (iX19),
	.iX20 (iX20), .iX21 (iX21), .iX22 (iX22), .iX23 (iX23),
	.iX24 (iX24), .iX25 (iX25), .iX26 (iX26), .iX27 (iX27),
	.iX28 (iX28), .iX29 (iX29), .iX30 (iX30), .iX31 (iX31),
	
	// Output Signals
	.oA0  (A0),   .oA1  (A1),   .oA2  (A2),   .oA3  (A3),
	.oA4  (A4),   .oA5  (A5),   .oA6  (A6),   .oA7  (A7),
	.oA8  (A8),   .oA9  (A9),   .oA10 (A10),  .oA11 (A11),
	.oA12 (A12),  .oA13 (A13),  .oA14 (A14),  .oA15 (A15),
	.oA16 (A16),  .oA17 (A17),  .oA18 (A18),  .oA19 (A19),
	.oA20 (A20),  .oA21 (A21),  .oA22 (A22),  .oA23 (A23),
	.oA24 (A24),  .oA25 (A25),  .oA26 (A26),  .oA27 (A27),
	.oA28 (A28),  .oA29 (A29),  .oA30 (A30),  .oA31 (A31)
  );
  
  // Stage2
  ACor_DCT_32p_S2 Stage2 (
	// Input Signals
	.iA0  (A0),   .iA1  (A1),   .iA2  (A2),   .iA3  (A3),
	.iA4  (A4),   .iA5  (A5),   .iA6  (A6),   .iA7  (A7),
	.iA8  (A8),   .iA9  (A9),   .iA10 (A10),  .iA11 (A11),
	.iA12 (A12),  .iA13 (A13),  .iA14 (A14),  .iA15 (A15),
	.iA16 (A16),  .iA17 (A17),  .iA18 (A18),  .iA19 (A19),
	.iA20 (A20),  .iA21 (A21),  .iA22 (A22),  .iA23 (A23),
	.iA24 (A24),  .iA25 (A25),  .iA26 (A26),  .iA27 (A27),
	.iA28 (A28),  .iA29 (A29),  .iA30 (A30),  .iA31 (A31),
	
	// Output Signals
	.oB0     (B0),     .oB1     (B1),     .oB2     (B2),     .oB3     (B3),
	.oB4     (B4),     .oB5     (B5),     .oB6     (B6),     .oB7     (B7),
	.oB8     (B8),     .oB9     (B9),     .oB10    (B10),    .oB11    (B11),
	.oB12    (B12),    .oB13    (B13),    .oB14    (B14),    .oB15    (B15),
	.oB16_0a (B16_0a), .oB16_0b (B16_0b), .oB16_1a (B16_1a), .oB16_1b (B16_1b),
	.oB16_2a (B16_2a), .oB16_2b (B16_2b), .oB16_3a (B16_3a), .oB16_3b (B16_3b),
	.oB16_4a (B16_4a), .oB16_4b (B16_4b), .oB16_5a (B16_5a), .oB16_5b (B16_5b),
	.oB16_6a (B16_6a), .oB16_6b (B16_6b), .oB16_7a (B16_7a), .oB16_7b (B16_7b),
	.oB17_0a (B17_0a), .oB17_0b (B17_0b), .oB17_1a (B17_1a), .oB17_1b (B17_1b),
	.oB17_2a (B17_2a), .oB17_2b (B17_2b), .oB17_3a (B17_3a), .oB17_3b (B17_3b),
	.oB17_4a (B17_4a), .oB17_4b (B17_4b), .oB17_5a (B17_5a), .oB17_5b (B17_5b),
	.oB17_6a (B17_6a), .oB17_6b (B17_6b), .oB17_7a (B17_7a), .oB17_7b (B17_7b),
	.oB18_0a (B18_0a), .oB18_0b (B18_0b), .oB18_1a (B18_1a), .oB18_1b (B18_1b),
	.oB18_2a (B18_2a), .oB18_2b (B18_2b), .oB18_3a (B18_3a), .oB18_3b (B18_3b),
	.oB18_4a (B18_4a), .oB18_4b (B18_4b), .oB18_5a (B18_5a), .oB18_5b (B18_5b),
	.oB18_6a (B18_6a), .oB18_6b (B18_6b), .oB18_7a (B18_7a), .oB18_7b (B18_7b),
	.oB19_0a (B19_0a), .oB19_0b (B19_0b), .oB19_1a (B19_1a), .oB19_1b (B19_1b),
	.oB19_2a (B19_2a), .oB19_2b (B19_2b), .oB19_3a (B19_3a), .oB19_3b (B19_3b),
	.oB19_4a (B19_4a), .oB19_4b (B19_4b), .oB19_5a (B19_5a), .oB19_5b (B19_5b),
	.oB19_6a (B19_6a), .oB19_6b (B19_6b), .oB19_7a (B19_7a), .oB19_7b (B19_7b),
	.oB20_0a (B20_0a), .oB20_0b (B20_0b), .oB20_1a (B20_1a), .oB20_1b (B20_1b),
	.oB20_2a (B20_2a), .oB20_2b (B20_2b), .oB20_3a (B20_3a), .oB20_3b (B20_3b),
	.oB20_4a (B20_4a), .oB20_4b (B20_4b), .oB20_5a (B20_5a), .oB20_5b (B20_5b),
	.oB20_6a (B20_6a), .oB20_6b (B20_6b), .oB20_7a (B20_7a), .oB20_7b (B20_7b),
	.oB21_0a (B21_0a), .oB21_0b (B21_0b), .oB21_1a (B21_1a), .oB21_1b (B21_1b),
	.oB21_2a (B21_2a), .oB21_2b (B21_2b), .oB21_3a (B21_3a), .oB21_3b (B21_3b),
	.oB21_4a (B21_4a), .oB21_4b (B21_4b), .oB21_5a (B21_5a), .oB21_5b (B21_5b),
	.oB21_6a (B21_6a), .oB21_6b (B21_6b), .oB21_7a (B21_7a), .oB21_7b (B21_7b),
	.oB22_0a (B22_0a), .oB22_0b (B22_0b), .oB22_1a (B22_1a), .oB22_1b (B22_1b),
	.oB22_2a (B22_2a), .oB22_2b (B22_2b), .oB22_3a (B22_3a), .oB22_3b (B22_3b),
	.oB22_4a (B22_4a), .oB22_4b (B22_4b), .oB22_5a (B22_5a), .oB22_5b (B22_5b),
	.oB22_6a (B22_6a), .oB22_6b (B22_6b), .oB22_7a (B22_7a), .oB22_7b (B22_7b),
	.oB23_0a (B23_0a), .oB23_0b (B23_0b), .oB23_1a (B23_1a), .oB23_1b (B23_1b),
	.oB23_2a (B23_2a), .oB23_2b (B23_2b), .oB23_3a (B23_3a), .oB23_3b (B23_3b),
	.oB23_4a (B23_4a), .oB23_4b (B23_4b), .oB23_5a (B23_5a), .oB23_5b (B23_5b),
	.oB23_6a (B23_6a), .oB23_6b (B23_6b), .oB23_7a (B23_7a), .oB23_7b (B23_7b)
  );
  
  // Stage3
  ACor_DCT_32p_S3 Stage3 (
	// Input Signals
	.iB0     (B0),     .iB1     (B1),     .iB2     (B2),     .iB3     (B3),
	.iB4     (B4),     .iB5     (B5),     .iB6     (B6),     .iB7     (B7),
	.iB8     (B8),     .iB9     (B9),     .iB10    (B10),    .iB11    (B11),
	.iB12    (B12),    .iB13    (B13),    .iB14    (B14),    .iB15    (B15),
	.iB16_0a (B16_0a), .iB16_0b (B16_0b), .iB16_1a (B16_1a), .iB16_1b (B16_1b),
	.iB16_2a (B16_2a), .iB16_2b (B16_2b), .iB16_3a (B16_3a), .iB16_3b (B16_3b),
	.iB16_4a (B16_4a), .iB16_4b (B16_4b), .iB16_5a (B16_5a), .iB16_5b (B16_5b),
	.iB16_6a (B16_6a), .iB16_6b (B16_6b), .iB16_7a (B16_7a), .iB16_7b (B16_7b),
	.iB17_0a (B17_0a), .iB17_0b (B17_0b), .iB17_1a (B17_1a), .iB17_1b (B17_1b),
	.iB17_2a (B17_2a), .iB17_2b (B17_2b), .iB17_3a (B17_3a), .iB17_3b (B17_3b),
	.iB17_4a (B17_4a), .iB17_4b (B17_4b), .iB17_5a (B17_5a), .iB17_5b (B17_5b),
	.iB17_6a (B17_6a), .iB17_6b (B17_6b), .iB17_7a (B17_7a), .iB17_7b (B17_7b),
	.iB18_0a (B18_0a), .iB18_0b (B18_0b), .iB18_1a (B18_1a), .iB18_1b (B18_1b),
	.iB18_2a (B18_2a), .iB18_2b (B18_2b), .iB18_3a (B18_3a), .iB18_3b (B18_3b),
	.iB18_4a (B18_4a), .iB18_4b (B18_4b), .iB18_5a (B18_5a), .iB18_5b (B18_5b),
	.iB18_6a (B18_6a), .iB18_6b (B18_6b), .iB18_7a (B18_7a), .iB18_7b (B18_7b),
	.iB19_0a (B19_0a), .iB19_0b (B19_0b), .iB19_1a (B19_1a), .iB19_1b (B19_1b),
	.iB19_2a (B19_2a), .iB19_2b (B19_2b), .iB19_3a (B19_3a), .iB19_3b (B19_3b),
	.iB19_4a (B19_4a), .iB19_4b (B19_4b), .iB19_5a (B19_5a), .iB19_5b (B19_5b),
	.iB19_6a (B19_6a), .iB19_6b (B19_6b), .iB19_7a (B19_7a), .iB19_7b (B19_7b),
	.iB20_0a (B20_0a), .iB20_0b (B20_0b), .iB20_1a (B20_1a), .iB20_1b (B20_1b),
	.iB20_2a (B20_2a), .iB20_2b (B20_2b), .iB20_3a (B20_3a), .iB20_3b (B20_3b),
	.iB20_4a (B20_4a), .iB20_4b (B20_4b), .iB20_5a (B20_5a), .iB20_5b (B20_5b),
	.iB20_6a (B20_6a), .iB20_6b (B20_6b), .iB20_7a (B20_7a), .iB20_7b (B20_7b),
	.iB21_0a (B21_0a), .iB21_0b (B21_0b), .iB21_1a (B21_1a), .iB21_1b (B21_1b),
	.iB21_2a (B21_2a), .iB21_2b (B21_2b), .iB21_3a (B21_3a), .iB21_3b (B21_3b),
	.iB21_4a (B21_4a), .iB21_4b (B21_4b), .iB21_5a (B21_5a), .iB21_5b (B21_5b),
	.iB21_6a (B21_6a), .iB21_6b (B21_6b), .iB21_7a (B21_7a), .iB21_7b (B21_7b),
	.iB22_0a (B22_0a), .iB22_0b (B22_0b), .iB22_1a (B22_1a), .iB22_1b (B22_1b),
	.iB22_2a (B22_2a), .iB22_2b (B22_2b), .iB22_3a (B22_3a), .iB22_3b (B22_3b),
	.iB22_4a (B22_4a), .iB22_4b (B22_4b), .iB22_5a (B22_5a), .iB22_5b (B22_5b),
	.iB22_6a (B22_6a), .iB22_6b (B22_6b), .iB22_7a (B22_7a), .iB22_7b (B22_7b),
	.iB23_0a (B23_0a), .iB23_0b (B23_0b), .iB23_1a (B23_1a), .iB23_1b (B23_1b),
	.iB23_2a (B23_2a), .iB23_2b (B23_2b), .iB23_3a (B23_3a), .iB23_3b (B23_3b),
	.iB23_4a (B23_4a), .iB23_4b (B23_4b), .iB23_5a (B23_5a), .iB23_5b (B23_5b),
	.iB23_6a (B23_6a), .iB23_6b (B23_6b), .iB23_7a (B23_7a), .iB23_7b (B23_7b),
	
	// Output Signals
	.oC0     (C0),     .oC1     (C1),     .oC2     (C2),     .oC3     (C3),
	.oC4     (C4),     .oC5     (C5),     .oC6     (C6),     .oC7     (C7),
	.oC8_0a  (C8_0a),  .oC8_0b  (C8_0b),  .oC8_1a  (C8_1a),  .oC8_1b  (C8_1b),
	.oC8_2a  (C8_2a),  .oC8_2b  (C8_2b),  .oC8_3a  (C8_3a),  .oC8_3b  (C8_3b),
	.oC9_0a  (C9_0a),  .oC9_0b  (C9_0b),  .oC9_1a  (C9_1a),  .oC9_1b  (C9_1b),
	.oC9_2a  (C9_2a),  .oC9_2b  (C9_2b),  .oC9_3a  (C9_3a),  .oC9_3b  (C9_3b),
	.oC10_0a (C10_0a), .oC10_0b (C10_0b), .oC10_1a (C10_1a), .oC10_1b (C10_1b),
	.oC10_2a (C10_2a), .oC10_2b (C10_2b), .oC10_3a (C10_3a), .oC10_3b (C10_3b),
	.oC11_0a (C11_0a), .oC11_0b (C11_0b), .oC11_1a (C11_1a), .oC11_1b (C11_1b),
	.oC11_2a (C11_2a), .oC11_2b (C11_2b), .oC11_3a (C11_3a), .oC11_3b (C11_3b),
	.oC12_0a (C12_0a), .oC12_0b (C12_0b), .oC12_1a (C12_1a), .oC12_1b (C12_1b),
	.oC12_2a (C12_2a), .oC12_2b (C12_2b), .oC12_3a (C12_3a), .oC12_3b (C12_3b),
	.oC12_4a (C12_4a), .oC12_4b (C12_4b), .oC12_5a (C12_5a), .oC12_5b (C12_5b),
	.oC12_6a (C12_6a), .oC12_6b (C12_6b), .oC12_7a (C12_7a), .oC12_7b (C12_7b),
	.oC13_0a (C13_0a), .oC13_0b (C13_0b), .oC13_1a (C13_1a), .oC13_1b (C13_1b),
	.oC13_2a (C13_2a), .oC13_2b (C13_2b), .oC13_3a (C13_3a), .oC13_3b (C13_3b),
	.oC13_4a (C13_4a), .oC13_4b (C13_4b), .oC13_5a (C13_5a), .oC13_5b (C13_5b),
	.oC13_6a (C13_6a), .oC13_6b (C13_6b), .oC13_7a (C13_7a), .oC13_7b (C13_7b),
	.oC14_0a (C14_0a), .oC14_0b (C14_0b), .oC14_1a (C14_1a), .oC14_1b (C14_1b),
	.oC14_2a (C14_2a), .oC14_2b (C14_2b), .oC14_3a (C14_3a), .oC14_3b (C14_3b),
	.oC14_4a (C14_4a), .oC14_4b (C14_4b), .oC14_5a (C14_5a), .oC14_5b (C14_5b),
	.oC14_6a (C14_6a), .oC14_6b (C14_6b), .oC14_7a (C14_7a), .oC14_7b (C14_7b),
	.oC15_0a (C15_0a), .oC15_0b (C15_0b), .oC15_1a (C15_1a), .oC15_1b (C15_1b),
	.oC15_2a (C15_2a), .oC15_2b (C15_2b), .oC15_3a (C15_3a), .oC15_3b (C15_3b),
	.oC15_4a (C15_4a), .oC15_4b (C15_4b), .oC15_5a (C15_5a), .oC15_5b (C15_5b),
	.oC15_6a (C15_6a), .oC15_6b (C15_6b), .oC15_7a (C15_7a), .oC15_7b (C15_7b)
  );
  
  // Stage4
  ACor_DCT_32p_S4 Stage4 (
	// Input Signals
	.iC0     (C0),     .iC1     (C1),     .iC2     (C2),     .iC3     (C3),
	.iC4     (C4),     .iC5     (C5),     .iC6     (C6),     .iC7     (C7),
	.iC8_0a  (C8_0a),  .iC8_0b  (C8_0b),  .iC8_1a  (C8_1a),  .iC8_1b  (C8_1b),
	.iC8_2a  (C8_2a),  .iC8_2b  (C8_2b),  .iC8_3a  (C8_3a),  .iC8_3b  (C8_3b),
	.iC9_0a  (C9_0a),  .iC9_0b  (C9_0b),  .iC9_1a  (C9_1a),  .iC9_1b  (C9_1b),
	.iC9_2a  (C9_2a),  .iC9_2b  (C9_2b),  .iC9_3a  (C9_3a),  .iC9_3b  (C9_3b),
	.iC10_0a (C10_0a), .iC10_0b (C10_0b), .iC10_1a (C10_1a), .iC10_1b (C10_1b),
	.iC10_2a (C10_2a), .iC10_2b (C10_2b), .iC10_3a (C10_3a), .iC10_3b (C10_3b),
	.iC11_0a (C11_0a), .iC11_0b (C11_0b), .iC11_1a (C11_1a), .iC11_1b (C11_1b),
	.iC11_2a (C11_2a), .iC11_2b (C11_2b), .iC11_3a (C11_3a), .iC11_3b (C11_3b),
	.iC12_0a (C12_0a), .iC12_0b (C12_0b), .iC12_1a (C12_1a), .iC12_1b (C12_1b),
	.iC12_2a (C12_2a), .iC12_2b (C12_2b), .iC12_3a (C12_3a), .iC12_3b (C12_3b),
	.iC12_4a (C12_4a), .iC12_4b (C12_4b), .iC12_5a (C12_5a), .iC12_5b (C12_5b),
	.iC12_6a (C12_6a), .iC12_6b (C12_6b), .iC12_7a (C12_7a), .iC12_7b (C12_7b),
	.iC13_0a (C13_0a), .iC13_0b (C13_0b), .iC13_1a (C13_1a), .iC13_1b (C13_1b),
	.iC13_2a (C13_2a), .iC13_2b (C13_2b), .iC13_3a (C13_3a), .iC13_3b (C13_3b),
	.iC13_4a (C13_4a), .iC13_4b (C13_4b), .iC13_5a (C13_5a), .iC13_5b (C13_5b),
	.iC13_6a (C13_6a), .iC13_6b (C13_6b), .iC13_7a (C13_7a), .iC13_7b (C13_7b),
	.iC14_0a (C14_0a), .iC14_0b (C14_0b), .iC14_1a (C14_1a), .iC14_1b (C14_1b),
	.iC14_2a (C14_2a), .iC14_2b (C14_2b), .iC14_3a (C14_3a), .iC14_3b (C14_3b),
	.iC14_4a (C14_4a), .iC14_4b (C14_4b), .iC14_5a (C14_5a), .iC14_5b (C14_5b),
	.iC14_6a (C14_6a), .iC14_6b (C14_6b), .iC14_7a (C14_7a), .iC14_7b (C14_7b),
	.iC15_0a (C15_0a), .iC15_0b (C15_0b), .iC15_1a (C15_1a), .iC15_1b (C15_1b),
	.iC15_2a (C15_2a), .iC15_2b (C15_2b), .iC15_3a (C15_3a), .iC15_3b (C15_3b),
	.iC15_4a (C15_4a), .iC15_4b (C15_4b), .iC15_5a (C15_5a), .iC15_5b (C15_5b),
	.iC15_6a (C15_6a), .iC15_6b (C15_6b), .iC15_7a (C15_7a), .iC15_7b (C15_7b),
	
	// Output Signals
	.oD0    (D0),    .oD1    (D1),    .oD2    (D2),    .oD3    (D3),
	.oD4_0a (D4_0a), .oD4_0b (D4_0b), .oD4_1a (D4_1a), .oD4_1b (D4_1b),
	.oD5_0a (D5_0a), .oD5_0b (D5_0b), .oD5_1a (D5_1a), .oD5_1b (D5_1b),
	.oD6_0a (D6_0a), .oD6_0b (D6_0b), .oD6_1a (D6_1a), .oD6_1b (D6_1b),
	.oD6_2a (D6_2a), .oD6_2b (D6_2b), .oD6_3a (D6_3a), .oD6_3b (D6_3b),
	.oD7_0a (D7_0a), .oD7_0b (D7_0b), .oD7_1a (D7_1a), .oD7_1b (D7_1b),
	.oD7_2a (D7_2a), .oD7_2b (D7_2b), .oD7_3a (D7_3a), .oD7_3b (D7_3b),
	.oD8_0a (D8_0a), .oD8_0b (D8_0b), .oD8_1a (D8_1a), .oD8_1b (D8_1b),
	.oD8_2a (D8_2a), .oD8_2b (D8_2b), .oD8_3a (D8_3a), .oD8_3b (D8_3b),
	.oD8_4a (D8_4a), .oD8_4b (D8_4b), .oD8_5a (D8_5a), .oD8_5b (D8_5b),
	.oD8_6a (D8_6a), .oD8_6b (D8_6b), .oD8_7a (D8_7a), .oD8_7b (D8_7b),
	.oD9_0a (D9_0a), .oD9_0b (D9_0b), .oD9_1a (D9_1a), .oD9_1b (D9_1b),
	.oD9_2a (D9_2a), .oD9_2b (D9_2b), .oD9_3a (D9_3a), .oD9_3b (D9_3b),
	.oD9_4a (D9_4a), .oD9_4b (D9_4b), .oD9_5a (D9_5a), .oD9_5b (D9_5b),
	.oD9_6a (D9_6a), .oD9_6b (D9_6b), .oD9_7a (D9_7a), .oD9_7b (D9_7b)
  );
  
  // Stage5
  ACor_DCT_32p_S5 Stage5 (
	// Input Signals
	.iD0    (D0),    .iD1    (D1),    .iD2    (D2),    .iD3    (D3),
	.iD4_0a (D4_0a), .iD4_0b (D4_0b), .iD4_1a (D4_1a), .iD4_1b (D4_1b),
	.iD5_0a (D5_0a), .iD5_0b (D5_0b), .iD5_1a (D5_1a), .iD5_1b (D5_1b),
	.iD6_0a (D6_0a), .iD6_0b (D6_0b), .iD6_1a (D6_1a), .iD6_1b (D6_1b),
	.iD6_2a (D6_2a), .iD6_2b (D6_2b), .iD6_3a (D6_3a), .iD6_3b (D6_3b),
	.iD7_0a (D7_0a), .iD7_0b (D7_0b), .iD7_1a (D7_1a), .iD7_1b (D7_1b),
	.iD7_2a (D7_2a), .iD7_2b (D7_2b), .iD7_3a (D7_3a), .iD7_3b (D7_3b),
	.iD8_0a (D8_0a), .iD8_0b (D8_0b), .iD8_1a (D8_1a), .iD8_1b (D8_1b),
	.iD8_2a (D8_2a), .iD8_2b (D8_2b), .iD8_3a (D8_3a), .iD8_3b (D8_3b),
	.iD8_4a (D8_4a), .iD8_4b (D8_4b), .iD8_5a (D8_5a), .iD8_5b (D8_5b),
	.iD8_6a (D8_6a), .iD8_6b (D8_6b), .iD8_7a (D8_7a), .iD8_7b (D8_7b),
	.iD9_0a (D9_0a), .iD9_0b (D9_0b), .iD9_1a (D9_1a), .iD9_1b (D9_1b),
	.iD9_2a (D9_2a), .iD9_2b (D9_2b), .iD9_3a (D9_3a), .iD9_3b (D9_3b),
	.iD9_4a (D9_4a), .iD9_4b (D9_4b), .iD9_5a (D9_5a), .iD9_5b (D9_5b),
	.iD9_6a (D9_6a), .iD9_6b (D9_6b), .iD9_7a (D9_7a), .iD9_7b (D9_7b),
	
	// Output Signals
	.oE0  (E0),   .oE1  (E1),   .oE2  (E2),   .oE3  (E3),
	.oE4  (E4),   .oE5  (E5),   .oE6  (E6),   .oE7  (E7),
	.oE8  (E8),   .oE9  (E9),   .oE10 (E10),  .oE11 (E11),
	.oE12 (E12),  .oE13 (E13),  .oE14 (E14),  .oE15 (E15),
	.oE16 (E16),  .oE17 (E17),  .oE18 (E18),  .oE19 (E19),
	.oE20 (E20),  .oE21 (E21),  .oE22 (E22),  .oE23 (E23),
	.oE24 (E24),  .oE25 (E25),  .oE26 (E26),  .oE27 (E27),
	.oE28 (E28),  .oE29 (E29),  .oE30 (E30),  .oE31 (E31)
  );
  
 /*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

 //	13.0 [12:0]
 assign oY0	 = E0;	// *sqrt(2)/8
 assign oY16 = E1;	// *sqrt(2)/8
 
 //	14.5 [18:0]
 assign oY8	 = E2;	// *1/4
 assign oY24 = E3;	// *1/4
 
 //	14.6 [19:0]
 assign oY4  = E4;	// *1/4
 assign oY20 = E6;	// *1/4
 assign oY12 = E7;	// *-1/4
 assign oY28 = E5;	// *1/4
 
 //	14.8 [21:0]
 assign oY2	 = E8;	// *1/4
 assign oY18 = E10;	// *1/4
 assign oY10 = E12;	// *1/4
 assign oY26 = E14;	// *1/4
 assign oY6	 = E15;	// *1/4
 assign oY22 = E13;	// *1/4
 assign oY14 = E11;	// *1/4
 assign oY30 = E9;	// *1/4
 
 //	14.10 [23:0]
 assign oY1	 = E16;	// *1/4
 assign oY17 = E18;	// *1/4
 assign oY9	 = E20;	// *1/4
 assign oY25 = E22;	// *1/4
 assign oY5	 = E24;	// *1/4
 assign oY21 = E26;	// *1/4
 assign oY13 = E28;	// *1/4
 assign oY29 = E30;	// *1/4
 assign oY3	 = E31;	// *1/4
 assign oY19 = E29;	// *1/4
 assign oY11 = E27;	// *1/4
 assign oY27 = E25;	// *1/4
 assign oY7	 = E23;	// *1/4
 assign oY23 = E21;	// *1/4
 assign oY15 = E19;	// *1/4
 assign oY31 = E17;	// *1/4
 
 endmodule
 
 module ACor_DCT_32p_S1 (
	// Input Signals
	input	[7:0]	iX0,  iX1,  iX2,  iX3,  iX4,  iX5,  iX6,  iX7,
		/* 8.0 */	iX8,  iX9,  iX10, iX11, iX12, iX13, iX14, iX15,
					iX16, iX17, iX18, iX19,	iX20, iX21, iX22, iX23,
					iX24, iX25, iX26, iX27,	iX28, iX29, iX30, iX31,
	
	// Output Signals
	output	[8:0]	oA0,  oA1,  oA2,  oA3,  oA4,  oA5,  oA6,  oA7,
		/* 9.0 */	oA8,  oA9,  oA10, oA11,	oA12, oA13, oA14, oA15,
					oA16, oA17, oA18, oA19,	oA20, oA21, oA22, oA23,
					oA24, oA25, oA26, oA27,	oA28, oA29, oA30, oA31
);

 // assign oA0  = { iX0[7], iX0} + {iX31[7],iX31};
 wire A0_c0;
 FA_Cir_Cin0 A0m0 (.iA (iX0[0]), .iB (iX31[0]), .oS (oA0[0]), .oC (A0_c0));
 Ripple_Add_8bit A0m1 (
	.iA (iX0[7:1]), .iB (iX31[7:1]),
	.iC (A0_c0),	.oS (oA0[8:1]));
 
 // assign oA1  = { iX1[7], iX1} + {iX30[7],iX30};
 wire A1_c0;
 FA_Cir_Cin0 A1m0 (.iA (iX1[0]), .iB (iX30[0]), .oS (oA1[0]), .oC (A1_c0));
 Ripple_Add_8bit A1m1 (
	.iA (iX1[7:1]),	.iB (iX30[7:1]),
	.iC (A1_c0),	.oS (oA1[8:1]));
 
 // assign oA2  = { iX2[7], iX2} + {iX29[7],iX29};
 wire A2_c0;
 FA_Cir_Cin0 A2m0 (.iA (iX2[0]), .iB (iX29[0]), .oS (oA2[0]), .oC (A2_c0));
 Ripple_Add_8bit A2m1 (
	.iA (iX2[7:1]),	.iB (iX29[7:1]),
	.iC (A2_c0),	.oS (oA2[8:1]));
 
 // assign oA3  = { iX3[7], iX3} + {iX28[7],iX28};
 wire A3_c0;
 FA_Cir_Cin0 A3m0 (.iA (iX3[0]), .iB (iX28[0]), .oS (oA3[0]), .oC (A3_c0));
 Ripple_Add_8bit A3m1 (
	.iA (iX3[7:1]),	.iB (iX28[7:1]),
	.iC (A3_c0),	.oS (oA3[8:1]));
 
 // assign oA4  = { iX4[7], iX4} + {iX27[7],iX27};
 wire A4_c0;
 FA_Cir_Cin0 A4m0 (.iA (iX4[0]), .iB (iX27[0]), .oS (oA4[0]), .oC (A4_c0));
 Ripple_Add_8bit A4m1 (
	.iA (iX4[7:1]),	.iB (iX27[7:1]),
	.iC (A4_c0),	.oS (oA4[8:1]));
 
 // assign oA5  = { iX5[7], iX5} + {iX26[7],iX26};
 wire A5_c0;
 FA_Cir_Cin0 A5m0 (.iA (iX5[0]), .iB (iX26[0]), .oS (oA5[0]), .oC (A5_c0));
 Ripple_Add_8bit A5m1 (
	.iA (iX5[7:1]),	.iB (iX26[7:1]),
	.iC (A5_c0),	.oS (oA5[8:1]));
 
 // assign oA6  = { iX6[7], iX6} + {iX25[7],iX25};
 wire A6_c0;
 FA_Cir_Cin0 A6m0 (.iA (iX6[0]), .iB (iX25[0]), .oS (oA6[0]), .oC (A6_c0));
 Ripple_Add_8bit A6m1 (
	.iA (iX6[7:1]),	.iB (iX25[7:1]),
	.iC (A6_c0),	.oS (oA6[8:1]));
 
 // assign oA7  = { iX7[7], iX7} + {iX24[7],iX24};
 wire A7_c0;
 FA_Cir_Cin0 A7m0 (.iA (iX7[0]), .iB (iX24[0]), .oS (oA7[0]), .oC (A7_c0));
 Ripple_Add_8bit A7m1 (
	.iA (iX7[7:1]),	.iB (iX24[7:1]),
	.iC (A7_c0),	.oS (oA7[8:1]));
 
 // assign oA8  = { iX8[7], iX8} + {iX23[7],iX23};
 wire A8_c0;
 FA_Cir_Cin0 A8m0 (.iA (iX8[0]), .iB (iX23[0]), .oS (oA8[0]), .oC (A8_c0));
 Ripple_Add_8bit A8m1 (
	.iA (iX8[7:1]),	.iB (iX23[7:1]),
	.iC (A8_c0),	.oS (oA8[8:1]));
 
 // assign oA9  = { iX9[7], iX9} + {iX22[7],iX22};
 wire A9_c0;
 FA_Cir_Cin0 A9m0 (.iA (iX9[0]), .iB (iX22[0]), .oS (oA9[0]), .oC (A9_c0));
 Ripple_Add_8bit A9m1 (
	.iA (iX9[7:1]),	.iB (iX22[7:1]),
	.iC (A9_c0),	.oS (oA9[8:1]));
 
 // assign oA10 = {iX10[7],iX10} + {iX21[7],iX21};
 wire A10_c0;
 FA_Cir_Cin0 A10m0 (.iA (iX10[0]), .iB (iX21[0]), .oS (oA10[0]), .oC (A10_c0));
 Ripple_Add_8bit A10m1 (
	.iA (iX10[7:1]),.iB (iX21[7:1]),
	.iC (A10_c0),	.oS (oA10[8:1]));
 
 // assign oA11 = {iX11[7],iX11} + {iX20[7],iX20};
 wire A11_c0;
 FA_Cir_Cin0 A11m0 (.iA (iX11[0]), .iB (iX20[0]), .oS (oA11[0]), .oC (A11_c0));
 Ripple_Add_8bit A11m1 (
	.iA (iX11[7:1]),.iB (iX20[7:1]),
	.iC (A11_c0),	.oS (oA11[8:1]));
 
 // assign oA12 = {iX12[7],iX12} + {iX19[7],iX19};
 wire A12_c0;
 FA_Cir_Cin0 A12m0 (.iA (iX12[0]), .iB (iX19[0]), .oS (oA12[0]), .oC (A12_c0));
 Ripple_Add_8bit A12m1 (
	.iA (iX12[7:1]),.iB (iX19[7:1]),
	.iC (A12_c0),	.oS (oA12[8:1]));
 
 // assign oA13 = {iX13[7],iX13} + {iX18[7],iX18};
 wire A13_c0;
 FA_Cir_Cin0 A13m0 (.iA (iX13[0]), .iB (iX18[0]), .oS (oA13[0]), .oC (A13_c0));
 Ripple_Add_8bit A13m1 (
	.iA (iX13[7:1]),.iB (iX18[7:1]),
	.iC (A13_c0),	.oS (oA13[8:1]));
 
 // assign oA14 = {iX14[7],iX14} + {iX17[7],iX17};
 wire A14_c0;
 FA_Cir_Cin0 A14m0 (.iA (iX14[0]), .iB (iX17[0]), .oS (oA14[0]), .oC (A14_c0));
 Ripple_Add_8bit A14m1 (
	.iA (iX14[7:1]),.iB (iX17[7:1]),
	.iC (A14_c0),	.oS (oA14[8:1]));
 
 // assign oA15 = {iX15[7],iX15} + {iX16[7],iX16};
 wire A15_c0;
 FA_Cir_Cin0 A15m0 (.iA (iX15[0]), .iB (iX16[0]), .oS (oA15[0]), .oC (A15_c0));
 Ripple_Add_8bit A15m1 (
	.iA (iX15[7:1]),.iB (iX16[7:1]),
	.iC (A15_c0),	.oS (oA15[8:1]));
 
 // assign oA16 = {iX15[7],iX15} - {iX16[7],iX16};
 wire A16_c0;
 FA_Cir_Cin1 A16m0 (.iA (iX15[0]), .iB (~iX16[0]), .oS (oA16[0]), .oC (A16_c0));
 Ripple_Add_8bit A16m1 (
	.iA (iX15[7:1]),.iB (~iX16[7:1]),
	.iC (A16_c0),	.oS (oA16[8:1]));
 
 // assign oA17 = {iX14[7],iX14} - {iX17[7],iX17};
 wire A17_c0;
 FA_Cir_Cin1 A17m0 (.iA (iX14[0]), .iB (~iX17[0]), .oS (oA17[0]), .oC (A17_c0));
 Ripple_Add_8bit A17m1 (
	.iA (iX14[7:1]),.iB (~iX17[7:1]),
	.iC (A17_c0),	.oS (oA17[8:1]));
 
 // assign oA18 = {iX13[7],iX13} - {iX18[7],iX18};
 wire A18_c0;
 FA_Cir_Cin1 A18m0 (.iA (iX13[0]), .iB (~iX18[0]), .oS (oA18[0]), .oC (A18_c0));
 Ripple_Add_8bit A18m1 (
	.iA (iX13[7:1]),.iB (~iX18[7:1]),
	.iC (A18_c0),	.oS (oA18[8:1]));
 
 // assign oA19 = {iX12[7],iX12} - {iX19[7],iX19};
 wire A19_c0;
 FA_Cir_Cin1 A19m0 (.iA (iX12[0]), .iB (~iX19[0]), .oS (oA19[0]), .oC (A19_c0));
 Ripple_Add_8bit A19m1 (
	.iA (iX12[7:1]),.iB (~iX19[7:1]),
	.iC (A19_c0),	.oS (oA19[8:1]));
 
 // assign oA20 = {iX11[7],iX11} - {iX20[7],iX20};
 wire A20_c0;
 FA_Cir_Cin1 A20m0 (.iA (iX11[0]), .iB (~iX20[0]), .oS (oA20[0]), .oC (A20_c0));
 Ripple_Add_8bit A20m1 (
	.iA (iX11[7:1]),.iB (~iX20[7:1]),
	.iC (A20_c0),	.oS (oA20[8:1]));
 
 // assign oA21 = {iX10[7],iX10} - {iX21[7],iX21};
 wire A21_c0;
 FA_Cir_Cin1 A21m0 (.iA (iX10[0]), .iB (~iX21[0]), .oS (oA21[0]), .oC (A21_c0));
 Ripple_Add_8bit A21m1 (
	.iA (iX10[7:1]),.iB (~iX21[7:1]),
	.iC (A21_c0),	.oS (oA21[8:1]));
 
 // assign oA22 = { iX9[7], iX9} - {iX22[7],iX22};
 wire A22_c0;
 FA_Cir_Cin1 A22m0 (.iA (iX9[0]), .iB (~iX22[0]), .oS (oA22[0]), .oC (A22_c0));
 Ripple_Add_8bit A22m1 (
	.iA (iX9[7:1]),	.iB (~iX22[7:1]),
	.iC (A22_c0),	.oS (oA22[8:1]));
 
 // assign oA23 = { iX8[7], iX8} - {iX23[7],iX23};
 wire A23_c0;
 FA_Cir_Cin1 A23m0 (.iA (iX8[0]), .iB (~iX23[0]), .oS (oA23[0]), .oC (A23_c0));
 Ripple_Add_8bit A23m1 (
	.iA (iX8[7:1]),	.iB (~iX23[7:1]),
	.iC (A23_c0),	.oS (oA23[8:1]));
 
 // assign oA24 = { iX7[7], iX7} - {iX24[7],iX24};
 wire A24_c0;
 FA_Cir_Cin1 A24m0 (.iA (iX7[0]), .iB (~iX24[0]), .oS (oA24[0]), .oC (A24_c0));
 Ripple_Add_8bit A24m1 (
	.iA (iX7[7:1]),	.iB (~iX24[7:1]),
	.iC (A24_c0),	.oS (oA24[8:1]));
 
 // assign oA25 = { iX6[7], iX6} - {iX25[7],iX25};
 wire A25_c0;
 FA_Cir_Cin1 A25m0 (.iA (iX6[0]), .iB (~iX25[0]), .oS (oA25[0]), .oC (A25_c0));
 Ripple_Add_8bit A25m1 (
	.iA (iX6[7:1]),	.iB (~iX25[7:1]),
	.iC (A25_c0),	.oS (oA25[8:1]));
 
 // assign oA26 = { iX5[7], iX5} - {iX26[7],iX26};
 wire A26_c0;
 FA_Cir_Cin1 A26m0 (.iA (iX5[0]), .iB (~iX26[0]), .oS (oA26[0]), .oC (A26_c0));
 Ripple_Add_8bit A26m1 (
	.iA (iX5[7:1]),	.iB (~iX26[7:1]),
	.iC (A26_c0),	.oS (oA26[8:1]));
 
 // assign oA27 = { iX4[7], iX4} - {iX27[7],iX27};
 wire A27_c0;
 FA_Cir_Cin1 A27m0 (.iA (iX4[0]), .iB (~iX27[0]), .oS (oA27[0]), .oC (A27_c0));
 Ripple_Add_8bit A27m1 (
	.iA (iX4[7:1]),	.iB (~iX27[7:1]),
	.iC (A27_c0),	.oS (oA27[8:1]));
 
 // assign oA28 = { iX3[7], iX3} - {iX28[7],iX28};
 wire A28_c0;
 FA_Cir_Cin1 A28m0 (.iA (iX3[0]), .iB (~iX28[0]), .oS (oA28[0]), .oC (A28_c0));
 Ripple_Add_8bit A28m1 (
	.iA (iX3[7:1]),	.iB (~iX28[7:1]),
	.iC (A28_c0),	.oS (oA28[8:1]));
 
 // assign oA29 = { iX2[7], iX2} - {iX29[7],iX29};
 wire A29_c0;
 FA_Cir_Cin1 A29m0 (.iA (iX2[0]), .iB (~iX29[0]), .oS (oA29[0]), .oC (A29_c0));
 Ripple_Add_8bit A29m1 (
	.iA (iX2[7:1]),	.iB (~iX29[7:1]),
	.iC (A29_c0),	.oS (oA29[8:1]));
 
 // assign oA30 = { iX1[7], iX1} - {iX30[7],iX30};
 wire A30_c0;
 FA_Cir_Cin1 A30m0 (.iA (iX1[0]), .iB (~iX30[0]), .oS (oA30[0]), .oC (A30_c0));
 Ripple_Add_8bit A30m1 (
	.iA (iX1[7:1]),	.iB (~iX30[7:1]),
	.iC (A30_c0),	.oS (oA30[8:1]));
 
 // assign oA31 = { iX0[7], iX0} - {iX31[7],iX31};
 wire A31_c0;
 FA_Cir_Cin1 A31m0 (.iA (iX0[0]), .iB (~iX31[0]), .oS (oA31[0]), .oC (A31_c0));
 Ripple_Add_8bit A31m1 (
	.iA (iX0[7:1]),	.iB (~iX31[7:1]),
	.iC (A31_c0),	.oS (oA31[8:1]));

endmodule

module ACor_DCT_32p_S2 (
	// Input Signals
	input	[8:0]	iA0,  iA1,  iA2,  iA3,	iA4,  iA5,  iA6,  iA7,
		/* 9.0 */	iA8,  iA9,  iA10, iA11,	iA12, iA13, iA14, iA15,
					iA16, iA17, iA18, iA19,	iA20, iA21, iA22, iA23,
					iA24, iA25, iA26, iA27,	iA28, iA29, iA30, iA31,
	
	// Output Signals
	output	[9:0]	oB0,  oB1,  oB2,  oB3,  oB4,  oB5,  oB6,  oB7,
		/*10.0 */	oB8,  oB9,  oB10, oB11, oB12, oB13, oB14, oB15,
	
	output	[20:0]	oB16_0a, oB16_0b, oB17_4a, oB17_4b, oB18_6a, oB18_6b, oB19_3a, oB19_3b,
		/*11.10*/	oB20_3a, oB20_3b, oB21_6a, oB21_6b, oB22_4a, oB22_4b, oB23_0a, oB23_0b,
	
	output	[19:0]	oB16_7a, oB16_7b, oB17_1a, oB17_1b, oB18_3a, oB18_3b, oB19_5a, oB19_5b,
		/*11.9 */	oB20_5a, oB20_5b, oB21_3a, oB21_3b, oB22_1a, oB22_1b, oB23_7a, oB23_7b,
	
	output	[20:0]	oB16_4a, oB16_4b, oB17_3a, oB17_3b, oB18_0a, oB18_0b, oB19_7a, oB19_7b,
		/*11.10*/	oB20_7a, oB20_7b, oB21_0a, oB21_0b, oB22_3a, oB22_3b, oB23_4a, oB23_4b,
	
	output	[15:0]	oB16_3a, oB16_3b, oB17_7a, oB17_7b, oB18_4a, oB18_4b, oB19_1a, oB19_1b,
		/*11.5 */	oB20_1a, oB20_1b, oB21_4a, oB21_4b, oB22_7a, oB22_7b, oB23_3a, oB23_3b,
	
	output	[17:0]	oB16_2a, oB16_2b, oB17_6a, oB17_6b, oB18_5a, oB18_5b, oB19_0a, oB19_0b,
		/*11.7 */	oB20_0a, oB20_0b, oB21_5a, oB21_5b, oB22_6a, oB22_6b, oB23_2a, oB23_2b,
	
	output	[15:0]	oB16_5a, oB16_5b, oB17_2a, oB17_2b, oB18_1a, oB18_1b, oB19_6a, oB19_6b,
		/*11.5 */	oB20_6a, oB20_6b, oB21_1a, oB21_1b, oB22_2a, oB22_2b, oB23_5a, oB23_5b,
	
	output	[13:0]	oB16_6a, oB16_6b, oB17_0a, oB17_0b, oB18_2a, oB18_2b, oB19_4a, oB19_4b,
		/*11.3 */	oB20_4a, oB20_4b, oB21_2a, oB21_2b, oB22_0a, oB22_0b, oB23_6a, oB23_6b,
	
	output	[14:0]	oB16_1a, oB16_1b, oB17_5a, oB17_5b, oB18_7a, oB18_7b, oB19_2a, oB19_2b,
		/*11.4 */	oB20_2a, oB20_2b, oB21_7a, oB21_7b, oB22_5a, oB22_5b, oB23_1a, oB23_1b
);

 // assign oB0  = {iA0[8],iA0} + {iA15[8],iA15};
 wire B0_c0;
 FA_Cir_Cin0 B0m0 (.iA (iA0[0]), .iB (iA15[0]), .oS (oB0[0]), .oC (B0_c0));
 Ripple_Add_9bit B0m1 (
	.iA (iA0[8:1]),	.iB (iA15[8:1]),
	.iC (B0_c0),	.oS (oB0[9:1]));
 
 // assign oB1  = {iA1[8],iA1} + {iA14[8],iA14};
 wire B1_c0;
 FA_Cir_Cin0 B1m0 (.iA (iA1[0]), .iB (iA14[0]), .oS (oB1[0]), .oC (B1_c0));
 Ripple_Add_9bit B1m1 (
	.iA (iA1[8:1]),	.iB (iA14[8:1]),
	.iC (B1_c0),	.oS (oB1[9:1]));
 
 // assign oB2  = {iA2[8],iA2} + {iA13[8],iA13};
 wire B2_c0;
 FA_Cir_Cin0 B2m0 (.iA (iA2[0]), .iB (iA13[0]), .oS (oB2[0]), .oC (B2_c0));
 Ripple_Add_9bit B2m1 (
	.iA (iA2[8:1]),	.iB (iA13[8:1]),
	.iC (B2_c0),	.oS (oB2[9:1]));
 
 // assign oB3  = {iA3[8],iA3} + {iA12[8],iA12};
 wire B3_c0;
 FA_Cir_Cin0 B3m0 (.iA (iA3[0]), .iB (iA12[0]), .oS (oB3[0]), .oC (B3_c0));
 Ripple_Add_9bit B3m1 (
	.iA (iA3[8:1]),	.iB (iA12[8:1]),
	.iC (B3_c0),	.oS (oB3[9:1]));
 
 // assign oB4  = {iA4[8],iA4} + {iA11[8],iA11};
 wire B4_c0;
 FA_Cir_Cin0 B4m0 (.iA (iA4[0]), .iB (iA11[0]), .oS (oB4[0]), .oC (B4_c0));
 Ripple_Add_9bit B4m1 (
	.iA (iA4[8:1]),	.iB (iA11[8:1]),
	.iC (B4_c0),	.oS (oB4[9:1]));
 
 // assign oB5  = {iA5[8],iA5} + {iA10[8],iA10};
 wire B5_c0;
 FA_Cir_Cin0 B5m0 (.iA (iA5[0]), .iB (iA10[0]), .oS (oB5[0]), .oC (B5_c0));
 Ripple_Add_9bit B5m1 (
	.iA (iA5[8:1]),	.iB (iA10[8:1]),
	.iC (B5_c0),	.oS (oB5[9:1]));
 
 // assign oB6  = {iA6[8],iA6} + { iA9[8], iA9};
 wire B6_c0;
 FA_Cir_Cin0 B6m0 (.iA (iA6[0]), .iB (iA9[0]), .oS (oB6[0]), .oC (B6_c0));
 Ripple_Add_9bit B6m1 (
	.iA (iA6[8:1]),	.iB (iA9[8:1]),
	.iC (B6_c0),	.oS (oB6[9:1]));
 
 // assign oB7  = {iA7[8],iA7} + { iA8[8], iA8};
 wire B7_c0;
 FA_Cir_Cin0 B7m0 (.iA (iA7[0]), .iB (iA8[0]), .oS (oB7[0]), .oC (B7_c0));
 Ripple_Add_9bit B7m1 (
	.iA (iA7[8:1]),	.iB (iA8[8:1]),
	.iC (B7_c0),	.oS (oB7[9:1]));
 
 // assign oB8  = {iA7[8],iA7} - { iA8[8], iA8};
 wire B8_c0;
 FA_Cir_Cin1 B8m0 (.iA (iA7[0]), .iB (~iA8[0]), .oS (oB8[0]), .oC (B8_c0));
 Ripple_Add_9bit B8m1 (
	.iA (iA7[8:1]),	.iB (~iA8[8:1]),
	.iC (B8_c0),	.oS (oB8[9:1]));
 
 // assign oB9  = {iA6[8],iA6} - { iA9[8], iA9};
 wire B9_c0;
 FA_Cir_Cin1 B9m0 (.iA (iA6[0]), .iB (~iA9[0]), .oS (oB9[0]), .oC (B9_c0));
 Ripple_Add_9bit B9m1 (
	.iA (iA6[8:1]),	.iB (~iA9[8:1]),
	.iC (B9_c0),	.oS (oB9[9:1]));
 
 // assign oB10 = {iA5[8],iA5} - {iA10[8],iA10};
 wire B10_c0;
 FA_Cir_Cin1 B10m0 (.iA (iA5[0]), .iB (~iA10[0]), .oS (oB10[0]), .oC (B10_c0));
 Ripple_Add_9bit B10m1 (
	.iA (iA5[8:1]),	.iB (~iA10[8:1]),
	.iC (B10_c0),	.oS (oB10[9:1]));
 
 // assign oB11 = {iA4[8],iA4} - {iA11[8],iA11};
 wire B11_c0;
 FA_Cir_Cin1 B11m0 (.iA (iA4[0]), .iB (~iA11[0]), .oS (oB11[0]), .oC (B11_c0));
 Ripple_Add_9bit B11m1 (
	.iA (iA4[8:1]),	.iB (~iA11[8:1]),
	.iC (B11_c0),	.oS (oB11[9:1]));
 
 // assign oB12 = {iA3[8],iA3} - {iA12[8],iA12};
 wire B12_c0;
 FA_Cir_Cin1 B12m0 (.iA (iA3[0]), .iB (~iA12[0]), .oS (oB12[0]), .oC (B12_c0));
 Ripple_Add_9bit B12m1 (
	.iA (iA3[8:1]),	.iB (~iA12[8:1]),
	.iC (B12_c0),	.oS (oB12[9:1]));
 
 // assign oB13 = {iA2[8],iA2} - {iA13[8],iA13};
 wire B13_c0;
 FA_Cir_Cin1 B13m0 (.iA (iA2[0]), .iB (~iA13[0]), .oS (oB13[0]), .oC (B13_c0));
 Ripple_Add_9bit B13m1 (
	.iA (iA2[8:1]),	.iB (~iA13[8:1]),
	.iC (B13_c0),	.oS (oB13[9:1]));
 
 // assign oB14 = {iA1[8],iA1} - {iA14[8],iA14};
 wire B14_c0;
 FA_Cir_Cin1 B14m0 (.iA (iA1[0]), .iB (~iA14[0]), .oS (oB14[0]), .oC (B14_c0));
 Ripple_Add_9bit B14m1 (
	.iA (iA1[8:1]),	.iB (~iA14[8:1]),
	.iC (B14_c0),	.oS (oB14[9:1]));
 
 // assign oB15 = {iA0[8],iA0} - {iA15[8],iA15};
 wire B15_c0;
 FA_Cir_Cin1 B15m0 (.iA (iA0[0]), .iB (~iA15[0]), .oS (oB15[0]), .oC (B15_c0));
 Ripple_Add_9bit B15m1 (
	.iA (iA0[8:1]),	.iB (~iA15[8:1]),
	.iC (B15_c0),	.oS (oB15[9:1]));

 ACor_DCT_32p_1to15_pi64_2Stg B16m0 (
	// Input Signals
	.iA (iA16),	.iB (iA31),
	
	// Output Signals
	.o0a (oB16_0a), .o0b(oB16_0b), .o1a (oB16_7a), .o1b (oB16_7b),
	.o2a (oB16_4a), .o2b(oB16_4b), .o3a (oB16_3a), .o3b (oB16_3b),
	.o4a (oB16_2a), .o4b(oB16_2b), .o5a (oB16_5a), .o5b (oB16_5b),
	.o6a (oB16_6a), .o6b(oB16_6b), .o7a (oB16_1a), .o7b (oB16_1b));

 ACor_DCT_32p_1to15_pi64_2Stg B17m0 (
	// Input Signals
	.iA (iA30),	.iB (iA17),
	
	// Output Signals
	.o0a (oB17_4a), .o0b(oB17_4b), .o1a (oB17_1a), .o1b (oB17_1b),
	.o2a (oB17_3a), .o2b(oB17_3b), .o3a (oB17_7a), .o3b (oB17_7b),
	.o4a (oB17_6a), .o4b(oB17_6b), .o5a (oB17_2a), .o5b (oB17_2b),
	.o6a (oB17_0a), .o6b(oB17_0b), .o7a (oB17_5a), .o7b (oB17_5b));

 ACor_DCT_32p_1to15_pi64_2Stg B18m0 (
	// Input Signals
	.iA (iA18),	.iB (iA29),
	
	// Output Signals
	.o0a (oB18_6a), .o0b(oB18_6b), .o1a (oB18_3a), .o1b (oB18_3b),
	.o2a (oB18_0a), .o2b(oB18_0b), .o3a (oB18_4a), .o3b (oB18_4b),
	.o4a (oB18_5a), .o4b(oB18_5b), .o5a (oB18_1a), .o5b (oB18_1b),
	.o6a (oB18_2a), .o6b(oB18_2b), .o7a (oB18_7a), .o7b (oB18_7b));

 ACor_DCT_32p_1to15_pi64_2Stg B19m0 (
	// Input Signals
	.iA (iA28),	.iB (iA19),
	
	// Output Signals
	.o0a (oB19_3a), .o0b(oB19_3b), .o1a (oB19_5a), .o1b (oB19_5b),
	.o2a (oB19_7a), .o2b(oB19_7b), .o3a (oB19_1a), .o3b (oB19_1b),
	.o4a (oB19_0a), .o4b(oB19_0b), .o5a (oB19_6a), .o5b (oB19_6b),
	.o6a (oB19_4a), .o6b(oB19_4b), .o7a (oB19_2a), .o7b (oB19_2b));

 ACor_DCT_32p_1to15_pi64_2Stg B20m0 (
	// Input Signals
	.iA (iA20),	.iB (iA27),
	
	// Output Signals
	.o0a (oB20_3a), .o0b(oB20_3b), .o1a (oB20_5a), .o1b (oB20_5b),
	.o2a (oB20_7a), .o2b(oB20_7b), .o3a (oB20_1a), .o3b (oB20_1b),
	.o4a (oB20_0a), .o4b(oB20_0b), .o5a (oB20_6a), .o5b (oB20_6b),
	.o6a (oB20_4a), .o6b(oB20_4b), .o7a (oB20_2a), .o7b (oB20_2b));

 ACor_DCT_32p_1to15_pi64_2Stg B21m0 (
	// Input Signals
	.iA (iA26),	.iB (iA21),
	
	// Output Signals
	.o0a (oB21_6a), .o0b(oB21_6b), .o1a (oB21_3a), .o1b (oB21_3b),
	.o2a (oB21_0a), .o2b(oB21_0b), .o3a (oB21_4a), .o3b (oB21_4b),
	.o4a (oB21_5a), .o4b(oB21_5b), .o5a (oB21_1a), .o5b (oB21_1b),
	.o6a (oB21_2a), .o6b(oB21_2b), .o7a (oB21_7a), .o7b (oB21_7b));

 ACor_DCT_32p_1to15_pi64_2Stg B22m0 (
	// Input Signals
	.iA (iA22),	.iB (iA25),
	
	// Output Signals
	.o0a (oB22_4a), .o0b(oB22_4b), .o1a (oB22_1a), .o1b (oB22_1b),
	.o2a (oB22_3a), .o2b(oB22_3b), .o3a (oB22_7a), .o3b (oB22_7b),
	.o4a (oB22_6a), .o4b(oB22_6b), .o5a (oB22_2a), .o5b (oB22_2b),
	.o6a (oB22_0a), .o6b(oB22_0b), .o7a (oB22_5a), .o7b (oB22_5b));

 ACor_DCT_32p_1to15_pi64_2Stg B23m0 (
	// Input Signals
	.iA (iA24),	.iB (iA23),
	
	// Output Signals
	.o0a (oB23_0a), .o0b(oB23_0b), .o1a (oB23_7a), .o1b (oB23_7b),
	.o2a (oB23_4a), .o2b(oB23_4b), .o3a (oB23_3a), .o3b (oB23_3b),
	.o4a (oB23_2a), .o4b(oB23_2b), .o5a (oB23_5a), .o5b (oB23_5b),
	.o6a (oB23_6a), .o6b(oB23_6b), .o7a (oB23_1a), .o7b (oB23_1b));

endmodule

module ACor_DCT_32p_S3 (
	// Input Signals
	input	[9:0]	iB0,  iB1,  iB2,  iB3,  iB4,  iB5,  iB6,  iB7,
		/*10.0 */	iB8,  iB9,  iB10, iB11, iB12, iB13, iB14, iB15,
	
	input	[20:0]	iB16_0a, iB16_0b, iB17_4a, iB17_4b, iB18_6a, iB18_6b, iB19_3a, iB19_3b,
		/*11.10*/	iB20_3a, iB20_3b, iB21_6a, iB21_6b, iB22_4a, iB22_4b, iB23_0a, iB23_0b,
	
	input	[19:0]	iB16_7a, iB16_7b, iB17_1a, iB17_1b, iB18_3a, iB18_3b, iB19_5a, iB19_5b,
		/*11.9 */	iB20_5a, iB20_5b, iB21_3a, iB21_3b, iB22_1a, iB22_1b, iB23_7a, iB23_7b,
	
	input	[20:0]	iB16_4a, iB16_4b, iB17_3a, iB17_3b, iB18_0a, iB18_0b, iB19_7a, iB19_7b,
		/*11.10*/	iB20_7a, iB20_7b, iB21_0a, iB21_0b, iB22_3a, iB22_3b, iB23_4a, iB23_4b,
	
	input	[15:0]	iB16_3a, iB16_3b, iB17_7a, iB17_7b, iB18_4a, iB18_4b, iB19_1a, iB19_1b,
		/*11.5 */	iB20_1a, iB20_1b, iB21_4a, iB21_4b, iB22_7a, iB22_7b, iB23_3a, iB23_3b,
	
	input	[17:0]	iB16_2a, iB16_2b, iB17_6a, iB17_6b, iB18_5a, iB18_5b, iB19_0a, iB19_0b,
		/*11.7 */	iB20_0a, iB20_0b, iB21_5a, iB21_5b, iB22_6a, iB22_6b, iB23_2a, iB23_2b,
	
	input	[15:0]	iB16_5a, iB16_5b, iB17_2a, iB17_2b, iB18_1a, iB18_1b, iB19_6a, iB19_6b,
		/*11.5 */	iB20_6a, iB20_6b, iB21_1a, iB21_1b, iB22_2a, iB22_2b, iB23_5a, iB23_5b,
	
	input	[13:0]	iB16_6a, iB16_6b, iB17_0a, iB17_0b, iB18_2a, iB18_2b, iB19_4a, iB19_4b,
		/*11.3 */	iB20_4a, iB20_4b, iB21_2a, iB21_2b, iB22_0a, iB22_0b, iB23_6a, iB23_6b,
	
	input	[14:0]	iB16_1a, iB16_1b, iB17_5a, iB17_5b, iB18_7a, iB18_7b, iB19_2a, iB19_2b,
		/*11.4 */	iB20_2a, iB20_2b, iB21_7a, iB21_7b, iB22_5a, iB22_5b, iB23_1a, iB23_1b,
		
	// Output Signals
	output	[10:0]	/*11.0 */	oC0, oC1, oC2, oC3, oC4, oC5, oC6, oC7,
	
	output	[19:0]	/*12.8 */	oC8_0a, oC8_0b, oC9_3a, oC9_3b, oC10_3a, oC10_3b, oC11_0a, oC11_0b,
	output	[17:0]	/*12.6 */	oC8_3a, oC8_3b, oC9_1a, oC9_1b, oC10_1a, oC10_1b, oC11_3a, oC11_3b,
	output	[17:0]	/*12.6 */	oC8_2a, oC8_2b, oC9_0a, oC9_0b, oC10_0a, oC10_0b, oC11_2a, oC11_2b,
	output	[14:0]	/*12.3 */	oC8_1a, oC8_1b, oC9_2a, oC9_2b, oC10_2a, oC10_2b, oC11_1a, oC11_1b,
	
	output	[21:0]	/*12.10*/	oC12_0a, oC12_0b, oC12_1a, oC12_1b,
	output	[18:0]	/*12.7 */	oC12_2a, oC12_2b, oC12_3a, oC12_3b,
	output	[21:0]	/*12.10*/	oC12_4a, oC12_4b, oC12_5a, oC12_5b,
	output	[20:0]	/*12.9 */	oC12_6a, oC12_6b, oC12_7a, oC12_7b,
	
	output	[21:0]	/*12.10*/	oC13_0a, oC13_0b, oC13_1a, oC13_1b,
	output	[20:0]	/*12.9 */	oC13_2a, oC13_2b, oC13_3a, oC13_3b,
	output	[18:0]	/*12.7 */	oC13_4a, oC13_4b, oC13_5a, oC13_5b,
	output	[21:0]	/*12.10*/	oC13_6a, oC13_6b, oC13_7a, oC13_7b,
	
	output	[18:0]	/*12.7 */	oC14_0a, oC14_0b, oC14_1a, oC14_1b,
	output	[21:0]	/*12.10*/	oC14_2a, oC14_2b, oC14_3a, oC14_3b,
	output	[20:0]	/*12.9 */	oC14_4a, oC14_4b, oC14_5a, oC14_5b,
	output	[21:0]	/*12.10*/	oC14_6a, oC14_6b, oC14_7a, oC14_7b,
	
	output	[20:0]	/*12.9 */	oC15_0a, oC15_0b, oC15_1a, oC15_1b,
	output	[21:0]	/*12.10*/	oC15_2a, oC15_2b, oC15_3a, oC15_3b,
	output	[21:0]	/*12.10*/	oC15_4a, oC15_4b, oC15_5a, oC15_5b,
	output	[18:0]	/*12.7 */	oC15_6a, oC15_6b, oC15_7a, oC15_7b
);

 // assign oC0 = {iB0[9],iB0} + {iB7[9],iB7};
 wire C0_c0;
 FA_Cir_Cin0 C0m0 (.iA (iB0[0]), .iB (iB7[0]), .oS (oC0[0]), .oC (C0_c0));
 Ripple_Add_10bit C0m1 (
	.iA (iB0[9:1]),	.iB (iB7[9:1]),
	.iC (C0_c0),	.oS (oC0[10:1]));
 
 // assign oC1 = {iB1[9],iB1} + {iB6[9],iB6};
 wire C1_c0;
 FA_Cir_Cin0 C1m0 (.iA (iB1[0]), .iB (iB6[0]), .oS (oC1[0]), .oC (C1_c0));
 Ripple_Add_10bit C1m1 (
	.iA (iB1[9:1]),	.iB (iB6[9:1]),
	.iC (C1_c0),	.oS (oC1[10:1]));
 
 // assign oC2 = {iB2[9],iB2} + {iB5[9],iB5};
 wire C2_c0;
 FA_Cir_Cin0 C2m0 (.iA (iB2[0]), .iB (iB5[0]), .oS (oC2[0]), .oC (C2_c0));
 Ripple_Add_10bit C2m1 (
	.iA (iB2[9:1]),	.iB (iB5[9:1]),
	.iC (C2_c0),	.oS (oC2[10:1]));
 
 // assign oC3 = {iB3[9],iB3} + {iB4[9],iB4};
 wire C3_c0;
 FA_Cir_Cin0 C3m0 (.iA (iB3[0]), .iB (iB4[0]), .oS (oC3[0]), .oC (C3_c0));
 Ripple_Add_10bit C3m1 (
	.iA (iB3[9:1]),	.iB (iB4[9:1]),
	.iC (C3_c0),	.oS (oC3[10:1]));
 
 // assign oC4 = {iB3[9],iB3} - {iB4[9],iB4};
 wire C4_c0;
 FA_Cir_Cin1 C4m0 (.iA (iB3[0]), .iB (~iB4[0]), .oS (oC4[0]), .oC (C4_c0));
 Ripple_Add_10bit C4m1 (
	.iA (iB3[9:1]),	.iB (~iB4[9:1]),
	.iC (C4_c0),	.oS (oC4[10:1]));
 
 // assign oC5 = {iB2[9],iB2} - {iB5[9],iB5};
 wire C5_c0;
 FA_Cir_Cin1 C5m0 (.iA (iB2[0]), .iB (~iB5[0]), .oS (oC5[0]), .oC (C5_c0));
 Ripple_Add_10bit C5m1 (
	.iA (iB2[9:1]),	.iB (~iB5[9:1]),
	.iC (C5_c0),	.oS (oC5[10:1]));
 
 // assign oC6 = {iB1[9],iB1} - {iB6[9],iB6};
 wire C6_c0;
 FA_Cir_Cin1 C6m0 (.iA (iB1[0]), .iB (~iB6[0]), .oS (oC6[0]), .oC (C6_c0));
 Ripple_Add_10bit C6m1 (
	.iA (iB1[9:1]),	.iB (~iB6[9:1]),
	.iC (C6_c0),	.oS (oC6[10:1]));
 
 // assign oC7 = {iB0[9],iB0} - {iB7[9],iB7};
 wire C7_c0;
 FA_Cir_Cin1 C7m0 (.iA (iB0[0]), .iB (~iB7[0]), .oS (oC7[0]), .oC (C7_c0));
 Ripple_Add_10bit C7m1 (
	.iA (iB0[9:1]),	.iB (~iB7[9:1]),
	.iC (C7_c0),	.oS (oC7[10:1]));

 ACor_DCT_32p_1to7_pi32_2Stg C8m0 (
	// Input Signals
	.iA	(iB8), .iB (iB15),
	
	// Output Signals
	.o0a (oC8_0a), .o0b (oC8_0b), .o1a (oC8_3a), .o1b (oC8_3b),
	.o2a (oC8_2a), .o2b (oC8_2b), .o3a (oC8_1a), .o3b (oC8_1b));

 ACor_DCT_32p_1to7_pi32_2Stg C9m0 (
	// Input Signals
	.iA (iB14), .iB (iB9),
	
	// Output Signals
	.o0a (oC9_3a), .o0b (oC9_3b), .o1a (oC9_1a), .o1b (oC9_1b),
	.o2a (oC9_0a), .o2b (oC9_0b), .o3a (oC9_2a), .o3b (oC9_2b));

 ACor_DCT_32p_1to7_pi32_2Stg C10m0 (
	// Input Signals
	.iA (iB10), .iB (iB13),
	
	// Output Signals
	.o0a (oC10_3a), .o0b (oC10_3b), .o1a (oC10_1a), .o1b (oC10_1b),
	.o2a (oC10_0a), .o2b (oC10_0b), .o3a (oC10_2a), .o3b (oC10_2b));

 ACor_DCT_32p_1to7_pi32_2Stg C11m0 (
	// Input Signals
	.iA (iB12), .iB (iB11),
	
	// Output Signals
	.o0a (oC11_0a), .o0b (oC11_0b), .o1a (oC11_3a), .o1b (oC11_3b),
	.o2a (oC11_2a), .o2b (oC11_2b), .o3a (oC11_1a), .o3b (oC11_1b));
 
 /**********************************
 **************  C12  **************
 **********************************/
	//  12.10 [21:0]			11.10 [20:0]				11.4  [14:0]
 //assign   oC12_0a	=	{iB16_0a[20],iB16_0a}      + {iB23_1a[14],iB23_1a,6'b0};
 wire C12_0a_c6;
 assign oC12_0a[5:0] = iB16_0a[5:0];
 FA_Cir_Cin0 C120am6 (.iA (iB16_0a[6]), .iB (iB23_1a[0]), .oS (oC12_0a[6]), .oC (C12_0a_c6));
 Ripple_Add_15bit C120am7 (
	.iA (iB16_0a[20:7]),	.iB (iB23_1a[14:1]),
	.iC (C12_0a_c6),		.oS (oC12_0a[21:7]));
 
	//  12.10 [21:0]			11.4  [14:0]				11.10 [20:0]
 //assign   oC12_0b	=	{iB23_1b[14],iB23_1b,6'b0} - {iB16_0b[20],iB16_0b};
 wire C12_0b_c1, C12_0b_c2, C12_0b_c3, C12_0b_c4, C12_0b_c5;
 assign oC12_0b[0] = iB16_0b[0];
 FA_Cir_Cin0 C120bm1 (.iA (~iB16_0b[1]), .iB (~iB16_0b[0]), .oS (oC12_0b[1]), .oC (C12_0b_c1));
 FA_Cir_Cin0 C120bm2 (.iA (~iB16_0b[2]), .iB (C12_0b_c1),   .oS (oC12_0b[2]), .oC (C12_0b_c2));
 FA_Cir_Cin0 C120bm3 (.iA (~iB16_0b[3]), .iB (C12_0b_c2),   .oS (oC12_0b[3]), .oC (C12_0b_c3));
 FA_Cir_Cin0 C120bm4 (.iA (~iB16_0b[4]), .iB (C12_0b_c3),   .oS (oC12_0b[4]), .oC (C12_0b_c4));
 FA_Cir_Cin0 C120bm5 (.iA (~iB16_0b[5]), .iB (C12_0b_c4),   .oS (oC12_0b[5]), .oC (C12_0b_c5));
 Ripple_Add_16bit C120bm6 (
	.iA (iB23_1b),		.iB (~iB16_0b[20:6]),
	.iC (C12_0b_c5),	.oS (oC12_0b[21:6]));
 
	//  12.10 [21:0]			11.4  [14:0]				11.10 [20:0]
 //assign   oC12_1a	=	{iB16_1a[14],iB16_1a,6'b0} + {iB23_0b[20],iB23_0b};
 wire C12_1a_c6;
 assign oC12_1a[5:0] = iB23_0b[5:0];
 FA_Cir_Cin0 C121am6 (.iA (iB16_1a[0]), .iB (iB23_0b[6]), .oS (oC12_1a[6]), .oC (C12_1a_c6));
 Ripple_Add_15bit C121am7 (
	.iA (iB16_1a[14:1]),	.iB (iB23_0b[20:7]),
	.iC (C12_1a_c6),		.oS (oC12_1a[21:7]));
 
	//  12.10 [21:0]			11.4  [14:0]				11.10 [20:0]
 //assign   oC12_1b	=	{iB16_1b[14],iB16_1b,6'b0} + {iB23_0a[20],iB23_0a};
 wire C12_1b_c6;
 assign oC12_1b[5:0] = iB23_0a[5:0];
 FA_Cir_Cin0 C121bm6 (.iA (iB16_1b[0]), .iB (iB23_0a[6]), .oS (oC12_1b[6]), .oC (C12_1b_c6));
 Ripple_Add_15bit C121bm7 (
	.iA (iB16_1b[14:1]),	.iB (iB23_0a[20:7]),
	.iC (C12_1b_c6),		.oS (oC12_1b[21:7]));
 
	//  12.7  [18:0]			11.7  [17:0]				11.5  [15:0]
 //assign   oC12_2a	=	{iB16_2a[17],iB16_2a}      + {iB23_3a[15],iB23_3a,2'b0};
 wire C12_2a_c3;
 assign oC12_2a[1:0] = iB16_2a[1:0];
 FA_Cir_Cin0 C122am2 (.iA (iB16_2a[2]), .iB (iB23_3a[0]), .oS (oC12_2a[2]), .oC (C12_2a_c3));
 Ripple_Add_16bit C122am3 (
	.iA (iB16_2a[17:3]),	.iB (iB23_3a[15:1]),
	.iC (C12_2a_c3),		.oS (oC12_2a[18:3]));
 
	//  12.7  [18:0]			11.5  [15:0]				11.7  [17:0]
 //assign   oC12_2b	=	{iB23_3b[15],iB23_3b,2'b0} - {iB16_2b[17],iB16_2b};
 wire C12_2b_c1;
 assign oC12_2b[0] = iB16_2b[0];
 FA_Cir_Cin0 C122bm1 (.iA (~iB16_2b[1]), .iB (~iB16_2b[0]), .oS (oC12_2b[1]), .oC (C12_2b_c1));
 Ripple_Add_17bit C122bm2 (
	.iA (iB23_3b),		.iB (~iB16_2b[17:2]),
	.iC (C12_2b_c1),	.oS (oC12_2b[18:2]));
 
	//  12.7  [18:0]			11.5  [15:0]				11.7  [17:0]
 //assign   oC12_3a	=	{iB16_3a[15],iB16_3a,2'b0} + {iB23_2b[17],iB23_2b};
 wire C12_3a_c3;
 assign oC12_3a[1:0] = iB23_2b[1:0];
 FA_Cir_Cin0 C123am2 (.iA (iB16_3a[0]), .iB (iB23_2b[2]), .oS (oC12_3a[2]), .oC (C12_3a_c3));
 Ripple_Add_16bit C123am3 (
	.iA (iB16_3a[15:1]),	.iB (iB23_2b[17:3]),
	.iC (C12_3a_c3),		.oS (oC12_3a[18:3]));
 
	//  12.7  [18:0]			11.5  [15:0]				11.7  [17:0]
 //assign   oC12_3b	=	{iB16_3b[15],iB16_3b,2'b0} + {iB23_2a[17],iB23_2a};
 wire C12_3b_c3;
 assign oC12_3b[1:0] = iB23_2a[1:0];
 FA_Cir_Cin0 C123bm2 (.iA (iB16_3b[0]), .iB (iB23_2a[2]), .oS (oC12_3b[2]), .oC (C12_3b_c3));
 Ripple_Add_16bit C123bm3 (
	.iA (iB16_3b[15:1]),	.iB (iB23_2a[17:3]),
	.iC (C12_3b_c3),		.oS (oC12_3b[18:3]));
 
	//  12.10 [21:0]			11.10 [20:0]				11.5  [15:0]
 //assign   oC12_4a	=	{iB16_4a[20],iB16_4a}      - {iB23_5a[15],iB23_5a,5'b0};
 wire C12_4a_c5;
 assign oC12_4a[4:0] = iB16_4a[4:0];
 FA_Cir_Cin1 C124am5 (.iA (iB16_4a[5]), .iB (~iB23_5a[0]), .oS (oC12_4a[5]), .oC (C12_4a_c5));
 Ripple_Add_16bit C124am6 (
	.iA (iB16_4a[20:6]),	.iB (~iB23_5a[15:1]),
	.iC (C12_4a_c5),		.oS (oC12_4a[21:6]));
 
	//  12.10 [21:0]			11.10 [20:0]				11.5  [15:0]
 //assign   oC12_4b	=	{iB16_4b[20],iB16_4b}      + {iB23_5b[15],iB23_5b,5'b0};
 wire C12_4b_c5;
 assign oC12_4b[4:0] = iB16_4b[4:0];
 FA_Cir_Cin0 C124bm5 (.iA (iB16_4b[5]), .iB (iB23_5b[0]), .oS (oC12_4b[5]), .oC (C12_4b_c5));
 Ripple_Add_16bit C124bm6 (
	.iA (iB16_4b[20:6]),	.iB (iB23_5b[15:1]),
	.iC (C12_4b_c5),		.oS (oC12_4b[21:6]));
 
	//  12.10 [21:0]			11.5  [15:0]				11.10 [20:0]
 //assign   oC12_5a	=	{iB16_5a[15],iB16_5a,5'b0} - {iB23_4b[20],iB23_4b};
 wire C12_5a_c1, C12_5a_c2, C12_5a_c3, C12_5a_c4;
 assign oC12_5a[0] = iB23_4b[0];
 FA_Cir_Cin0 C125am1 (.iA (~iB23_4b[1]), .iB (~iB23_4b[0]), .oS (oC12_5a[1]), .oC (C12_5a_c1));
 FA_Cir_Cin0 C125am2 (.iA (~iB23_4b[2]), .iB (C12_5a_c1),   .oS (oC12_5a[2]), .oC (C12_5a_c2));
 FA_Cir_Cin0 C125am3 (.iA (~iB23_4b[3]), .iB (C12_5a_c2),   .oS (oC12_5a[3]), .oC (C12_5a_c3));
 FA_Cir_Cin0 C125am4 (.iA (~iB23_4b[4]), .iB (C12_5a_c3),   .oS (oC12_5a[4]), .oC (C12_5a_c4));
 Ripple_Add_17bit C125am5 (
	.iA (iB16_5a),		.iB (~iB23_4b[20:5]),
	.iC (C12_5a_c4),	.oS (oC12_5a[21:5]));
 
	//  12.10 [21:0]			11.5  [15:0]				11.10 [20:0]
 //assign   oC12_5b	=	{iB16_5b[15],iB16_5b,5'b0} - {iB23_4a[20],iB23_4a};
 wire C12_5b_c1, C12_5b_c2, C12_5b_c3, C12_5b_c4;
 assign oC12_5b[0] = iB23_4a[0];
 FA_Cir_Cin0 C125bm1 (.iA (~iB23_4a[1]), .iB (~iB23_4a[0]), .oS (oC12_5b[1]), .oC (C12_5b_c1));
 FA_Cir_Cin0 C125bm2 (.iA (~iB23_4a[2]), .iB (C12_5b_c1),   .oS (oC12_5b[2]), .oC (C12_5b_c2));
 FA_Cir_Cin0 C125bm3 (.iA (~iB23_4a[3]), .iB (C12_5b_c2),   .oS (oC12_5b[3]), .oC (C12_5b_c3));
 FA_Cir_Cin0 C125bm4 (.iA (~iB23_4a[4]), .iB (C12_5b_c3),   .oS (oC12_5b[4]), .oC (C12_5b_c4));
 Ripple_Add_17bit C125bm5 (
	.iA (iB16_5b),		.iB (~iB23_4a[20:5]),
	.iC (C12_5b_c4),	.oS (oC12_5b[21:5]));
 
	//  12.9  [20:0]			11.3  [13:0]				11.9  [19:0]
 //assign   oC12_6a	=	{iB16_6a[13],iB16_6a,6'b0} - {iB23_7a[19],iB23_7a};
 wire C12_6a_c1, C12_6a_c2, C12_6a_c3, C12_6a_c4, C12_6a_c5;
 assign oC12_6a[0] = iB23_7a[0];
 FA_Cir_Cin0 C126am1 (.iA (~iB23_7a[1]), .iB (~iB23_7a[0]), .oS (oC12_6a[1]), .oC (C12_6a_c1));
 FA_Cir_Cin0 C126am2 (.iA (~iB23_7a[2]), .iB (C12_6a_c1),   .oS (oC12_6a[2]), .oC (C12_6a_c2));
 FA_Cir_Cin0 C126am3 (.iA (~iB23_7a[3]), .iB (C12_6a_c2),   .oS (oC12_6a[3]), .oC (C12_6a_c3));
 FA_Cir_Cin0 C126am4 (.iA (~iB23_7a[4]), .iB (C12_6a_c3),   .oS (oC12_6a[4]), .oC (C12_6a_c4));
 FA_Cir_Cin0 C126am5 (.iA (~iB23_7a[5]), .iB (C12_6a_c4),   .oS (oC12_6a[5]), .oC (C12_6a_c5));
 Ripple_Add_15bit C126am6 (
	.iA (iB16_6a),		.iB (~iB23_7a[19:6]),
	.iC (C12_6a_c5),	.oS (oC12_6a[20:6]));
 
	//  12.9  [20:0]			11.3  [13:0]				11.9  [19:0]
 //assign   oC12_6b	=	{iB16_6b[13],iB16_6b,6'b0} + {iB23_7b[19],iB23_7b};
 wire C12_6b_c6;
 assign oC12_6b[5:0] = iB23_7b[5:0];
 FA_Cir_Cin0 C126bm6 (.iA (iB16_6b[0]), .iB (iB23_7b[6]), .oS (oC12_6b[6]), .oC (C12_6b_c6));
 Ripple_Add_14bit C126bm7 (
	.iA (iB16_6b[13:1]),	.iB (iB23_7b[19:7]),
	.iC (C12_6b_c6),		.oS (oC12_6b[20:7]));
 
	//  12.9  [20:0]			11.9  [19:0]				11.3  [13:0]
 //assign   oC12_7a	=	{iB16_7a[19],iB16_7a}      - {iB23_6b[13],iB23_6b,6'b0};
 wire C12_7a_c6;
 assign oC12_7a[5:0] = iB16_7a[5:0];
 FA_Cir_Cin1 C127am6 (.iA (iB16_7a[6]), .iB (~iB23_6b[0]), .oS (oC12_7a[6]), .oC (C12_7a_c6));
 Ripple_Add_14bit C127am7 (
	.iA (iB16_7a[19:7]),	.iB (~iB23_6b[13:1]),
	.iC (C12_7a_c6),		.oS (oC12_7a[20:7]));
 
	//  12.9  [20:0]			11.9  [19:0]				11.3  [13:0]
 //assign   oC12_7b	=	{iB16_7b[19],iB16_7b}      - {iB23_6a[13],iB23_6a,6'b0};
 wire C12_7b_c6;
 assign oC12_7b[5:0] = iB16_7b[5:0];
 FA_Cir_Cin1 C127bm6 (.iA (iB16_7b[6]), .iB (~iB23_6a[0]), .oS (oC12_7b[6]), .oC (C12_7b_c6));
 Ripple_Add_14bit C127bm7 (
	.iA (iB16_7b[19:7]),	.iB (~iB23_6a[13:1]),
	.iC (C12_7b_c6),		.oS (oC12_7b[20:7]));
 
 /**********************************
 **************  C13  **************
 **********************************/
	//	12.10 [21:0]			11.10 [20:0]				11.5  [15:0]
 //assign   oC13_0a	=	{iB18_0a[20],iB18_0a}      + {iB21_1a[15],iB21_1a,5'b0};
 wire C13_0a_c5;
 assign oC13_0a[4:0] = iB18_0a[4:0];
 FA_Cir_Cin0 C130am5 (.iA (iB18_0a[5]), .iB (iB21_1a[0]), .oS (oC13_0a[5]), .oC (C13_0a_c5));
 Ripple_Add_16bit C130am6 (
	.iA (iB18_0a[20:6]),	.iB (iB21_1a[15:1]),
	.iC (C13_0a_c5),		.oS (oC13_0a[21:6]));
 
	//	12.10 [21:0]			11.5  [15:0]				11.10 [20:0]
 //assign   oC13_0b	=	{iB21_1b[15],iB21_1b,5'b0} - {iB18_0b[20],iB18_0b};
 wire C13_0b_c1, C13_0b_c2, C13_0b_c3, C13_0b_c4;
 assign oC13_0b[0] = iB18_0b[0];
 FA_Cir_Cin0 C130bm1 (.iA (~iB18_0b[1]), .iB (~iB18_0b[0]), .oS (oC13_0b[1]), .oC (C13_0b_c1));
 FA_Cir_Cin0 C130bm2 (.iA (~iB18_0b[2]), .iB (C13_0b_c1),   .oS (oC13_0b[2]), .oC (C13_0b_c2));
 FA_Cir_Cin0 C130bm3 (.iA (~iB18_0b[3]), .iB (C13_0b_c2),   .oS (oC13_0b[3]), .oC (C13_0b_c3));
 FA_Cir_Cin0 C130bm4 (.iA (~iB18_0b[4]), .iB (C13_0b_c3),   .oS (oC13_0b[4]), .oC (C13_0b_c4));
 Ripple_Add_17bit C130bm5 (
	.iA (iB21_1b),		.iB (~iB18_0b[20:5]),
	.iC (C13_0b_c4),	.oS (oC13_0b[21:5]));
 
	//	12.10 [21:0]			11.5  [15:0]				11.10 [20:0]
 //assign   oC13_1a	=	{iB18_1a[15],iB18_1a,5'b0} + {iB21_0b[20],iB21_0b};
 wire C13_1a_c5;
 assign oC13_1a[4:0] = iB21_0b[4:0];
 FA_Cir_Cin0 C131am5 (.iA (iB18_1a[0]), .iB (iB21_0b[5]), .oS (oC13_1a[5]), .oC (C13_1a_c5));
 Ripple_Add_16bit C131am6 (
	.iA (iB18_1a[15:1]),	.iB (iB21_0b[20:6]),
	.iC (C13_1a_c5),		.oS (oC13_1a[21:6]));
 
	//	12.10 [21:0]			11.5  [15:0]				11.10 [20:0]
 //assign   oC13_1b	=	{iB18_1b[15],iB18_1b,5'b0} + {iB21_0a[20],iB21_0a};
 wire C13_1b_c5;
 assign oC13_1b[4:0] = iB21_0a[4:0];
 FA_Cir_Cin0 C131bm5 (.iA (iB18_1b[0]), .iB (iB21_0a[5]), .oS (oC13_1b[5]), .oC (C13_1b_c5));
 Ripple_Add_16bit C131bm6 (
	.iA (iB18_1b[15:1]),	.iB (iB21_0a[20:6]),
	.iC (C13_1b_c5),		.oS (oC13_1b[21:6]));
 
	//	12.9  [20:0]			11.3  [13:0]				11.9  [19:0]
 //assign   oC13_2a	=	{iB18_2a[13],iB18_2a,6'b0} + {iB21_3a[19],iB21_3a};
 wire C13_2a_c6;
 assign oC13_2a[5:0] = iB21_3a[5:0];
 FA_Cir_Cin0 C132am6 (.iA (iB18_2a[0]), .iB (iB21_3a[6]), .oS (oC13_2a[6]), .oC (C13_2a_c6));
 Ripple_Add_14bit C132am7 (
	.iA (iB18_2a[13:1]),	.iB (iB21_3a[19:7]),
	.iC (C13_2a_c6),		.oS (oC13_2a[20:7]));
 
	//	12.9  [20:0]			11.9  [19:0]				11.3  [13:0]
 //assign   oC13_2b	=	{iB21_3b[19],iB21_3b}      - {iB18_2b[13],iB18_2b,6'b0};
 wire C13_2b_c6;
 assign oC13_2b[5:0] = iB21_3b[5:0];
 FA_Cir_Cin1 C132bm6 (.iA (iB21_3b[6]), .iB (~iB18_2b[0]), .oS (oC13_2b[6]), .oC (C13_2b_c6));
 Ripple_Add_14bit C132bm7 (
	.iA (iB21_3b[19:7]),	.iB (~iB18_2b[13:1]),
	.iC (C13_2b_c6),		.oS (oC13_2b[20:7]));
 
	//	12.9  [20:0]			11.9  [19:0]				11.3  [13:0]
 //assign   oC13_3a	=	{iB18_3a[19],iB18_3a}      + {iB21_2b[13],iB21_2b,6'b0};
 wire C13_3a_c6;
 assign oC13_3a[5:0] = iB18_3a[5:0];
 FA_Cir_Cin0 C133am6 (.iA (iB18_3a[6]), .iB (iB21_2b[0]), .oS (oC13_3a[6]), .oC (C13_3a_c6));
 Ripple_Add_14bit C133am7 (
	.iA (iB18_3a[19:7]),	.iB (iB21_2b[13:1]),
	.iC (C13_3a_c6),		.oS (oC13_3a[20:7]));
 
	//	12.9  [20:0]			11.9  [19:0]				11.3  [13:0]
 //assign   oC13_3b	=	{iB18_3b[19],iB18_3b}      + {iB21_2a[13],iB21_2a,6'b0};
 wire C13_3b_c6;
 assign oC13_3b[5:0] = iB18_3b[5:0];
 FA_Cir_Cin0 C133bm6 (.iA (iB18_3b[6]), .iB (iB21_2a[0]), .oS (oC13_3b[6]), .oC (C13_3b_c6));
 Ripple_Add_14bit C133bm7 (
	.iA (iB18_3b[19:7]),	.iB (iB21_2a[13:1]),
	.iC (C13_3b_c6),		.oS (oC13_3b[20:7]));
 
	//	12.7  [18:0]			11.5  [15:0]				11.7  [17:0]
 //assign   oC13_4a	=	{iB18_4a[15],iB18_4a,2'b0} - {iB21_5b[17],iB21_5b};
 wire C13_4a_c1;
 assign oC13_4a[0] = iB21_5b[0];
 FA_Cir_Cin0 C134am1 (.iA (~iB21_5b[1]), .iB (~iB21_5b[0]), .oS (oC13_4a[1]), .oC (C13_4a_c1));
 Ripple_Add_17bit C134am2 (
	.iA (iB18_4a),		.iB (~iB21_5b[17:2]),
	.iC (C13_4a_c1),	.oS (oC13_4a[18:2]));
 
	//	12.7  [18:0]			11.5  [15:0]				11.7  [17:0]
 //assign   oC13_4b	=	{iB18_4b[15],iB18_4b,2'b0} - {iB21_5a[17],iB21_5a};
 wire C13_4b_c1;
 assign oC13_4b[0] = iB21_5a[0];
 FA_Cir_Cin0 C134bm1 (.iA (~iB21_5a[1]), .iB (~iB21_5a[0]), .oS (oC13_4b[1]), .oC (C13_4b_c1));
 Ripple_Add_17bit C134bm2 (
	.iA (iB18_4b),		.iB (~iB21_5a[17:2]),
	.iC (C13_4b_c1),	.oS (oC13_4b[18:2]));
 
	//	12.7  [18:0]			11.7  [17:0]				11.5  [15:0]
 //assign   oC13_5a	=	{iB18_5a[17],iB18_5a}      - {iB21_4a[15],iB21_4a,2'b0};
 wire C13_5a_c2;
 assign oC13_5a[1:0] = iB18_5a[1:0];
 FA_Cir_Cin1 C135am2 (.iA (iB18_5a[2]), .iB (~iB21_4a[0]), .oS (oC13_5a[2]), .oC (C13_5a_c2));
 Ripple_Add_16bit C135am3 (
	.iA (iB18_5a[17:3]),	.iB (~iB21_4a[15:1]),
	.iC (C13_5a_c2),		.oS (oC13_5a[18:3]));
 
	//	12.7  [18:0]			11.7  [17:0]				11.5  [15:0]
 //assign   oC13_5b	=	{iB18_5b[17],iB18_5b}      + {iB21_4b[15],iB21_4b,2'b0};
 wire C13_5b_c3;
 assign oC13_5b[1:0] = iB18_5b[1:0];
 FA_Cir_Cin0 C135bm2 (.iA (iB18_5b[2]), .iB (iB21_4b[0]), .oS (oC13_5b[2]), .oC (C13_5b_c3));
 Ripple_Add_16bit C135bm3 (
	.iA (iB18_5b[17:3]),	.iB (iB21_4b[15:1]),
	.iC (C13_5b_c3),		.oS (oC13_5b[18:3]));
 
	//	12.10 [21:0]			11.10 [20:0]				11.4  [14:0]
 //assign   oC13_6a	=	{iB18_6a[20],iB18_6a}      - {iB21_7a[14],iB21_7a,6'b0};
 wire C13_6a_c6;
 assign oC13_6a[5:0] = iB18_6a[5:0];
 FA_Cir_Cin1 C136am6 (.iA (iB18_6a[6]), .iB (~iB21_7a[0]), .oS (oC13_6a[6]), .oC (C13_6a_c6));
 Ripple_Add_15bit C136am7 (
	.iA (iB18_6a[20:7]),	.iB (~iB21_7a[14:1]),
	.iC (C13_6a_c6),		.oS (oC13_6a[21:7]));
 
	//	12.10 [21:0]			11.10 [20:0]				11.4  [14:0]
 //assign   oC13_6b	=	{iB18_6b[20],iB18_6b}      + {iB21_7b[14],iB21_7b,6'b0};
 wire C13_6b_c6;
 assign oC13_6b[5:0] = iB18_6b[5:0];
 FA_Cir_Cin0 C136bm6 (.iA (iB18_6b[6]), .iB (iB21_7b[0]), .oS (oC13_6b[6]), .oC (C13_6b_c6));
 Ripple_Add_15bit C136bm7 (
	.iA (iB18_6b[20:7]),	.iB (iB21_7b[14:1]),
	.iC (C13_6b_c6),		.oS (oC13_6b[21:7]));
 
	//	12.10 [21:0]			11.4  [14:0]				11.10 [20:0]
 //assign   oC13_7a	=	{iB18_7a[14],iB18_7a,6'b0} - {iB21_6b[20],iB21_6b};
 wire C13_7a_c1, C13_7a_c2, C13_7a_c3, C13_7a_c4, C13_7a_c5;
 assign oC13_7a[0] = iB21_6b[0];
 FA_Cir_Cin0 C137am1 (.iA (~iB21_6b[1]), .iB (~iB21_6b[0]), .oS (oC13_7a[1]), .oC (C13_7a_c1));
 FA_Cir_Cin0 C137am2 (.iA (~iB21_6b[2]), .iB (C13_7a_c1),   .oS (oC13_7a[2]), .oC (C13_7a_c2));
 FA_Cir_Cin0 C137am3 (.iA (~iB21_6b[3]), .iB (C13_7a_c2),   .oS (oC13_7a[3]), .oC (C13_7a_c3));
 FA_Cir_Cin0 C137am4 (.iA (~iB21_6b[4]), .iB (C13_7a_c3),   .oS (oC13_7a[4]), .oC (C13_7a_c4));
 FA_Cir_Cin0 C137am5 (.iA (~iB21_6b[5]), .iB (C13_7a_c4),   .oS (oC13_7a[5]), .oC (C13_7a_c5));
 Ripple_Add_16bit C137am6 (
	.iA (iB18_7a),		.iB (~iB21_6b[20:6]),
	.iC (C13_7a_c5),	.oS (oC13_7a[21:6]));
 
	//	12.10 [21:0]			11.4  [14:0]				11.10 [20:0]
 //assign   oC13_7b	=	{iB18_7b[14],iB18_7b,6'b0} - {iB21_6a[20],iB21_6a};
 wire C13_7b_c1, C13_7b_c2, C13_7b_c3, C13_7b_c4, C13_7b_c5;
 assign oC13_7b[0] = iB21_6a[0];
 FA_Cir_Cin0 C137bm1 (.iA (~iB21_6a[1]), .iB (~iB21_6a[0]), .oS (oC13_7b[1]), .oC (C13_7b_c1));
 FA_Cir_Cin0 C137bm2 (.iA (~iB21_6a[2]), .iB (C13_7b_c1),   .oS (oC13_7b[2]), .oC (C13_7b_c2));
 FA_Cir_Cin0 C137bm3 (.iA (~iB21_6a[3]), .iB (C13_7b_c2),   .oS (oC13_7b[3]), .oC (C13_7b_c3));
 FA_Cir_Cin0 C137bm4 (.iA (~iB21_6a[4]), .iB (C13_7b_c3),   .oS (oC13_7b[4]), .oC (C13_7b_c4));
 FA_Cir_Cin0 C137bm5 (.iA (~iB21_6a[5]), .iB (C13_7b_c4),   .oS (oC13_7b[5]), .oC (C13_7b_c5));
 Ripple_Add_16bit C137bm6 (
	.iA (iB18_7b),		.iB (~iB21_6a[20:6]),
	.iC (C13_7b_c5),	.oS (oC13_7b[21:6]));
 
 /**********************************
 **************  C14  **************
 **********************************/
	//	12.7  [18:0]			11.7  [17:0]				11.5  [15:0]
 //assign   oC14_0a	=	{iB20_0a[17],iB20_0a}      + {iB19_1a[15],iB19_1a,2'b0};
 wire C14_0a_c3;
 assign oC14_0a[1:0] = iB20_0a[1:0];
 FA_Cir_Cin0 C140am2 (.iA (iB20_0a[2]), .iB (iB19_1a[0]), .oS (oC14_0a[2]), .oC (C14_0a_c3));
 Ripple_Add_16bit C140am3 (
	.iA (iB20_0a[17:3]),	.iB (iB19_1a[15:1]),
	.iC (C14_0a_c3),		.oS (oC14_0a[18:3]));
 
	//	12.7  [18:0]			11.5  [15:0]				11.7  [17:0]
 //assign   oC14_0b	=	{iB19_1b[15],iB19_1b,2'b0} - {iB20_0b[17],iB20_0b};
 wire C14_0b_c1;
 assign oC14_0b[0] = iB20_0b[0];
 FA_Cir_Cin0 C140bm1 (.iA (~iB20_0b[1]), .iB (~iB20_0b[0]), .oS (oC14_0b[1]), .oC (C14_0b_c1));
 Ripple_Add_17bit C140bm2 (
	.iA (iB19_1b),		.iB (~iB20_0b[17:2]),
	.iC (C14_0b_c1),	.oS (oC14_0b[18:2]));
 
	//	12.7  [18:0]			11.5  [15:0]				11.7  [17:0]
 //assign   oC14_1a	=	{iB20_1a[15],iB20_1a,2'b0} + {iB19_0b[17],iB19_0b};
 wire C14_1a_c3;
 assign oC14_1a[1:0] = iB19_0b[1:0];
 FA_Cir_Cin0 C141am2 (.iA (iB20_1a[0]), .iB (iB19_0b[2]), .oS (oC14_1a[2]), .oC (C14_1a_c3));
 Ripple_Add_16bit C141am3 (
	.iA (iB20_1a[15:1]),	.iB (iB19_0b[17:3]),
	.iC (C14_1a_c3),		.oS (oC14_1a[18:3]));
 
	//	12.7  [18:0]			11.5  [15:0]				11.7  [17:0]
 //assign   oC14_1b	=	{iB20_1b[15],iB20_1b,2'b0} + {iB19_0a[17],iB19_0a};
 wire C14_1b_c3;
 assign oC14_1b[1:0] = iB19_0a[1:0];
 FA_Cir_Cin0 C141bm2 (.iA (iB20_1b[0]), .iB (iB19_0a[2]), .oS (oC14_1b[2]), .oC (C14_1b_c3));
 Ripple_Add_16bit C141bm3 (
	.iA (iB20_1b[15:1]),	.iB (iB19_0a[17:3]),
	.iC (C14_1b_c3),		.oS (oC14_1b[18:3]));
 
	//	12.10 [21:0]			11.4  [14:0]				11.10 [20:0]
 //assign   oC14_2a	=	{iB20_2a[14],iB20_2a,6'b0} + {iB19_3b[20],iB19_3b};
 wire C14_2a_c6;
 assign oC14_2a[5:0] = iB19_3b[5:0];
 FA_Cir_Cin0 C142am6 (.iA (iB20_2a[0]), .iB (iB19_3b[6]), .oS (oC14_2a[6]), .oC (C14_2a_c6));
 Ripple_Add_15bit C142am7 (
	.iA (iB20_2a[14:1]),	.iB (iB19_3b[20:7]),
	.iC (C14_2a_c6),		.oS (oC14_2a[21:7]));
 
	//	12.10 [21:0]			11.4  [14:0]				11.10 [20:0]
 //assign   oC14_2b	=	{iB20_2b[14],iB20_2b,6'b0} + {iB19_3a[20],iB19_3a};
 wire C14_2b_c6;
 assign oC14_2b[5:0] = iB19_3a[5:0];
 FA_Cir_Cin0 C142bm6 (.iA (iB20_2b[0]), .iB (iB19_3a[6]), .oS (oC14_2b[6]), .oC (C14_2b_c6));
 Ripple_Add_15bit C142bm7 (
	.iA (iB20_2b[14:1]),	.iB (iB19_3a[20:7]),
	.iC (C14_2b_c6),		.oS (oC14_2b[21:7]));
 
	//	12.10 [21:0]			11.10 [20:0]				11.4  [14:0]
 //assign   oC14_3a	=	{iB20_3a[20],iB20_3a}      + {iB19_2a[14],iB19_2a,6'b0};
 wire C14_3a_c6;
 assign oC14_3a[5:0] = iB20_3a[5:0];
 FA_Cir_Cin0 C143am6 (.iA (iB20_3a[6]), .iB (iB19_2a[0]), .oS (oC14_3a[6]), .oC (C14_3a_c6));
 Ripple_Add_15bit C143am7 (
	.iA (iB20_3a[20:7]),	.iB (iB19_2a[14:1]),
	.iC (C14_3a_c6),		.oS (oC14_3a[21:7]));
 
	//	12.10 [21:0]			11.4  [14:0]				11.10 [20:0]
 //assign   oC14_3b	=	{iB19_2b[14],iB19_2b,6'b0} - {iB20_3b[20],iB20_3b};
 wire C14_3b_c1, C14_3b_c2, C14_3b_c3, C14_3b_c4, C14_3b_c5;
 assign oC14_3b[0] = iB20_3b[0];
 FA_Cir_Cin0 C143bm1 (.iA (~iB20_3b[1]), .iB (~iB20_3b[0]), .oS (oC14_3b[1]), .oC (C14_3b_c1));
 FA_Cir_Cin0 C143bm2 (.iA (~iB20_3b[2]), .iB (C14_3b_c1),   .oS (oC14_3b[2]), .oC (C14_3b_c2));
 FA_Cir_Cin0 C143bm3 (.iA (~iB20_3b[3]), .iB (C14_3b_c2),   .oS (oC14_3b[3]), .oC (C14_3b_c3));
 FA_Cir_Cin0 C143bm4 (.iA (~iB20_3b[4]), .iB (C14_3b_c3),   .oS (oC14_3b[4]), .oC (C14_3b_c4));
 FA_Cir_Cin0 C143bm5 (.iA (~iB20_3b[5]), .iB (C14_3b_c4),   .oS (oC14_3b[5]), .oC (C14_3b_c5));
 Ripple_Add_16bit C143bm6 (
	.iA (iB19_2b),		.iB (~iB20_3b[20:6]),
	.iC (C14_3b_c5),	.oS (oC14_3b[21:6]));
 
	//	12.9  [20:0]			11.3  [13:0]				11.9  [19:0]
 //assign   oC14_4a	=	{iB20_4a[13],iB20_4a,6'b0} - {iB19_5a[19],iB19_5a};
 wire C14_4a_c1, C14_4a_c2, C14_4a_c3, C14_4a_c4, C14_4a_c5;
 assign oC14_4a[0] = iB19_5a[0];
 FA_Cir_Cin0 C144am1 (.iA (~iB19_5a[1]), .iB (~iB19_5a[0]), .oS (oC14_4a[1]), .oC (C14_4a_c1));
 FA_Cir_Cin0 C144am2 (.iA (~iB19_5a[2]), .iB (C14_4a_c1),   .oS (oC14_4a[2]), .oC (C14_4a_c2));
 FA_Cir_Cin0 C144am3 (.iA (~iB19_5a[3]), .iB (C14_4a_c2),   .oS (oC14_4a[3]), .oC (C14_4a_c3));
 FA_Cir_Cin0 C144am4 (.iA (~iB19_5a[4]), .iB (C14_4a_c3),   .oS (oC14_4a[4]), .oC (C14_4a_c4));
 FA_Cir_Cin0 C144am5 (.iA (~iB19_5a[5]), .iB (C14_4a_c4),   .oS (oC14_4a[5]), .oC (C14_4a_c5));
 Ripple_Add_15bit C144am6 (
	.iA (iB20_4a),		.iB (~iB19_5a[19:6]),
	.iC (C14_4a_c5),	.oS (oC14_4a[20:6]));
 
	//	12.9  [20:0]			11.3  [13:0]				11.9  [19:0]
 //assign   oC14_4b	=	{iB20_4b[13],iB20_4b,6'b0} + {iB19_5b[19],iB19_5b};
 wire C14_4b_c6;
 assign oC14_4b[5:0] = iB19_5b[5:0];
 FA_Cir_Cin0 C144bm6 (.iA (iB20_4b[0]), .iB (iB19_5b[6]), .oS (oC14_4b[6]), .oC (C14_4b_c6));
 Ripple_Add_14bit C144bm7 (
	.iA (iB20_4b[13:1]),	.iB (iB19_5b[19:7]),
	.iC (C14_4b_c6),		.oS (oC14_4b[20:7]));
 
	//	12.9  [20:0]			11.9  [19:0]				11.3  [13:0]
 //assign   oC14_5a	=	{iB20_5a[19],iB20_5a}      - {iB19_4b[13],iB19_4b,6'b0};
 wire C14_5a_c6;
 assign oC14_5a[5:0] = iB20_5a[5:0];
 FA_Cir_Cin1 C145am6 (.iA (iB20_5a[6]), .iB (~iB19_4b[0]), .oS (oC14_5a[6]), .oC (C14_5a_c6));
 Ripple_Add_14bit C145am7 (
	.iA (iB20_5a[19:7]),	.iB (~iB19_4b[13:1]),
	.iC (C14_5a_c6),		.oS (oC14_5a[20:7]));
 
	//	12.9  [20:0]			11.9  [19:0]				11.3  [13:0]
 //assign   oC14_5b	=	{iB20_5b[19],iB20_5b}      - {iB19_4a[13],iB19_4a,6'b0};
 wire C14_5b_c6;
 assign oC14_5b[5:0] = iB20_5b[5:0];
 FA_Cir_Cin1 C145bm6 (.iA (iB20_5b[6]), .iB (~iB19_4a[0]), .oS (oC14_5b[6]), .oC (C14_5b_c6));
 Ripple_Add_14bit C145bm7 (
	.iA (iB20_5b[19:7]),	.iB (~iB19_4a[13:1]),
	.iC (C14_5b_c6),		.oS (oC14_5b[20:7]));
 
	//	12.10 [21:0]			11.5  [15:0]				11.10 [20:0]
 //assign   oC14_6a	=	{iB20_6a[15],iB20_6a,5'b0} - {iB19_7b[20],iB19_7b};
 wire C14_6a_c1, C14_6a_c2, C14_6a_c3, C14_6a_c4;
 assign oC14_6a[0] = iB19_7b[0];
 FA_Cir_Cin0 C146am1 (.iA (~iB19_7b[1]), .iB (~iB19_7b[0]), .oS (oC14_6a[1]), .oC (C14_6a_c1));
 FA_Cir_Cin0 C146am2 (.iA (~iB19_7b[2]), .iB (C14_6a_c1),   .oS (oC14_6a[2]), .oC (C14_6a_c2));
 FA_Cir_Cin0 C146am3 (.iA (~iB19_7b[3]), .iB (C14_6a_c2),   .oS (oC14_6a[3]), .oC (C14_6a_c3));
 FA_Cir_Cin0 C146am4 (.iA (~iB19_7b[4]), .iB (C14_6a_c3),   .oS (oC14_6a[4]), .oC (C14_6a_c4));
 Ripple_Add_17bit C146am5 (
	.iA (iB20_6a),		.iB (~iB19_7b[20:5]),
	.iC (C14_6a_c4),	.oS (oC14_6a[21:5]));
 
	//	12.10 [21:0]			11.5  [15:0]				11.10 [20:0]
 //assign   oC14_6b	=	{iB20_6b[15],iB20_6b,5'b0} - {iB19_7a[20],iB19_7a};
 wire C14_6b_c1, C14_6b_c2, C14_6b_c3, C14_6b_c4;
 assign oC14_6b[0] = iB19_7a[0];
 FA_Cir_Cin0 C146bm1 (.iA (~iB19_7a[1]), .iB (~iB19_7a[0]), .oS (oC14_6b[1]), .oC (C14_6b_c1));
 FA_Cir_Cin0 C146bm2 (.iA (~iB19_7a[2]), .iB (C14_6b_c1),   .oS (oC14_6b[2]), .oC (C14_6b_c2));
 FA_Cir_Cin0 C146bm3 (.iA (~iB19_7a[3]), .iB (C14_6b_c2),   .oS (oC14_6b[3]), .oC (C14_6b_c3));
 FA_Cir_Cin0 C146bm4 (.iA (~iB19_7a[4]), .iB (C14_6b_c3),   .oS (oC14_6b[4]), .oC (C14_6b_c4));
 Ripple_Add_17bit C146bm5 (
	.iA (iB20_6b),		.iB (~iB19_7a[20:5]),
	.iC (C14_6b_c4),	.oS (oC14_6b[21:5]));
 
	//	12.10 [21:0]			11.10 [20:0]				11.5  [15:0]
 //assign   oC14_7a	=	{iB20_7a[20],iB20_7a}      - {iB19_6a[15],iB19_6a,5'b0};
 wire C14_7a_c5;
 assign oC14_7a[4:0] = iB20_7a[4:0];
 FA_Cir_Cin1 C147am5 (.iA (iB20_7a[5]), .iB (~iB19_6a[0]), .oS (oC14_7a[5]), .oC (C14_7a_c5));
 Ripple_Add_16bit C147am6 (
	.iA (iB20_7a[20:6]),	.iB (~iB19_6a[15:1]),
	.iC (C14_7a_c5),		.oS (oC14_7a[21:6]));
 
	//	12.10 [21:0]			11.10 [20:0]				11.5  [15:0]
 //assign   oC14_7b	=	{iB20_7b[20],iB20_7b}      + {iB19_6b[15],iB19_6b,5'b0};
 wire C14_7b_c5;
 assign oC14_7b[4:0] = iB20_7b[4:0];
 FA_Cir_Cin0 C147bm5 (.iA (iB20_7b[5]), .iB (iB19_6b[0]), .oS (oC14_7b[5]), .oC (C14_7b_c5));
 Ripple_Add_16bit C147bm6 (
	.iA (iB20_7b[20:6]),	.iB (iB19_6b[15:1]),
	.iC (C14_7b_c5),		.oS (oC14_7b[21:6]));
 
 /**********************************
 **************  C15  **************
 **********************************/
	//	12.9  [20:0]			11.3  [13:0]				11.9  [19:0]
 //assign   oC15_0a	=	{iB22_0a[13],iB22_0a,6'b0} + {iB17_1a[19],iB17_1a};
 wire C15_0a_c6;
 assign oC15_0a[5:0] = iB17_1a[5:0];
 FA_Cir_Cin0 C150am6 (.iA (iB22_0a[0]), .iB (iB17_1a[6]), .oS (oC15_0a[6]), .oC (C15_0a_c6));
 Ripple_Add_14bit C150am7 (
	.iA (iB22_0a[13:1]),	.iB (iB17_1a[19:7]),
	.iC (C15_0a_c6),		.oS (oC15_0a[20:7]));
 
	//	12.9  [20:0]			11.9  [19:0]				11.3  [13:0]
 //assign   oC15_0b	=	{iB17_1b[19],iB17_1b}      - {iB22_0b[13],iB22_0b,6'b0};
 wire C15_0b_c6;
 assign oC15_0b[5:0] = iB17_1b[5:0];
 FA_Cir_Cin1 C150bm6 (.iA (iB17_1b[6]), .iB (~iB22_0b[0]), .oS (oC15_0b[6]), .oC (C15_0b_c6));
 Ripple_Add_14bit C150bm7 (
	.iA (iB17_1b[19:7]),	.iB (~iB22_0b[13:1]),
	.iC (C15_0b_c6),		.oS (oC15_0b[20:7]));
 
	//	12.9  [20:0]			11.9  [19:0]				11.3  [13:0]
 //assign   oC15_1a	=	{iB22_1a[19],iB22_1a}      + {iB17_0b[13],iB17_0b,6'b0};
 wire C15_1a_c6;
 assign oC15_1a[5:0] = iB22_1a[5:0];
 FA_Cir_Cin0 C151am6 (.iA (iB22_1a[6]), .iB (iB17_0b[0]), .oS (oC15_1a[6]), .oC (C15_1a_c6));
 Ripple_Add_14bit C151am7 (
	.iA (iB22_1a[19:7]),	.iB (iB17_0b[13:1]),
	.iC (C15_1a_c6),		.oS (oC15_1a[20:7]));
 
	//	12.9  [20:0]			11.9  [19:0]				11.3  [13:0]
 //assign   oC15_1b	=	{iB22_1b[19],iB22_1b}      + {iB17_0a[13],iB17_0a,6'b0};
 wire C15_1b_c6;
 assign oC15_1b[5:0] = iB22_1b[5:0];
 FA_Cir_Cin0 C151bm6 (.iA (iB22_1b[6]), .iB (iB17_0a[0]), .oS (oC15_1b[6]), .oC (C15_1b_c6));
 Ripple_Add_14bit C151bm7 (
	.iA (iB22_1b[19:7]),	.iB (iB17_0a[13:1]),
	.iC (C15_1b_c6),		.oS (oC15_1b[20:7]));
 
	//	12.10 [21:0]			11.5  [15:0]				11.10 [20:0]
 //assign   oC15_2a	=	{iB22_2a[15],iB22_2a,5'b0} + {iB17_3b[20],iB17_3b};
 wire C15_2a_c5;
 assign oC15_2a[4:0] = iB17_3b[4:0];
 FA_Cir_Cin0 C152am5 (.iA (iB22_2a[0]), .iB (iB17_3b[5]), .oS (oC15_2a[5]), .oC (C15_2a_c5));
 Ripple_Add_16bit C152am6 (
	.iA (iB22_2a[15:1]),	.iB (iB17_3b[20:6]),
	.iC (C15_2a_c5),		.oS (oC15_2a[21:6]));
 
	//	12.10 [21:0]			11.5  [15:0]				11.10 [20:0]
 //assign   oC15_2b	=	{iB22_2b[15],iB22_2b,5'b0} + {iB17_3a[20],iB17_3a};
 wire C15_2b_c5;
 assign oC15_2b[4:0] = iB17_3a[4:0];
 FA_Cir_Cin0 C152bm5 (.iA (iB22_2b[0]), .iB (iB17_3a[5]), .oS (oC15_2b[5]), .oC (C15_2b_c5));
 Ripple_Add_16bit C152bm6 (
	.iA (iB22_2b[15:1]),	.iB (iB17_3a[20:6]),
	.iC (C15_2b_c5),		.oS (oC15_2b[21:6]));
 
	//	12.10 [21:0]			11.10 [20:0]				11.5  [15:0]
 //assign   oC15_3a	=	{iB22_3a[20],iB22_3a}      + {iB17_2a[15],iB17_2a,5'b0};
 wire C15_3a_c5;
 assign oC15_3a[4:0] = iB22_3a[4:0];
 FA_Cir_Cin0 C153am5 (.iA (iB22_3a[5]), .iB (iB17_2a[0]), .oS (oC15_3a[5]), .oC (C15_3a_c5));
 Ripple_Add_16bit C153am6 (
	.iA (iB22_3a[20:6]),	.iB (iB17_2a[15:1]),
	.iC (C15_3a_c5),		.oS (oC15_3a[21:6]));
 
	//	12.10 [21:0]			11.5  [15:0]				11.10 [20:0]
 //assign   oC15_3b	=	{iB17_2b[15],iB17_2b,5'b0} - {iB22_3b[20],iB22_3b};
 wire C15_3b_c1, C15_3b_c2, C15_3b_c3, C15_3b_c4;
 assign oC15_3b[0] = iB22_3b[0];
 FA_Cir_Cin0 C153bm1 (.iA (~iB22_3b[1]), .iB (~iB22_3b[0]), .oS (oC15_3b[1]), .oC (C15_3b_c1));
 FA_Cir_Cin0 C153bm2 (.iA (~iB22_3b[2]), .iB (C15_3b_c1),   .oS (oC15_3b[2]), .oC (C15_3b_c2));
 FA_Cir_Cin0 C153bm3 (.iA (~iB22_3b[3]), .iB (C15_3b_c2),   .oS (oC15_3b[3]), .oC (C15_3b_c3));
 FA_Cir_Cin0 C153bm4 (.iA (~iB22_3b[4]), .iB (C15_3b_c3),   .oS (oC15_3b[4]), .oC (C15_3b_c4));
 Ripple_Add_17bit C153bm5 (
	.iA (iB17_2b),		.iB (~iB22_3b[20:5]),
	.iC (C15_3b_c4),	.oS (oC15_3b[21:5]));
 
	//	12.10 [21:0]			11.10 [20:0]				11.4  [14:0]
 //assign   oC15_4a	=	{iB22_4a[20],iB22_4a}      - {iB17_5a[14],iB17_5a,6'b0};
 wire C15_4a_c6;
 assign oC15_4a[5:0] = iB22_4a[5:0];
 FA_Cir_Cin1 C154am6 (.iA (iB22_4a[6]), .iB (~iB17_5a[0]), .oS (oC15_4a[6]), .oC (C15_4a_c6));
 Ripple_Add_15bit C154am7 (
	.iA (iB22_4a[20:7]),	.iB (~iB17_5a[14:1]),
	.iC (C15_4a_c6),		.oS (oC15_4a[21:7]));
 
	//	12.10 [21:0]			11.10 [20:0]				11.4  [14:0]
 //assign   oC15_4b	=	{iB22_4b[20],iB22_4b}      + {iB17_5b[14],iB17_5b,6'b0};
 wire C15_4b_c6;
 assign oC15_4b[5:0] = iB22_4b[5:0];
 FA_Cir_Cin0 C154bm6 (.iA (iB22_4b[6]), .iB (iB17_5b[0]), .oS (oC15_4b[6]), .oC (C15_4b_c6));
 Ripple_Add_15bit C154bm7 (
	.iA (iB22_4b[20:7]),	.iB (iB17_5b[14:1]),
	.iC (C15_4b_c6),		.oS (oC15_4b[21:7]));
 
	//	12.10 [21:0]			11.4  [14:0]				11.10 [20:0]
 //assign   oC15_5a	=	{iB22_5a[14],iB22_5a,6'b0} - {iB17_4b[20],iB17_4b};
 wire C15_5a_c1, C15_5a_c2, C15_5a_c3, C15_5a_c4, C15_5a_c5;
 assign oC15_5a[0] = iB17_4b[0];
 FA_Cir_Cin0 C155am1 (.iA (~iB17_4b[1]), .iB (~iB17_4b[0]), .oS (oC15_5a[1]), .oC (C15_5a_c1));
 FA_Cir_Cin0 C155am2 (.iA (~iB17_4b[2]), .iB (C15_5a_c1),   .oS (oC15_5a[2]), .oC (C15_5a_c2));
 FA_Cir_Cin0 C155am3 (.iA (~iB17_4b[3]), .iB (C15_5a_c2),   .oS (oC15_5a[3]), .oC (C15_5a_c3));
 FA_Cir_Cin0 C155am4 (.iA (~iB17_4b[4]), .iB (C15_5a_c3),   .oS (oC15_5a[4]), .oC (C15_5a_c4));
 FA_Cir_Cin0 C155am5 (.iA (~iB17_4b[5]), .iB (C15_5a_c4),   .oS (oC15_5a[5]), .oC (C15_5a_c5));
 Ripple_Add_16bit C155am6 (
	.iA (iB22_5a),		.iB (~iB17_4b[20:6]),
	.iC (C15_5a_c5),	.oS (oC15_5a[21:6]));
 
	//	12.10 [21:0]			11.4  [14:0]				11.10 [20:0]
 //assign   oC15_5b	=	{iB22_5b[14],iB22_5b,6'b0} - {iB17_4a[20],iB17_4a};
 wire C15_5b_c1, C15_5b_c2, C15_5b_c3, C15_5b_c4, C15_5b_c5;
 assign oC15_5b[0] = iB17_4a[0];
 FA_Cir_Cin0 C155bm1 (.iA (~iB17_4a[1]), .iB (~iB17_4a[0]), .oS (oC15_5b[1]), .oC (C15_5b_c1));
 FA_Cir_Cin0 C155bm2 (.iA (~iB17_4a[2]), .iB (C15_5b_c1),   .oS (oC15_5b[2]), .oC (C15_5b_c2));
 FA_Cir_Cin0 C155bm3 (.iA (~iB17_4a[3]), .iB (C15_5b_c2),   .oS (oC15_5b[3]), .oC (C15_5b_c3));
 FA_Cir_Cin0 C155bm4 (.iA (~iB17_4a[4]), .iB (C15_5b_c3),   .oS (oC15_5b[4]), .oC (C15_5b_c4));
 FA_Cir_Cin0 C155bm5 (.iA (~iB17_4a[5]), .iB (C15_5b_c4),   .oS (oC15_5b[5]), .oC (C15_5b_c5));
 Ripple_Add_16bit C155bm6 (
	.iA (iB22_5b),		.iB (~iB17_4a[20:6]),
	.iC (C15_5b_c5),	.oS (oC15_5b[21:6]));
 
	//	12.7  [18:0]			11.7  [17:0]				11.5  [15:0]
 //assign   oC15_6a	=	{iB22_6a[17],iB22_6a}      - {iB17_7a[15],iB17_7a,2'b0};
 wire C15_6a_c2;
 assign oC15_6a[1:0] = iB22_6a[1:0];
 FA_Cir_Cin1 C156am2 (.iA (iB22_6a[2]), .iB (~iB17_7a[0]), .oS (oC15_6a[2]), .oC (C15_6a_c2));
 Ripple_Add_16bit C156am3 (
	.iA (iB22_6a[17:3]),	.iB (~iB17_7a[15:1]),
	.iC (C15_6a_c2),		.oS (oC15_6a[18:3]));
 
	//	12.7  [18:0]			11.7  [17:0]				11.5  [15:0]
 //assign   oC15_6b	=	{iB22_6b[17],iB22_6b}      + {iB17_7b[15],iB17_7b,2'b0};
 wire C15_6b_c3;
 assign oC15_6b[1:0] = iB22_6b[1:0];
 FA_Cir_Cin0 C156bm2 (.iA (iB22_6b[2]), .iB (iB17_7b[0]), .oS (oC15_6b[2]), .oC (C15_6b_c3));
 Ripple_Add_16bit C156bm3 (
	.iA (iB22_6b[17:3]),	.iB (iB17_7b[15:1]),
	.iC (C15_6b_c3),		.oS (oC15_6b[18:3]));
 
	//	12.7  [18:0]			11.5  [15:0]				11.7  [17:0]
 //assign   oC15_7a	=	{iB22_7a[15],iB22_7a,2'b0} - {iB17_6b[17],iB17_6b};
 wire C15_7a_c1;
 assign oC15_7a[0] = iB17_6b[0];
 FA_Cir_Cin0 C157am1 (.iA (~iB17_6b[1]), .iB (~iB17_6b[0]), .oS (oC15_7a[1]), .oC (C15_7a_c1));
 Ripple_Add_17bit C157am2 (
	.iA (iB22_7a),		.iB (~iB17_6b[17:2]),
	.iC (C15_7a_c1),	.oS (oC15_7a[18:2]));
 
	//	12.7  [18:0]			11.5  [15:0]				11.7  [17:0]
 //assign   oC15_7b	=	{iB22_7b[15],iB22_7b,2'b0} - {iB17_6a[17],iB17_6a};
 wire C15_7b_c1;
 assign oC15_7b[0] = iB17_6a[0];
 FA_Cir_Cin0 C157bm1 (.iA (~iB17_6a[1]), .iB (~iB17_6a[0]), .oS (oC15_7b[1]), .oC (C15_7b_c1));
 Ripple_Add_17bit C157bm2 (
	.iA (iB22_7b),		.iB (~iB17_6a[17:2]),
	.iC (C15_7b_c1),	.oS (oC15_7b[18:2]));

endmodule

module ACor_DCT_32p_S4 (
	// Input Signals
	input	[10:0]	/*11.0 */	iC0, iC1, iC2, iC3, iC4, iC5, iC6, iC7,
	
	input	[19:0]	/*12.8 */	iC8_0a, iC8_0b, iC9_3a, iC9_3b, iC10_3a, iC10_3b, iC11_0a, iC11_0b,
	input	[17:0]	/*12.6 */	iC8_3a, iC8_3b, iC9_1a, iC9_1b, iC10_1a, iC10_1b, iC11_3a, iC11_3b,
	input	[17:0]	/*12.6 */	iC8_2a, iC8_2b, iC9_0a, iC9_0b, iC10_0a, iC10_0b, iC11_2a, iC11_2b,
	input	[14:0]	/*12.3 */	iC8_1a, iC8_1b, iC9_2a, iC9_2b, iC10_2a, iC10_2b, iC11_1a, iC11_1b,
	
	input	[21:0]	/*12.10*/	iC12_0a, iC12_0b, iC12_1a, iC12_1b,
	input	[18:0]	/*12.7 */	iC12_2a, iC12_2b, iC12_3a, iC12_3b,
	input	[21:0]	/*12.10*/	iC12_4a, iC12_4b, iC12_5a, iC12_5b,
	input	[20:0]	/*12.9 */	iC12_6a, iC12_6b, iC12_7a, iC12_7b,
	
	input	[21:0]	/*12.10*/	iC13_0a, iC13_0b, iC13_1a, iC13_1b,
	input	[20:0]	/*12.9 */	iC13_2a, iC13_2b, iC13_3a, iC13_3b,
	input	[18:0]	/*12.7 */	iC13_4a, iC13_4b, iC13_5a, iC13_5b,
	input	[21:0]	/*12.10*/	iC13_6a, iC13_6b, iC13_7a, iC13_7b,
	
	input	[18:0]	/*12.7 */	iC14_0a, iC14_0b, iC14_1a, iC14_1b,
	input	[21:0]	/*12.10*/	iC14_2a, iC14_2b, iC14_3a, iC14_3b,
	input	[20:0]	/*12.9 */	iC14_4a, iC14_4b, iC14_5a, iC14_5b,
	input	[21:0]	/*12.10*/	iC14_6a, iC14_6b, iC14_7a, iC14_7b,
	
	input	[20:0]	/*12.9 */	iC15_0a, iC15_0b, iC15_1a, iC15_1b,
	input	[21:0]	/*12.10*/	iC15_2a, iC15_2b, iC15_3a, iC15_3b,
	input	[21:0]	/*12.10*/	iC15_4a, iC15_4b, iC15_5a, iC15_5b,
	input	[18:0]	/*12.7 */	iC15_6a, iC15_6b, iC15_7a, iC15_7b,
	
	// Output Signals
	output	[11:0]	/*12.0 */	oD0, oD1, oD2, oD3,
	
	output	[18:0]	/*13.6 */	oD4_0a, oD4_0b, oD5_1a, oD5_1b,
	output	[16:0]	/*13.4 */	oD4_1a, oD4_1b, oD5_0a, oD5_0b,
 
	output	[20:0]	/*13.8 */	oD6_0a, oD6_0b, oD6_1a, oD6_1b,
	output	[18:0]	/*13.6 */	oD6_2a, oD6_2b, oD6_3a, oD6_3b,
	
	output	[18:0]	/*13.6 */	oD7_0a, oD7_0b, oD7_1a, oD7_1b,
	output	[20:0]	/*13.8 */	oD7_2a, oD7_2b, oD7_3a, oD7_3b,
	
	output	[22:0]	/*13.10*/	oD8_0a, oD8_0b, oD8_1a, oD8_1b,
								oD8_2a, oD8_2b, oD8_3a, oD8_3b,
								oD8_4a, oD8_4b, oD8_5a, oD8_5b,
								oD8_6a, oD8_6b, oD8_7a, oD8_7b,
	
	output	[22:0]	/*13.10*/	oD9_0a, oD9_0b, oD9_1a, oD9_1b,
								oD9_2a, oD9_2b, oD9_3a, oD9_3b,
								oD9_4a, oD9_4b, oD9_5a, oD9_5b,
								oD9_6a, oD9_6b, oD9_7a, oD9_7b
);

 // assign oD0 = {iC0[10],iC0} + {iC3[10],iC3};
 wire D0_c0;
 FA_Cir_Cin0 D0m0 (.iA (iC0[0]), .iB (iC3[0]), .oS (oD0[0]), .oC (D0_c0));
 Ripple_Add_11bit D0m1 (
	.iA (iC0[10:1]),.iB (iC3[10:1]),
	.iC (D0_c0),	.oS (oD0[11:1]));
 
 // assign oD1 = {iC1[10],iC1} + {iC2[10],iC2};
 wire D1_c0;
 FA_Cir_Cin0 D1m0 (.iA (iC1[0]), .iB (iC2[0]), .oS (oD1[0]), .oC (D1_c0));
 Ripple_Add_11bit D1m1 (
	.iA (iC1[10:1]),.iB (iC2[10:1]),
	.iC (D1_c0),	.oS (oD1[11:1]));
 
 // assign oD2 = {iC1[10],iC1} - {iC2[10],iC2};
 wire D2_c0;
 FA_Cir_Cin1 D2m0 (.iA (iC1[0]), .iB (~iC2[0]), .oS (oD2[0]), .oC (D2_c0));
 Ripple_Add_11bit D2m1 (
	.iA (iC1[10:1]),.iB (~iC2[10:1]),
	.iC (D2_c0),	.oS (oD2[11:1]));
 
 // assign oD3 = {iC0[10],iC0} - {iC3[10],iC3};
 wire D3_c0;
 FA_Cir_Cin1 D3m0 (.iA (iC0[0]), .iB (~iC3[0]), .oS (oD3[0]), .oC (D3_c0));
 Ripple_Add_11bit D3m1 (
	.iA (iC0[10:1]),.iB (~iC3[10:1]),
	.iC (D3_c0),	.oS (oD3[11:1]));
 
 ACor_DCT_32p_1to3_pi16_2Stg D4m0 (
	// Input Signals
	.iA (iC4), .iB (iC7),
	
	// Output Signals
	.o0a (oD4_0a), .o0b (oD4_0b), .o1a (oD4_1a), .o1b (oD4_1b));

 ACor_DCT_32p_1to3_pi16_2Stg D5m0 (
	// Input Signals
	.iA (iC6), .iB (iC5),
	
	// Output Signals
	.o0a (oD5_1a), .o0b (oD5_1b), .o1a (oD5_0a), .o1b (oD5_0b));

 /*********************************
 **************  D6  **************
 *********************************/
	//	13.8  [20:0]			12.8  [19:0]				12.3  [14:0]
 //assign   oD6_0a	=	{ iC8_0a[19], iC8_0a}      + {iC11_1a[14],iC11_1a,5'b0};
 wire D6_0a_c5;
 assign oD6_0a[4:0] = iC8_0a[4:0];
 FA_Cir_Cin0 D60am5 (.iA (iC8_0a[5]), .iB (iC11_1a[0]), .oS (oD6_0a[5]), .oC (D6_0a_c5));
 Ripple_Add_15bit D60am6 (
	.iA (iC8_0a[19:6]),	.iB (iC11_1a[14:1]),
	.iC (D6_0a_c5),		.oS (oD6_0a[20:6]));
 
	//	13.8  [20:0]			12.3  [14:0]				12.8  [19:0]
 //assign   oD6_0b	=	{iC11_1b[14],iC11_1b,5'b0} - { iC8_0b[19], iC8_0b};
 wire D6_0b_c1, D6_0b_c2, D6_0b_c3, D6_0b_c4;
 assign oD6_0b[0] = iC8_0b[0];
 FA_Cir_Cin0 D60bm1 (.iA (~iC8_0b[1]), .iB (~iC8_0b[0]), .oS (oD6_0b[1]), .oC (D6_0b_c1));
 FA_Cir_Cin0 D60bm2 (.iA (~iC8_0b[2]), .iB (D6_0b_c1),   .oS (oD6_0b[2]), .oC (D6_0b_c2));
 FA_Cir_Cin0 D60bm3 (.iA (~iC8_0b[3]), .iB (D6_0b_c2),   .oS (oD6_0b[3]), .oC (D6_0b_c3));
 FA_Cir_Cin0 D60bm4 (.iA (~iC8_0b[4]), .iB (D6_0b_c3),   .oS (oD6_0b[4]), .oC (D6_0b_c4));
 Ripple_Add_16bit D60bm5 (
	.iA (iC11_1b),	.iB (~iC8_0b[19:5]),
	.iC (D6_0b_c4),	.oS (oD6_0b[20:5]));
 
	//	13.8  [20:0]			12.3  [14:0]				12.8  [19:0]
 //assign   oD6_1a	=	{ iC8_1a[14], iC8_1a,5'b0} + {iC11_0b[19],iC11_0b};
 wire D6_1a_c5;
 assign oD6_1a[4:0] = iC11_0b[4:0];
 FA_Cir_Cin0 D61am5 (.iA (iC8_1a[0]), .iB (iC11_0b[5]), .oS (oD6_1a[5]), .oC (D6_1a_c5));
 Ripple_Add_15bit D61am6 (
	.iA (iC8_1a[14:1]),	.iB (iC11_0b[19:6]),
	.iC (D6_1a_c5),		.oS (oD6_1a[20:6]));
 
	//	13.8  [20:0]			12.3  [14:0]				12.8  [19:0]
 //assign   oD6_1b	=	{ iC8_1b[14], iC8_1b,5'b0} + {iC11_0a[19],iC11_0a};
 wire D6_1b_c5;
 assign oD6_1b[4:0] = iC11_0a[4:0];
 FA_Cir_Cin0 D61bm5 (.iA (iC8_1b[0]), .iB (iC11_0a[5]), .oS (oD6_1b[5]), .oC (D6_1b_c5));
 Ripple_Add_15bit D61bm6 (
	.iA (iC8_1b[14:1]),	.iB (iC11_0a[19:6]),
	.iC (D6_1b_c5),		.oS (oD6_1b[20:6]));
 
	//	13.6  [18:0]			12.6  [17:0]				12.6  [17:0]
 //assign   oD6_2a	=	{ iC8_2a[17], iC8_2a}      - {iC11_3a[17],iC11_3a};
 wire D6_2a_c0;
 FA_Cir_Cin1 D62am1 (.iA (iC8_2a[0]), .iB (~iC11_3a[0]), .oS (oD6_2a[0]), .oC (D6_2a_c0));
 Ripple_Add_18bit D62am2 (
	.iA (iC8_2a[17:1]),	.iB (~iC11_3a[17:1]),
	.iC (D6_2a_c0),		.oS (oD6_2a[18:1]));
 
	//	13.6  [18:0]			12.6  [17:0]				12.6  [17:0]
 //assign   oD6_2b	=	{ iC8_2b[17], iC8_2b}      + {iC11_3b[17],iC11_3b};
 wire D6_2b_c0;
 FA_Cir_Cin0 D62bm0 (.iA (iC8_2b[0]), .iB (iC11_3b[0]), .oS (oD6_2b[0]), .oC (D6_2b_c0));
 Ripple_Add_18bit D62bm1 (
	.iA (iC8_2b[17:1]),	.iB (iC11_3b[17:1]),
	.iC (D6_2b_c0),		.oS (oD6_2b[18:1]));
 
	//	13.6  [18:0]			12.6  [17:0]				12.6  [17:0]
 //assign   oD6_3a	=	{ iC8_3a[17], iC8_3a}      - {iC11_2b[17],iC11_2b};
 wire D6_3a_c0;
 FA_Cir_Cin1 D63am1 (.iA (iC8_3a[0]), .iB (~iC11_2b[0]), .oS (oD6_3a[0]), .oC (D6_3a_c0));
 Ripple_Add_18bit D63am2 (
	.iA (iC8_3a[17:1]),	.iB (~iC11_2b[17:1]),
	.iC (D6_3a_c0),		.oS (oD6_3a[18:1]));
 
	//	13.6  [18:0]			12.6  [17:0]				12.6  [17:0]
 //assign   oD6_3b	=	{ iC8_3b[17], iC8_3b}      - {iC11_2a[17],iC11_2a};
 wire D6_3b_c0;
 FA_Cir_Cin1 D63bm1 (.iA (iC8_3b[0]), .iB (~iC11_2a[0]), .oS (oD6_3b[0]), .oC (D6_3b_c0));
 Ripple_Add_18bit D63bm2 (
	.iA (iC8_3b[17:1]),	.iB (~iC11_2a[17:1]),
	.iC (D6_3b_c0),		.oS (oD6_3b[18:1]));
 
 /*********************************
 **************  D7  **************
 *********************************/
	//	13.6  [18:0]			12.6  [17:0]				12.6  [17:0]
 //assign   oD7_0a	=	{iC10_0a[17],iC10_0a}      + { iC9_1a[17], iC9_1a};
 wire D7_0a_c0;
 FA_Cir_Cin0 D70am0 (.iA (iC10_0a[0]), .iB (iC9_1a[0]), .oS (oD7_0a[0]), .oC (D7_0a_c0));
 Ripple_Add_18bit D70am1 (
	.iA (iC10_0a[17:1]),	.iB (iC9_1a[17:1]),
	.iC (D7_0a_c0),			.oS (oD7_0a[18:1]));
 
	//	13.6  [18:0]			12.6  [17:0]				12.6  [17:0]
 //assign   oD7_0b	=	{ iC9_1b[17], iC9_1b}      - {iC10_0b[17],iC10_0b};
 wire D7_0b_c0;
 FA_Cir_Cin1 D70bm1 (.iA (iC9_1b[0]), .iB (~iC10_0b[0]), .oS (oD7_0b[0]), .oC (D7_0b_c0));
 Ripple_Add_18bit D70bm2 (
	.iA (iC9_1b[17:1]),	.iB (~iC10_0b[17:1]),
	.iC (D7_0b_c0),		.oS (oD7_0b[18:1]));
 
	//	13.6  [18:0]			12.6  [17:0]				12.6  [17:0]
 //assign   oD7_1a	=	{iC10_1a[17],iC10_1a}      + { iC9_0b[17], iC9_0b};
 wire D7_1a_c0;
 FA_Cir_Cin0 D71am0 (.iA (iC10_1a[0]), .iB (iC9_0b[0]), .oS (oD7_1a[0]), .oC (D7_1a_c0));
 Ripple_Add_18bit D71am1 (
	.iA (iC10_1a[17:1]),	.iB (iC9_0b[17:1]),
	.iC (D7_1a_c0),			.oS (oD7_1a[18:1]));
 
	//	13.6  [18:0]			12.6  [17:0]				12.6  [17:0]
 //assign   oD7_1b	=	{iC10_1b[17],iC10_1b}      + { iC9_0a[17], iC9_0a};
 wire D7_1b_c0;
 FA_Cir_Cin0 D71bm0 (.iA (iC10_1b[0]), .iB (iC9_0a[0]), .oS (oD7_1b[0]), .oC (D7_1b_c0));
 Ripple_Add_18bit D71bm1 (
	.iA (iC10_1b[17:1]),	.iB (iC9_0a[17:1]),
	.iC (D7_1b_c0),			.oS (oD7_1b[18:1]));
 
	//	13.8  [20:0]			12.3  [14:0]				12.8  [19:0]
 //assign   oD7_2a	=	{iC10_2a[14],iC10_2a,5'b0} - { iC9_3b[19], iC9_3b};
 wire D7_2a_c1, D7_2a_c2, D7_2a_c3, D7_2a_c4;
 assign oD7_2a[0] = iC9_3b[0];
 FA_Cir_Cin0 D72am1 (.iA (~iC9_3b[1]), .iB (~iC9_3b[0]), .oS (oD7_2a[1]), .oC (D7_2a_c1));
 FA_Cir_Cin0 D72am2 (.iA (~iC9_3b[2]), .iB (D7_2a_c1),   .oS (oD7_2a[2]), .oC (D7_2a_c2));
 FA_Cir_Cin0 D72am3 (.iA (~iC9_3b[3]), .iB (D7_2a_c2),   .oS (oD7_2a[3]), .oC (D7_2a_c3));
 FA_Cir_Cin0 D72am4 (.iA (~iC9_3b[4]), .iB (D7_2a_c3),   .oS (oD7_2a[4]), .oC (D7_2a_c4));
 Ripple_Add_16bit D72am5 (
	.iA (iC10_2a),	.iB (~iC9_3b[19:5]),
	.iC (D7_2a_c4),	.oS (oD7_2a[20:5]));
 
	//	13.8  [20:0]			12.3  [14:0]				12.8  [19:0]
 //assign   oD7_2b	=	{iC10_2b[14],iC10_2b,5'b0} - { iC9_3a[19], iC9_3a};
 wire D7_2b_c1, D7_2b_c2, D7_2b_c3, D7_2b_c4;
 assign oD7_2b[0] = iC9_3a[0];
 FA_Cir_Cin0 D72bm1 (.iA (~iC9_3a[1]), .iB (~iC9_3a[0]), .oS (oD7_2b[1]), .oC (D7_2b_c1));
 FA_Cir_Cin0 D72bm2 (.iA (~iC9_3a[2]), .iB (D7_2b_c1),   .oS (oD7_2b[2]), .oC (D7_2b_c2));
 FA_Cir_Cin0 D72bm3 (.iA (~iC9_3a[3]), .iB (D7_2b_c2),   .oS (oD7_2b[3]), .oC (D7_2b_c3));
 FA_Cir_Cin0 D72bm4 (.iA (~iC9_3a[4]), .iB (D7_2b_c3),   .oS (oD7_2b[4]), .oC (D7_2b_c4));
 Ripple_Add_16bit D72bm5 (
	.iA (iC10_2b),	.iB (~iC9_3a[19:5]),
	.iC (D7_2b_c4),	.oS (oD7_2b[20:5]));
 
	//	13.8  [20:0]			12.8  [19:0]				12.3  [14:0]
 //assign   oD7_3a	=	{iC10_3a[19],iC10_3a}      - { iC9_2a[14], iC9_2a,5'b0};
 wire D7_3a_c5;
 assign oD7_3a[4:0] = iC10_3a[4:0];
 FA_Cir_Cin1 D73am5 (.iA (iC10_3a[5]), .iB (~iC9_2a[0]), .oS (oD7_3a[5]), .oC (D7_3a_c5));
 Ripple_Add_15bit D73am6 (
	.iA (iC10_3a[19:6]),	.iB (~iC9_2a[14:1]),
	.iC (D7_3a_c5),			.oS (oD7_3a[20:6]));
 
	//	13.8  [20:0]			12.8  [19:0]				12.3  [14:0]
 //assign   oD7_3b	=	{iC10_3b[19],iC10_3b}      + { iC9_2b[14], iC9_2b,5'b0};
 wire D7_3b_c5;
 assign oD7_3b[4:0] = iC10_3b[4:0];
 FA_Cir_Cin0 D73bm5 (.iA (iC10_3b[5]), .iB (iC9_2b[0]), .oS (oD7_3b[5]), .oC (D7_3b_c5));
 Ripple_Add_15bit D73bm6 (
	.iA (iC10_3b[19:6]),	.iB (iC9_2b[14:1]),
	.iC (D7_3b_c5),			.oS (oD7_3b[20:6]));

 /*********************************
 **************  D8  **************
 *********************************/
	//	13.10 [22:0]			12.10 [21:0]				12.7  [18:0]
 //assign   oD8_0a	=	{iC12_0a[21],iC12_0a}      + {iC14_0a[18],iC14_0a,3'b0};
 wire D8_0a_c3;
 assign oD8_0a[2:0] = iC12_0a[2:0];
 FA_Cir_Cin0 D80am3 (.iA (iC12_0a[3]), .iB (iC14_0a[0]), .oS (oD8_0a[3]), .oC (D8_0a_c3));
 Ripple_Add_19bit D80am4 (
	.iA (iC12_0a[21:4]),	.iB (iC14_0a[18:1]),
	.iC (D8_0a_c3),			.oS (oD8_0a[22:4]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.7  [18:0]
 //assign   oD8_0b	=	{iC12_0b[21],iC12_0b}      + {iC14_0b[18],iC14_0b,3'b0};
 wire D8_0b_c3;
 assign oD8_0b[2:0] = iC12_0b[2:0];
 FA_Cir_Cin0 D80bm3 (.iA (iC12_0b[3]), .iB (iC14_0b[0]), .oS (oD8_0b[3]), .oC (D8_0b_c3));
 Ripple_Add_19bit D80bm4 (
	.iA (iC12_0b[21:4]),	.iB (iC14_0b[18:1]),
	.iC (D8_0b_c3),			.oS (oD8_0b[22:4]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.7  [18:0]
 //assign   oD8_1a	=	{iC12_1a[21],iC12_1a}      + {iC14_1a[18],iC14_1a,3'b0};
 wire D8_1a_c3;
 assign oD8_1a[2:0] = iC12_1a[2:0];
 FA_Cir_Cin0 D81am3 (.iA (iC12_1a[3]), .iB (iC14_1a[0]), .oS (oD8_1a[3]), .oC (D8_1a_c3));
 Ripple_Add_19bit D81am4 (
	.iA (iC12_1a[21:4]),	.iB (iC14_1a[18:1]),
	.iC (D8_1a_c3),			.oS (oD8_1a[22:4]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.7  [18:0]
 //assign   oD8_1b	=	{iC12_1b[21],iC12_1b}      + {iC14_1b[18],iC14_1b,3'b0};
 wire D8_1b_c3;
 assign oD8_1b[2:0] = iC12_1b[2:0];
 FA_Cir_Cin0 D81bm3 (.iA (iC12_1b[3]), .iB (iC14_1b[0]), .oS (oD8_1b[3]), .oC (D8_1b_c3));
 Ripple_Add_19bit D81bm4 (
	.iA (iC12_1b[21:4]),	.iB (iC14_1b[18:1]),
	.iC (D8_1b_c3),			.oS (oD8_1b[22:4]));
 
	//	13.10 [22:0]			12.7  [18:0]				12.10 [21:0]
 //assign   oD8_2a	=	{iC12_2a[18],iC12_2a,3'b0} - {iC14_2a[21],iC14_2a};
 wire D8_2a_c1, D8_2a_c2;
 assign oD8_2a[0] = iC14_2a[0];
 FA_Cir_Cin0 D82am1 (.iA (~iC14_2a[1]), .iB (~iC14_2a[0]), .oS (oD8_2a[1]), .oC (D8_2a_c1));
 FA_Cir_Cin0 D82am2 (.iA (~iC14_2a[2]), .iB (D8_2a_c1),    .oS (oD8_2a[2]), .oC (D8_2a_c2));
 Ripple_Add_20bit D82am3 (
	.iA (iC12_2a),	.iB (~iC14_2a[21:3]),
	.iC (D8_2a_c2),	.oS (oD8_2a[22:3]));
 
	//	13.10 [22:0]			12.7  [18:0]				12.10 [21:0]
 //assign   oD8_2b	=	{iC12_2b[18],iC12_2b,3'b0} - {iC14_2b[21],iC14_2b};
 wire D8_2b_c1, D8_2b_c2;
 assign oD8_2b[0] = iC14_2b[0];
 FA_Cir_Cin0 D82bm1 (.iA (~iC14_2b[1]), .iB (~iC14_2b[0]), .oS (oD8_2b[1]), .oC (D8_2b_c1));
 FA_Cir_Cin0 D82bm2 (.iA (~iC14_2b[2]), .iB (D8_2b_c1),    .oS (oD8_2b[2]), .oC (D8_2b_c2));
 Ripple_Add_20bit D82bm3 (
	.iA (iC12_2b),	.iB (~iC14_2b[21:3]),
	.iC (D8_2b_c2),	.oS (oD8_2b[22:3]));
 
	//	13.10 [22:0]			12.7  [18:0]				12.10 [21:0]
 //assign   oD8_3a	=	{iC12_3a[18],iC12_3a,3'b0} + {iC14_3b[21],iC14_3b};
 wire D8_3a_c3;
 assign oD8_3a[2:0] = iC14_3b[2:0];
 FA_Cir_Cin0 D83am3 (.iA (iC12_3a[0]), .iB (iC14_3b[3]), .oS (oD8_3a[3]), .oC (D8_3a_c3));
 Ripple_Add_19bit D83am4 (
	.iA (iC12_3a[18:1]),	.iB (iC14_3b[21:4]),
	.iC (D8_3a_c3),			.oS (oD8_3a[22:4]));
 
	//	13.10 [22:0]			12.7  [18:0]				12.10 [21:0]
 //assign   oD8_3b	=	{iC12_3b[18],iC12_3b,3'b0} - {iC14_3a[21],iC14_3a};
 wire D8_3b_c1, D8_3b_c2;
 assign oD8_3b[0] = iC14_3a[0];
 FA_Cir_Cin0 D83bm1 (.iA (~iC14_3a[1]), .iB (~iC14_3a[0]), .oS (oD8_3b[1]), .oC (D8_3b_c1));
 FA_Cir_Cin0 D83bm2 (.iA (~iC14_3a[2]), .iB (D8_3b_c1),    .oS (oD8_3b[2]), .oC (D8_3b_c2));
 Ripple_Add_20bit D83bm3 (
	.iA (iC12_3b),	.iB (~iC14_3a[21:3]),
	.iC (D8_3b_c2),	.oS (oD8_3b[22:3]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.9  [20:0]
 //assign   oD8_4a	=	{iC12_4a[21],iC12_4a}      + {iC14_4b[20],iC14_4b,1'b0};
 wire D8_4a_c1;
 assign oD8_4a[0] = iC12_4a[0];
 FA_Cir_Cin0 D84am0 (.iA (iC12_4a[1]), .iB (iC14_4b[0]), .oS (oD8_4a[1]), .oC (D8_4a_c1));
 Ripple_Add_21bit D84am1 (
	.iA (iC12_4a[21:2]),	.iB (iC14_4b[20:1]),
	.iC (D8_4a_c1),			.oS (oD8_4a[22:2]));
 
	//	13.10 [22:0]			12.9  [20:0]				12.10 [21:0]
 //assign   oD8_4b	=	{iC14_4a[20],iC14_4a,1'b0} - {iC12_4b[21],iC12_4b};
 assign oD8_4b[0] = iC12_4b[0];
 Ripple_Add_22bit D84bm0 (
	.iA (iC14_4a),		.iB (~iC12_4b[21:1]),
	.iC (~iC12_4b[0]),	.oS (oD8_4b[22:1]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.9  [20:0]
 //assign   oD8_5a	=	{iC12_5a[21],iC12_5a}      - {iC14_5b[20],iC14_5b,1'b0};
 wire D8_5a_c1;
 assign oD8_5a[0] = iC12_5a[0];
 FA_Cir_Cin1 D85am1 (.iA (iC12_5a[1]), .iB (~iC14_5b[0]), .oS (oD8_5a[1]), .oC (D8_5a_c1));
 Ripple_Add_21bit D85am2 (
	.iA (iC12_5a[21:2]),	.iB (~iC14_5b[20:1]),
	.iC (D8_5a_c1),			.oS (oD8_5a[22:2]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.9  [20:0]
 //assign   oD8_5b	=	{iC12_5b[21],iC12_5b}      + {iC14_5a[20],iC14_5a,1'b0};
 wire D8_5b_c1;
 assign oD8_5b[0] = iC12_5b[0];
 FA_Cir_Cin0 D85bm0 (.iA (iC12_5b[1]), .iB (iC14_5a[0]), .oS (oD8_5b[1]), .oC (D8_5b_c1));
 Ripple_Add_21bit D85bm1 (
	.iA (iC12_5b[21:2]),	.iB (iC14_5a[20:1]),
	.iC (D8_5b_c1),			.oS (oD8_5b[22:2]));
 
	//	13.10 [22:0]			12.9  [20:0]				12.10 [21:0]
 //assign   oD8_6a	=	{iC12_6a[20],iC12_6a,1'b0} + {iC14_6b[21],iC14_6b};
 wire D8_6a_c1;
 assign oD8_6a[0] = iC14_6b[0];
 FA_Cir_Cin0 D86am0 (.iA (iC12_6a[0]), .iB (iC14_6b[1]), .oS (oD8_6a[1]), .oC (D8_6a_c1));
 Ripple_Add_21bit D86am1 (
	.iA (iC12_6a[20:1]),	.iB (iC14_6b[21:2]),
	.iC (D8_6a_c1),			.oS (oD8_6a[22:2]));
 
	//	13.10 [22:0]			12.9  [20:0]				12.10 [21:0]
 //assign   oD8_6b	=	{iC12_6b[20],iC12_6b,1'b0} + {iC14_6a[21],iC14_6a};
 wire D8_6b_c1;
 assign oD8_6b[0] = iC14_6a[0];
 FA_Cir_Cin0 D86bm0 (.iA (iC12_6b[0]), .iB (iC14_6a[1]), .oS (oD8_6b[1]), .oC (D8_6b_c1));
 Ripple_Add_21bit D86bm1 (
	.iA (iC12_6b[20:1]),	.iB (iC14_6a[21:2]),
	.iC (D8_6b_c1),			.oS (oD8_6b[22:2]));
 
	//	13.10 [22:0]			12.9  [20:0]				12.10 [21:0]
 //assign   oD8_7a	=	{iC12_7a[20],iC12_7a,1'b0} + {iC14_7a[21],iC14_7a};
 wire D8_7a_c1;
 assign oD8_7a[0] = iC14_7a[0];
 FA_Cir_Cin0 D87am0 (.iA (iC12_7a[0]), .iB (iC14_7a[1]), .oS (oD8_7a[1]), .oC (D8_7a_c1));
 Ripple_Add_21bit D87am1 (
	.iA (iC12_7a[20:1]),	.iB (iC14_7a[21:2]),
	.iC (D8_7a_c1),			.oS (oD8_7a[22:2]));
 
	//	13.10 [22:0]			12.9  [20:0]				12.10 [21:0]
 //assign   oD8_7b	=	{iC12_7b[20],iC12_7b,1'b0} - {iC14_7b[21],iC14_7b};
 assign oD8_7b[0] = iC14_7b[0];
 Ripple_Add_22bit D87bm0 (
	.iA (iC12_7b),		.iB (~iC14_7b[21:1]),
	.iC (~iC14_7b[0]),	.oS (oD8_7b[22:1]));
 
 /*********************************
 **************  D9  **************
 *********************************/
	//	13.10 [22:0]			12.10 [21:0]				12.9  [20:0]
 //assign   oD9_0a	=	{iC13_0a[21],iC13_0a}      + {iC15_0a[20],iC15_0a,1'b0};
 wire D9_0a_c1;
 assign oD9_0a[0] = iC13_0a[0];
 FA_Cir_Cin0 D90am0 (.iA (iC13_0a[1]), .iB (iC15_0a[0]), .oS (oD9_0a[1]), .oC (D9_0a_c1));
 Ripple_Add_21bit D90am1 (
	.iA (iC13_0a[21:2]),	.iB (iC15_0a[20:1]),
	.iC (D9_0a_c1),			.oS (oD9_0a[22:2]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.9  [20:0]
 //assign   oD9_0b	=	{iC13_0b[21],iC13_0b}      + {iC15_0b[20],iC15_0b,1'b0};
 wire D9_0b_c1;
 assign oD9_0b[0] = iC13_0b[0];
 FA_Cir_Cin0 D90bm0 (.iA (iC13_0b[1]), .iB (iC15_0b[0]), .oS (oD9_0b[1]), .oC (D9_0b_c1));
 Ripple_Add_21bit D90bm1 (
	.iA (iC13_0b[21:2]),	.iB (iC15_0b[20:1]),
	.iC (D9_0b_c1),			.oS (oD9_0b[22:2]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.9  [20:0]
 //assign   oD9_1a	=	{iC13_1a[21],iC13_1a}      + {iC15_1a[20],iC15_1a,1'b0};
 wire D9_1a_c1;
 assign oD9_1a[0] = iC13_1a[0];
 FA_Cir_Cin0 D91am0 (.iA (iC13_1a[1]), .iB (iC15_1a[0]), .oS (oD9_1a[1]), .oC (D9_1a_c1));
 Ripple_Add_21bit D91am1 (
	.iA (iC13_1a[21:2]),	.iB (iC15_1a[20:1]),
	.iC (D9_1a_c1),			.oS (oD9_1a[22:2]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.9  [20:0]
 //assign   oD9_1b	=	{iC13_1b[21],iC13_1b}      + {iC15_1b[20],iC15_1b,1'b0};
 wire D9_1b_c1;
 assign oD9_1b[0] = iC13_1b[0];
 FA_Cir_Cin0 D91bm0 (.iA (iC13_1b[1]), .iB (iC15_1b[0]), .oS (oD9_1b[1]), .oC (D9_1b_c1));
 Ripple_Add_21bit D91bm1 (
	.iA (iC13_1b[21:2]),	.iB (iC15_1b[20:1]),
	.iC (D9_1b_c1),			.oS (oD9_1b[22:2]));
 
	//	13.10 [22:0]			12.9  [20:0]				12.10 [21:0]
 //assign   oD9_2a	=	{iC13_2a[20],iC13_2a,1'b0} - {iC15_2a[21],iC15_2a};
 assign oD9_2a[0] = iC15_2a[0];
 Ripple_Add_22bit D92am0 (
	.iA (iC13_2a),		.iB (~iC15_2a[21:1]),
	.iC (~iC15_2a[0]),	.oS (oD9_2a[22:1]));
 
	//	13.10 [22:0]			12.9  [20:0]				12.10 [21:0]
 //assign   oD9_2b	=	{iC13_2b[20],iC13_2b,1'b0} - {iC15_2b[21],iC15_2b};
 assign oD9_2b[0] = iC15_2b[0];
 Ripple_Add_22bit D92bm0 (
	.iA (iC13_2b),		.iB (~iC15_2b[21:1]),
	.iC (~iC15_2b[0]),	.oS (oD9_2b[22:1]));
 
	//	13.10 [22:0]			12.9  [20:0]				12.10 [21:0]
 //assign   oD9_3a	=	{iC13_3a[20],iC13_3a,1'b0} + {iC15_3b[21],iC15_3b};
 wire D9_3a_c1;
 assign oD9_3a[0] = iC15_3b[0];
 FA_Cir_Cin0 D93am0 (.iA (iC13_3a[0]), .iB (iC15_3b[1]), .oS (oD9_3a[1]), .oC (D9_3a_c1));
 Ripple_Add_21bit D93am1 (
	.iA (iC13_3a[20:1]),	.iB (iC15_3b[21:2]),
	.iC (D9_3a_c1),			.oS (oD9_3a[22:2]));
 
	//	13.10 [22:0]			12.9  [20:0]				12.10 [21:0]
 //assign   oD9_3b	=	{iC13_3b[20],iC13_3b,1'b0} - {iC15_3a[21],iC15_3a};
 assign oD9_3b[0] = iC15_3a[0];
 Ripple_Add_22bit D93bm0 (
	.iA (iC13_3b),		.iB (~iC15_3a[21:1]),
	.iC (~iC15_3a[0]),	.oS (oD9_3b[22:1]));
 
	//	13.10 [22:0]			12.7  [18:0]				12.10 [21:0]
 //assign   oD9_4a	=	{iC13_4a[18],iC13_4a,3'b0} - {iC15_4a[21],iC15_4a};
 wire D9_4a_c1, D9_4a_c2;
 assign oD9_4a[0] = iC15_4a[0];
 FA_Cir_Cin0 D94am1 (.iA (~iC15_4a[1]), .iB (~iC15_4a[0]), .oS (oD9_4a[1]), .oC (D9_4a_c1));
 FA_Cir_Cin0 D94am2 (.iA (~iC15_4a[2]), .iB (D9_4a_c1),    .oS (oD9_4a[2]), .oC (D9_4a_c2));
 Ripple_Add_20bit D94am3 (
	.iA (iC13_4a),	.iB (~iC15_4a[21:3]),
	.iC (D9_4a_c2),	.oS (oD9_4a[22:3]));
 
	//	13.10 [22:0]			12.7  [18:0]				12.10 [21:0]
 //assign   oD9_4b	=	{iC13_4b[18],iC13_4b,3'b0} + {iC15_4b[21],iC15_4b};
 wire D9_4b_c3;
 assign oD9_4b[2:0] = iC15_4b[2:0];
 FA_Cir_Cin0 D94bm3 (.iA (iC13_4b[0]), .iB (iC15_4b[3]), .oS (oD9_4b[3]), .oC (D9_4b_c3));
 Ripple_Add_19bit D94bm4 (
	.iA (iC13_4b[18:1]),	.iB (iC15_4b[21:4]),
	.iC (D9_4b_c3),			.oS (oD9_4b[22:4]));
 
	//	13.10 [22:0]			12.7  [18:0]				12.10 [21:0]
 //assign   oD9_5a	=	{iC13_5a[18],iC13_5a,3'b0} - {iC15_5b[21],iC15_5b};
 wire D9_5a_c1, D9_5a_c2;
 assign oD9_5a[0] = iC15_5b[0];
 FA_Cir_Cin0 D95am1 (.iA (~iC15_5b[1]), .iB (~iC15_5b[0]), .oS (oD9_5a[1]), .oC (D9_5a_c1));
 FA_Cir_Cin0 D95am2 (.iA (~iC15_5b[2]), .iB (D9_5a_c1),    .oS (oD9_5a[2]), .oC (D9_5a_c2));
 Ripple_Add_20bit D95am3 (
	.iA (iC13_5a),	.iB (~iC15_5b[21:3]),
	.iC (D9_5a_c2),	.oS (oD9_5a[22:3]));
 
	//	13.10 [22:0]			12.7  [18:0]				12.10 [21:0]
 //assign   oD9_5b	=	{iC13_5b[18],iC13_5b,3'b0} - {iC15_5a[21],iC15_5a};
 wire D9_5b_c1, D9_5b_c2;
 assign oD9_5b[0] = iC15_5a[0];
 FA_Cir_Cin0 D95bm1 (.iA (~iC15_5a[1]), .iB (~iC15_5a[0]), .oS (oD9_5b[1]), .oC (D9_5b_c1));
 FA_Cir_Cin0 D95bm2 (.iA (~iC15_5a[2]), .iB (D9_5b_c1),    .oS (oD9_5b[2]), .oC (D9_5b_c2));
 Ripple_Add_20bit D95bm3 (
	.iA (iC13_5b),	.iB (~iC15_5a[21:3]),
	.iC (D9_5b_c2),	.oS (oD9_5b[22:3]));
 
	//	13.10 [22:0]			12.7  [18:0]				12.10 [21:0]
 //assign   oD9_6a	=	{iC15_6b[18],iC15_6b,3'b0} - {iC13_6a[21],iC13_6a};
 wire D9_6a_c1, D9_6a_c2;
 assign oD9_6a[0] = iC13_6a[0];
 FA_Cir_Cin0 D96am1 (.iA (~iC13_6a[1]), .iB (~iC13_6a[0]), .oS (oD9_6a[1]), .oC (D9_6a_c1));
 FA_Cir_Cin0 D96am2 (.iA (~iC13_6a[2]), .iB (D9_6a_c1),    .oS (oD9_6a[2]), .oC (D9_6a_c2));
 Ripple_Add_20bit D96am3 (
	.iA (iC15_6b),	.iB (~iC13_6a[21:3]),
	.iC (D9_6a_c2),	.oS (oD9_6a[22:3]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.7  [18:0]
 //assign   oD9_6b	=	{iC13_6b[21],iC13_6b}      + {iC15_6a[18],iC15_6a,3'b0};
 wire D9_6b_c3;
 assign oD9_6b[2:0] = iC13_6b[2:0];
 FA_Cir_Cin0 D96bm3 (.iA (iC13_6b[3]), .iB (iC15_6a[0]), .oS (oD9_6b[3]), .oC (D9_6b_c3));
 Ripple_Add_19bit D96bm4 (
	.iA (iC13_6b[21:4]),	.iB (iC15_6a[18:1]),
	.iC (D9_6b_c3),			.oS (oD9_6b[22:4]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.7  [18:0]
 //assign   oD9_7a	=	{iC13_7a[21],iC13_7a}      + {iC15_7b[18],iC15_7b,3'b0};
 wire D9_7a_c3;
 assign oD9_7a[2:0] = iC13_7a[2:0];
 FA_Cir_Cin0 D97am3 (.iA (iC13_7a[3]), .iB (iC15_7b[0]), .oS (oD9_7a[3]), .oC (D9_7a_c3));
 Ripple_Add_19bit D97am4 (
	.iA (iC13_7a[21:4]),	.iB (iC15_7b[18:1]),
	.iC (D9_7a_c3),			.oS (oD9_7a[22:4]));
 
	//	13.10 [22:0]			12.10 [21:0]				12.7  [18:0]
 //assign   oD9_7b	=	{iC13_7b[21],iC13_7b}      - {iC15_7a[18],iC15_7a,3'b0};
 wire D9_7b_c3;
 assign oD9_7b[2:0] = iC13_7b[2:0];
 FA_Cir_Cin1 D97bm3 (.iA (iC13_7b[3]), .iB (~iC15_7a[0]), .oS (oD9_7b[3]), .oC (D9_7b_c3));
 Ripple_Add_19bit D97bm4 (
	.iA (iC13_7b[21:4]),	.iB (~iC15_7a[18:1]),
	.iC (D9_7b_c3),			.oS (oD9_7b[22:4]));

endmodule

module ACor_DCT_32p_S5 (
	// Input Signals
	input	[11:0]	/*12.0 */	iD0, iD1, iD2, iD3,
	
	input	[18:0]	/*13.6 */	iD4_0a, iD4_0b, iD5_1a, iD5_1b,
	input	[16:0]	/*13.4 */	iD4_1a, iD4_1b, iD5_0a, iD5_0b,
 
	input	[20:0]	/*13.8 */	iD6_0a, iD6_0b, iD6_1a, iD6_1b,
	input	[18:0]	/*13.6 */	iD6_2a, iD6_2b, iD6_3a, iD6_3b,
	
	input	[18:0]	/*13.6 */	iD7_0a, iD7_0b, iD7_1a, iD7_1b,
	input	[20:0]	/*13.8 */	iD7_2a, iD7_2b, iD7_3a, iD7_3b,
	
	input	[22:0]	/*13.10*/	iD8_0a, iD8_0b, iD8_1a, iD8_1b,
								iD8_2a, iD8_2b, iD8_3a, iD8_3b,
								iD8_4a, iD8_4b, iD8_5a, iD8_5b,
								iD8_6a, iD8_6b, iD8_7a, iD8_7b,
	
	input	[22:0]	/*13.10*/	iD9_0a, iD9_0b, iD9_1a, iD9_1b,
								iD9_2a, iD9_2b, iD9_3a, iD9_3b,
								iD9_4a, iD9_4b, iD9_5a, iD9_5b,
								iD9_6a, iD9_6b, iD9_7a, iD9_7b,
	
	// Output Signals
	output	[12:0]	/*13.0 */	oE0, oE1,
	
	output	[18:0]	/*14.5 */	oE2, oE3,
 
	output	[19:0]	/*14.6 */	oE4, oE5, oE6, oE7,
 
	output	[21:0]	/*14.8 */	oE8,  oE9,  oE10, oE11,
								oE12, oE13, oE14, oE15,
	
	output	[23:0]	/*14.10 */	oE16, oE17, oE18, oE19,
								oE20, oE21, oE22, oE23,
								oE24, oE25, oE26, oE27,
								oE28, oE29, oE30, oE31
);

 //assign oE0 = {iD0[11],iD0} + {iD1[11],iD1};
 wire E0_c0;
 FA_Cir_Cin0 E0m0 (.iA (iD0[0]), .iB (iD1[0]), .oS (oE0[0]), .oC (E0_c0));
 Ripple_Add_12bit E0m1 (
	.iA (iD0[11:1]),.iB (iD1[11:1]),
	.iC (E0_c0),	.oS (oE0[12:1]));
 
 //assign oE1 = {iD0[11],iD0} - {iD1[11],iD1};
 wire E1_c0;
 FA_Cir_Cin1 E1m0 (.iA (iD0[0]), .iB (~iD1[0]), .oS (oE1[0]), .oC (E1_c0));
 Ripple_Add_12bit E1m1 (
	.iA (iD0[11:1]),.iB (~iD1[11:1]),
	.iC (E1_c0),	.oS (oE1[12:1]));

 ACor_DCT_32p_pi8_2Stg E2E3m0 (
	// Input Signals
	.iA (iD2), .iB (iD3),
	
	// Output Signals
	.o0a (oE2), .o0b (oE3));

 /********************************/
	//	14.6  [19:0]		13.6 [18:0]					13.4 [16:0]
 //assign		oE4		=	{iD4_0a[18],iD4_0a}      + {iD5_0a[16],iD5_0a,2'b0};
 wire E4_c2;
 assign oE4[1:0] = iD4_0a[1:0];
 FA_Cir_Cin0 E4m2 (.iA (iD4_0a[2]), .iB (iD5_0a[0]), .oS (oE4[2]), .oC (E4_c2));
 Ripple_Add_17bit E4m3 (
	.iA (iD4_0a[18:3]),	.iB (iD5_0a[16:1]),
	.iC (E4_c2),		.oS (oE4[19:3]));
 
	//	14.6  [19:0]		13.4 [16:0]					13.6 [18:0]
 //assign		oE5		=	{iD5_0b[16],iD5_0b,2'b0} - {iD4_0b[18],iD4_0b};
 wire E5_c1;
 assign oE5[0] = iD4_0b[0];
 FA_Cir_Cin0 E5m1 (.iA (~iD4_0b[1]), .iB (~iD4_0b[0]), .oS (oE5[1]), .oC (E5_c1));
 Ripple_Add_18bit E5m2 (
	.iA (iD5_0b),	.iB (~iD4_0b[18:2]),
	.iC (E5_c1),	.oS (oE5[19:2]));
 
	//	14.6  [19:0]		13.4 [16:0]					13.6 [18:0]
 //assign		oE6		=	{iD4_1a[16],iD4_1a,2'b0} - {iD5_1b[18],iD5_1b};
 wire E6_c1;
 assign oE6[0] = iD5_1b[0];
 FA_Cir_Cin0 E6m1 (.iA (~iD5_1b[1]), .iB (~iD5_1b[0]), .oS (oE6[1]), .oC (E6_c1));
 Ripple_Add_18bit E6m2 (
	.iA (iD4_1a),	.iB (~iD5_1b[18:2]),
	.iC (E6_c1),	.oS (oE6[19:2]));
 
	//	14.6  [19:0]		13.4 [16:0]					13.6 [18:0]
 //assign		oE7		=	{iD4_1b[16],iD4_1b,2'b0} - {iD5_1a[18],iD5_1a};
 wire E7_c1;
 assign oE7[0] = iD5_1a[0];
 FA_Cir_Cin0 E7m1 (.iA (~iD5_1a[1]), .iB (~iD5_1a[0]), .oS (oE7[1]), .oC (E7_c1));
 Ripple_Add_18bit E7m2 (
	.iA (iD4_1b),	.iB (~iD5_1a[18:2]),
	.iC (E7_c1),	.oS (oE7[19:2]));
 
 /********************************/
	//	14.8  [21:0]		13.8 [20:0]	 				13.6 [18:0]
 //assign		oE8		=	{iD6_0a[20],iD6_0a}      + {iD7_0a[18],iD7_0a,2'b0};
 wire E8_c2;
 assign oE8[1:0] = iD6_0a[1:0];
 FA_Cir_Cin0 E8m2 (.iA (iD6_0a[2]), .iB (iD7_0a[0]), .oS (oE8[2]), .oC (E8_c2));
 Ripple_Add_19bit E8m3 (
	.iA (iD6_0a[20:3]),	.iB (iD7_0a[18:1]),
	.iC (E8_c2),		.oS (oE8[21:3]));
 
	//	14.8  [21:0]		13.8 [20:0]					13.6 [18:0]
 //assign		oE9		=	{iD6_0b[20],iD6_0b}      + {iD7_0b[18],iD7_0b,2'b0};
 wire E9_c2;
 assign oE9[1:0] = iD6_0b[1:0];
 FA_Cir_Cin0 E9m2 (.iA (iD6_0b[2]), .iB (iD7_0b[0]), .oS (oE9[2]), .oC (E9_c2));
 Ripple_Add_19bit E9m3 (
	.iA (iD6_0b[20:3]),	.iB (iD7_0b[18:1]),
	.iC (E9_c2),		.oS (oE9[21:3]));
 
	//	14.8  [21:0]		13.8 [20:0]					13.6 [18:0]
 //assign		oE10	=	{iD6_1a[20],iD6_1a}      - {iD7_1a[18],iD7_1a,2'b0};
 wire E10_c2;
 assign oE10[1:0] = iD6_1a[1:0];
 FA_Cir_Cin1 E10m2 (.iA (iD6_1a[2]), .iB (~iD7_1a[0]), .oS (oE10[2]), .oC (E10_c2));
 Ripple_Add_19bit E10m3 (
	.iA (iD6_1a[20:3]),	.iB (~iD7_1a[18:1]),
	.iC (E10_c2),		.oS (oE10[21:3]));
 
	//	14.8  [21:0]		13.8 [20:0]					13.6 [18:0]
 //assign		oE11	=	{iD6_1b[20],iD6_1b}      - {iD7_1b[18],iD7_1b,2'b0};
 wire E11_c2;
 assign oE11[1:0] = iD6_1b[1:0];
 FA_Cir_Cin1 E11m2 (.iA (iD6_1b[2]),	.iB (~iD7_1b[0]),	.oS (oE11[2]),	.oC (E11_c2));
 Ripple_Add_19bit E11m3 (
	.iA (iD6_1b[20:3]),	.iB (~iD7_1b[18:1]),
	.iC (E11_c2),		.oS (oE11[21:3]));
 
	//	14.8  [21:0]		13.6 [18:0]					13.8 [20:0]
 //assign		oE12	=	{iD6_2a[18],iD6_2a,2'b0} - {iD7_2b[20],iD7_2b};
 wire E12_c1;
 assign oE12[0] = iD7_2b[0];
 FA_Cir_Cin0 E12m1 (.iA (~iD7_2b[1]), .iB (~iD7_2b[0]), .oS (oE12[1]), .oC (E12_c1));
 Ripple_Add_20bit E12m2 (
	.iA (iD6_2a),	.iB (~iD7_2b[20:2]),
	.iC (E12_c1),	.oS (oE12[21:2]));
 
	//	14.8  [21:0]		13.8 [20:0]					13.6 [18:0]
 //assign		oE13	=	{iD7_2a[20],iD7_2a}      - {iD6_2b[18],iD6_2b,2'b0};
 wire E13_c2;
 assign oE13[1:0] = iD7_2a[1:0];
 FA_Cir_Cin1 E13m2 (.iA (iD7_2a[2]),	.iB (~iD6_2b[0]),	.oS (oE13[2]),	.oC (E13_c2));
 Ripple_Add_19bit E13m3 (
	.iA (iD7_2a[20:3]),	.iB (~iD6_2b[18:1]),
	.iC (E13_c2),		.oS (oE13[21:3]));
 
	//	14.8  [21:0]		13.6 [18:0]					13.8 [20:0]
 //assign		oE14	=	{iD6_3a[18],iD6_3a,2'b0} + {iD7_3a[20],iD7_3a};
 wire E14_c2;
 assign oE14[1:0] = iD7_3a[1:0];
 FA_Cir_Cin0 E14m2 (.iA (iD6_3a[0]), .iB (iD7_3a[2]), .oS (oE14[2]), .oC (E14_c2));
 Ripple_Add_19bit E14m3 (
	.iA (iD6_3a[18:1]),	.iB (iD7_3a[20:3]),
	.iC (E14_c2),		.oS (oE14[21:3]));
 
	//	14.8  [21:0]		13.6 [18:0]					13.8 [20:0]
 //assign		oE15	=	{iD6_3b[18],iD6_3b,2'b0} - {iD7_3b[20],iD7_3b};
 wire E15_c1;
 assign oE15[0] = iD7_3b[0];
 FA_Cir_Cin0 E15m1 (.iA (~iD7_3b[1]), .iB (~iD7_3b[0]), .oS (oE15[1]), .oC (E15_c1));
 Ripple_Add_20bit E15m2 (
	.iA (iD6_3b),	.iB (~iD7_3b[20:2]),
	.iC (E15_c1),	.oS (oE15[21:2]));

 /********************************/
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE16	=	{iD8_0a[22],iD8_0a} + {iD9_0a[22],iD9_0a};
 wire E16_c0;
 FA_Cir_Cin0 E16m0 (.iA (iD8_0a[0]), .iB (iD9_0a[0]), .oS (oE16[0]), .oC (E16_c0));
 Ripple_Add_23bit E16m1 (
	.iA (iD8_0a[22:1]),	.iB (iD9_0a[22:1]),
	.iC (E16_c0),		.oS (oE16[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE17	=	{iD8_0b[22],iD8_0b} + {iD9_0b[22],iD9_0b};
 wire E17_c0;
 FA_Cir_Cin0 E17m0 (.iA (iD8_0b[0]), .iB (iD9_0b[0]), .oS (oE17[0]), .oC (E17_c0));
 Ripple_Add_23bit E17m1 (
	.iA (iD8_0b[22:1]),	.iB (iD9_0b[22:1]),
	.iC (E17_c0),		.oS (oE17[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE18	=	{iD8_1a[22],iD8_1a} - {iD9_1a[22],iD9_1a};
 wire E18_c0;
 FA_Cir_Cin1 E18m0 (.iA (iD8_1a[0]), .iB (~iD9_1a[0]), .oS (oE18[0]), .oC (E18_c0));
 Ripple_Add_23bit E18m1 (
	.iA (iD8_1a[22:1]),	.iB (~iD9_1a[22:1]),
	.iC (E18_c0),		.oS (oE18[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE19	=	{iD8_1b[22],iD8_1b} - {iD9_1b[22],iD9_1b};
 wire E19_c0;
 FA_Cir_Cin1 E19m0 (.iA (iD8_1b[0]), .iB (~iD9_1b[0]), .oS (oE19[0]), .oC (E19_c0));
 Ripple_Add_23bit E19m1 (
	.iA (iD8_1b[22:1]),	.iB (~iD9_1b[22:1]),
	.iC (E19_c0),		.oS (oE19[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE20	=	{iD8_2a[22],iD8_2a} - {iD9_2b[22],iD9_2b};
 wire E20_c0;
 FA_Cir_Cin1 E20m0 (.iA (iD8_2a[0]), .iB (~iD9_2b[0]), .oS (oE20[0]), .oC (E20_c0));
 Ripple_Add_23bit E20m1 (
	.iA (iD8_2a[22:1]),	.iB (~iD9_2b[22:1]),
	.iC (E20_c0),		.oS (oE20[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE21	=	{iD8_2b[22],iD8_2b} + {iD9_2a[22],iD9_2a};
 wire E21_c0;
 FA_Cir_Cin0 E21m0 (.iA (iD8_2b[0]), .iB (iD9_2a[0]), .oS (oE21[0]), .oC (E21_c0));
 Ripple_Add_23bit E21m1 (
	.iA (iD8_2b[22:1]),	.iB (iD9_2a[22:1]),
	.iC (E21_c0),		.oS (oE21[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE22	=	{iD8_3a[22],iD8_3a} + {iD9_3b[22],iD9_3b};
 wire E22_c0;
 FA_Cir_Cin0 E22m0 (.iA (iD8_3a[0]), .iB (iD9_3b[0]), .oS (oE22[0]), .oC (E22_c0));
 Ripple_Add_23bit E22m1 (
	.iA (iD8_3a[22:1]),	.iB (iD9_3b[22:1]),
	.iC (E22_c0),		.oS (oE22[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE23	=	{iD8_3b[22],iD8_3b} - {iD9_3a[22],iD9_3a};
 wire E23_c0;
 FA_Cir_Cin1 E23m0 (.iA (iD8_3b[0]), .iB (~iD9_3a[0]), .oS (oE23[0]), .oC (E23_c0));
 Ripple_Add_23bit E23m1 (
	.iA (iD8_3b[22:1]),	.iB (~iD9_3a[22:1]),
	.iC (E23_c0),		.oS (oE23[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE24	=	{iD8_4a[22],iD8_4a} + {iD9_4a[22],iD9_4a};
 wire E24_c0;
 FA_Cir_Cin0 E24m0 (.iA (iD8_4a[0]), .iB (iD9_4a[0]), .oS (oE24[0]), .oC (E24_c0));
 Ripple_Add_23bit E24m1 (
	.iA (iD8_4a[22:1]),	.iB (iD9_4a[22:1]),
	.iC (E24_c0),		.oS (oE24[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE25	=	{iD8_4b[22],iD8_4b} + {iD9_4b[22],iD9_4b};
 wire E25_c0;
 FA_Cir_Cin0 E25m0 (.iA (iD8_4b[0]), .iB (iD9_4b[0]), .oS (oE25[0]), .oC (E25_c0));
 Ripple_Add_23bit E25m1 (
	.iA (iD8_4b[22:1]),	.iB (iD9_4b[22:1]),
	.iC (E25_c0),		.oS (oE25[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE26	=	{iD8_5a[22],iD8_5a} - {iD9_5b[22],iD9_5b};
 wire E26_c0;
 FA_Cir_Cin1 E26m0 (.iA (iD8_5a[0]), .iB (~iD9_5b[0]), .oS (oE26[0]), .oC (E26_c0));
 Ripple_Add_23bit E26m1 (
	.iA (iD8_5a[22:1]),	.iB (~iD9_5b[22:1]),
	.iC (E26_c0),		.oS (oE26[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE27	=	{iD8_5b[22],iD8_5b} - {iD9_5a[22],iD9_5a};
 wire E27_c0;
 FA_Cir_Cin1 E27m0 (.iA (iD8_5b[0]), .iB (~iD9_5a[0]), .oS (oE27[0]), .oC (E27_c0));
 Ripple_Add_23bit E27m1 (
	.iA (iD8_5b[22:1]),	.iB (~iD9_5a[22:1]),
	.iC (E27_c0),		.oS (oE27[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE28	=	{iD8_6a[22],iD8_6a} + {iD9_6a[22],iD9_6a};
 wire E28_c0;
 FA_Cir_Cin0 E28m0 (.iA (iD8_6a[0]), .iB (iD9_6a[0]), .oS (oE28[0]), .oC (E28_c0));
 Ripple_Add_23bit E28m1 (
	.iA (iD8_6a[22:1]),	.iB (iD9_6a[22:1]),
	.iC (E28_c0),		.oS (oE28[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE29	=	{iD9_6b[22],iD9_6b} - {iD8_6b[22],iD8_6b};
 wire E29_c0;
 FA_Cir_Cin1 E29m0 (.iA (iD9_6b[0]), .iB (~iD8_6b[0]), .oS (oE29[0]), .oC (E29_c0));
 Ripple_Add_23bit E29m1 (
	.iA (iD9_6b[22:1]),	.iB (~iD8_6b[22:1]),
	.iC (E29_c0),		.oS (oE29[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE30	=	{iD8_7a[22],iD8_7a} + {iD9_7a[22],iD9_7a};
 wire E30_c0;
 FA_Cir_Cin0 E30m0 (.iA (iD8_7a[0]), .iB (iD9_7a[0]), .oS (oE30[0]), .oC (E30_c0));
 Ripple_Add_23bit E30m1 (
	.iA (iD8_7a[22:1]),	.iB (iD9_7a[22:1]),
	.iC (E30_c0),		.oS (oE30[23:1]));
 
	//	14.10 [23:0]		13.10 [22:0]		13.10 [22:0]
 //assign		oE31	=	{iD8_7b[22],iD8_7b} + {iD9_7b[22],iD9_7b};
 wire E31_c0;
 FA_Cir_Cin0 E31m0 (.iA (iD8_7b[0]), .iB (iD9_7b[0]), .oS (oE31[0]), .oC (E31_c0));
 Ripple_Add_23bit E31m1 (
	.iA (iD8_7b[22:1]),	.iB (iD9_7b[22:1]),
	.iC (E31_c0),		.oS (oE31[23:1]));

endmodule

module ACor_DCT_32p_pi8_2Stg (
	// Input Signals
	input	[11:0]	/*12.0*/	iA, iB,
	
	// Output Signals
	output	[18:0]	/*14.5*/	o0a, o0b
);

 wire	/*13.1*/	[13:0]	S1_0top, S1_0bot;
 wire	/*14.5*/	[18:0]	S2_0top, S2_0bot;
 
 //assign S1_0top = {iB[11],iB,1'b0} + {{(2){iA[11]}},iA};	// S1_top = b + a*2^-1;
 wire S1_0top_c1;
 assign S1_0top[0] = iA[0];
 FA_Cir_Cin0 S10tpm1 (.iA (iB[0]), .iB (iA[1]), .oS(S1_0top[1]), .oC (S1_0top_c1));
 Ripple_Add_12bit S10tpm2 (
	.iA (iB[11:1]),		.iB ({iA[11],iA[11:2]}),
	.iC (S1_0top_c1),	.oS (S1_0top[13:2]));
 
 //assign S1_0bot = {iA[11],iA,1'b0} - {{(2){iB[11]}},iB};	// S1_bot = a - b*2^-1;
 assign S1_0bot[0] = iB[0];
 Ripple_Add_13bit S10btm0 (
	.iA (iA), 		.iB (~{iB[11],iB[11:1]}),
	.iC (~iB[0]),	.oS (S1_0bot[13:1]));
 
 //assign S2_0top = {S1_0top[13],S1_0top,4'b0} - {{(5){S1_0bot[13]}},S1_0bot};	// S2_top = S1_top - S1_bot*2^-4;
 wire S2_0top_c1, S2_0top_c2, S2_0top_c3;
 assign S2_0top[0] = S1_0bot[0];
 FA_Cir_Cin0 S20tpm1 (.iA (~S1_0bot[1]), .iB (~S1_0bot[0]), .oS (S2_0top[1]), .oC (S2_0top_c1));
 FA_Cir_Cin0 S20tpm2 (.iA (~S1_0bot[2]), .iB (S2_0top_c1),  .oS (S2_0top[2]), .oC (S2_0top_c2));
 FA_Cir_Cin0 S20tpm3 (.iA (~S1_0bot[3]), .iB (S2_0top_c2),  .oS (S2_0top[3]), .oC (S2_0top_c3));
 Ripple_Add_15bit S20tpm4 (
	.iA (S1_0top),		.iB (~{{(4){S1_0bot[13]}},S1_0bot[13:4]}),
	.iC (S2_0top_c3),	.oS (S2_0top[18:4]));
 
 //assign S2_0bot = {S1_0bot[13],S1_0bot,4'b0} + {{(5){S1_0top[13]}},S1_0top};	// S2_bot = S1_bot + S1_top*2^-4;
 wire S2_0bot_c4;
 assign S2_0bot[3:0] = S1_0top[3:0];
 FA_Cir_Cin0 S20btm4 (.iA (S1_0bot[0]), .iB (S1_0top[4]), .oS (S2_0bot[4]), .oC (S2_0bot_c4));
 Ripple_Add_14bit S20btm5 (
	.iA (S1_0bot[13:1]),	.iB ({{(4){S1_0top[13]}},S1_0top[13:5]}),
	.iC (S2_0bot_c4),		.oS (S2_0bot[18:5]));
 
 assign o0a = S2_0top;
 assign o0b = S2_0bot;

endmodule

module ACor_DCT_32p_1to3_pi16_2Stg (
	// Input Signals
	input	[10:0]	/*11.0*/	iA, iB,
	
	// Output Signals
	output	[18:0]	/*13.6*/	o0a, o0b,
	output	[16:0]	/*13.4*/	o1a, o1b
);

 /* pi/16 */
 wire	/*12.2*/	[13:0]	S1_0top, S1_0bot;
 wire	/*13.6*/	[18:0]	S2_0top, S2_0bot;
 
 //assign S1_0top = {iB[10],iB,2'b0} + {{(3){iA[10]}},iA};	// S1_top = b + a*2^-2;
 wire S1_0top_c2;
 assign S1_0top[1:0] = iA[1:0];
 FA_Cir_Cin0 S10tpm2 (.iA (iB[0]), .iB (iA[2]), .oS (S1_0top[2]), .oC (S1_0top_c2));
 Ripple_Add_11bit S10tpm3 (
	.iA (iB[10:1]),		.iB ({{(2){iA[10]}},iA[10:3]}),
	.iC (S1_0top_c2),	.oS (S1_0top[13:3]));
 
 //assign S1_0bot = {iA[10],iA,2'b0} - {{(3){iB[10]}},iB};	// S1_bot = a - b*2^-2;
 wire S1_0bot_c1;
 assign S1_0bot[0] = iB[0];
 FA_Cir_Cin0 S10btm1 (.iA (~iB[1]), .iB (~iB[0]), .oS (S1_0bot[1]), .oC (S1_0bot_c1));
 Ripple_Add_12bit S10btm2 (
	.iA (iA),			.iB (~{{(2){iB[10]}},iB[10:2]}),
	.iC (S1_0bot_c1),	.oS(S1_0bot[13:2]));
 
 //assign S2_0top = {S1_0top[13],S1_0top,4'b0} - {{(5){S1_0bot[13]}},S1_0bot};	// S2_top = S1_top - S1_bot*2^-4;
 wire S2_0top_c1, S2_0top_c2, S2_0top_c3;
 assign S2_0top[0] = S1_0bot[0];
 FA_Cir_Cin0 S20tpm1 (.iA (~S1_0bot[1]), .iB (~S1_0bot[0]), .oS (S2_0top[1]), .oC (S2_0top_c1));
 FA_Cir_Cin0 S20tpm2 (.iA (~S1_0bot[2]), .iB (S2_0top_c1),  .oS (S2_0top[2]), .oC (S2_0top_c2));
 FA_Cir_Cin0 S20tpm3 (.iA (~S1_0bot[3]), .iB (S2_0top_c2),  .oS (S2_0top[3]), .oC (S2_0top_c3));
 Ripple_Add_15bit S20tpm4 (
	.iA (S1_0top),		.iB (~{{(4){S1_0bot[13]}},S1_0bot[13:4]}),
	.iC (S2_0top_c3),	.oS (S2_0top[18:4]));
 
 //assign S2_0bot = {S1_0bot[13],S1_0bot,4'b0} + {{(5){S1_0top[13]}},S1_0top};	// S2_bot = S1_bot + S1_top*2^-4;
 wire S2_0bot_c4;
 assign S2_0bot[3:0] = S1_0top[3:0];
 FA_Cir_Cin0 S20btm4 (.iA (S1_0bot[0]), .iB (S1_0top[4]), .oS (S2_0bot[4]), .oC (S2_0bot_c4));
 Ripple_Add_14bit S20btm5 (
	.iA (S1_0bot[13:1]),	.iB ({{(4){S1_0top[13]}},S1_0top[13:5]}),
	.iC (S2_0bot_c4),		.oS (S2_0bot[18:5]));
 
 assign o0a = S2_0top;
 assign o0b = S2_0bot;

 /* 3pi/16 */
 wire	/*12.1*/	[12:0]	S1_1top, S1_1bot;
 wire	/*13.4*/	[16:0]	S2_1top, S2_1bot;
 
 //assign S1_1top = {iA[10],iA,1'b0} + {{(2){iB[10]}},iB};	// S1_top = a + b*2^-1;
 wire S1_1top_c1;
 assign S1_1top[0] = iB[0];
 FA_Cir_Cin0 S11tpm1 (.iA (iA[0]), .iB (iB[1]), .oS (S1_1top[1]), .oC (S1_1top_c1));
 Ripple_Add_11bit S11tpm2 (
	.iA (iA[10:1]),		.iB ({iB[10],iB[10:2]}),
	.iC (S1_1top_c1),	.oS (S1_1top[12:2]));
 
 //assign S1_1bot = {iB[10],iB,1'b0} - {{(2){iA[10]}},iA};	// S1_bot = b - a*2^-1;
 assign S1_1bot[0] = iA[0];
 Ripple_Add_12bit S11btm0 (
	.iA (iB),		.iB (~{iA[10],iA[10:1]}),
	.iC (~iA[0]),	.oS (S1_1bot[12:1]));
 
 //assign S2_1top = {S1_1top[12],S1_1top,3'b0} + {{(4){S1_1bot[12]}},S1_1bot};	// S2_top = S1_top + S1_bot*2^-3;
 wire S2_1top_c3;
 assign S2_1top[2:0] = S1_1bot[2:0];
 FA_Cir_Cin0 S21tpm3 (.iA (S1_1top[0]), .iB (S1_1bot[3]), .oS (S2_1top[3]), .oC (S2_1top_c3));
 Ripple_Add_13bit S21tpm4 (
	.iA (S1_1top[12:1]),	.iB ({{(3){S1_1bot[12]}},S1_1bot[12:4]}),
	.iC (S2_1top_c3),		.oS (S2_1top[16:4]));
 
 //assign S2_1bot = {S1_1bot[12],S1_1bot,3'b0} - {{(4){S1_1top[12]}},S1_1top};	// S2_bot = S1_bot - S1_top*2^-3;
 wire S2_1bot_c1, S2_1bot_c2;
 assign S2_1bot[0] = S1_1top[0];
 FA_Cir_Cin0 S21btm1 (.iA (~S1_1top[1]), .iB (~S1_1top[0]), .oS (S2_1bot[1]), .oC (S2_1bot_c1));
 FA_Cir_Cin0 S21btm2 (.iA (~S1_1top[2]), .iB (S2_1bot_c1),  .oS (S2_1bot[2]), .oC (S2_1bot_c2));
 Ripple_Add_14bit S21btm3 (
	.iA (S1_1bot),		.iB (~{{(3){S1_1top[12]}},S1_1top[12:3]}),
	.iC (S2_1bot_c2),	.oS (S2_1bot[16:3]));
 
 assign o1a = S2_1top;
 assign o1b = S2_1bot;

endmodule

module ACor_DCT_32p_1to7_pi32_2Stg (
	// Input Signals
	input	[9:0]	/*10.0*/	iA, iB,
	
	// Output Signals
	output	[19:0]	/*12.8*/	o0a, o0b,
	output	[17:0]	/*12.6*/	o1a, o1b,
	output	[17:0]	/*12.6*/	o2a, o2b,
	output	[14:0]	/*12.3*/	o3a, o3b
);

 /* pi/32 */
 wire	/*11.3*/	[13:0]	S1_0top, S1_0bot;
 wire	/*12.8*/	[19:0]	S2_0top, S2_0bot;
 
 //assign S1_0top = {iB[9],iB,3'b0} + {{(4){iA[9]}},iA};	// S1_top = b + a*2^-3;
 wire S1_0top_c3;
 assign S1_0top[2:0] = iA[2:0];
 FA_Cir_Cin0 S10tpm3 (.iA (iB[0]), .iB (iA[3]), .oS (S1_0top[3]), .oC (S1_0top_c3));
 Ripple_Add_10bit S10tpm4 (
	.iA (iB[9:1]),		.iB ({{(3){iA[9]}},iA[9:4]}),
	.iC (S1_0top_c3),	.oS (S1_0top[13:4]));
 
 //assign S1_0bot = {iA[9],iA,3'b0} - {{(4){iB[9]}},iB};	// S1_bot = a - b*2^-3;
 wire S1_0bot_c1, S1_0bot_c2;
 assign S1_0bot[0] = iB[0];
 FA_Cir_Cin0 S10btm1 (.iA (~iB[1]), .iB (~iB[0]),     .oS (S1_0bot[1]), .oC (S1_0bot_c1));
 FA_Cir_Cin0 S10btm2 (.iA (~iB[2]), .iB (S1_0bot_c1), .oS (S1_0bot[2]), .oC (S1_0bot_c2));
 Ripple_Add_11bit S10btm3 (
	.iA (iA),			.iB (~{{(3){iB[9]}},iB[9:3]}),
	.iC (S1_0bot_c2),	.oS (S1_0bot[13:3]));
 
 //assign S2_0top = {S1_0top[13],S1_0top,5'b0} - {{(6){S1_0bot[13]}},S1_0bot};	// S2_top = S1_top - S1_bot*2^-5;
 wire S2_0top_c1, S2_0top_c2, S2_0top_c3, S2_0top_c4;
 assign S2_0top[0] = S1_0bot[0];
 FA_Cir_Cin0 S20tpm1 (.iA (~S1_0bot[1]), .iB (~S1_0bot[0]), .oS (S2_0top[1]), .oC (S2_0top_c1));
 FA_Cir_Cin0 S20tpm2 (.iA (~S1_0bot[2]), .iB (S2_0top_c1),  .oS (S2_0top[2]), .oC (S2_0top_c2));
 FA_Cir_Cin0 S20tpm3 (.iA (~S1_0bot[3]), .iB (S2_0top_c2),  .oS (S2_0top[3]), .oC (S2_0top_c3));
 FA_Cir_Cin0 S20tpm4 (.iA (~S1_0bot[4]), .iB (S2_0top_c3),  .oS (S2_0top[4]), .oC (S2_0top_c4));
 Ripple_Add_15bit S20tpm5 (
	.iA (S1_0top),		.iB (~{{(5){S1_0bot[13]}},S1_0bot[13:5]}),
	.iC (S2_0top_c4),	.oS (S2_0top[19:5]));
 
 //assign S2_0bot = {S1_0bot[13],S1_0bot,5'b0} + {{(6){S1_0top[13]}},S1_0top};	// S2_bot = S1_bot + S1_top*2^-5;
 wire S2_0bot_c5;
 assign S2_0bot[4:0] = S1_0top[4:0];
 FA_Cir_Cin0 S20btm5 (.iA (S1_0bot[0]), .iB (S1_0top[5]), .oS (S2_0bot[5]), .oC (S2_0bot_c5));
 Ripple_Add_14bit S20btm6 (
	.iA (S1_0bot[13:1]),	.iB ({{(5){S1_0top[13]}},S1_0top[13:6]}),
	.iC (S2_0bot_c5),		.oS (S2_0bot[19:6]));
 
 assign o0a = S2_0top;
 assign o0b = S2_0bot;

 /* 3pi/32 */
 wire	/*11.2*/	[12:0]	S1_1top, S1_1bot;
 wire	/*12.6*/	[17:0]	S2_1top, S2_1bot;
 
 //assign S1_1top = {iA[9],iA,2'b0} + {{(3){iB[9]}},iB};	// S1_top = a + b*2^-2;
 wire S1_1top_c2;
 assign S1_1top[1:0] = iB[1:0];
 FA_Cir_Cin0 S11tpm2 (.iA (iA[0]), .iB (iB[2]), .oS (S1_1top[2]), .oC (S1_1top_c2));
 Ripple_Add_10bit S11tpm3 (
	.iA (iA[9:1]),		.iB ({{(2){iB[9]}},iB[9:3]}),
	.iC (S1_1top_c2),	.oS (S1_1top[12:3]));
 
 //assign S1_1bot = {iB[9],iB,2'b0} - {{(3){iA[9]}},iA};	// S1_bot = b - a*2^-2;
 wire S1_1bot_c1;
 assign S1_1bot[0] = iA[0];
 FA_Cir_Cin0 S11btm1 (.iA (~iA[1]), .iB (~iA[0]), .oS (S1_1bot[1]), .oC (S1_1bot_c1));
 Ripple_Add_11bit S11btm2 (
	.iA (iB),			.iB (~{{(2){iA[9]}},iA[9:2]}),
	.iC (S1_1bot_c1),	.oS (S1_1bot[12:2]));
 
 //assign S2_1top = {S1_1top[12],S1_1top,4'b0} + {{(5){S1_1bot[12]}},S1_1bot};	// S2_top = S1_top + S1_bot*2^-4;
 wire S2_1top_c4;
 assign S2_1top[3:0] = S1_1bot[3:0];
 FA_Cir_Cin0 S21tpm4 (.iA (S1_1top[0]), .iB (S1_1bot[4]), .oS (S2_1top[4]), .oC (S2_1top_c4));
 Ripple_Add_13bit S21tpm5 (
	.iA (S1_1top[12:1]),	.iB ({{(4){S1_1bot[12]}},S1_1bot[12:5]}),
	.iC (S2_1top_c4),		.oS (S2_1top[17:5]));
 
 //assign S2_1bot = {S1_1bot[12],S1_1bot,4'b0} - {{(5){S1_1top[12]}},S1_1top};	// S2_bot = S1_bot - S1_top*2^-4;
 wire S2_1bot_c1, S2_1bot_c2, S2_1bot_c3;
 assign S2_1bot[0] = S1_1top[0];
 FA_Cir_Cin0 S21btm1 (.iA (~S1_1top[1]), .iB (~S1_1top[0]), .oS (S2_1bot[1]), .oC (S2_1bot_c1));
 FA_Cir_Cin0 S21btm2 (.iA (~S1_1top[2]), .iB (S2_1bot_c1),  .oS (S2_1bot[2]), .oC (S2_1bot_c2));
 FA_Cir_Cin0 S21btm3 (.iA (~S1_1top[3]), .iB (S2_1bot_c2),  .oS (S2_1bot[3]), .oC (S2_1bot_c3));
 Ripple_Add_14bit S21btm4 (
	.iA (S1_1bot),		.iB (~{{(4){S1_1top[12]}},S1_1top[12:4]}),
	.iC (S2_1bot_c3),	.oS (S2_1bot[17:4]));
 
 assign o1a = S2_1top;
 assign o1b = S2_1bot;

 /* 5pi/32 */
 wire	/*11.1*/	[11:0]	S1_2top, S1_2bot;
 wire	/*12.6*/	[17:0]	S2_2top, S2_2bot;
 
 //assign S1_2top = {iB[9],iB,1'b0} + {{(2){iA[9]}},iA};	// S1_top = b + a*2^-1;
 wire S1_2top_c1;
 assign S1_2top[0] = iA[0];
 FA_Cir_Cin0 S12tpm1 (.iA (iB[0]), .iB (iA[1]), .oS (S1_2top[1]), .oC (S1_2top_c1));
 Ripple_Add_10bit S12tpm2 (
	.iA (iB[9:1]),		.iB ({iA[9],iA[9:2]}),
	.iC (S1_2top_c1),	.oS (S1_2top[11:2]));
 
 //assign S1_2bot = {iA[9],iA,1'b0} - {{(2){iB[9]}},iB};	// S1_bot = a - b*2^-1;
 assign S1_2bot[0] = iB[0];
 Ripple_Add_11bit S12btm0 (
	.iA (iA),		.iB (~{iB[9],iB[9:1]}),
	.iC (~iB[0]),	.oS (S1_2bot[11:1]));
 
 //assign S2_2top = {S1_2top[11],S1_2top,5'b0} + {{(6){S1_2bot[11]}},S1_2bot};	// S2_top = S1_top + S1_bot*2^-5;
 wire S2_2top_c5;
 assign S2_2top[4:0] = S1_2bot[4:0];
 FA_Cir_Cin0 S22tpm5 (.iA (S1_2top[0]), .iB (S1_2bot[5]), .oS (S2_2top[5]), .oC (S2_2top_c5));
 Ripple_Add_12bit S22tpm6 (
	.iA (S1_2top[11:1]),	.iB ({{(5){S1_2bot[11]}},S1_2bot[11:6]}),
	.iC (S2_2top_c5),		.oS (S2_2top[17:6]));
 
 //assign S2_2bot = {S1_2bot[11],S1_2bot,5'b0} - {{(6){S1_2top[11]}},S1_2top};	// S2_bot = S1_bot - S1_top*2^-5;
 wire S2_2bot_c1, S2_2bot_c2, S2_2bot_c3, S2_2bot_c4;
 assign S2_2bot[0] = S1_2top[0];
 FA_Cir_Cin0 S22btm1 (.iA (~S1_2top[1]), .iB (~S1_2top[0]), .oS (S2_2bot[1]), .oC (S2_2bot_c1));
 FA_Cir_Cin0 S22btm2 (.iA (~S1_2top[2]), .iB (S2_2bot_c1),  .oS (S2_2bot[2]), .oC (S2_2bot_c2));
 FA_Cir_Cin0 S22btm3 (.iA (~S1_2top[3]), .iB (S2_2bot_c2),  .oS (S2_2bot[3]), .oC (S2_2bot_c3));
 FA_Cir_Cin0 S22btm4 (.iA (~S1_2top[4]), .iB (S2_2bot_c3),  .oS (S2_2bot[4]), .oC (S2_2bot_c4));
 Ripple_Add_13bit S22btm5 (
	.iA (S1_2bot),		.iB (~{{(5){S1_2top[11]}},S1_2top[11:5]}),
	.iC (S2_2bot_c4),	.oS (S2_2bot[17:5]));
 
 assign o2a = S2_2top;
 assign o2b = S2_2bot;

 /* 7pi/32 */
 wire	/*11.0*/	[10:0]	S1_3top, S1_3bot;
 wire	/*12.3*/	[14:0]	S2_3top, S2_3bot;
 
 //assign S1_3top = {iA[9],iA} + {iB[9],iB};	// S1_top = a + b;
 wire S1_3top_c0;
 FA_Cir_Cin0 S13tpm0 (.iA (iA[0]), .iB (iB[0]), .oS (S1_3top[0]), .oC (S1_3top_c0));
 Ripple_Add_10bit S13tpm1 (
	.iA (iA[9:1]),		.iB (iB[9:1]),
	.iC (S1_3top_c0),	.oS (S1_3top[10:1]));
 
 //assign S1_3bot = {iB[9],iB} - {iA[9],iA};	// S1_bot = b - a;
 wire S1_3bot_c1;
 FA_Cir_Cin1 S13btm1 (.iA (iB[0]), .iB (~iA[0]), .oS (S1_3bot[0]), .oC (S1_3bot_c1));
 Ripple_Add_10bit S13btm2 (
	.iA (iB[9:1]),		.iB (~iA[9:1]),
	.iC (S1_3bot_c1),	.oS (S1_3bot[10:1]));
 
 //assign S2_3top = {S1_3top[10],S1_3top,3'b0} - {{(4){S1_3bot[10]}},S1_3bot};	// S2_top = S1_top - S1_bot*2^-3;
 wire S2_3top_c1, S2_3top_c2;
 assign S2_3top[0] = S1_3bot[0];
 FA_Cir_Cin0 S23tpm1 (.iA (~S1_3bot[1]), .iB (~S1_3bot[0]), .oS (S2_3top[1]), .oC (S2_3top_c1));
 FA_Cir_Cin0 S23tpm2 (.iA (~S1_3bot[2]), .iB (S2_3top_c1),  .oS (S2_3top[2]), .oC (S2_3top_c2));
 Ripple_Add_12bit S23tpm3 (
	.iA (S1_3top),		.iB (~{{(3){S1_3bot[10]}},S1_3bot[10:3]}),
	.iC (S2_3top_c2),	.oS (S2_3top[14:3]));
 
 //assign S2_3bot = {S1_3bot[10],S1_3bot,3'b0} + {{(4){S1_3top[10]}},S1_3top};	// S2_bot = S1_bot + S1_top*2^-3;
 wire S2_3bot_c3;
 assign S2_3bot[2:0] = S1_3top[2:0];
 FA_Cir_Cin0 S23btm3 (.iA (S1_3bot[0]), .iB (S1_3top[3]), .oS (S2_3bot[3]), .oC (S2_3bot_c3));
 Ripple_Add_11bit S23btm4 (
	.iA (S1_3bot[10:1]),	.iB ({{(3){S1_3top[10]}},S1_3top[10:4]}),
	.iC (S2_3bot_c3),		.oS (S2_3bot[14:4]));
 
 assign o3a = S2_3top;
 assign o3b = S2_3bot;

endmodule

module ACor_DCT_32p_1to15_pi64_2Stg (
	// Input Signals
	input	[8:0]	/* 9.0 */	iA, iB,
	
	// Output Signals
	output	[20:0]	/*11.10*/	o0a, o0b,
	output	[19:0]	/*11.9 */	o1a, o1b,
	output	[20:0]	/*11.10*/	o2a, o2b,
	output	[15:0]	/*11.5 */	o3a, o3b,
	output	[17:0]	/*11.7 */	o4a, o4b,
	output	[15:0]	/*11.5 */	o5a, o5b,
	output	[13:0]	/*11.3 */	o6a, o6b,
	output	[14:0]	/*11.4 */	o7a, o7b
);

 /* pi/64 */
 wire	/*10.4 */	[13:0]	S1_0top, S1_0bot;
 wire	/*11.10*/	[20:0]	S2_0top, S2_0bot;
 
 //assign S1_0top = {iB[8],iB,4'b0} + {{(5){iA[8]}},iA};	// S1_top = b + a*2^-4;
 wire S1_0top_c4;
 assign S1_0top[3:0] = iA[3:0];
 FA_Cir_Cin0 S10tpm4 (.iA (iB[0]), .iB (iA[4]), .oS (S1_0top[4]), .oC (S1_0top_c4));
 Ripple_Add_9bit S10tpm5 (
	.iA (iB[8:1]),		.iB ({{(4){iA[8]}},iA[8:5]}),
	.iC (S1_0top_c4),	.oS (S1_0top[13:5]));
 
 //assign S1_0bot = {iA[8],iA,4'b0} - {{(5){iB[8]}},iB};	// S1_bot = a - b*2^-4;
 wire S1_0bot_c1, S1_0bot_c2, S1_0bot_c3;
 assign S1_0bot[0] = iB[0];
 FA_Cir_Cin0 S10btm1 (.iA (~iB[1]), .iB (~iB[0]),     .oS (S1_0bot[1]), .oC (S1_0bot_c1));
 FA_Cir_Cin0 S10btm2 (.iA (~iB[2]), .iB (S1_0bot_c1), .oS (S1_0bot[2]), .oC (S1_0bot_c2));
 FA_Cir_Cin0 S10btm3 (.iA (~iB[3]), .iB (S1_0bot_c2), .oS (S1_0bot[3]), .oC (S1_0bot_c3));
 Ripple_Add_10bit S10btm4 (
	.iA (iA),			.iB (~{{(4){iB[8]}},iB[8:4]}),
	.iC (S1_0bot_c3),	.oS (S1_0bot[13:4]));
 
 //assign S2_0top = {S1_0top[13],S1_0top,6'b0} - {{(7){S1_0bot[13]}},S1_0bot};	// S2_top = S1_top - S1_bot*2^-6;
 wire S2_0top_c1, S2_0top_c2, S2_0top_c3, S2_0top_c4, S2_0top_c5;
 assign S2_0top[0] = S1_0bot[0];
 FA_Cir_Cin0 S20tpm1 (.iA (~S1_0bot[1]), .iB (~S1_0bot[0]), .oS (S2_0top[1]), .oC (S2_0top_c1));
 FA_Cir_Cin0 S20tpm2 (.iA (~S1_0bot[2]), .iB (S2_0top_c1),  .oS (S2_0top[2]), .oC (S2_0top_c2));
 FA_Cir_Cin0 S20tpm3 (.iA (~S1_0bot[3]), .iB (S2_0top_c2),  .oS (S2_0top[3]), .oC (S2_0top_c3));
 FA_Cir_Cin0 S20tpm4 (.iA (~S1_0bot[4]), .iB (S2_0top_c3),  .oS (S2_0top[4]), .oC (S2_0top_c4));
 FA_Cir_Cin0 S20tpm5 (.iA (~S1_0bot[5]), .iB (S2_0top_c4),  .oS (S2_0top[5]), .oC (S2_0top_c5));
 Ripple_Add_15bit S20tpm6 (
	.iA (S1_0top),		.iB (~{{(6){S1_0bot[13]}},S1_0bot[13:6]}),
	.iC (S2_0top_c5),	.oS (S2_0top[20:6]));
 
 //assign S2_0bot = {S1_0bot[13],S1_0bot,6'b0} + {{(7){S1_0top[13]}},S1_0top};	// S2_bot = S1_bot + S1_top*2^-6;
 wire S2_0bot_c6;
 assign S2_0bot[5:0] = S1_0top[5:0];
 FA_Cir_Cin0 S20btm6 (.iA (S1_0bot[0]), .iB (S1_0top[6]), .oS (S2_0bot[6]), .oC (S2_0bot_c6));
 Ripple_Add_14bit S20btm7 (
	.iA (S1_0bot[13:1]),	.iB ({{(6){S1_0top[13]}},S1_0top[13:7]}),
	.iC (S2_0bot_c6),		.oS (S2_0bot[20:7]));
 
 assign o0a = S2_0top; 
 assign o0b = S2_0bot; 

 /* 3pi/64 */
 wire	/*10.3 */	[12:0]	S1_1top, S1_1bot;
 wire	/*11.9 */	[19:0]	S2_1top, S2_1bot;
 
 //assign S1_1top = {iA[8],iA,3'b0} + {{(4){iB[8]}},iB};	// S1_top = a + b*2^-3;
 wire S1_1top_c3;
 assign S1_1top[2:0] = iB[2:0];
 FA_Cir_Cin0 S11tpm3 (.iA (iA[0]), .iB (iB[3]), .oS (S1_1top[3]), .oC (S1_1top_c3));
 Ripple_Add_9bit S11tpm4 (
	.iA (iA[8:1]),		.iB ({{(3){iB[8]}},iB[8:4]}),
	.iC (S1_1top_c3),	.oS (S1_1top[12:4]));
 
 //assign S1_1bot = {iB[8],iB,3'b0} - {{(4){iA[8]}},iA};	// S1_bot = b - a*2^-3;
 wire S1_1bot_c1, S1_1bot_c2;
 assign S1_1bot[0] = iA[0];
 FA_Cir_Cin0 S11btm1 (.iA (~iA[1]), .iB (~iA[0]),     .oS (S1_1bot[1]), .oC (S1_1bot_c1));
 FA_Cir_Cin0 S11btm2 (.iA (~iA[2]), .iB (S1_1bot_c1), .oS (S1_1bot[2]), .oC (S1_1bot_c2));
 Ripple_Add_10bit S11btm3 (
	.iA (iB),			.iB (~{{(3){iA[8]}},iA[8:3]}),
	.iC (S1_1bot_c2),	.oS (S1_1bot[12:3]));
 
 //assign S2_1top = {S1_1top[12],S1_1top,6'b0} + {{(7){S1_1bot[12]}},S1_1bot};	// S2_top = S1_top + S1_bot*2^-6;
 wire S2_1top_c6;
 assign S2_1top[5:0] = S1_1bot[5:0];
 FA_Cir_Cin0 S21tpm6 (.iA (S1_1top[0]), .iB (S1_1bot[6]), .oS (S2_1top[6]), .oC (S2_1top_c6));
 Ripple_Add_13bit S21tpm7 (
	.iA (S1_1top[12:1]),	.iB ({{(6){S1_1bot[12]}},S1_1bot[12:7]}),
	.iC (S2_1top_c6),		.oS (S2_1top[19:7]));
 
 //assign S2_1bot = {S1_1bot[12],S1_1bot,6'b0} - {{(7){S1_1top[12]}},S1_1top};	// S2_bot = S1_bot - S1_top*2^-6;
 wire S2_1bot_c1, S2_1bot_c2, S2_1bot_c3, S2_1bot_c4, S2_1bot_c5;
 assign S2_1bot[0] = S1_1top[0];
 FA_Cir_Cin0 S21btm1 (.iA (~S1_1top[1]), .iB (~S1_1top[0]), .oS (S2_1bot[1]), .oC (S2_1bot_c1));
 FA_Cir_Cin0 S21btm2 (.iA (~S1_1top[2]), .iB (S2_1bot_c1),  .oS (S2_1bot[2]), .oC (S2_1bot_c2));
 FA_Cir_Cin0 S21btm3 (.iA (~S1_1top[3]), .iB (S2_1bot_c2),  .oS (S2_1bot[3]), .oC (S2_1bot_c3));
 FA_Cir_Cin0 S21btm4 (.iA (~S1_1top[4]), .iB (S2_1bot_c3),  .oS (S2_1bot[4]), .oC (S2_1bot_c4));
 FA_Cir_Cin0 S21btm5 (.iA (~S1_1top[5]), .iB (S2_1bot_c4),  .oS (S2_1bot[5]), .oC (S2_1bot_c5));
 Ripple_Add_14bit S21btm6 (
	.iA (S1_1bot),		.iB (~{{(6){S1_1top[12]}},S1_1top[12:6]}),
	.iC (S2_1bot_c5),	.oS (S2_1bot[19:6]));
 
 assign o1a = S2_1top;
 assign o1b = S2_1bot;

 /* 5pi/64 */
 wire	/*10.2 */	[11:0]	S1_2top, S1_2bot;
 wire	/*11.10*/	[20:0]	S2_2top, S2_2bot;
 
 //assign S1_2top = {iB[8],iB,2'b0} + {{(3){iA[8]}},iA};	// S1_top = b + a*2^-2;
 wire S1_2top_c2;
 assign S1_2top[1:0] = iA[1:0];
 FA_Cir_Cin0 S12tpm2 (.iA (iB[0]), .iB (iA[2]), .oS (S1_2top[2]), .oC (S1_2top_c2));
 Ripple_Add_9bit S12tpm3 (
	.iA (iB[8:1]),		.iB ({{(2){iA[8]}},iA[8:3]}),
	.iC (S1_2top_c2),	.oS (S1_2top[11:3]));
 
 //assign S1_2bot = {iA[8],iA,2'b0} - {{(3){iB[8]}},iB};	// S1_bot = a - b*2^-2;
 wire S1_2bot_c1;
 assign S1_2bot[0] = iB[0];
 FA_Cir_Cin0 S12btm1 (.iA (~iB[1]), .iB (~iB[0]), .oS (S1_2bot[1]), .oC (S1_2bot_c1));
 Ripple_Add_10bit S12btm2 (
	.iA (iA),			.iB (~{{(2){iB[8]}},iB[8:2]}),
	.iC (S1_2bot_c1),	.oS (S1_2bot[11:2]));
 
 //assign S2_2top = {S1_2top[11],S1_2top,8'b0} + {{(12){S1_2bot[11]}},S1_2bot[11:3]};	// S2_top = S1_top + S1_bot*2^-11;
 wire S2_2top_c8;
 assign S2_2top[7:0] = S1_2bot[10:3];
 FA_Cir_Cin0 S22tpm8 (.iA (S1_2top[0]), .iB (S1_2bot[11]), .oS (S2_2top[8]), .oC (S2_2top_c8));
 Ripple_Add_12bit S22tpm9 (
	.iA (S1_2top[11:1]),	.iB ({(11){S1_2bot[11]}}),
	.iC (S2_2top_c8),		.oS (S2_2top[20:9]));
 
 //assign S2_2bot = {S1_2bot[11],S1_2bot,8'b0} - {{(12){S1_2top[11]}},S1_2top[11:3]};	// S2_bot = S1_bot - S1_top*2^-11;
 wire S2_2bot_c1, S2_2bot_c2, S2_2bot_c3, S2_2bot_c4, S2_2bot_c5, S2_2bot_c6, S2_2bot_c7;
 assign S2_2bot[0] = S1_2top[3];
 FA_Cir_Cin0 S22btm1 (.iA (~S1_2top[4]),  .iB (~S1_2top[3]), .oS (S2_2bot[1]), .oC (S2_2bot_c1));
 FA_Cir_Cin0 S22btm2 (.iA (~S1_2top[5]),  .iB (S2_2bot_c1),  .oS (S2_2bot[2]), .oC (S2_2bot_c2));
 FA_Cir_Cin0 S22btm3 (.iA (~S1_2top[6]),  .iB (S2_2bot_c2),  .oS (S2_2bot[3]), .oC (S2_2bot_c3));
 FA_Cir_Cin0 S22btm4 (.iA (~S1_2top[7]),  .iB (S2_2bot_c3),  .oS (S2_2bot[4]), .oC (S2_2bot_c4));
 FA_Cir_Cin0 S22btm5 (.iA (~S1_2top[8]),  .iB (S2_2bot_c4),  .oS (S2_2bot[5]), .oC (S2_2bot_c5));
 FA_Cir_Cin0 S22btm6 (.iA (~S1_2top[9]),  .iB (S2_2bot_c5),  .oS (S2_2bot[6]), .oC (S2_2bot_c6));
 FA_Cir_Cin0 S22btm7 (.iA (~S1_2top[10]), .iB (S2_2bot_c6),  .oS (S2_2bot[7]), .oC (S2_2bot_c7));
 Ripple_Add_13bit S22btm8 (
	.iA (S1_2bot),		.iB (~{{(10){S1_2top[11]}},S1_2top[11:10]}),
	.iC (S2_2bot_c7),	.oS (S2_2bot[20:8]));
 
 assign o2a = S2_2top;
 assign o2b = S2_2bot;

 /* 7pi/64 */
 wire	/*10.2 */	[11:0]	S1_3top, S1_3bot;
 wire	/*11.5 */	[15:0]	S2_3top, S2_3bot;
 
 //assign S1_3top = {iA[8],iA,2'b0} + {{(3){iB[8]}},iB};	// S1_top = a + b*2^-2;
 wire S1_3top_c2;
 assign S1_3top[1:0] = iB[1:0];
 FA_Cir_Cin0 S13tpm2 (.iA (iA[0]), .iB (iB[2]), .oS (S1_3top[2]), .oC (S1_3top_c2));
 Ripple_Add_9bit S13tpm3 (
	.iA (iA[8:1]),		.iB ({{(2){iB[8]}},iB[8:3]}),
	.iC (S1_3top_c2),	.oS (S1_3top[11:3]));
 
 //assign S1_3bot = {iB[8],iB,2'b0} - {{(3){iA[8]}},iA};	// S1_bot = b - a*2^-2;
 wire S1_3bot_c1;
 assign S1_3bot[0] = iA[0];
 FA_Cir_Cin0 S13btm1 (.iA (~iA[1]), .iB (~iA[0]), .oS (S1_3bot[1]), .oC (S1_3bot_c1));
 Ripple_Add_10bit S13btm2 (
	.iA (iB),			.iB (~{{(2){iA[8]}},iA[8:2]}),
	.iC (S1_3bot_c1),	.oS (S1_3bot[11:2]));
 
 //assign S2_3top = {S1_3top[11],S1_3top,3'b0} + {{(4){S1_3bot[11]}},S1_3bot};	// S2_top = S1_top + S1_bot*2^-3;
 wire S2_3top_c3;
 assign S2_3top[2:0] = S1_3bot[2:0];
 FA_Cir_Cin0 S23tpm3 (.iA (S1_3top[0]), .iB (S1_3bot[3]), .oS (S2_3top[3]), .oC (S2_3top_c3));
 Ripple_Add_12bit S23tpm4 (
	.iA (S1_3top[11:1]),	.iB ({{(3){S1_3bot[11]}},S1_3bot[11:4]}),
	.iC (S2_3top_c3),		.oS (S2_3top[15:4]));
 
 //assign S2_3bot = {S1_3bot[11],S1_3bot,3'b0} - {{(4){S1_3top[11]}},S1_3top};	// S2_bot = S1_bot - S1_top*2^-3;
 wire S2_3bot_c1, S2_3bot_c2;
 assign S2_3bot[0] = S1_3top[0];
 FA_Cir_Cin0 S23btm1 (.iA (~S1_3top[1]), .iB (~S1_3top[0]), .oS (S2_3bot[1]), .oC (S2_3bot_c1));
 FA_Cir_Cin0 S23btm2 (.iA (~S1_3top[2]), .iB (S2_3bot_c1),  .oS (S2_3bot[2]), .oC (S2_3bot_c2));
 Ripple_Add_13bit S23btm3 (
	.iA (S1_3bot),		.iB (~{{(3){S1_3top[11]}},S1_3top[11:3]}),
	.iC (S2_3bot_c2),	.oS (S2_3bot[15:3]));
 
 assign o3a = S2_3top;
 assign o3b = S2_3bot;

 /* 9pi/64 */
 wire	/*10.1 */	[10:0]	S1_4top, S1_4bot;
 wire	/*11.7 */	[17:0]	S2_4top, S2_4bot;
 
 //assign S1_4top = {iB[8],iB,1'b0} + {{(2){iA[8]}},iA};	// S1_top = b + a*2^-1;
 wire S1_4top_c1;
 assign S1_4top[0] = iA[0];
 FA_Cir_Cin0 S14tpm1 (.iA (iB[0]), .iB (iA[1]), .oS (S1_4top[1]), .oC (S1_4top_c1));
 Ripple_Add_9bit S14tpm2 (
	.iA (iB[8:1]),		.iB ({iA[8],iA[8:2]}),
	.iC (S1_4top_c1),	.oS (S1_4top[10:2]));
 
 //assign S1_4bot = {iA[8],iA,1'b0} - {{(2){iB[8]}},iB};	// S1_bot = a - b*2^-1;
 assign S1_4bot[0] = iB[0];
 Ripple_Add_10bit S14btm0 (
	.iA (iA),		.iB (~{iB[8],iB[8:1]}),
	.iC (~iB[0]),	.oS (S1_4bot[10:1]));
 
 //assign S2_4top = {S1_4top[10],S1_4top,6'b0} - {{(7){S1_4bot[10]}},S1_4bot};	// S2_top = S1_top - S1_bot*2^-6;
 wire S2_4top_c1, S2_4top_c2, S2_4top_c3, S2_4top_c4, S2_4top_c5;
 assign S2_4top[0] = S1_4bot[0];
 FA_Cir_Cin0 S24tpm1 (.iA (~S1_4bot[1]), .iB (~S1_4bot[0]), .oS (S2_4top[1]), .oC (S2_4top_c1));
 FA_Cir_Cin0 S24tpm2 (.iA (~S1_4bot[2]), .iB (S2_4top_c1),  .oS (S2_4top[2]), .oC (S2_4top_c2));
 FA_Cir_Cin0 S24tpm3 (.iA (~S1_4bot[3]), .iB (S2_4top_c2),  .oS (S2_4top[3]), .oC (S2_4top_c3));
 FA_Cir_Cin0 S24tpm4 (.iA (~S1_4bot[4]), .iB (S2_4top_c3),  .oS (S2_4top[4]), .oC (S2_4top_c4));
 FA_Cir_Cin0 S24tpm5 (.iA (~S1_4bot[5]), .iB (S2_4top_c4),  .oS (S2_4top[5]), .oC (S2_4top_c5));
 Ripple_Add_12bit S24tpm6 (
	.iA (S1_4top),		.iB (~{{(6){S1_4bot[10]}},S1_4bot[10:6]}),
	.iC (S2_4top_c5),	.oS (S2_4top[17:6]));
 
 //assign S2_4bot = {S1_4bot[10],S1_4bot,6'b0} + {{(7){S1_4top[10]}},S1_4top};	// S2_bot = S1_bot + S1_top*2^-6;
 wire S2_4bot_c6;
 assign S2_4bot[5:0] = S1_4top[5:0];
 FA_Cir_Cin0 S24btm6 (.iA (S1_4bot[0]), .iB (S1_4top[6]), .oS (S2_4bot[6]), .oC (S2_4bot_c6));
 Ripple_Add_11bit S24btm7 (
	.iA (S1_4bot[10:1]),	.iB ({{(6){S1_4top[10]}},S1_4top[10:7]}),
	.iC (S2_4bot_c6),		.oS (S2_4bot[17:7]));
 
 assign o4a = S2_4top;
 assign o4b = S2_4bot;

 /* 11pi/64 */
 wire	/*10.1 */	[10:0]	S1_5top, S1_5bot;
 wire	/*11.5 */	[15:0]	S2_5top, S2_5bot;
 
 //assign S1_5top = {iA[8],iA,1'b0} + {{(2){iB[8]}},iB};	// S1_top = a + b*2^-1;
 wire S1_5top_c1;
 assign S1_5top[0] = iB[0];
 FA_Cir_Cin0 S15tpm1 (.iA (iA[0]), .iB (iB[1]), .oS (S1_5top[1]), .oC (S1_5top_c1));
 Ripple_Add_9bit S15tpm2 (
	.iA (iA[8:1]),		.iB ({iB[8],iB[8:2]}),
	.iC (S1_5top_c1),	.oS (S1_5top[10:2]));
 
 //assign S1_5bot = {iB[8],iB,1'b0} - {{(2){iA[8]}},iA};	// S1_bot = b - a*2^-1;
 assign S1_5bot[0] = iA[0];
 Ripple_Add_10bit S15btm0 (
	.iA (iB),		.iB (~{iA[8],iA[8:1]}),
	.iC (~iA[0]),	.oS (S1_5bot[10:1]));
 
 //assign S2_5top = {S1_5top[10],S1_5top,4'b0} + {{(5){S1_5bot[10]}},S1_5bot};	// S2_top = S1_top + S1_bot*2^-4;
 wire S2_5top_c4;
 assign S2_5top[3:0] = S1_5bot[3:0];
 FA_Cir_Cin0 S25tpm4 (.iA (S1_5top[0]), .iB (S1_5bot[4]), .oS (S2_5top[4]), .oC (S2_5top_c4));
 Ripple_Add_11bit S25tpm5 (
	.iA (S1_5top[10:1]),	.iB ({{(4){S1_5bot[10]}},S1_5bot[10:5]}),
	.iC (S2_5top_c4),		.oS (S2_5top[15:5]));
 
 //assign S2_5bot = {S1_5bot[10],S1_5bot,4'b0} - {{(5){S1_5top[10]}},S1_5top};	// S2_bot = S1_bot - S1_top*2^-4;
 wire S2_5bot_c1, S2_5bot_c2, S2_5bot_c3;
 assign S2_5bot[0] = S1_5top[0];
 FA_Cir_Cin0 S25btm1 (.iA (~S1_5top[1]), .iB (~S1_5top[0]), .oS (S2_5bot[1]), .oC (S2_5bot_c1));
 FA_Cir_Cin0 S25btm2 (.iA (~S1_5top[2]), .iB (S2_5bot_c1),  .oS (S2_5bot[2]), .oC (S2_5bot_c2));
 FA_Cir_Cin0 S25btm3 (.iA (~S1_5top[3]), .iB (S2_5bot_c2),  .oS (S2_5bot[3]), .oC (S2_5bot_c3));
 Ripple_Add_12bit S25btm4 (
	.iA (S1_5bot),		.iB (~{{(4){S1_5top[10]}},S1_5top[10:4]}),
	.iC (S2_5bot_c3),	.oS (S2_5bot[15:4]));
 
 assign o5a = S2_5top;
 assign o5b = S2_5bot;

 /* 13pi/64 */
 wire	/*10.0 */	[9:0]	S1_6top, S1_6bot;
 wire	/*11.3 */	[13:0]	S2_6top, S2_6bot;
 
 //assign S1_6top = {iB[8],iB} + {iA[8],iA};	// S1_top = b + a;
 wire S1_6top_c0;
 FA_Cir_Cin0 S16tpm0 (.iA (iB[0]), .iB (iA[0]), .oS (S1_6top[0]), .oC (S1_6top_c0));
 Ripple_Add_9bit S16tpm1 (
	.iA (iB[8:1]),		.iB (iA[8:1]),
	.iC (S1_6top_c0),	.oS (S1_6top[9:1]));
 
 //assign S1_6bot = {iA[8],iA} - {iB[8],iB};	// S1_bot = a - b;
 wire S1_6bot_c0;
 FA_Cir_Cin1 S16btm0 (.iA (iA[0]), .iB (~iB[0]), .oS (S1_6bot[0]), .oC (S1_6bot_c0));
 Ripple_Add_9bit S16btm1 (
	.iA (iA[8:1]),		.iB (~iB[8:1]),
	.iC (S1_6bot_c0),	.oS (S1_6bot[9:1]));
 
 //assign S2_6top = {S1_6top[9],S1_6top,3'b0} - {{(4){S1_6bot[9]}},S1_6bot};	// S2_top = S1_top - S1_bot*2^-3;
 wire S2_6top_c1, S2_6top_c2;
 assign S2_6top[0] = S1_6bot[0];
 FA_Cir_Cin0 S26tpm1 (.iA (~S1_6bot[1]), .iB (~S1_6bot[0]), .oS (S2_6top[1]), .oC (S2_6top_c1));
 FA_Cir_Cin0 S26tpm2 (.iA (~S1_6bot[2]), .iB (S2_6top_c1),  .oS (S2_6top[2]), .oC (S2_6top_c2));
 Ripple_Add_11bit S26tpm3 (
	.iA (S1_6top),		.iB (~{{(3){S1_6bot[9]}},S1_6bot[9:3]}),
	.iC (S2_6top_c2),	.oS (S2_6top[13:3]));
 
 //assign S2_6bot = {S1_6bot[9],S1_6bot,3'b0} + {{(4){S1_6top[9]}},S1_6top};	// S2_bot = S1_bot + S1_top*2^-3;
 wire S2_6bot_c3;
 assign S2_6bot[2:0] = S1_6top[2:0];
 FA_Cir_Cin0 S26btm3 (.iA (S1_6bot[0]), .iB (S1_6top[3]), .oS (S2_6bot[3]), .oC (S2_6bot_c3));
 Ripple_Add_10bit S26btm4 (
	.iA (S1_6bot[9:1]),	.iB ({{(3){S1_6top[9]}},S1_6top[9:4]}),
	.iC (S2_6bot_c3),	.oS (S2_6bot[13:4]));
 
 assign o6a = S2_6top;
 assign o6b = S2_6bot;

 /* 15pi/64 */
 wire	/*10.0 */	[9:0]	S1_7top, S1_7bot;
 wire	/*11.4 */	[14:0]	S2_7top, S2_7bot;
 
 //assign S1_7top = {iA[8],iA} + {iB[8],iB};	// S1_top = a + b;
 wire S1_7top_c0;
 FA_Cir_Cin0 S17tpm0 (.iA (iA[0]), .iB (iB[0]), .oS (S1_7top[0]), .oC (S1_7top_c0));
 Ripple_Add_9bit S17tpm1 (
	.iA (iA[8:1]),		.iB (iB[8:1]),
	.iC (S1_7top_c0),	.oS (S1_7top[9:1]));
 
 //assign S1_7bot = {iB[8],iB} - {iA[8],iA};	// S1_bot = b - a;
 wire S1_7bot_c0;
 FA_Cir_Cin1 S17btm0 (.iA (iB[0]), .iB (~iA[0]), .oS (S1_7bot[0]), .oC (S1_7bot_c0));
 Ripple_Add_9bit S17btm1 (
	.iA (iB[8:1]),		.iB (~iA[8:1]),
	.iC (S1_7bot_c0),	.oS (S1_7bot[9:1]));
 
 //assign S2_7top = {S1_7top[9],S1_7top,4'b0} - {{(5){S1_7bot[9]}},S1_7bot};	// S2_top = S1_top - S1_bot*2^-4;
 wire S2_7top_c1, S2_7top_c2, S2_7top_c3;
 assign S2_7top[0] = S1_7bot[0];
 FA_Cir_Cin0 S27tpm1 (.iA (~S1_7bot[1]), .iB (~S1_7bot[0]), .oS (S2_7top[1]), .oC (S2_7top_c1));
 FA_Cir_Cin0 S27tpm2 (.iA (~S1_7bot[2]), .iB (S2_7top_c1),  .oS (S2_7top[2]), .oC (S2_7top_c2));
 FA_Cir_Cin0 S27tpm3 (.iA (~S1_7bot[3]), .iB (S2_7top_c2),  .oS (S2_7top[3]), .oC (S2_7top_c3));
 Ripple_Add_11bit S27tpm4 (
	.iA (S1_7top),		.iB (~{{(4){S1_7bot[9]}},S1_7bot[9:4]}),
	.iC (S2_7top_c3),	.oS (S2_7top[14:4]));
 
 //assign S2_7bot = {S1_7bot[9],S1_7bot,4'b0} + {{(5){S1_7top[9]}},S1_7top};	// S2_bot = S1_bot + S1_top*2^-4;
 wire S2_7bot_c4;
 assign S2_7bot[3:0] = S1_7top[3:0];
 FA_Cir_Cin0 S27btm4 (.iA (S1_7bot[0]), .iB (S1_7top[4]), .oS (S2_7bot[4]), .oC (S2_7bot_c4));
 Ripple_Add_10bit S27btm5 (
	.iA (S1_7bot[9:1]),	.iB ({{(4){S1_7top[9]}},S1_7top[9:5]}),
	.iC (S2_7bot_c4),	.oS (S2_7bot[14:5]));
 
 assign o7a = S2_7top;
 assign o7b = S2_7bot;

endmodule

module Ripple_Add_8bit (
	input	[6:0]	iA, iB,
	input			iC,
	output	[7:0]	oS
);

wire	[5:0]	C;
FA_Cir S0 (.iA (iA[0]), .iB (iB[0]), .iC (iC),   .oS (oS[0]), .oC (C[0]));
FA_Cir S1 (.iA (iA[1]), .iB (iB[1]), .iC (C[0]), .oS (oS[1]), .oC (C[1]));
FA_Cir S2 (.iA (iA[2]), .iB (iB[2]), .iC (C[1]), .oS (oS[2]), .oC (C[2]));
FA_Cir S3 (.iA (iA[3]), .iB (iB[3]), .iC (C[2]), .oS (oS[3]), .oC (C[3]));
FA_Cir S4 (.iA (iA[4]), .iB (iB[4]), .iC (C[3]), .oS (oS[4]), .oC (C[4]));
FA_Cir S5 (.iA (iA[5]), .iB (iB[5]), .iC (C[4]), .oS (oS[5]), .oC (C[5]));

wire	X, V;
assign X = iA[6]^iB[6];
assign V = iA[6]&iB[6];
assign oS[6] = X^C[5];
assign oS[7] = (X) ? ~(V|C[5]) : V;

endmodule

module Ripple_Add_9bit (
	input	[7:0]	iA, iB,
	input			iC,
	output	[8:0]	oS
);

wire	[6:0]	C;
FA_Cir S0 (.iA (iA[0]), .iB (iB[0]), .iC (iC),   .oS (oS[0]), .oC (C[0]));
FA_Cir S1 (.iA (iA[1]), .iB (iB[1]), .iC (C[0]), .oS (oS[1]), .oC (C[1]));
FA_Cir S2 (.iA (iA[2]), .iB (iB[2]), .iC (C[1]), .oS (oS[2]), .oC (C[2]));
FA_Cir S3 (.iA (iA[3]), .iB (iB[3]), .iC (C[2]), .oS (oS[3]), .oC (C[3]));
FA_Cir S4 (.iA (iA[4]), .iB (iB[4]), .iC (C[3]), .oS (oS[4]), .oC (C[4]));
FA_Cir S5 (.iA (iA[5]), .iB (iB[5]), .iC (C[4]), .oS (oS[5]), .oC (C[5]));
FA_Cir S6 (.iA (iA[6]), .iB (iB[6]), .iC (C[5]), .oS (oS[6]), .oC (C[6]));

wire	X, V;
assign X = iA[7]^iB[7];
assign V = iA[7]&iB[7];
assign oS[7] = X^C[6];
assign oS[8] = (X) ? ~(V|C[6]) : V;

endmodule

module Ripple_Add_10bit (
	input	[8:0]	iA, iB,
	input			iC,
	output	[9:0]	oS
);

wire	[7:0]	C;
FA_Cir S0 (.iA (iA[0]), .iB (iB[0]), .iC (iC),   .oS (oS[0]), .oC (C[0]));
FA_Cir S1 (.iA (iA[1]), .iB (iB[1]), .iC (C[0]), .oS (oS[1]), .oC (C[1]));
FA_Cir S2 (.iA (iA[2]), .iB (iB[2]), .iC (C[1]), .oS (oS[2]), .oC (C[2]));
FA_Cir S3 (.iA (iA[3]), .iB (iB[3]), .iC (C[2]), .oS (oS[3]), .oC (C[3]));
FA_Cir S4 (.iA (iA[4]), .iB (iB[4]), .iC (C[3]), .oS (oS[4]), .oC (C[4]));
FA_Cir S5 (.iA (iA[5]), .iB (iB[5]), .iC (C[4]), .oS (oS[5]), .oC (C[5]));
FA_Cir S6 (.iA (iA[6]), .iB (iB[6]), .iC (C[5]), .oS (oS[6]), .oC (C[6]));
FA_Cir S7 (.iA (iA[7]), .iB (iB[7]), .iC (C[6]), .oS (oS[7]), .oC (C[7]));

wire	X, V;
assign X = iA[8]^iB[8];
assign V = iA[8]&iB[8];
assign oS[8] = X^C[7];
assign oS[9] = (X) ? ~(V|C[7]) : V;

endmodule

module Ripple_Add_11bit (
	input	[9:0]	iA, iB,
	input			iC,
	output	[10:0]	oS
);

wire	[8:0]	C;
FA_Cir S0 (.iA (iA[0]), .iB (iB[0]), .iC (iC),   .oS (oS[0]),  .oC (C[0]));
FA_Cir S1 (.iA (iA[1]), .iB (iB[1]), .iC (C[0]), .oS (oS[1]),  .oC (C[1]));
FA_Cir S2 (.iA (iA[2]), .iB (iB[2]), .iC (C[1]), .oS (oS[2]),  .oC (C[2]));
FA_Cir S3 (.iA (iA[3]), .iB (iB[3]), .iC (C[2]), .oS (oS[3]),  .oC (C[3]));
FA_Cir S4 (.iA (iA[4]), .iB (iB[4]), .iC (C[3]), .oS (oS[4]),  .oC (C[4]));
FA_Cir S5 (.iA (iA[5]), .iB (iB[5]), .iC (C[4]), .oS (oS[5]),  .oC (C[5]));
FA_Cir S6 (.iA (iA[6]), .iB (iB[6]), .iC (C[5]), .oS (oS[6]),  .oC (C[6]));
FA_Cir S7 (.iA (iA[7]), .iB (iB[7]), .iC (C[6]), .oS (oS[7]),  .oC (C[7]));
FA_Cir S8 (.iA (iA[8]), .iB (iB[8]), .iC (C[7]), .oS (oS[8]),  .oC (C[8]));

wire	X, V;
assign X = iA[9]^iB[9];
assign V = iA[9]&iB[9];
assign oS[9]  = X^C[8];
assign oS[10] = (X) ? ~(V|C[8]) : V;

endmodule

module Ripple_Add_12bit (
	input	[10:0]	iA, iB,
	input			iC,
	output	[11:0]	oS
);

wire	[9:0]	C;
FA_Cir S0 (.iA (iA[0]), .iB (iB[0]), .iC (iC),   .oS (oS[0]), .oC (C[0]));
FA_Cir S1 (.iA (iA[1]), .iB (iB[1]), .iC (C[0]), .oS (oS[1]), .oC (C[1]));
FA_Cir S2 (.iA (iA[2]), .iB (iB[2]), .iC (C[1]), .oS (oS[2]), .oC (C[2]));
FA_Cir S3 (.iA (iA[3]), .iB (iB[3]), .iC (C[2]), .oS (oS[3]), .oC (C[3]));
FA_Cir S4 (.iA (iA[4]), .iB (iB[4]), .iC (C[3]), .oS (oS[4]), .oC (C[4]));
FA_Cir S5 (.iA (iA[5]), .iB (iB[5]), .iC (C[4]), .oS (oS[5]), .oC (C[5]));
FA_Cir S6 (.iA (iA[6]), .iB (iB[6]), .iC (C[5]), .oS (oS[6]), .oC (C[6]));
FA_Cir S7 (.iA (iA[7]), .iB (iB[7]), .iC (C[6]), .oS (oS[7]), .oC (C[7]));
FA_Cir S8 (.iA (iA[8]), .iB (iB[8]), .iC (C[7]), .oS (oS[8]), .oC (C[8]));
FA_Cir S9 (.iA (iA[9]), .iB (iB[9]), .iC (C[8]), .oS (oS[9]), .oC (C[9]));

wire	X, V;
assign X = iA[10]^iB[10];
assign V = iA[10]&iB[10];
assign oS[10] = X^C[9];
assign oS[11] = (X) ? ~(V|C[9]) : V;

endmodule

module Ripple_Add_13bit (
	input	[11:0]	iA, iB,
	input			iC,
	output	[12:0]	oS
);

wire	[10:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),   .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]), .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]), .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]), .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]), .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]), .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]), .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]), .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]), .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]), .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]), .oS (oS[10]), .oC (C[10]));

wire	X, V;
assign X = iA[11]^iB[11];
assign V = iA[11]&iB[11];
assign oS[11] = X^C[10];
assign oS[12] = (X) ? ~(V|C[10]) : V;

endmodule

module Ripple_Add_14bit (
	input	[12:0]	iA, iB,
	input			iC,
	output	[13:0]	oS
);

wire	[11:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),    .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]),  .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]),  .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]),  .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]),  .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]),  .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]),  .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]),  .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]),  .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]),  .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]),  .oS (oS[10]), .oC (C[10]));
FA_Cir S11 (.iA (iA[11]), .iB (iB[11]), .iC (C[10]), .oS (oS[11]), .oC (C[11]));

wire	X, V;
assign X = iA[12]^iB[12];
assign V = iA[12]&iB[12];
assign oS[12] = X^C[11];
assign oS[13] = (X) ? ~(V|C[11]) : V;

endmodule

module Ripple_Add_15bit (
	input	[13:0]	iA, iB,
	input			iC,
	output	[14:0]	oS
);

wire	[12:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),    .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]),  .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]),  .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]),  .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]),  .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]),  .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]),  .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]),  .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]),  .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]),  .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]),  .oS (oS[10]), .oC (C[10]));
FA_Cir S11 (.iA (iA[11]), .iB (iB[11]), .iC (C[10]), .oS (oS[11]), .oC (C[11]));
FA_Cir S12 (.iA (iA[12]), .iB (iB[12]), .iC (C[11]), .oS (oS[12]), .oC (C[12]));

wire	X, V;
assign X = iA[13]^iB[13];
assign V = iA[13]&iB[13];
assign oS[13] = X^C[12];
assign oS[14] = (X) ? ~(V|C[12]) : V;

endmodule

module Ripple_Add_16bit (
	input	[14:0]	iA, iB,
	input			iC,
	output	[15:0]	oS
);

wire	[13:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),    .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]),  .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]),  .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]),  .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]),  .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]),  .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]),  .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]),  .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]),  .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]),  .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]),  .oS (oS[10]), .oC (C[10]));
FA_Cir S11 (.iA (iA[11]), .iB (iB[11]), .iC (C[10]), .oS (oS[11]), .oC (C[11]));
FA_Cir S12 (.iA (iA[12]), .iB (iB[12]), .iC (C[11]), .oS (oS[12]), .oC (C[12]));
FA_Cir S13 (.iA (iA[13]), .iB (iB[13]), .iC (C[12]), .oS (oS[13]), .oC (C[13]));

wire	X, V;
assign X = iA[14]^iB[14];
assign V = iA[14]&iB[14];
assign oS[14] = X^C[13];
assign oS[15] = (X) ? ~(V|C[13]) : V;

endmodule

module Ripple_Add_17bit (
	input	[15:0]	iA, iB,
	input			iC,
	output	[16:0]	oS
);

wire	[14:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),    .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]),  .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]),  .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]),  .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]),  .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]),  .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]),  .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]),  .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]),  .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]),  .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]),  .oS (oS[10]), .oC (C[10]));
FA_Cir S11 (.iA (iA[11]), .iB (iB[11]), .iC (C[10]), .oS (oS[11]), .oC (C[11]));
FA_Cir S12 (.iA (iA[12]), .iB (iB[12]), .iC (C[11]), .oS (oS[12]), .oC (C[12]));
FA_Cir S13 (.iA (iA[13]), .iB (iB[13]), .iC (C[12]), .oS (oS[13]), .oC (C[13]));
FA_Cir S14 (.iA (iA[14]), .iB (iB[14]), .iC (C[13]), .oS (oS[14]), .oC (C[14]));

wire	X, V;
assign X = iA[15]^iB[15];
assign V = iA[15]&iB[15];
assign oS[15] = X^C[14];
assign oS[16] = (X) ? ~(V|C[14]) : V;

endmodule

module Ripple_Add_18bit (
	input	[16:0]	iA, iB,
	input			iC,
	output	[17:0]	oS
);

wire	[15:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),    .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]),  .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]),  .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]),  .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]),  .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]),  .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]),  .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]),  .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]),  .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]),  .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]),  .oS (oS[10]), .oC (C[10]));
FA_Cir S11 (.iA (iA[11]), .iB (iB[11]), .iC (C[10]), .oS (oS[11]), .oC (C[11]));
FA_Cir S12 (.iA (iA[12]), .iB (iB[12]), .iC (C[11]), .oS (oS[12]), .oC (C[12]));
FA_Cir S13 (.iA (iA[13]), .iB (iB[13]), .iC (C[12]), .oS (oS[13]), .oC (C[13]));
FA_Cir S14 (.iA (iA[14]), .iB (iB[14]), .iC (C[13]), .oS (oS[14]), .oC (C[14]));
FA_Cir S15 (.iA (iA[15]), .iB (iB[15]), .iC (C[14]), .oS (oS[15]), .oC (C[15]));

wire	X, V;
assign X = iA[16]^iB[16];
assign V = iA[16]&iB[16];
assign oS[16] = X^C[15];
assign oS[17] = (X) ? ~(V|C[15]) : V;

endmodule

module Ripple_Add_19bit (
	input	[17:0]	iA, iB,
	input			iC,
	output	[18:0]	oS
);

wire	[16:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),    .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]),  .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]),  .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]),  .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]),  .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]),  .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]),  .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]),  .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]),  .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]),  .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]),  .oS (oS[10]), .oC (C[10]));
FA_Cir S11 (.iA (iA[11]), .iB (iB[11]), .iC (C[10]), .oS (oS[11]), .oC (C[11]));
FA_Cir S12 (.iA (iA[12]), .iB (iB[12]), .iC (C[11]), .oS (oS[12]), .oC (C[12]));
FA_Cir S13 (.iA (iA[13]), .iB (iB[13]), .iC (C[12]), .oS (oS[13]), .oC (C[13]));
FA_Cir S14 (.iA (iA[14]), .iB (iB[14]), .iC (C[13]), .oS (oS[14]), .oC (C[14]));
FA_Cir S15 (.iA (iA[15]), .iB (iB[15]), .iC (C[14]), .oS (oS[15]), .oC (C[15]));
FA_Cir S16 (.iA (iA[16]), .iB (iB[16]), .iC (C[15]), .oS (oS[16]), .oC (C[16]));

wire	X, V;
assign X = iA[17]^iB[17];
assign V = iA[17]&iB[17];
assign oS[17] = X^C[16];
assign oS[18] = (X) ? ~(V|C[16]) : V;

endmodule

module Ripple_Add_20bit (
	input	[18:0]	iA, iB,
	input			iC,
	output	[19:0]	oS
);

wire	[17:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),    .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]),  .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]),  .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]),  .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]),  .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]),  .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]),  .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]),  .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]),  .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]),  .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]),  .oS (oS[10]), .oC (C[10]));
FA_Cir S11 (.iA (iA[11]), .iB (iB[11]), .iC (C[10]), .oS (oS[11]), .oC (C[11]));
FA_Cir S12 (.iA (iA[12]), .iB (iB[12]), .iC (C[11]), .oS (oS[12]), .oC (C[12]));
FA_Cir S13 (.iA (iA[13]), .iB (iB[13]), .iC (C[12]), .oS (oS[13]), .oC (C[13]));
FA_Cir S14 (.iA (iA[14]), .iB (iB[14]), .iC (C[13]), .oS (oS[14]), .oC (C[14]));
FA_Cir S15 (.iA (iA[15]), .iB (iB[15]), .iC (C[14]), .oS (oS[15]), .oC (C[15]));
FA_Cir S16 (.iA (iA[16]), .iB (iB[16]), .iC (C[15]), .oS (oS[16]), .oC (C[16]));
FA_Cir S17 (.iA (iA[17]), .iB (iB[17]), .iC (C[16]), .oS (oS[17]), .oC (C[17]));

wire	X, V;
assign X = iA[18]^iB[18];
assign V = iA[18]&iB[18];
assign oS[18] = X^C[17];
assign oS[19] = (X) ? ~(V|C[17]) : V;

endmodule

module Ripple_Add_21bit (
	input	[19:0]	iA, iB,
	input			iC,
	output	[20:0]	oS
);

wire	[18:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),    .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]),  .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]),  .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]),  .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]),  .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]),  .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]),  .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]),  .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]),  .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]),  .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]),  .oS (oS[10]), .oC (C[10]));
FA_Cir S11 (.iA (iA[11]), .iB (iB[11]), .iC (C[10]), .oS (oS[11]), .oC (C[11]));
FA_Cir S12 (.iA (iA[12]), .iB (iB[12]), .iC (C[11]), .oS (oS[12]), .oC (C[12]));
FA_Cir S13 (.iA (iA[13]), .iB (iB[13]), .iC (C[12]), .oS (oS[13]), .oC (C[13]));
FA_Cir S14 (.iA (iA[14]), .iB (iB[14]), .iC (C[13]), .oS (oS[14]), .oC (C[14]));
FA_Cir S15 (.iA (iA[15]), .iB (iB[15]), .iC (C[14]), .oS (oS[15]), .oC (C[15]));
FA_Cir S16 (.iA (iA[16]), .iB (iB[16]), .iC (C[15]), .oS (oS[16]), .oC (C[16]));
FA_Cir S17 (.iA (iA[17]), .iB (iB[17]), .iC (C[16]), .oS (oS[17]), .oC (C[17]));
FA_Cir S18 (.iA (iA[18]), .iB (iB[18]), .iC (C[17]), .oS (oS[18]), .oC (C[18]));

wire	X, V;
assign X = iA[19]^iB[19];
assign V = iA[19]&iB[19];
assign oS[19] = X^C[18];
assign oS[20] = (X) ? ~(V|C[18]) : V;

endmodule

module Ripple_Add_22bit (
	input	[20:0]	iA, iB,
	input			iC,
	output	[21:0]	oS
);

wire	[19:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),    .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]),  .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]),  .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]),  .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]),  .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]),  .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]),  .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]),  .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]),  .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]),  .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]),  .oS (oS[10]), .oC (C[10]));
FA_Cir S11 (.iA (iA[11]), .iB (iB[11]), .iC (C[10]), .oS (oS[11]), .oC (C[11]));
FA_Cir S12 (.iA (iA[12]), .iB (iB[12]), .iC (C[11]), .oS (oS[12]), .oC (C[12]));
FA_Cir S13 (.iA (iA[13]), .iB (iB[13]), .iC (C[12]), .oS (oS[13]), .oC (C[13]));
FA_Cir S14 (.iA (iA[14]), .iB (iB[14]), .iC (C[13]), .oS (oS[14]), .oC (C[14]));
FA_Cir S15 (.iA (iA[15]), .iB (iB[15]), .iC (C[14]), .oS (oS[15]), .oC (C[15]));
FA_Cir S16 (.iA (iA[16]), .iB (iB[16]), .iC (C[15]), .oS (oS[16]), .oC (C[16]));
FA_Cir S17 (.iA (iA[17]), .iB (iB[17]), .iC (C[16]), .oS (oS[17]), .oC (C[17]));
FA_Cir S18 (.iA (iA[18]), .iB (iB[18]), .iC (C[17]), .oS (oS[18]), .oC (C[18]));
FA_Cir S19 (.iA (iA[19]), .iB (iB[19]), .iC (C[18]), .oS (oS[19]), .oC (C[19]));

wire	X, V;
assign X = iA[20]^iB[20];
assign V = iA[20]&iB[20];
assign oS[20] = X^C[19];
assign oS[21] = (X) ? ~(V|C[19]) : V;

endmodule

module Ripple_Add_23bit (
	input	[21:0]	iA, iB,
	input			iC,
	output	[22:0]	oS
);

wire	[20:0]	C;
FA_Cir S0  (.iA (iA[0]),  .iB (iB[0]),  .iC (iC),    .oS (oS[0]),  .oC (C[0]));
FA_Cir S1  (.iA (iA[1]),  .iB (iB[1]),  .iC (C[0]),  .oS (oS[1]),  .oC (C[1]));
FA_Cir S2  (.iA (iA[2]),  .iB (iB[2]),  .iC (C[1]),  .oS (oS[2]),  .oC (C[2]));
FA_Cir S3  (.iA (iA[3]),  .iB (iB[3]),  .iC (C[2]),  .oS (oS[3]),  .oC (C[3]));
FA_Cir S4  (.iA (iA[4]),  .iB (iB[4]),  .iC (C[3]),  .oS (oS[4]),  .oC (C[4]));
FA_Cir S5  (.iA (iA[5]),  .iB (iB[5]),  .iC (C[4]),  .oS (oS[5]),  .oC (C[5]));
FA_Cir S6  (.iA (iA[6]),  .iB (iB[6]),  .iC (C[5]),  .oS (oS[6]),  .oC (C[6]));
FA_Cir S7  (.iA (iA[7]),  .iB (iB[7]),  .iC (C[6]),  .oS (oS[7]),  .oC (C[7]));
FA_Cir S8  (.iA (iA[8]),  .iB (iB[8]),  .iC (C[7]),  .oS (oS[8]),  .oC (C[8]));
FA_Cir S9  (.iA (iA[9]),  .iB (iB[9]),  .iC (C[8]),  .oS (oS[9]),  .oC (C[9]));
FA_Cir S10 (.iA (iA[10]), .iB (iB[10]), .iC (C[9]),  .oS (oS[10]), .oC (C[10]));
FA_Cir S11 (.iA (iA[11]), .iB (iB[11]), .iC (C[10]), .oS (oS[11]), .oC (C[11]));
FA_Cir S12 (.iA (iA[12]), .iB (iB[12]), .iC (C[11]), .oS (oS[12]), .oC (C[12]));
FA_Cir S13 (.iA (iA[13]), .iB (iB[13]), .iC (C[12]), .oS (oS[13]), .oC (C[13]));
FA_Cir S14 (.iA (iA[14]), .iB (iB[14]), .iC (C[13]), .oS (oS[14]), .oC (C[14]));
FA_Cir S15 (.iA (iA[15]), .iB (iB[15]), .iC (C[14]), .oS (oS[15]), .oC (C[15]));
FA_Cir S16 (.iA (iA[16]), .iB (iB[16]), .iC (C[15]), .oS (oS[16]), .oC (C[16]));
FA_Cir S17 (.iA (iA[17]), .iB (iB[17]), .iC (C[16]), .oS (oS[17]), .oC (C[17]));
FA_Cir S18 (.iA (iA[18]), .iB (iB[18]), .iC (C[17]), .oS (oS[18]), .oC (C[18]));
FA_Cir S19 (.iA (iA[19]), .iB (iB[19]), .iC (C[18]), .oS (oS[19]), .oC (C[19]));
FA_Cir S20 (.iA (iA[20]), .iB (iB[20]), .iC (C[19]), .oS (oS[20]), .oC (C[20]));

wire	X, V;
assign X = iA[21]^iB[21];
assign V = iA[21]&iB[21];
assign oS[21] = X^C[20];
assign oS[22] = (X) ? ~(V|C[20]) : V;

endmodule

module FA_Cir (
	input	iA, iB, iC,
	output	oS, oC
);

wire	X;

assign X = iA^iB;

assign oS = iC^X;
assign oC = (iA&iB)|(X&iC);

endmodule

module FA_Cir_Cin0 (
	input	iA, iB,
	output	oS, oC
);

assign oS = iA^iB;
assign oC = iA&iB;

endmodule

module FA_Cir_Cin1 (
	input	iA, iB,
	output	oS, oC
);

wire	X;

assign X = iA^iB;

assign oS = ~X;
assign oC = (iA&iB)|X;

endmodule
