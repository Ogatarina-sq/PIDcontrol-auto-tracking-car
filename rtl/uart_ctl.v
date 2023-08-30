module uart_ctl(
	input              CLK,
	input              RST,
	//----------------------------------------
	input              DIFF_PHEN,
	input      [15: 0] DIFF_PHDAT,
	input      [54: 0] LTHMAXD,
	input              CHECK_DOE,
	input      [63: 0] CHECK_DAT1,
	input      [63: 0] CHECK_DAT2,
	input      [63: 0] CHECK_DAT3,
	input      [63: 0] CHECK_DAT4,
	input      [63: 0] CHECK_DAT5,
	input      [63: 0] CHECK_DAT6,
	input      [63: 0] CHECK_DAT7,
	input      [63: 0] CHECK_DAT8,
	input      [63: 0] CHECK_DAT9,
	input      [63: 0] CHECK_DAT10,
	input      [63: 0] CHECK_DAT11,
	input      [63: 0] CHECK_DAT12,
	input      [63: 0] CHECK_DAT13,
	input      [63: 0] CHECK_DAT14,
	input      [63: 0] CHECK_DAT15,
	input      [63: 0] CHECK_DAT16,
	//----------------------------------------
	output             ARM_TXD,
	input              ARM_RXD,
	output             SIM_TXD,
	input              SIM_RXD
);

reg          Clk16;
reg  [7 : 0] DivCnt;
reg  [15: 0] TxBuff[70:0];

reg          TxBuffBuy;
reg  [7 : 0] STATU;
reg          TxEn;
reg  [7 : 0] TxDat;
reg  [7 : 0] TxCnt;
reg  [7 : 0] DlyCnt;
wire         TxRusy;

reg  [7 : 0] DlyCnt1;
reg          UartTx;

assign SIM_TXD       = ARM_TXD;
 
