module fft_top(
	input              CLK,
	input              RST,
	output             PULSSRT,
	//----------------------------------
	input              DDC1_DEN,
	input      [15: 0] DDC1_DATI,
	input      [15: 0] DDC1_DATQ,
	input              DDC2_DEN,
	input      [15: 0] DDC2_DATI,
	input      [15: 0] DDC2_DATQ,
	//----------------------------------
	output reg         DIFFDOE,
	output reg [15: 0] DIFFDATA,
	output reg [54: 0] LTHMAXD
);

wire         FftBusy1;
wire         FftBusy2;

wire         DdcDoe1;
wire [15: 0] DdcDatI1;
wire [15: 0] DdcDatQ1;

wire         DdcDoe2;
wire [15: 0] DdcDatI2;
wire [15: 0] DdcDatQ2;

wire         OFftDoe1;
wire [26: 0] OFftDatI1;
wire [26: 0] OFftDatQ1;
wire         OFftDoe2;
wire [26: 0] OFftDatI2;
wire [26: 0] OFftDatQ2;

wire [53: 0] SquDataI;
wire [53: 0] SquDataQ;

reg          SquDOe;
reg          SquDOeR;
reg  [54: 0] SquData;
reg  [54: 0] LthSquData;

reg          SyOFftDoe1;
reg  [26: 0] SyOFftDatI1;
reg  [26: 0] SyOFftDatQ1;
reg          SyOFftDoe2;
reg  [26: 0] SyOFftDatI2;
reg  [26: 0] SyOFftDatQ2;
reg          Sy1OFftDoe1;
reg  [26: 0] Sy1OFftDatI1;
reg  [26: 0] Sy1OFftDatQ1;
reg          Sy1OFftDoe2;
reg  [26: 0] Sy1OFftDatI2;
reg  [26: 0] Sy1OFftDatQ2;
reg          Sy2OFftDoe1;
reg  [26: 0] Sy2OFftDatI1;
reg  [26: 0] Sy2OFftDatQ1;
reg          Sy2OFftDoe2;
reg  [26: 0] Sy2OFftDatI2;
reg  [26: 0] Sy2OFftDatQ2;

reg  [26: 0] Lth1DatI;
reg  [26: 0] Lth1DatQ;
reg  [26: 0] Lth2DatI;
reg  [26: 0] Lth2DatQ;

reg  [26: 0] Lth1DatRI;
reg  [26: 0] Lth1DatRQ;
reg  [26: 0] Lth2DatRI;
reg  [26: 0] Lth2DatRQ;

wire signed [15: 0] Phdat1;
wire signed [15: 0] Phdat2;

reg  [10: 0] DVOut; 
wire         OverEnd;
reg signed [16: 0] SubPh;
reg  [15: 0] OffDataR;
wire         OffDoe;
reg  [7 : 0] DlyCnt;

assign OverEnd        = DVOut[10] & (!DVOut[9]);

