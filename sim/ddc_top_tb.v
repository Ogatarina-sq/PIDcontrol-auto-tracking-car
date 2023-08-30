module ddc_top_tb();

reg          CLK;
reg          RST;


wire         DdcDOe1;
wire [15: 0] DdcDatI1;
wire [15: 0] DdcDatQ1;

wire         DdcDOe2;
wire [15: 0] DdcDatI2;
wire [15: 0] DdcDatQ2;


ddc_top inst_ddc_top1(
	.CLK           ( CLK        ),
	.RST           ( RST        ),
	.DDCRST        ( 1'b0       ),
	//-----------------------------

	//-----------------------------
	.DDC1_DOE      ( DdcDOe1    ),
	.DDC1_DATI     ( DdcDatI1   ),
	.DDC1_DATQ     ( DdcDatQ1   ),
	.DDC2_DOE      ( DdcDOe2    ),
	.DDC2_DATI     ( DdcDatI2   ),
	.DDC2_DATQ     ( DdcDatQ2   )
);


initial begin
	RST = 1'b1;
	#1000;
	RST = 1'b0;
end

always begin
      CLK = 1'b0;
      #5 CLK = 1'b1;
      #5;
   end  




endmodule
