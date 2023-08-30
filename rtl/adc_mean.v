module adc_mean(
	input              CLK,
	input              RST,
	//------------------------------
	input      [15: 0] ADC1DAT,
	input      [15: 0] ADC2DAT,
	//------------------------------
	output     [15: 0] MEANDAT
);

reg  [15: 0] AdcDat1;
reg  [15: 0] AdcDat2;

reg  [15: 0] MeanDat1;
reg  [15: 0] MeanDat2;
reg  [31: 0] SumDat1;
reg  [31: 0] SumDat2;
reg  [15: 0] DatCnt;

assign MEANDAT      = (MeanDat1 > MeanDat2) ? MeanDat1 : MeanDat2;

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		AdcDat1      <= 16'd0;
	end else if(ADC1DAT[15])begin
		AdcDat1      <= ~ADC1DAT +1;
	end else begin
		AdcDat1      <= ADC1DAT;
	end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		AdcDat2      <= 16'd0;
	end else if(ADC2DAT[15])begin
		AdcDat2      <= ~ADC2DAT +1;
	end else begin
		AdcDat2      <= ADC2DAT;
	end
end

always@(posedge CLK,posedge RST)begin
	if(RST)begin
		SumDat1     <= 32'd0;
		SumDat2     <= 32'd0;
		DatCnt      <= 16'd0;
		MeanDat1    <= 16'd0;
		MeanDat2    <= 16'd0;
	end else if(DatCnt == 16'd1023)begin
		DatCnt      <= 16'd0;
		SumDat1     <= 32'd0;
		SumDat2     <= 32'd0;
		MeanDat1    <= SumDat1[25:10];
		MeanDat2    <= SumDat2[25:10];
	end else begin
		DatCnt      <= DatCnt + 16'd1;
		SumDat1     <= SumDat1 + AdcDat1;
		SumDat2     <= SumDat2 + AdcDat2;
	end
end


endmodule
