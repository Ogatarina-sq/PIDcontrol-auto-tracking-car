module check_wave(
	input              CLK,
	input              RST,
	input              PULSSRT,
	//-------------------------------
	input              DDC_DEN,
	input      [15: 0] DDC_DATI,
	input      [15: 0] DDC_DATQ,
	//-------------------------------
	output reg         Morse_out,     //Alter
	output reg         CHECK_DOE,
	output reg [63: 0] CHECK_DAT1,
	output reg [63: 0] CHECK_DAT2,
	output reg [63: 0] CHECK_DAT3,
	output reg [63: 0] CHECK_DAT4,
	output reg [63: 0] CHECK_DAT5,
	output reg [63: 0] CHECK_DAT6,
	output reg [63: 0] CHECK_DAT7,
	output reg [63: 0] CHECK_DAT8,
	output reg [63: 0] CHECK_DAT9,
	output reg [63: 0] CHECK_DAT10,
	output reg [63: 0] CHECK_DAT11,
	output reg [63: 0] CHECK_DAT12,
	output reg [63: 0] CHECK_DAT13,
	output reg [63: 0] CHECK_DAT14,
	output reg [63: 0] CHECK_DAT15,
	output reg [63: 0] CHECK_DAT16
);

wire [31: 0] MultDatI;
wire [31: 0] MultDatQ;
reg  [31: 0] AddData;
wire [15: 0] SqrtDat;

reg          Sy1SqrtDen;
reg          Sy2SqrtDen;
reg          Sy3SqrtDen;
reg          SqrtDen;
reg  [15: 0] SqrtDatR;

reg  [31: 0] SumDat;
reg  [15: 0] DatCnt1;
reg  [15: 0] MeanDat;

reg  [7 : 0] STATU;
reg          FifoRst;
reg          DdcDEn;
reg  [15: 0] DdcDatI;
reg  [15: 0] DdcDatQ;
reg  [15: 0] DatCnt;
reg          FREn;
wire [15: 0] FifoRDat;

reg  [1024:0] BitDat;

reg  [15: 0] LthLDat;
reg  [15: 0] LthMDat;
reg  [15: 0] LthDDat;


