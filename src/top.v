//============================================================================//
// AIC2021 Project1 - TPU Design                                              //
// file: top.v                                                                //
// description: Top module complete your TPU design here                      //
// authors: kaikai (deekai9139@gmail.com)                                     //
//          suhan  (jjs93126@gmail.com)                                       //
//============================================================================//
`include "define.v"
`include "global_buffer.v"

module top(clk, rst, start, m, n,  k, done);

  input clk;
  input rst;
  input start;
  input [3:0] m, k, n;
  output reg done;

  reg                   wr_en_a,
                        wr_en_b,
                        wr_en_out;
  reg  [`DATA_SIZE-1:0] index_a,       //adderss
                        index_b,
                        index_out;
  reg  [`WORD_SIZE-1:0] data_in_a,
                        data_in_b,
                        data_in_o;
  wire [`WORD_SIZE-1:0] data_out_a,
                        data_out_b,
                        data_out_o;

//----------------------------------------------------------------------------//
// TPU module declaration                                                     //
//----------------------------------------------------------------------------//
  //****TPU tpu1(); add your design here*****//
parameter IDLE = 2'd0;
parameter BUZY = 2'd1;
parameter OUTP = 2'd2;
parameter DONE = 2'd3;

reg [`DATA_SIZE-1:0] mula_temp [0:15];
reg [`DATA_SIZE-1:0] mulb_temp [0:15];
reg [`DATA_SIZE-1:0] psum_temp [0:15];

reg [`DATA_SIZE-1:0] a1_temp;
reg [`DATA_SIZE-1:0] a2_temp [0:1];
reg [`DATA_SIZE-1:0] a3_temp [0:2];
reg [`DATA_SIZE-1:0] a4_temp [0:3];

reg [`DATA_SIZE-1:0] b1_temp;
reg [`DATA_SIZE-1:0] b2_temp [0:1];
reg [`DATA_SIZE-1:0] b3_temp [0:2];
reg [`DATA_SIZE-1:0] b4_temp [0:3];

