`include "defines.h"

module tb;

  function logic [127:0] swap16 (input [127:0] i);
  begin
    logic [15:0] [7:0] i_bytes, o_bytes;
    i_bytes = i;
    for (int i = 0; i < 16; i++) begin
      o_bytes[i] = i_bytes[15-i];
    end
    swap16 = o_bytes;
  end
  endfunction
  

  logic clk = 1'b0;
  logic rst = 1'b0;
  logic [127:0] key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
  logic done, ready;
  logic [39*`RED-1:0] random;
  logic [128*2-1:0] random_for_shares;
  logic start;
  logic [127:0] key_i[2], state_i[2], state_o[2], state_o_cap;

  always #5 clk = ~clk;
  initial begin
    rst = 1;
    repeat (2) @(posedge clk);
    rst = 0;
  end

  typedef enum {IDLE, SEND_TASK, WAIT_TASK, CHECK} fsm_e;
  localparam logic [127:0] inputs [4] = '{
    0: '0,
    1: '1,
    2: swap16(128'h6bc1bee22e409f96e93d7e117393172a),
    3: swap16(128'h2b7e151628aed2a6abf7158809cf4f3c)
  };

  localparam logic [127:0] references [4] = '{
    0: swap16(128'h7DF76B0C1AB899B33E42F047B91B546F),
    1: swap16(128'h8AF2860142F786F409307C1A3F7EAAAC),
    2: swap16(128'h3AD77BB40D7A3660A89ECAF32466EF97),
    3: swap16(128'h7F3591D36FD517A37B6DE9E0DF934B7A)
  };
  localparam MAX_TEST_NUM = 10;

  fsm_e fsm;
  int tstcnt;
  always @(posedge clk) begin
    if (rst) begin
      fsm <= IDLE;
      tstcnt <= 0;
      state_i <= '{default: '0};
      key_i <= '{default: '0};
      state_o_cap <= '0;
      random <= '0;
      random_for_shares <= '0;
    end else begin
      for (int i = 0; i < 39*`RED; i+=32)
        random[i+:32] <= $urandom();
      for (int i = 0; i < 256; i+=32)
        random_for_shares[i+:32] <= $urandom();
      case (fsm)
        IDLE:
          begin
            fsm <= SEND_TASK;
            state_i[0] <= inputs[tstcnt % 4] ^ random_for_shares[127:0];
            state_i[1] <= random_for_shares[127:0];
            key_i[0] <= key ^ random_for_shares[255:128];
            key_i[1] <= random_for_shares[255:128];
          end
        SEND_TASK:
          fsm <= WAIT_TASK;
        WAIT_TASK:
          begin
            if (done) begin
              fsm <= CHECK;
              state_o_cap <= state_o[0] ^ state_o[1];
            end
          end
        CHECK:
          begin
            if (state_o_cap !== references[tstcnt % 4]) begin
              $display("test %0d :: FAIL: expected = %0h; received = %0h", tstcnt, references[tstcnt % 4], state_o_cap);
              $finish();
            end else begin
              $display("test %0d :: check_valid", tstcnt);
              if (tstcnt == MAX_TEST_NUM-1) begin
                $display("DONE");
                $finish();
              end
            end
            tstcnt <= tstcnt + 1;
            fsm <= IDLE;
          end
        default:
          begin
            $display("SOMETHING GOES WRONG");
            $finish();
          end
      endcase
    end
  end

  assign start = fsm == SEND_TASK;
  logic key_destruct = fsm == CHECK;

  openAES_128e dut (
      .clk_i(clk)
    , .srst_i(rst)
    , .start_i(start)
    , .state_i(state_i[0])
    , .key_i(swap16(key_i[0]))
    , .state_share2_i(state_i[1])
    , .key_share2_i(swap16(key_i[1]))
    , .rand_i(random)
    , .state_o(state_o[0])
    , .state_share2_o(state_o[1])
    , .done_o(done)
    , .ready_o(ready)
    , .key_destruct_i(key_destruct)
  );



endmodule