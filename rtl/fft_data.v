module fft_data(
	input              CLK,
	input              RST,
	input              FFTEN,
	output reg         PULSSRT,
	//-----------------------------------
	input              DDCDEN,
	input      [15: 0] DDCDATI,
	input      [15: 0] DDCDATQ,
	//-----------------------------------
	input              FFTBUSY,
	output             FFTDOE,
	output     [15: 0] FFTDATI,
	output     [15: 0] FFTDATQ
);

reg  [7 : 0] STATU;
reg  [15: 0] DatCnt;
reg          FWEn;
reg  [31: 0] FWData;
reg          FREn;
reg          FifoRst;
wire [31: 0] FRData;

assign FFTDOE       = FREn;
assign FFTDATI      = FRData[15:0];
assign FFTDATQ      = FRData[31:16];

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		STATU         <= 8'd0;
		FWEn          <= 1'b0;
		FWData        <= 32'd0;
		FREn          <= 1'b0;
		DatCnt        <= 16'd0;
		FifoRst       <= 1'b0;
		PULSSRT       <= 1'b0;
	end else begin
		case(STATU)
			8'd0   :begin
						if(FFTEN & (!FFTBUSY) & DDCDEN)begin
							STATU         <= 8'd1;
							PULSSRT       <= 1'b1;
						end else begin
							STATU         <= 8'd0;
						end
					end
			8'd1   :begin
						PULSSRT       <= 1'b0;
						if(DDCDEN)begin
							FWEn          <= 1'b1;
							FWData        <= {DDCDATQ,DDCDATI};
							STATU         <= 8'd2;
						end else begin
							FWEn          <= 1'b0;
							FWData        <= 32'd0;
							STATU         <= 8'd1;
						end
					end
			8'd2   :begin
						FWEn          <= 1'b0;
						if(DatCnt == 16'd1023)begin
							DatCnt        <= 16'd0;
							STATU         <= 8'd3;
						end else begin
							STATU         <= 8'd1;
							DatCnt        <= DatCnt + 16'd1;
						end
					end
			8'd3   :begin
						if(DatCnt == 16'd1024)begin
							DatCnt        <= 16'd0;
							STATU         <= 8'd4;
							FREn          <= 1'b0;
						end else begin
							DatCnt        <= DatCnt + 16'd1;
							STATU         <= 8'd3;
							FREn          <= 1'b1;
						end
					end
			8'd4   :begin
						if(DatCnt == 16'd31)begin
							STATU         <= 8'd0;
							DatCnt        <= 16'd0;
							FifoRst       <= 1'b0;
						end else begin
							STATU         <= 8'd4;
							DatCnt        <= DatCnt + 16'd1;
							FifoRst       <= 1'b1;
						end
					end
			default:STATU         <= 8'd0;
		endcase
	end
end

fft_fifo inst_fft_fifo(
	.aclr             ( FifoRst  ),
	//------------------------------------
	.wrclk            ( CLK      ),
	.wrreq            ( FWEn     ),
	.data             ( FWData   ),
	.wrfull           ( ),
	//------------------------------------
	.rdclk            ( CLK      ),
	.rdreq            ( FREn     ),
	.q                ( FRData   ),
	.rdempty          ( )
);



endmodule
