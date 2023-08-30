module top(
	//ADC1-------------------------------
	input              ADC1_CLK,
	input      [15: 0] ADC1_DATA,
	input              ADC1_OR,
	output             ADA1_DITH,
	output             ADA1_PGA,
	//ADC2-------------------------------
//	input              ADC2_CLK,
	input      [15: 0] ADC2_DATA,
	input              ADC2_OR,
	output             ADA2_DITH,
	output             ADA2_PGA,
	//--uart-----------------------------
	output             ARM_TXD,
	input              ARM_RXD,
	output             SIM_TXD,
	input              SIM_RXD,
	//--gpio to arm----------------------
	input      [7 : 0] GPIO_IN,
	output     [7 : 0] GPIO_OUT
);

wire         RST;
wire         CLKG;
wire         LocKed;

reg  [31: 0] DlyCnt;
wire         DdcRst;

wire         DdcDOe1;
wire [15: 0] DdcDatI1;
wire [15: 0] DdcDatQ1;

wire         DdcDOe2;
wire [15: 0] DdcDatI2;
wire [15: 0] DdcDatQ2;

wire         DiffDoe;
wire [15: 0] DiffDat;

wire [54: 0] LthMaxDat;

//wire [15: 0] AdcMean;
wire         PulsSrt;

wire         CheckDen;
wire [63: 0] CheckDat1;
wire [63: 0] CheckDat2;
wire [63: 0] CheckDat3;
wire [63: 0] CheckDat4;
wire [63: 0] CheckDat5;
wire [63: 0] CheckDat6;
wire [63: 0] CheckDat7;
wire [63: 0] CheckDat8;
wire [63: 0] CheckDat9;
wire [63: 0] CheckDat10;
wire [63: 0] CheckDat11;
wire [63: 0] CheckDat12;
wire [63: 0] CheckDat13;
wire [63: 0] CheckDat14;
wire [63: 0] CheckDat15;
wire [63: 0] CheckDat16;

assign RST            = DdcRst;

//assign GPIO_OUT       = GPIO_IN;    //tbj20190529

assign ADA1_DITH      = 1'b1;
assign ADA1_PGA       = 1'b0;
assign ADA2_DITH      = 1'b1;
assign ADA2_PGA       = 1'b0;

