//T_nCS-------|   |--------
//            |___|
//             ___
//            |   |
//R_Ready-----|   |--------
//
//CMD  00     1bit start , 8bit data , 1bit stop 
//     01     1bit start , 8bit data , 1bit odd  , 1bit stop 
//     10     1bit start , 8bit data , 1bit even , 1bit stop 

module uart_core(
     CLK_Uart16x,
	 RST,
	 
	 CMD,     //00  Norm ,  01   odd  ,   10  even
	
	 T_nCS,
	 T_Busy,
	 T_Data,
	 T_TXD,
	 //////////////////////////////
	 //T_State,
	 //R_State,
	 //T_CntBit,
	 //R_CntBit,
	 //////////////////////////////
	 R_Error,
	 R_Ready,
	 R_Data,
	 R_RXD
	 
	 
	 );
	 //////////////////////////////
	 //output       [4:0] T_State ;
	 //output       [4:0] R_State ;
	 //output       [3:0] T_CntBit ;
	 //output       [3:0] R_CntBit ;
	 ///////////////////////////
	 
	 
	 input           CLK_Uart16x ;
	 input           RST ;
	 
	 input    [1:0]  CMD ;    //00  Norm ,  01   odd  ,   10  even
	 
	 
	 input           T_nCS ;
	 output          T_Busy ;
	 input    [7:0]  T_Data ;
	 output          T_TXD ;
	 reg             T_Busy ;
	 reg             T_TXD ;
	 reg             T_PARITY ;
	 reg      [10:0] T_MoveData ;
	 reg      [3:0]  T_CntBit ;
	 
	 reg             Syn1_T_nCS ;
	 reg             Syn2_T_nCS ;
	 reg      [3:0]  BitNum ;
	 
	 
	 output          R_Error ;
	 output          R_Ready ;
	 output   [7:0]  R_Data ;
	 input           R_RXD ;
	 reg      [7:0]  R_Data ;
	 reg             R_Error ;
	 reg             R_Ready ;
	 reg             R_PARITY ;
	 reg             Syn1_R_RXD ;
	 reg             Syn2_R_RXD ;
	 reg             Syn3_R_RXD ;
	 reg      [10:0] R_MoveData ;
	 reg      [3:0]  R_CntBit ;
	 
	 reg       [4:0] T_State ;
	 reg       [4:0] R_State ;
	 parameter [4:0] Idle       = 5'b0_0000 ,
	                 Start      = 5'b0_0001 ,
						  One        = 5'b0_0011 ,
						  Two        = 5'b0_0010 ,
						  Three      = 5'b0_0110 ,
						  Four       = 5'b0_0100 ,
						  Five       = 5'b0_0101 ,
						  Six        = 5'b0_0111 ,
						  Seven      = 5'b0_1111 ,
						  Eight      = 5'b0_1110 ,
						  Nine       = 5'b0_1100 ,
						  Ten        = 5'b0_1101 ,
						  Eleven     = 5'b0_1001 ,
						  Twelve     = 5'b0_1011 ,
						  Thirteen   = 5'b0_1010 ,
						  Fourteen   = 5'b0_1000 ,
						  Fifteen    = 5'b1_1000 ,
						  Sixteen    = 5'b1_0000 ;

					

always @( posedge CLK_Uart16x , posedge RST )begin
    if( RST )begin
	     Syn1_T_nCS   <= 1'b1 ;
		  Syn1_T_nCS   <= 1'b1 ;
	 end else begin
	     Syn1_T_nCS   <= T_nCS ;
		 Syn2_T_nCS   <= Syn1_T_nCS ;
	 end

end

			
always @( posedge CLK_Uart16x , posedge RST )begin
    if( RST )begin
	    Syn1_R_RXD   <= 1'b1 ;
		Syn2_R_RXD   <= 1'b1 ;
		Syn3_R_RXD   <= 1'b1 ;
	 end else begin
	    Syn1_R_RXD   <= R_RXD ;
		Syn2_R_RXD   <= Syn1_R_RXD ;
		Syn3_R_RXD   <= Syn2_R_RXD ;
	 end

