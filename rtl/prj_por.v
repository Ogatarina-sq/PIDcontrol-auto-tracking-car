module prj_por(
	input              CLK,
	input              RST,
	//----------------------------
	input      [15: 0] MIX_DATI,
	input      [15: 0] MIX_DATQ,
	//----------------------------
	output reg         DDC_DOE,
	output reg [15: 0] DDC_DATI,
	output reg [15: 0] DDC_DATQ
);

wire         CicDatOe;
wire [118:0] CicDatWI;
wire [118:0] CicDatWQ;

reg          CicDatOr;
reg  [15: 0] CicDatRI;
reg  [15: 0] CicDatRQ;

wire         FirDatOe;
wire [41: 0] FirDataI;
wire [41: 0] FirDataQ;

cic_core inst_cic_core_i(
	.clk                ( CLK      ),
	.reset_n            ( !RST     ),
	//-----------------------------------
	.rate               ( 13'd2500 ),
	//-----------------------------------
	.in_valid           ( 1'b1     ),
	.in_data            ( MIX_DATI ),
	//-----------------------------------
	.out_ready          ( 1'b1     ),
	.out_valid          ( CicDatOe ),
	.out_data           ( CicDatWI )
);

cic_core inst_cic_core_q(
	.clk                ( CLK      ),
	.reset_n            ( !RST     ),
	//-----------------------------------
	.rate               ( 13'd2500 ),
	//-----------------------------------
	.in_valid           ( 1'b1     ),
	.in_data            ( MIX_DATQ ),
	//-----------------------------------
	.out_valid          ( ),
	.out_ready          ( 1'b1     ),
	.out_data           ( CicDatWQ )
);

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		CicDatOr     <= 1'b0;
		CicDatRI     <= 16'd0;
		CicDatRQ     <= 16'd0;
	end else begin
		CicDatOr     <= CicDatOe;
		CicDatRI     <= CicDatWI[115:100] + CicDatWI[99];
		CicDatRQ     <= CicDatWQ[115:100] + CicDatWQ[99];
//		CicDatRI     <= CicDatWI[55:40] + CicDatWI[39];
//		CicDatRQ     <= CicDatWQ[55:40] + CicDatWQ[39];
	end
end

fir_core inst_fir_core_i(
	.clk                ( CLK      ),
	.reset_n            ( !RST     ),
	//----------------------------------
	.ast_sink_valid     ( CicDatOr ),
	.ast_sink_data      ( CicDatRI ),
	//----------------------------------
	.ast_source_valid   ( FirDatOe ),
	.ast_source_data    ( FirDataI )
);
  
fir_core inst_fir_core_q(
	.clk                ( CLK      ),
	.reset_n            ( !RST     ),
	//----------------------------------
	.ast_sink_valid     ( CicDatOr ),
	.ast_sink_data      ( CicDatRQ ),
	//----------------------------------
	.ast_source_valid   ( ),
	.ast_source_data    ( FirDataQ )
);

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		DDC_DOE       <= 1'b0;
		DDC_DATI      <= 16'd0;
		DDC_DATQ      <= 16'd0;
	end else begin
		DDC_DOE       <= FirDatOe;
		DDC_DATI      <= FirDataI[34:19] + FirDataI[18];
		DDC_DATQ      <= FirDataQ[34:19] + FirDataQ[18];
//		DDC_DATI      <= FirDataI[35:20] + FirDataI[19];
//		DDC_DATQ      <= FirDataQ[35:20] + FirDataQ[19];
	end
end

endmodule
