module fft_pro(
	input              CLK,
	input              RST,
	//--------------------------------
	output             FFTBUSY,
	input              FFTDOE,
	input      [15: 0] FFTDATI,
	input      [15: 0] FFTDATQ,
	//--------------------------------
	output             OFFTDOE,
	output     [26: 0] OFFTDATI,
	output     [26: 0] OFFTDATQ
);

reg  [9 : 0] WinAdd;
wire [15: 0] WinDat;

reg          SyFtDOe;
reg  [15: 0] SyFtDatI;
reg  [15: 0] SyFtDatQ;

reg          Sy1FtDOe;
reg  [15: 0] Sy1FtDatI;
reg  [15: 0] Sy1FtDatQ;

reg          WindMultDoe;
wire [31: 0] WindMultDI;
wire [31: 0] WindMultDQ;

reg          WindDoe;
reg  [15: 0] WindDatI;
reg  [15: 0] WindDatQ;

reg          Sy1WindDoe;
reg  [15: 0] Sy1WindDatI;
reg  [15: 0] Sy1WindDatQ;

wire         WindSop;
wire         WindEop;
reg          SinkSop;
reg          SinkEop;
reg  [3 : 0] SySinkSop;
reg  [3 : 0] SySinkEop;   
wire         SinkReady;    

assign WindSop            = FFTDOE & (WinAdd == 10'd0);
assign WindEop            = FFTDOE & (WinAdd == 10'd1023);

assign FFTBUSY            = (!SinkReady) | (OFFTDOE);

//--Add wind---------------------------------------------------------
ram_wind inst_ram_wind(
	.clock            ( CLK    ),
	.address          ( WinAdd ),
	.q                ( WinDat )
);

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		SyFtDOe     <= 1'b0;
		SyFtDatI    <= 16'd0;
		SyFtDatQ    <= 16'd0;
		WinAdd      <= 10'd0;
	end else if(FFTDOE)begin
		SyFtDOe     <= 1'b1;
		SyFtDatI    <= FFTDATI;
		SyFtDatQ    <= FFTDATQ;
		WinAdd      <= WinAdd + 10'd1;
	end else begin
		SyFtDOe     <= 1'b0;
	end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		Sy1FtDOe    <= 1'b0;
		Sy1FtDatI   <= 16'd0;
		Sy1FtDatQ   <= 16'd0;
	end else begin
		Sy1FtDOe    <= SyFtDOe;
		Sy1FtDatI   <= SyFtDatI;
		Sy1FtDatQ   <= SyFtDatQ;
	end
end

mix_mult inst_wind_multi(
	.clock          ( CLK        ),
	.aclr           ( RST        ),
	//----------------------------
	.dataa          ( Sy1FtDatI  ),
	.datab          ( WinDat     ),
	.result         ( WindMultDI )
);

mix_mult inst_wind_multq(
	.clock          ( CLK        ),
	.aclr           ( RST        ),
	//----------------------------
	.dataa          ( Sy1FtDatQ  ),
	.datab          ( WinDat     ),
	.result         ( WindMultDQ )
);

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		WindMultDoe   <= 1'b0;
		WindDoe       <= 1'b0;
		WindDatI      <= 16'd0;
		WindDatQ      <= 16'd0;
		SinkSop       <= 1'b0;
		SinkEop       <= 1'b0;
		Sy1WindDoe    <= 1'b0;
		Sy1WindDatI   <= 16'd0;
		Sy1WindDatQ   <= 16'd0;
		SySinkSop     <= 4'd0;
		SySinkEop     <= 4'd0;
	end else begin
		WindMultDoe   <= Sy1FtDOe;
		WindDoe       <= WindMultDoe;
		WindDatI      <= WindMultDI[31:16] + WindMultDI[15];
		WindDatQ      <= WindMultDQ[31:16] + WindMultDQ[15];
		SySinkSop     <= {SySinkSop[2:0],WindSop};
		SySinkEop     <= {SySinkEop[2:0],WindEop};
		SinkSop       <= SySinkSop[3];
		SinkEop       <= SySinkEop[3];
		Sy1WindDoe    <= WindDoe;
		Sy1WindDatI   <= WindDatI;
		Sy1WindDatQ   <= WindDatQ;
	end
end

//--Add wind end------------------------------------------------------

fft_core inst_fft_core(
	.clk              ( CLK         ),
	.reset_n          ( !RST        ),
	//--------------------------------------
	.sink_valid       ( Sy1WindDoe  ),
	.sink_ready       ( SinkReady   ),
	.sink_error       ( 2'b00       ),
	.sink_sop         ( SinkSop     ),
	.sink_eop         ( SinkEop     ),
	.sink_real        ( Sy1WindDatI ),
	.sink_imag        ( Sy1WindDatQ ),
	.fftpts_in        ( 11'h400     ),
	.inverse          ( 1'b0        ),
	//--------------------------------------
	.source_valid     ( OFFTDOE     ),
	.source_ready     ( 1'b1        ),
	.source_sop       ( ),
	.source_eop       ( ),
	.source_real      ( OFFTDATI    ),
	.source_imag      ( OFFTDATQ    )
);


endmodule