always@(posedge CLK,posedge RST)begin
	if(RST)begin
		DivCnt      <= 8'd0;
		Clk16       <= 1'b0;
	end else if(DivCnt == 8'd26)begin
		DivCnt      <= 8'd0;
		Clk16       <= ~Clk16;
	end else begin
		DivCnt      <= DivCnt + 8'd1;
	end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		UartTx         <= 1'b0;
		DlyCnt1        <= 8'd31;
	end else if(DIFF_PHEN)begin
		UartTx         <= 1'b1;
		DlyCnt1        <= 8'd0;
//	end else if(DlyCnt1 == 8'd31)begin 
	end else if(TxBuffBuy)begin
		UartTx         <= 1'b0;
		DlyCnt1        <= DlyCnt1;
	end else begin
		DlyCnt1        <= DlyCnt1 + 8'd1;
	end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		TxBuff[0]    <= 16'h55aa;
		TxBuff[1]    <= 16'h6699;
		TxBuff[2]    <= 16'd0;
		TxBuff[3]    <= 16'd0;
		TxBuff[4]    <= 16'd0;
		TxBuff[5]    <= 16'd0;
		TxBuff[6]    <= 16'd0;
		TxBuff[7]    <= 16'd0;
		TxBuff[8]    <= 16'd0;
		
		TxBuff[9]    <= 16'd0;
		TxBuff[10]   <= 16'd0;
		TxBuff[11]   <= 16'd0;
		TxBuff[12]   <= 16'd0;
		TxBuff[13]   <= 16'd0;
		TxBuff[14]   <= 16'd0;
		TxBuff[15]   <= 16'd0;
		TxBuff[16]   <= 16'd0;
		TxBuff[17]   <= 16'd0;
		TxBuff[18]   <= 16'd0;
		TxBuff[19]   <= 16'd0;
		
		TxBuff[20]   <= 16'd0;
		TxBuff[21]   <= 16'd0;
		TxBuff[22]   <= 16'd0;
		TxBuff[23]   <= 16'd0;
		TxBuff[24]   <= 16'd0;
		TxBuff[25]   <= 16'd0;
		TxBuff[26]   <= 16'd0;
		TxBuff[27]   <= 16'd0;
		TxBuff[28]   <= 16'd0;
		TxBuff[29]   <= 16'd0;
		
		TxBuff[30]   <= 16'd0;
		TxBuff[31]   <= 16'd0;
		TxBuff[32]   <= 16'd0;
		TxBuff[33]   <= 16'd0;
		TxBuff[34]   <= 16'd0;
		TxBuff[35]   <= 16'd0;
		TxBuff[36]   <= 16'd0;
		TxBuff[37]   <= 16'd0;
		TxBuff[38]   <= 16'd0;
		TxBuff[39]   <= 16'd0;
		
		TxBuff[40]   <= 16'd0;
		TxBuff[41]   <= 16'd0;
		TxBuff[42]   <= 16'd0;
		TxBuff[43]   <= 16'd0;
		TxBuff[44]   <= 16'd0;
		TxBuff[45]   <= 16'd0;
		TxBuff[46]   <= 16'd0;
		TxBuff[47]   <= 16'd0;
		TxBuff[48]   <= 16'd0;
		TxBuff[49]   <= 16'd0;
		
		TxBuff[50]   <= 16'd0;
		TxBuff[51]   <= 16'd0;
		TxBuff[52]   <= 16'd0;
		TxBuff[53]   <= 16'd0;
		TxBuff[54]   <= 16'd0;
		TxBuff[55]   <= 16'd0;
		TxBuff[56]   <= 16'd0;
		TxBuff[57]   <= 16'd0;
		TxBuff[58]   <= 16'd0;
		TxBuff[59]   <= 16'd0;
		
		TxBuff[60]   <= 16'd0;
		TxBuff[61]   <= 16'd0;
		TxBuff[62]   <= 16'd0;
		TxBuff[63]   <= 16'd0;
		TxBuff[64]   <= 16'd0;
		TxBuff[65]   <= 16'd0;
		TxBuff[66]   <= 16'd0;
		TxBuff[67]   <= 16'd0;
		TxBuff[68]   <= 16'd0;
		TxBuff[69]   <= 16'd0;
		TxBuff[70]   <= 16'd0;
	end else if(DIFF_PHEN)begin
		TxBuff[2]    <= LTHMAXD[54:48];
		TxBuff[3]    <= LTHMAXD[47:32];
		TxBuff[4]    <= LTHMAXD[31:16];
		TxBuff[5]    <= LTHMAXD[15: 0];
		
		TxBuff[6]    <= DIFF_PHDAT;
		
		TxBuff[7]    <= CHECK_DAT1[63:48];
		TxBuff[8]    <= CHECK_DAT1[47:32];
		TxBuff[9]    <= CHECK_DAT1[31:16];
		TxBuff[10]   <= CHECK_DAT1[15:0];
		TxBuff[11]   <= CHECK_DAT2[63:48];
		TxBuff[12]   <= CHECK_DAT2[47:32];
		TxBuff[13]   <= CHECK_DAT2[31:16];
		TxBuff[14]   <= CHECK_DAT2[15:0];
		TxBuff[15]   <= CHECK_DAT3[63:48];
		TxBuff[16]   <= CHECK_DAT3[47:32];
		
		TxBuff[17]   <= CHECK_DAT3[31:16];
		TxBuff[18]   <= CHECK_DAT3[15:0];
		TxBuff[19]   <= CHECK_DAT4[63:48];
		TxBuff[20]   <= CHECK_DAT4[47:32];
		TxBuff[21]   <= CHECK_DAT4[31:16];
		TxBuff[22]   <= CHECK_DAT4[15:0];
		TxBuff[23]   <= CHECK_DAT5[63:48];
		TxBuff[24]   <= CHECK_DAT5[47:32];
		TxBuff[25]   <= CHECK_DAT5[31:16];
		TxBuff[26]   <= CHECK_DAT5[15:0];
		
		TxBuff[27]   <= CHECK_DAT6[63:48];
		TxBuff[28]   <= CHECK_DAT6[47:32];
		TxBuff[29]   <= CHECK_DAT6[31:16];
		TxBuff[30]   <= CHECK_DAT6[15:0];
		TxBuff[31]   <= CHECK_DAT7[63:48];
		TxBuff[32]   <= CHECK_DAT7[47:32];
		TxBuff[33]   <= CHECK_DAT7[31:16];
		TxBuff[34]   <= CHECK_DAT7[15:0];
		TxBuff[35]   <= CHECK_DAT8[63:48];
		TxBuff[36]   <= CHECK_DAT8[47:32];
		
		TxBuff[37]   <= CHECK_DAT8[31:16];
		TxBuff[38]   <= CHECK_DAT8[15:0];
		TxBuff[39]   <= CHECK_DAT9[63:48];
		TxBuff[40]   <= CHECK_DAT9[47:32];
		TxBuff[41]   <= CHECK_DAT9[31:16];
		TxBuff[42]   <= CHECK_DAT9[15:0];
		TxBuff[43]   <= CHECK_DAT10[63:48];
		TxBuff[44]   <= CHECK_DAT10[47:32];
		TxBuff[45]   <= CHECK_DAT10[31:16];
		TxBuff[46]   <= CHECK_DAT10[15:0];
		
		TxBuff[47]   <= CHECK_DAT11[63:48];
		TxBuff[48]   <= CHECK_DAT11[47:32];
		TxBuff[49]   <= CHECK_DAT11[31:16];
		TxBuff[50]   <= CHECK_DAT11[15:0];
		TxBuff[51]   <= CHECK_DAT12[63:48];
		TxBuff[52]   <= CHECK_DAT12[47:32];
		TxBuff[53]   <= CHECK_DAT12[31:16];
		TxBuff[54]   <= CHECK_DAT12[15:0];
		TxBuff[55]   <= CHECK_DAT13[63:48];
		TxBuff[56]   <= CHECK_DAT13[47:32];
		
		TxBuff[57]   <= CHECK_DAT13[31:16];
		TxBuff[58]   <= CHECK_DAT13[15:0];
		TxBuff[59]   <= CHECK_DAT14[63:48];
		TxBuff[60]   <= CHECK_DAT14[47:32];
		TxBuff[61]   <= CHECK_DAT14[31:16];
		TxBuff[62]   <= CHECK_DAT14[15:0];
		TxBuff[63]   <= CHECK_DAT15[63:48];
		TxBuff[64]   <= CHECK_DAT15[47:32];
		TxBuff[65]   <= CHECK_DAT15[31:16];
		TxBuff[66]   <= CHECK_DAT15[15:0];
		
		TxBuff[67]   <= CHECK_DAT16[63:48];
		TxBuff[68]   <= CHECK_DAT16[47:32];
		TxBuff[69]   <= CHECK_DAT16[31:16];
		TxBuff[70]   <= CHECK_DAT16[15:0];
	end
end

always@(posedge Clk16,posedge RST)begin
	if(RST)begin
		STATU         <= 8'd0;
		TxEn          <= 1'b0;
		TxDat         <= 8'd0;
		TxCnt         <= 8'd0;
		TxBuffBuy     <= 1'b0;
		DlyCnt        <= 8'd0;
	end else begin
		case(STATU)
			8'd0   :begin
						if((!TxRusy) & UartTx)begin
							STATU         <= 8'd1;
							TxBuffBuy     <= 1'b1;
						end else begin
							STATU         <= 8'd0;
						end
					end
			8'd1   :begin
						TxBuffBuy     <= 1'b0;
						if(!TxRusy)begin
							STATU         <= 8'd2;
						end else begin
							STATU         <= 8'd1;
						end
						TxDat         <= TxBuff[TxCnt][15:8];
					end
			8'd2   :begin
						TxEn          <= 1'b1;
						STATU         <= 8'd3;
					end
			8'd3   :begin
						TxEn          <= 1'b0;
						if(DlyCnt == 8'd3)begin
							DlyCnt        <= 8'd0;
							STATU         <= 8'd4;
						end else begin
							DlyCnt        <= DlyCnt + 8'd1;
							STATU         <= 8'd3;
						end
					end
			8'd4   :begin
						if(!TxRusy)begin
							STATU         <= 8'd5;
						end else begin
							STATU         <= 8'd4;
						end
						TxDat         <= TxBuff[TxCnt][7:0];
					end
			8'd5   :begin
						TxEn          <= 1'b1;
						STATU         <= 8'd6;
					end
			8'd6   :begin
						TxEn          <= 1'b0;
						if(DlyCnt == 8'd2)begin
							DlyCnt        <= 8'd0;
							STATU         <= 8'd7;
						end else begin
							DlyCnt        <= DlyCnt + 8'd1;
							STATU         <= 8'd6;
						end
					end
			8'd7   :begin
						if(TxCnt == 8'd70)begin
							TxCnt         <= 8'd0;
							STATU         <= 8'd0;
						end else begin
							TxCnt         <= TxCnt + 8'd1;
							STATU         <= 8'd1;
						end
					end
			default:;
		endcase
	end
end

uart_core  uart_core_inst(
     .CLK_Uart16x  ( Clk16   ),
	 .RST          ( RST     ),
	 .CMD          ( 2'b00   ),     //00  Norm ,  01   odd  ,   10  even
	
	 .T_nCS        ( !TxEn   ),
	 .T_Busy       ( TxRusy  ),
	 .T_Data       ( TxDat   ),
	 .T_TXD        ( ARM_TXD ),
	 .R_Error      (  ),
	 .R_Ready      (  ),
	 .R_Data       (  ),
	 .R_RXD        ( ARM_RXD )
);






endmodule