reg [`DATA_SIZE-1:0] mul [0:15];

reg [1:0] state, n_state;
reg [1:0] row_offset;
reg [1:0] col_offset;
reg [4:0] counter;
reg [4:0] counter1;
reg [1:0] counter_a;
reg [1:0] counter_b;
reg [4:0] in_addr_a;
reg [4:0] in_addr_b;
reg [4:0] out_addr;
reg [2:0] out_limit;

integer i;

always @(*) begin
  row_offset = (n >= 9) ? 3 : (n >= 5 && n < 9) ? 2 : 1;
  col_offset = (m >= 9) ? 2 : (m >= 5 && m < 9) ? 1 : 0;
end

always @(posedge clk or posedge rst) begin
  if(rst) state <= IDLE;
  else state <= n_state;
end

always @(*) begin
  case (state)
    IDLE: n_state = (start) ? BUZY : IDLE;
    BUZY: n_state = (counter <= (k + 6)) ? BUZY : OUTP;
    OUTP: n_state = (counter1 < out_limit) ? OUTP : (counter_b == row_offset) ? DONE : IDLE;
    DONE: n_state = DONE;
    default: n_state = IDLE;
  endcase
end

always @(*) begin
  out_limit = (counter_a == col_offset && m[1:0] != 2'b00) ? m[1:0] : 4;
end

always @(*) begin
  if(state == OUTP)
    {wr_en_a, wr_en_b, wr_en_out} = 3'b001;
  else
    {wr_en_a, wr_en_b, wr_en_out} = 3'b000;
end

always @(*) begin
  done = (state == DONE);
end

always @(posedge clk or posedge rst) begin
  if(rst) counter <= 0;
  else begin
    if(state == BUZY)
      counter <= counter + 1;
    else
      counter <= 0;
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) counter1 <= 0;
  else begin
    if(state == OUTP)
      counter1 <= counter1 + 1;
    else
      counter1 <= 0;
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) counter_a <= 0;
  else begin
    if(state == OUTP && n_state == IDLE) begin
      if(counter_a < col_offset)
        counter_a <= counter_a + 1;
      else
        counter_a <= 0;
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) counter_b <= 0;
  else begin
    if(state == IDLE && counter_a == col_offset)
      counter_b <= counter_b + 1;
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) in_addr_a <= 0;
  else begin
    if(state == OUTP) begin
      if(counter_a == col_offset)
        in_addr_a <= 0;
      else if(k == 1)
        in_addr_a <= 1;
    end
    else if(n_state == BUZY) begin
      if(counter < (k - 1))
        in_addr_a <= in_addr_a + 1;
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) in_addr_b <= 0;
  else begin
    if(state == OUTP) begin
      in_addr_b <= k * counter_b;
    end
    else if(n_state == BUZY) begin
      if(counter < (k - 1))
        in_addr_b <= in_addr_b + 1;
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) out_addr <= 0;
  else begin
    if(state == OUTP && n_state == OUTP)
      out_addr <= out_addr + 1;
  end
end

always @(*) begin
  index_a = in_addr_a;
  index_b = in_addr_b;
end

always @(posedge clk or posedge rst) begin
  if(rst) index_out <= 0;
  else index_out <= out_addr;
end



///////////////////////////////////////////////////////////
//                                                       //
//                       MAC array                       //
//                                                       //
///////////////////////////////////////////////////////////
always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(i = 0; i < 16; i = i + 1)
      mula_temp[i] <= 8'd0;
  end
  else begin
    if(state == BUZY) begin
      mula_temp[0] <= a1_temp;
      mula_temp[1] <= mula_temp[0];
      mula_temp[2] <= mula_temp[1];
      mula_temp[3] <= mula_temp[2];

      mula_temp[4] <= a2_temp[0];
      mula_temp[5] <= mula_temp[4];
      mula_temp[6] <= mula_temp[5];
      mula_temp[7] <= mula_temp[6];

      mula_temp[8] <= a3_temp[0];
      mula_temp[9] <= mula_temp[8];
      mula_temp[10] <= mula_temp[9];
      mula_temp[11] <= mula_temp[10];

      mula_temp[12] <= a4_temp[0];
      mula_temp[13] <= mula_temp[12];
      mula_temp[14] <= mula_temp[13];
      mula_temp[15] <= mula_temp[14];
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(i = 0; i < 16; i = i + 1)
      mulb_temp[i] <= 8'd0;
  end
  else begin
    if(state == BUZY) begin
      mulb_temp[0] <= b1_temp;
      mulb_temp[4] <= mulb_temp[0];
      mulb_temp[8] <= mulb_temp[4];
      mulb_temp[12] <= mulb_temp[8];

      mulb_temp[1] <= b2_temp[0];
      mulb_temp[5] <= mulb_temp[1];
      mulb_temp[9] <= mulb_temp[5];
      mulb_temp[13] <= mulb_temp[9];

      mulb_temp[2] <= b3_temp[0];
      mulb_temp[6] <= mulb_temp[2];
      mulb_temp[10] <= mulb_temp[6];
      mulb_temp[14] <= mulb_temp[10];

      mulb_temp[3] <= b4_temp[0];
      mulb_temp[7] <= mulb_temp[3];
      mulb_temp[11] <= mulb_temp[7];
      mulb_temp[15] <= mulb_temp[11];
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(i = 0; i < 16; i = i + 1)
      psum_temp[i] <= 8'd0;
  end
  else begin
    if(state == BUZY) begin
      for(i = 0; i < 16; i = i + 1)
        psum_temp[i] <= psum_temp[i] + mul[i];
    end
    else if(state == IDLE) begin
      for(i = 0; i < 16; i = i + 1)
        psum_temp[i] <= 8'd0;
    end
  end
end

always @(*) begin
  for(i = 0; i < 16; i = i + 1)
    mul[i] = mula_temp[i] * mulb_temp[i];
end




///////////////////////////////////////////////////////////
//                                                       //
//                   Data_Loader_A                       //
//                                                       //
///////////////////////////////////////////////////////////
always @(posedge clk or posedge rst) begin
  if(rst) a1_temp <= 0;
  else begin
    if(state == BUZY) begin
      if(counter < k)
        a1_temp <= data_out_a[31:24];
      else
        a1_temp <= 0;
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(i = 0; i < 2; i = i + 1)
      a2_temp[i] <= 8'd0;
  end
  else begin
    if(state == BUZY) begin
      a2_temp[0] <= a2_temp[1];
      if(counter < k)
        a2_temp[1] <= data_out_a[23:16];
      else
        a2_temp[1] <= 0;
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(i = 0; i < 3; i = i + 1)
      a3_temp[i] <= 8'd0;
  end
  else begin
    if(state == BUZY) begin
      a3_temp[0] <= a3_temp[1];
      a3_temp[1] <= a3_temp[2];
      if(counter < k)
        a3_temp[2] <= data_out_a[15:8];
      else
        a3_temp[2] <= 0;
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(i = 0; i < 4; i = i + 1)
      a4_temp[i] <= 8'd0;
  end
  else begin
    if(state == BUZY) begin
      a4_temp[0] <= a4_temp[1];
      a4_temp[1] <= a4_temp[2];
      a4_temp[2] <= a4_temp[3];
      if(counter < k)
        a4_temp[3] <= data_out_a[7:0];
      else
        a4_temp[3] <= 0;
    end
  end
end



///////////////////////////////////////////////////////////
//                                                       //
//                   Data_Loader_B                       //
//                                                       //
///////////////////////////////////////////////////////////
always @(posedge clk or posedge rst) begin
  if(rst) b1_temp <= 0;
  else begin
    if(state == BUZY)
      if(counter < k)
        b1_temp <= data_out_b[31:24];
      else
        b1_temp <= 0;
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(i = 0; i < 2; i = i + 1)
      b2_temp[i] <= 8'd0;
  end
  else begin
    if(state == BUZY) begin
      b2_temp[0] <= b2_temp[1];
      if(counter < k)
        b2_temp[1] <= data_out_b[23:16];
      else
        b2_temp[1] <= 0;
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(i = 0; i < 3; i = i + 1)
      b3_temp[i] <= 8'd0;
  end
  else begin
    if(state == BUZY) begin
      b3_temp[0] <= b3_temp[1];
      b3_temp[1] <= b3_temp[2];
      if(counter < k)
        b3_temp[2] <= data_out_b[15:8];
      else
        b3_temp[2] <= 0;
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    for(i = 0; i < 4; i = i + 1)
      b4_temp[i] <= 8'd0;
  end
  else begin
    if(state == BUZY) begin
      b4_temp[0] <= b4_temp[1];
      b4_temp[1] <= b4_temp[2];
      b4_temp[2] <= b4_temp[3];
      if(counter < k)
        b4_temp[3] <= data_out_b[7:0];
      else
        b4_temp[3] <= 0;
    end
  end
end


always @(*) begin
  data_in_a = 0;
  data_in_b = 0;
end

always @(posedge clk or posedge rst) begin
  if(rst) data_in_o <= 0;
  else data_in_o <= {psum_temp[(counter1 << 2) + 3], psum_temp[(counter1 << 2) + 2], psum_temp[(counter1 << 2) + 1], psum_temp[counter1 << 2]};
end








//----------------------------------------------------------------------------//
// Global buffers declaration                                                 //
//----------------------------------------------------------------------------//
  global_buffer GBUFF_A(.clk     (clk       ),
                        .rst     (rst       ),
                        .wr_en   (wr_en_a   ),
                        .index   (index_a   ),
                        .data_in (data_in_a ),
                        .data_out(data_out_a));

  global_buffer GBUFF_B(.clk     (clk       ),
                        .rst     (rst       ),
                        .wr_en   (wr_en_b   ),
                        .index   (index_b   ),
                        .data_in (data_in_b ),
                        .data_out(data_out_b));

  global_buffer GBUFF_OUT(.clk     (clk      ),
                          .rst     (rst      ),
                          .wr_en   (wr_en_out),
                          .index   (index_out),
                          .data_in (data_in_o),
                          .data_out(data_out_o));

endmodule