assign OffDoe         = (DlyCnt == 8'd31);


always@(posedge CLK,posedge RST)begin
	if(RST)begin
		DlyCnt     <= 8'd32;
	end else if(OverEnd)begin
		DlyCnt     <= 8'd0;
	end else if(DlyCnt == 8'd32)begin
		DlyCnt     <= DlyCnt;
	end else begin
		DlyCnt     <= DlyCnt + 8'd1;
	end
end

fft_data inst_fft_data1(
	.CLK              ( CLK       ),
	.RST              ( RST       ),
	.FFTEN            ( 1'b1      ),
	.PULSSRT          ( PULSSRT   ),
	//-----------------------------------
	.DDCDEN           ( DDC1_DEN  ),
	.DDCDATI          ( DDC1_DATI ),
	.DDCDATQ          ( DDC1_DATQ ),
	//-----------------------------------
	.FFTBUSY          ( FftBusy1  ),
	.FFTDOE           ( DdcDoe1   ),
	.FFTDATI          ( DdcDatI1  ),
	.FFTDATQ          ( DdcDatQ1  )
);

fft_data inst_fft_data2(
	.CLK              ( CLK       ),
	.RST              ( RST       ),
	.FFTEN            ( 1'b1      ),
	//-----------------------------------
	.DDCDEN           ( DDC2_DEN  ),
	.DDCDATI          ( DDC2_DATI ),
	.DDCDATQ          ( DDC2_DATQ ),
	//-----------------------------------
	.FFTBUSY          ( FftBusy2  ),
	.FFTDOE           ( DdcDoe2   ),
	.FFTDATI          ( DdcDatI2  ),
	.FFTDATQ          ( DdcDatQ2  )
);

fft_pro inst_fft_pro1(
	.CLK              ( CLK       ),
	.RST              ( RST       ),
	//-------------------------------------
	.FFTBUSY          ( FftBusy1  ),
	.FFTDOE           ( DdcDoe1   ),
	.FFTDATI          ( DdcDatI1  ),
	.FFTDATQ          ( DdcDatQ1  ),
	//-------------------------------------
	.OFFTDOE          ( OFftDoe1  ),
	.OFFTDATI         ( OFftDatI1 ),
	.OFFTDATQ         ( OFftDatQ1 )
);

fft_pro inst_fft_pro2(
	.CLK              ( CLK       ),
	.RST              ( RST       ),
	//-------------------------------------
	.FFTBUSY          ( FftBusy2  ),
	.FFTDOE           ( DdcDoe2   ),
	.FFTDATI          ( DdcDatI2  ),
	.FFTDATQ          ( DdcDatQ2  ),
	//-------------------------------------
	.OFFTDOE          ( OFftDoe2  ),
	.OFFTDATI         ( OFftDatI2 ),
	.OFFTDATQ         ( OFftDatQ2 )
);

//-------------------------------------------------------------------
mult2 inst_mult2i(
	.clock      ( CLK       ),
	.aclr       ( RST       ),
	//----------------------------
	.dataa      ( OFftDatI1 ),
	.result     ( SquDataI  )
);

mult2 inst_mult2q(
	.clock      ( CLK       ),
	.aclr       ( RST       ),
	//----------------------------
	.dataa      ( OFftDatQ1 ),
	.result     ( SquDataQ  )
);

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		SquData      <= 55'd0;
		SquDOe       <= 1'b0;
		SquDOeR      <= 1'b0;
	end else begin
		SquDOe       <= OFftDoe1;
		SquDOeR      <= SquDOe;
		SquData      <= SquDataI + SquDataQ;
	end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		SyOFftDoe1        <= 1'b0;
		SyOFftDatI1       <= 27'd0;
		SyOFftDatQ1       <= 27'd0;
		SyOFftDoe2        <= 1'b0;
		SyOFftDatI2       <= 27'd0;
		SyOFftDatQ2       <= 27'd0;
		Sy1OFftDoe1       <= 1'b0;
		Sy1OFftDatI1      <= 27'd0;
		Sy1OFftDatQ1      <= 27'd0;
		Sy1OFftDoe2       <= 1'b0;
		Sy1OFftDatI2      <= 27'd0;
		Sy1OFftDatQ2      <= 27'd0;
		Sy1OFftDoe1       <= 1'b0;
		Sy1OFftDatI1      <= 27'd0;
		Sy1OFftDatQ1      <= 27'd0;
		Sy1OFftDoe2       <= 1'b0;
		Sy1OFftDatI2      <= 27'd0;
		Sy1OFftDatQ2      <= 27'd0;
	end else begin
		SyOFftDoe1        <= OFftDoe1;
		SyOFftDatI1       <= OFftDatI1;
		SyOFftDatQ1       <= OFftDatQ1;
		SyOFftDoe2        <= OFftDoe2;
		SyOFftDatI2       <= OFftDatI2;
		SyOFftDatQ2       <= OFftDatQ2;
		Sy1OFftDoe1       <= SyOFftDoe1;
		Sy1OFftDatI1      <= SyOFftDatI1;
		Sy1OFftDatQ1      <= SyOFftDatQ1;
		Sy1OFftDoe2       <= SyOFftDoe2;
		Sy1OFftDatI2      <= SyOFftDatI2;
		Sy1OFftDatQ2      <= SyOFftDatQ2;
		Sy2OFftDoe1       <= Sy1OFftDoe1;
		Sy2OFftDatI1      <= Sy1OFftDatI1;
		Sy2OFftDatQ1      <= Sy1OFftDatQ1;
		Sy2OFftDoe2       <= Sy1OFftDoe2;
		Sy2OFftDatI2      <= Sy1OFftDatI2;
		Sy2OFftDatQ2      <= Sy1OFftDatQ2;
	end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		LthSquData    <= 55'd0;
		LTHMAXD       <= 55'd0;
		Lth1DatI      <= 27'd0;
		Lth1DatQ      <= 27'd0;
		Lth2DatI      <= 27'd0;
		Lth2DatQ      <= 27'd0;
	end else if(SquDOeR)begin
		if(LthSquData <= SquData)begin
			LthSquData    <= SquData;  
			Lth1DatI      <= Sy1OFftDatI1;
			Lth1DatQ      <= Sy1OFftDatQ1;
			Lth2DatI      <= Sy1OFftDatI2;
			Lth2DatQ      <= Sy1OFftDatQ2;
			LTHMAXD       <= SquData;
		end
	end else begin
		LthSquData    <= 55'd0;
	end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		Lth1DatRI     <= 27'd0;
		Lth1DatRQ     <= 27'd0;
		Lth2DatRI     <= 27'd0;
		Lth2DatRQ     <= 27'd0;
	end else begin
		Lth1DatRI     <= Lth1DatI;
		Lth1DatRQ     <= Lth1DatQ;
		Lth2DatRI     <= Lth2DatI;
		Lth2DatRQ     <= Lth2DatQ;
	end
end

atan2 inst_atan1(
	.clk          ( CLK       ),
	.areset       ( RST       ), 
	//-----------------------------------
	.x            ( Lth1DatRI ),
	.y            ( Lth1DatRQ ),
	.q            ( Phdat1    )
);

atan2 inst_atan2(
	.clk          ( CLK       ),
	.areset       ( RST       ), 
	//-----------------------------------
	.x            ( Lth2DatRI ),
	.y            ( Lth2DatRQ ),
	.q            ( Phdat2    )
);

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		DVOut       <= 11'd0;
	end else begin
		DVOut       <= {DVOut[9:0],SquDOeR};
	end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		OffDataR    <= 16'd0;
	end else if(DVOut[10])begin
		SubPh<=Phdat1 - Phdat2;
		if(SubPh > 25736)begin
			OffDataR    <= SubPh - 51472;
		end else if(SubPh < -32767)begin
			OffDataR    <= SubPh + 51472;
		end else begin
			OffDataR    <= SubPh;
		end
    end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		DIFFDOE      <= 1'b0;
		DIFFDATA     <= 16'd0;
	end else if(OffDoe)begin
		DIFFDOE      <= 1'b1;
		DIFFDATA     <= OffDataR;
	end else begin
		DIFFDOE      <= 1'b0;
	end
end

endmodule