end
			

always @( posedge CLK_Uart16x , posedge RST )begin
    if( RST )begin
	     BitNum       <=  4'd10 ;
	 end else begin
        case( CMD )
		      2'b00 : begin
				    BitNum       <=  4'd10 ;
				end
				2'b01 : begin
				    BitNum       <=  4'd11 ;
				end
				2'b10 : begin
				    BitNum       <=  4'd11 ;
				end
				2'b11 : begin
				    BitNum       <=  4'd10 ;
				end
		   endcase
	 end
end				
						
						
always @( posedge CLK_Uart16x , posedge RST )begin
    if( RST )begin
	     T_MoveData   <=  11'd0 ;
		  T_PARITY     <=  1'b0 ;
		  T_CntBit     <=  4'd0 ;
		  T_Busy       <=  1'b0 ;
		  T_TXD        <=  1'b1 ;
		  
		  
		  T_State      <=  Idle ;
	 end else begin
	     case( T_State )
	         Idle : begin
				    T_Busy       <=  1'b0 ;
		          T_PARITY     <=  1'b0 ;
					 T_CntBit     <=  4'd0 ;
					 T_TXD        <=  1'b1 ;
				    if( {Syn2_T_nCS,Syn1_T_nCS} == 2'b10 )begin
					     T_MoveData   <=  {1'b1,1'b0,T_Data,1'b0} ;
						  T_State      <=  Start ;
					 end else begin
					     T_MoveData   <=  11'd0 ;
						  T_State      <=  Idle ;
					 end
				end
				Start : begin
				    T_Busy       <=  1'b1 ;
				    T_State      <=  One ;
				    if( BitNum == 4'd10 )begin
						  T_MoveData[9] <=  1'b1 ;
					 end else begin
					     T_MoveData[9] <=  1'b0 ;
					 end
				end
				One : begin
				    T_TXD        <=  T_MoveData[0] ;
					 T_State      <=  Two ;
				end
				Two : begin
				    T_CntBit     <=  T_CntBit + 1'b1 ;
				    T_State      <=  Three ;
				end
				Three : begin
				    T_PARITY     <=  T_PARITY ^ T_TXD ;
				    T_State      <=  Four ;
				end
				Four : begin
				    T_MoveData[9:0]   <=  T_MoveData[10:1] ;
					 T_MoveData[10]    <=  1'b1 ;
				    T_State      <=  Five ;
				end
				Five : begin
				    T_State      <=  Six ;
				end
				Six : begin
				    T_State      <=  Seven ;
				end
				Seven : begin
				    T_State      <=  Eight ;
				end
				Eight : begin
				    T_State      <=  Nine ;
				end
				Nine : begin
				    T_State      <=  Ten ;
				end
				Ten : begin
				    T_State      <=  Eleven ;
				end
				Eleven : begin
				    T_State      <=  Twelve ;
				end
				Twelve : begin
				    T_State      <=  Thirteen ;
				end
				Thirteen : begin
				    T_State      <=  Fourteen ;
				end
				Fourteen : begin
				    T_State      <=  Fifteen ;
					 if( ( T_CntBit == 4'd9 ) && ( CMD == 2'b01 ) )begin //  0dd
					     T_MoveData[0] <= ~T_PARITY ;
					 end
				    
				end
				Fifteen : begin
				    T_State      <=  Sixteen ;
					 if( ( T_CntBit == 4'd9 ) && ( CMD == 2'b10 ) )begin
					     T_MoveData[0] <= T_PARITY ;
					 end
				    
				end
				Sixteen : begin
				    if( T_CntBit == BitNum )begin
				        T_State      <=  Idle ;
					 end else begin
					     T_State      <=  One ;
					 end
				end
				default : begin
				    T_State      <=  Idle ;
				end
	    endcase
	 end
end
	 
	 
always @( posedge CLK_Uart16x , posedge RST )begin
    if( RST )begin
	     R_MoveData   <=  11'd0 ;
		  R_PARITY     <=  1'b0 ;
		  R_CntBit     <=  4'd0 ;
		  R_Error      <=  1'b0 ;
		  R_Ready      <=  1'b1 ;
		  
		  R_State      <=  Idle ;
	 end else begin
	     case( R_State )
	         Idle : begin
		          R_PARITY     <=  1'b0 ;
					 R_CntBit     <=  4'd0 ;
					 R_MoveData   <=  11'd0 ;
					 R_Ready      <=  1'b1 ;
				    if( {Syn2_R_RXD,Syn1_R_RXD} == 2'b10 )begin
					     R_Error      <=  1'b0 ;
						  R_State      <=  One ;
					 end else begin
				        
						  R_State      <=  Idle ;
					 end
				end
				One : begin
				    R_Ready      <=  1'b0 ;
					 R_State      <=  Two ;
				end
				Two : begin
				    
				    R_State      <=  Three ;
				end
				Three : begin
				    
				    R_State      <=  Four ;
				end
				Four : begin
				    
				    R_State      <=  Five ;
				end
				Five : begin
				    R_State      <=  Six ;
				end
				Six : begin
				    R_State      <=  Seven ;
				end
				Seven : begin
				    if( ( R_CntBit == 4'd9 ) && ( CMD != 2'b00 ) )begin
					     if( R_PARITY == Syn3_R_RXD )begin
						      R_State      <=  Eight ;
						  end else begin
						      R_Error      <=  1'b1 ;
						      R_State      <=  Idle ;
						  end
					 end else begin
				        R_State      <=  Eight ;
					 end
				end
				Eight : begin
				    R_MoveData[10] <=  Syn3_R_RXD ;
					 R_PARITY       <=  R_PARITY ^ Syn3_R_RXD ;
				    R_State        <=  Nine ;
				end
				Nine : begin
				    R_CntBit     <=  R_CntBit + 1'b1 ;
				    R_State      <=  Ten ;
				end
				Ten : begin
				    R_MoveData[9:0]   <=  R_MoveData[10:1] ;
					 
				    R_State      <=  Eleven ;
				end
				Fifteen : begin
				    if( R_CntBit != BitNum )begin
					     R_State  <=  Sixteen ;
					 end else if( Syn3_R_RXD == 1'b1 )begin
					     R_State  <=  Sixteen ;
					 end else begin
					     R_Error      <=  1'b1 ;
					     R_State      <=  Idle ;
					 end
				    
				end
				Twelve : begin
				    R_State      <=  Thirteen ;
				end
				Thirteen : begin
				    R_State      <=  Fourteen ;
				end
				Fourteen : begin
				    R_State      <=  Fifteen ;
				    if( ( R_CntBit == 4'd9 ) && ( CMD == 2'b01 ) )begin
					     R_PARITY <= ~R_PARITY ;
					 end else if( ( R_CntBit == 4'd9 ) && ( CMD == 2'b10 ) )begin
					     R_PARITY <= R_PARITY ;
					 end
				    
				end
				Eleven : begin
				    if( R_CntBit == BitNum )begin
					     if( CMD == 2'b00 )begin
					         R_Data <= R_MoveData[8:1] ;
					     end else begin
					         R_Data <= R_MoveData[7:0] ;
					     end
				        R_State      <=  Idle ;
					 end else begin
					     //R_State      <=  One ;
					     R_State      <=  Twelve ;
					 end
				    
				end
				
				Sixteen : begin
				R_State      <=  One ;
				/*
				    if( R_CntBit == BitNum )begin
					     if( CMD == 2'b00 )begin
					         R_Data <= R_MoveData[8:1] ;
					     end else begin
					         R_Data <= R_MoveData[7:0] ;
					     end
				        R_State      <=  Idle ;
					 end else begin
					     R_State      <=  One ;
					 end
					 */
				end
				
				default : begin
				    R_State      <=  Idle ;
				end
		endcase
	 end
end	 
	 
	 
	 
	 
	 
endmodule 