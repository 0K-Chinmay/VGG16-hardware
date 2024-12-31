`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2024 21:36:16
// Design Name: 
// Module Name: Main_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Main_1
#(parameter MatAW=5 ,ADW=5,DATW=10)
(
    input clk,
    input rst,
    input load,
 //   input conv,
 //   input wenA,
 //   input wenW,
    output reg done
//    input [ADW-1:0]Addrin,
   // output reg [DATW-1:0] datout
    );
    localparam Idle=3'b000,
              MaxPool=3'b001,
              Conv=3'b010,
              Finish=3'b011,
              ConPr=3'b100;
              
    reg [2:0] current_state,next_state;
    reg [DATW-1:0] convD;
    wire [ADW-1:0] raddrA,raddrW;
    wire [DATW-1:0] Wmat [8:0];
    wire [DATW-1:0] Amat [MatAW**2-1:0];
    reg [DATW-1:0] Prod [(MatAW-2)**2-1:0];
    
    reg[15:0] i;
    integer j,stride,Act,Wct;
    genvar k;
    
    generate 
        for (k = 0; k < MatAW**2; k = k + 1) begin
               assign Amat[k] = (k + 1)%7+1;
        end
    endgenerate
    
     generate 
        for (k = 0; k < 9; k = k + 1) begin
               assign Wmat[k] = (k + 1)%3 + 1;
        end
    endgenerate
    
    always@(posedge clk)begin
      if(rst) begin
        current_state<=Idle;
        i<=0;
      end else begin     
        current_state<=next_state;   
        i<=current_state==next_state ? i+1:0;
      end
    end

    
    always@(*) begin  
    done=0;
    next_state=current_state;
      case(current_state) 
         
         Idle:begin          
           Wct=0;
           Act=0;
           convD=0;
           stride=1;
           next_state=Conv;
         end

         Conv:begin
         convD = Amat[0 + Act] * Wmat[0] +
                Amat[1 + Act] * Wmat[1] +
                Amat[2 + Act] * Wmat[2] +
                Amat[MatAW + Act] * Wmat[3] +
                Amat[MatAW+1 + Act] * Wmat[4] +
                Amat[MatAW+2 + Act] * Wmat[5] +
                Amat[2*MatAW + Act] * Wmat[6] +
                Amat[MatAW*2+1 + Act] * Wmat[7] +
                Amat[MatAW*2+2 + Act] * Wmat[8];
         
         Prod[i]=convD; 
         $display("%d---%d----%d",Prod[i],Act,i);
         Act=(i+1)%(MatAW-2)==0?Act+3:Act+stride;
         next_state=i<((MatAW-2)**2-1)?Conv:Finish;
         end
         
         MaxPool:begin
         
         
         end
         
         Finish:begin
         
         done=1;
          // $display("neong");
         next_state=Idle;
         end 
         
      
      endcase
    end

endmodule