assign DdcRst         = (DlyCnt < 32'd100_000_000);

always@(posedge CLKG,negedge LocKed)begin
	if(!LocKed)begin
		DlyCnt      <= 32'd0;
	end else if(DlyCnt == 32'd100_000_000)begin
		DlyCnt      <= DlyCnt;
	end else begin
		DlyCnt      <= DlyCnt + 32'd1;
	end
end

syspll inst_syspll(
	.refclk       ( ADC1_CLK ),
	.rst          ( 1'b0     ),
	.outclk_0     ( CLKG     ),
	.locked       ( LocKed   )
);

//adc_mean inst_adc_mean(
//	.CLK           ( CLKG      ),
//	.RST           ( RST       ),
//	//------------------------------
//	.ADC1DAT       ( ADC1_DATA ),
//	.ADC2DAT       ( ADC2_DATA ),
//	//------------------------------
//	.MEANDAT       ( AdcMean   )
//);

ddc_top inst_ddc_top1(
	.CLK           ( CLKG       ),
	.RST           ( RST        ),
	.DDCRST        ( RST        ),
	//-----------------------------
	.ADCDATA       ( ADC1_DATA  ),
	.ADCDATB       ( ADC2_DATA  ),
	//-----------------------------
	.DDC1_DOE      ( DdcDOe1    ),
	.DDC1_DATI     ( DdcDatI1   ),
	.DDC1_DATQ     ( DdcDatQ1   ),
	.DDC2_DOE      ( DdcDOe2    ),
	.DDC2_DATI     ( DdcDatI2   ),
	.DDC2_DATQ     ( DdcDatQ2   )
);

fft_top inst_fft_top(
	.CLK           ( CLKG       ),
	.RST           ( RST        ),
	.PULSSRT       ( PulsSrt    ),
	//----------------------------------
	.DDC1_DEN      ( DdcDOe1    ),
	.DDC1_DATI     ( DdcDatI1   ),
	.DDC1_DATQ     ( DdcDatQ1   ),
	.DDC2_DEN      ( DdcDOe2    ),
	.DDC2_DATI     ( DdcDatI2   ),
	.DDC2_DATQ     ( DdcDatQ2   ),
	//----------------------------------
	.DIFFDOE       ( DiffDoe    ),
	.DIFFDATA      ( DiffDat    ),
	.LTHMAXD       ( LthMaxDat  )
);

check_wave inst_check_wave(
	.CLK           ( CLKG       ),
	.RST           ( RST        ),
	.PULSSRT       ( PulsSrt    ),
	//-------------------------------
	.DDC_DEN       ( DdcDOe1    ),
	.DDC_DATI      ( DdcDatI1   ),
	.DDC_DATQ      ( DdcDatQ1   ),
	//-------------------------------
	.Morse_out     ( GPIO_OUT[0]),  //tbj20190529
	.CHECK_DOE     ( CheckDen   ),
	.CHECK_DAT1    ( CheckDat1  ),
	.CHECK_DAT2    ( CheckDat2  ),
	.CHECK_DAT3    ( CheckDat3  ),
	.CHECK_DAT4    ( CheckDat4  ),
	.CHECK_DAT5    ( CheckDat5  ),
	.CHECK_DAT6    ( CheckDat6  ),
	.CHECK_DAT7    ( CheckDat7  ),
	.CHECK_DAT8    ( CheckDat8  ),
	.CHECK_DAT9    ( CheckDat9  ),
	.CHECK_DAT10   ( CheckDat10 ),
	.CHECK_DAT11   ( CheckDat11 ),
	.CHECK_DAT12   ( CheckDat12 ),
	.CHECK_DAT13   ( CheckDat13 ),
	.CHECK_DAT14   ( CheckDat14 ),
	.CHECK_DAT15   ( CheckDat15 ),
	.CHECK_DAT16   ( CheckDat16 )
);

uart_ctl inst_uart_ctl(
	.CLK           ( CLKG       ),
	.RST           ( RST        ),
	//----------------------------------------
	.DIFF_PHEN     ( DiffDoe    ),
	.DIFF_PHDAT    ( DiffDat    ),
	.LTHMAXD       ( LthMaxDat  ),
//	.ADC_DATA      ( AdcMean    ),
	.CHECK_DOE     ( CheckDen   ),
	.CHECK_DAT1    ( CheckDat1  ),
	.CHECK_DAT2    ( CheckDat2  ),
	.CHECK_DAT3    ( CheckDat3  ),
	.CHECK_DAT4    ( CheckDat4  ),
	.CHECK_DAT5    ( CheckDat5  ),
	.CHECK_DAT6    ( CheckDat6  ),
	.CHECK_DAT7    ( CheckDat7  ),
	.CHECK_DAT8    ( CheckDat8  ),
	.CHECK_DAT9    ( CheckDat9  ),
	.CHECK_DAT10   ( CheckDat10 ),
	.CHECK_DAT11   ( CheckDat11 ),
	.CHECK_DAT12   ( CheckDat12 ),
	.CHECK_DAT13   ( CheckDat13 ),
	.CHECK_DAT14   ( CheckDat14 ),
	.CHECK_DAT15   ( CheckDat15 ),
	.CHECK_DAT16   ( CheckDat16 ),
	//----------------------------------------
	.ARM_TXD       ( ARM_TXD    ),
	.ARM_RXD       ( ARM_RXD    ),
	.SIM_TXD       ( SIM_TXD    ),
	.SIM_RXD       ( SIM_RXD    )
);


////--sim----------------------------------------------------------
//reg  [3 : 0] STATU;
//reg          FifoRst;
//reg  [15: 0] CouCnt;
//reg          DFifoWen;
//reg          DFifoRen;
//reg  [15: 0] DFifoWDI1;
//reg  [15: 0] DFifoWDQ1;
//reg  [15: 0] DFifoWDI2;
//reg  [15: 0] DFifoWDQ2;
//
//wire [15: 0] DFifoRDI1;
//wire [15: 0] DFifoRDQ1;
//wire [15: 0] DFifoRDI2;
//wire [15: 0] DFifoRDQ2;
//
//always@(posedge CLKG,posedge RST)begin
//	if(RST)begin
//		STATU          <= 4'd0;
//		FifoRst        <= 1'b0;
//		CouCnt         <= 16'd0;
//		DFifoWen       <= 1'b0;
//		DFifoWDI1      <= 16'd0;
//		DFifoWDQ1      <= 16'd0;
//		DFifoWDI2      <= 16'd0;
//		DFifoWDQ2      <= 16'd0;
//		DFifoRen       <= 1'b0;
//	end else begin
//		case(STATU)
//			4'd0   :begin
//						if(CouCnt == 16'd511)begin
//							STATU          <= 4'd1;
//							CouCnt         <= 16'd0;
//						end else if(DdcDOe1)begin
//							STATU          <= 4'd0;
//							CouCnt         <= CouCnt + 16'd1;
//						end
//					end
//			4'd1   :begin
//						if(DdcDOe1)begin
//							DFifoWen       <= 1'b1;
//							DFifoWDI1      <= DdcDatI1;
//							DFifoWDQ1      <= DdcDatQ1;
//							DFifoWDI2      <= DdcDatI2;
//							DFifoWDQ2      <= DdcDatQ2;
//							STATU          <= 4'd2;
//							if(CouCnt == 16'd8191)begin
//								CouCnt         <= 16'd0;
//								STATU          <= 4'd2;
//							end else begin
//								STATU          <= 4'd1;
//								CouCnt         <= CouCnt + 16'd1;
//							end
//						end else begin
//							DFifoWen       <= 1'b0;
//							STATU          <= 4'd1;
//						end
//					end
//			4'd2   :begin
//						DFifoWen       <= 1'b0;
//						STATU          <= 4'd3;
//					end
//			4'd3   :begin
//						if(CouCnt == 16'd8191)begin
//							CouCnt         <= 16'd0;
//							DFifoRen       <= 1'b0;
//							STATU          <= 4'd4;
//						end else begin
//							STATU          <= 4'd3;
//							DFifoRen       <= 1'b1;
//							CouCnt         <= CouCnt + 16'd1;
//						end
//					end
//			4'd4   :begin
//						if(CouCnt == 16'd7)begin
//							STATU          <= 4'd5;
//							CouCnt         <= 16'd0;
//						end else begin
//							STATU          <= 4'd4;
//							CouCnt         <= CouCnt + 16'd1;
//						end
//					end
//			4'd5   :begin
//						if(CouCnt == 16'd7)begin
//							STATU          <= 4'd0;
//							CouCnt         <= 16'd0;
//							FifoRst        <= 1'b0;
//						end else begin
//							STATU          <= 4'd5;
//							CouCnt         <= CouCnt + 16'd1;
//							FifoRst        <= 1'b1;
//						end
//					end
//			default:STATU          <= 4'd0;
//		endcase
//	end
//end
//
//sim_fifo sim_fifoi1 (
//	.aclr             ( FifoRst   ),
//	//------------------------------------
//	.wrclk            ( CLKG      ),
//	.wrreq            ( DFifoWen  ),
//	.data             ( DFifoWDI1 ),
//	//------------------------------------
//	.rdclk            ( CLKG      ),
//	.rdreq            ( DFifoRen  ),
//	.q                ( DFifoRDI1 )
//);
//
//sim_fifo sim_fifoq1 (
//	.aclr             ( FifoRst   ),
//	//------------------------------------
//	.wrclk            ( CLKG      ),
//	.wrreq            ( DFifoWen  ),
//	.data             ( DFifoWDQ1 ),
//	//------------------------------------
//	.rdclk            ( CLKG      ),
//	.rdreq            ( DFifoRen  ),
//	.q                ( DFifoRDQ1 )
//);
//
//sim_fifo sim_fifoi2 (
//	.aclr             ( FifoRst   ),
//	//------------------------------------
//	.wrclk            ( CLKG      ),
//	.wrreq            ( DFifoWen  ),
//	.data             ( DFifoWDI2 ),
//	//------------------------------------
//	.rdclk            ( CLKG      ),
//	.rdreq            ( DFifoRen  ),
//	.q                ( DFifoRDI2 )
//);
//
//sim_fifo sim_fifoq2 (
//	.aclr             ( FifoRst   ),
//	//------------------------------------
//	.wrclk            ( CLKG      ),
//	.wrreq            ( DFifoWen  ),
//	.data             ( DFifoWDQ2 ),
//	//------------------------------------
//	.rdclk            ( CLKG      ),
//	.rdreq            ( DFifoRen  ),
//	.q                ( DFifoRDQ2 )
//);



























endmodule