always@(posedge CLK,posedge RST)begin
	if(RST)begin
	        Morse_out     <= 1'b0;     //alter
		STATU         <= 8'd0;
		FifoRst       <= 1'b0;
		DdcDEn        <= 1'b0;
		DdcDatI       <= 16'd0;
		DdcDatQ       <= 16'd0;
		DatCnt        <= 16'd0;
		FREn          <= 1'b0;
		BitDat        <= 1025'd0;
		CHECK_DOE     <= 1'b0;
		CHECK_DAT1    <= 64'd0;
		CHECK_DAT2    <= 64'd0;
		CHECK_DAT3    <= 64'd0;
		CHECK_DAT4    <= 64'd0;
		CHECK_DAT5    <= 64'd0;
		CHECK_DAT6    <= 64'd0;
		CHECK_DAT7    <= 64'd0;
		CHECK_DAT8    <= 64'd0;
		CHECK_DAT9    <= 64'd0;
		CHECK_DAT10   <= 64'd0;
		CHECK_DAT11   <= 64'd0;
		CHECK_DAT12   <= 64'd0;
		CHECK_DAT13   <= 64'd0;
		CHECK_DAT14   <= 64'd0;
		CHECK_DAT15   <= 64'd0;
		CHECK_DAT16   <= 64'd0;
	end else begin
		case(STATU)
			8'd0   :begin
						if(PULSSRT)begin
							STATU         <= 8'd1;
							FifoRst       <= 1'b1;
						end else begin
							STATU         <= 8'd0;
						end
						BitDat        <= 1025'd0;
					end
			8'd1   :begin
						FifoRst       <= 1'b0;
						if(DDC_DEN)begin
							DdcDEn        <= 1'b1;
							DdcDatI       <= DDC_DATI;
							DdcDatQ       <= DDC_DATQ;
							STATU         <= 8'd2;
						end else begin
							DdcDEn        <= 1'b0;
							DdcDatI       <= 16'd0;
							DdcDatQ       <= 16'd0;
							STATU         <= 8'd1;
						end
					end
			8'd2   :begin
						DdcDEn        <= 1'b0;
						if(DatCnt == 16'd1023)begin
							DatCnt        <= 16'd0;
							STATU         <= 8'd3;
						end else begin
							STATU         <= 8'd1;
							DatCnt        <= DatCnt + 16'd1;
						end
					end
			8'd3   :begin
						if(DatCnt == 16'd9)begin
							DatCnt        <= 16'd0;
							STATU         <= 8'd4;
						end else begin
							DatCnt        <= DatCnt + 16'd1;
							STATU         <= 8'd3;
						end
					end
			8'd4   :begin
						if(DatCnt == 16'd1024)begin
							DatCnt        <= 16'd0;
							STATU         <= 8'd5;
							FREn          <= 1'b0;
						end else begin
							DatCnt        <= DatCnt + 16'd1;
							STATU         <= 8'd4;
							FREn          <= 1'b1;
						end
						if(FifoRDat <= LthDDat[15:1])begin
							BitDat[1024-DatCnt] <= 1'b0;
							Morse_out <= 1'b0;               //Alter
						end else begin
							BitDat[1024-DatCnt] <= 1'b1;
							Morse_out <= 1'b1;               //Alter
						end
					end
			8'd5   :begin
						CHECK_DOE     <= 1'b1;
						CHECK_DAT1    <= BitDat[1023:960];
						CHECK_DAT2    <= BitDat[959:896];
						CHECK_DAT3    <= BitDat[895:832];
						CHECK_DAT4    <= BitDat[831:768];
						CHECK_DAT5    <= BitDat[767:704];
						CHECK_DAT6    <= BitDat[703:640];
						CHECK_DAT7    <= BitDat[639:576];
						CHECK_DAT8    <= BitDat[575:512];
						CHECK_DAT9    <= BitDat[511:448];
						CHECK_DAT10   <= BitDat[447:384];
						CHECK_DAT11   <= BitDat[383:320];
						CHECK_DAT12   <= BitDat[319:256];
						CHECK_DAT13   <= BitDat[255:192];
						CHECK_DAT14   <= BitDat[191:128];
						CHECK_DAT15   <= BitDat[127:64];
						CHECK_DAT16   <= BitDat[63:0];
						STATU         <= 8'd6;
					end
			8'd6   :begin
						CHECK_DOE     <= 1'b0;
						if(DatCnt == 16'd31)begin
							STATU         <= 8'd0;
							DatCnt        <= 16'd0;
						end else begin
							STATU         <= 8'd6;
							DatCnt        <= DatCnt + 16'd1;
						end
					end
			default:STATU         <= 8'd0;
		endcase
	end
end

mult2_16 inst_mult2_16i(
	.clock       ( CLK      ),
	.aclr        ( RST      ),
	.dataa       ( DdcDatI  ),
	.datab       ( DdcDatI  ),
	.result      ( MultDatI )
);

mult2_16 inst_mult2_16q(
	.clock       ( CLK      ),
	.aclr        ( RST      ),
	.dataa       ( DdcDatQ  ),
	.datab       ( DdcDatQ  ),
	.result      ( MultDatQ )
);

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		AddData       <= 32'd0;
	end else begin
		AddData       <= MultDatI + MultDatQ;
	end
end

aqrt2 inst_aqrt2(
	.clk        ( CLK     ),
	.aclr       ( RST     ),
	
	.radical    ( AddData ),
	.q          ( SqrtDat ),
	.remainder  ( )
);

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		Sy1SqrtDen       <= 1'b0;
		Sy2SqrtDen       <= 1'b0;
		Sy3SqrtDen       <= 1'b0;
	end else begin
		Sy1SqrtDen       <= DdcDEn;
		Sy2SqrtDen       <= Sy1SqrtDen;
		Sy3SqrtDen       <= Sy2SqrtDen;
	end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		SqrtDen          <= 1'b0;
		SqrtDatR         <= 16'd0;
	end else if(Sy3SqrtDen)begin
		SqrtDen          <= 1'b1;
		SqrtDatR         <= SqrtDat;
	end else begin
		SqrtDen          <= 1'b0;
	end
end

always@(posedge CLK,posedge FifoRst)begin
	if(FifoRst)begin
		LthLDat        <= 16'd32767;
		LthMDat        <= 16'd0;
	end else if(SqrtDen)begin
		if(LthLDat > SqrtDatR)begin
			LthLDat        <= SqrtDatR;    
		end
		if(LthMDat < SqrtDatR)begin
			LthMDat        <= SqrtDatR;
		end
	end
end

always@(posedge CLK,posedge FifoRst)begin
	if(FifoRst)begin
		LthDDat        <= 16'd0;
	end else begin
		LthDDat        <= LthMDat - LthLDat;
	end
end


//always@(posedge CLK,posedge RST)begin
//	if(RST)begin
//		SumDat     <= 32'd0;
//		DatCnt1     <= 16'd0;
//		MeanDat    <= 16'd0;
//	end else if(DatCnt1 == 16'd1023)begin
//		DatCnt1    <= 16'd0;
//		SumDat     <= 32'd0;
//		MeanDat    <= SumDat1[25:10];
//	end else if(SqrtDen)begin
//		DatCnt1    <= DatCnt1 + 16'd1;
//		SumDat     <= SumDat + SqrtDatR;
//	end
//end

check_fifo inst_check_fifo(
	.aclr             ( FifoRst  ),
	//------------------------------------
	.wrclk            ( CLK      ),
	.wrreq            ( SqrtDen  ),
	.data             ( SqrtDatR ),
	.wrfull           ( ),
	//------------------------------------
	.rdclk            ( CLK      ),
	.rdreq            ( FREn     ),
	.q                ( FifoRDat ),
	.rdempty          ( )
);



endmodule
