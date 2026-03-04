`default_nettype none
`timescale 1ns / 1ps

// Self-checking testbench for tt_um_morse_to_hex
// Tests all 16 hex digits plus one invalid sequence.
// No tasks — every button press and check is written out explicitly so you can
// follow the simulation line by line.
//
// Button mapping (ui_in bits):
//   [0] = dot      [1] = dash      [2] = confirm      [3] = clear
//
// Each button press follows this pattern (edge detection needs one full cycle):
//   @(negedge clk); ui_in[N] = 1;   <- assert on negedge to avoid setup races
//   @(posedge clk);                   <- rising edge detected, state machine acts
//   @(negedge clk); ui_in[N] = 0;   <- deassert
//   @(posedge clk);                   <- _prev register clears, ready for next press
//
// Expected uo_out[6:0] is active-LOW (= ~hex2ssd_output):
//   hex2ssd active-HIGH -> invert for active-low display
//   0->1000000  1->1111001  2->0100100  3->0110000
//   4->0011001  5->0010010  6->0000010  7->1111000
//   8->0000000  9->0011000  A->0001000  B->0000011
//   C->1000110  D->0100001  E->0000110  F->0001110

module tb;

  // --------------------------------------------------------------------------
  // DUT signals
  // --------------------------------------------------------------------------
  reg        clk, rst_n, ena;
  reg  [7:0] ui_in, uio_in;
  wire [7:0] uo_out, uio_out, uio_oe;

  tt_um_morse_to_hex dut (
    .ui_in  (ui_in),
    .uo_out (uo_out),
    .uio_in (uio_in),
    .uio_out(uio_out),
    .uio_oe (uio_oe),
    .ena    (ena),
    .clk    (clk),
    .rst_n  (rst_n)
  );

  // 10 ns clock period
  initial clk = 0;
  always #5 clk = ~clk;

  integer pass_count, fail_count;

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);

    pass_count = 0;
    fail_count = 0;

    // Hold reset for 4 cycles then release
    rst_n = 0; ena = 1; ui_in = 8'h00; uio_in = 8'h00;
    repeat(4) @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    // =========================================================================
    // TEST 1: E  ->  .
    // morseToHex: count=1, buffer=00000
    // hex2ssd(E) = 7'b1111001 active-high  ->  active-low uo_out = 7'b0000110
    // =========================================================================
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0000110 && uo_out[7]===1'b0)
      begin $display("[PASS] E  | input: .        | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] E  | input: .        | got ssd=%07b err=%b | exp ssd=0000110 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 2: A  ->  . -
    // morseToHex: count=2, buffer=10000
    // hex2ssd(A) = 7'b1110111  ->  active-low = 7'b0001000
    // =========================================================================
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0001000 && uo_out[7]===1'b0)
      begin $display("[PASS] A  | input: .-       | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] A  | input: .-       | got ssd=%07b err=%b | exp ssd=0001000 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 3: D  ->  - . .
    // morseToHex: count=3, buffer=00100
    // hex2ssd(D) = 7'b1011110  ->  active-low = 7'b0100001
    // =========================================================================
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0100001 && uo_out[7]===1'b0)
      begin $display("[PASS] D  | input: -..      | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] D  | input: -..      | got ssd=%07b err=%b | exp ssd=0100001 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 4: B  ->  - . . .
    // morseToHex: count=4, buffer=00010
    // hex2ssd(B) = 7'b1111100  ->  active-low = 7'b0000011
    // =========================================================================
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0000011 && uo_out[7]===1'b0)
      begin $display("[PASS] B  | input: -...     | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] B  | input: -...     | got ssd=%07b err=%b | exp ssd=0000011 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 5: C  ->  - . - .
    // morseToHex: count=4, buffer=01010
    // hex2ssd(C) = 7'b0111001  ->  active-low = 7'b1000110
    // =========================================================================
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b1000110 && uo_out[7]===1'b0)
      begin $display("[PASS] C  | input: -.-.     | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] C  | input: -.-.     | got ssd=%07b err=%b | exp ssd=1000110 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 6: F  ->  . . - .
    // morseToHex: count=4, buffer=01000
    // hex2ssd(F) = 7'b1110001  ->  active-low = 7'b0001110
    // =========================================================================
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0001110 && uo_out[7]===1'b0)
      begin $display("[PASS] F  | input: ..-.     | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] F  | input: ..-.     | got ssd=%07b err=%b | exp ssd=0001110 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 7: 0  ->  - - - - -
    // morseToHex: count=5, buffer=11111
    // hex2ssd(0) = 7'b0111111  ->  active-low = 7'b1000000
    // =========================================================================
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b1000000 && uo_out[7]===1'b0)
      begin $display("[PASS] 0  | input: -----    | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] 0  | input: -----    | got ssd=%07b err=%b | exp ssd=1000000 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 8: 1  ->  . - - - -
    // morseToHex: count=5, buffer=11110
    // hex2ssd(1) = 7'b0000110  ->  active-low = 7'b1111001
    // =========================================================================
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b1111001 && uo_out[7]===1'b0)
      begin $display("[PASS] 1  | input: .----    | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] 1  | input: .----    | got ssd=%07b err=%b | exp ssd=1111001 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 9: 2  ->  . . - - -
    // morseToHex: count=5, buffer=11100
    // hex2ssd(2) = 7'b1011011  ->  active-low = 7'b0100100
    // =========================================================================
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0100100 && uo_out[7]===1'b0)
      begin $display("[PASS] 2  | input: ..---    | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] 2  | input: ..---    | got ssd=%07b err=%b | exp ssd=0100100 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 10: 3  ->  . . . - -
    // morseToHex: count=5, buffer=11000
    // hex2ssd(3) = 7'b1001111  ->  active-low = 7'b0110000
    // =========================================================================
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0110000 && uo_out[7]===1'b0)
      begin $display("[PASS] 3  | input: ...--    | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] 3  | input: ...--    | got ssd=%07b err=%b | exp ssd=0110000 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 11: 4  ->  . . . . -
    // morseToHex: count=5, buffer=10000
    // hex2ssd(4) = 7'b1100110  ->  active-low = 7'b0011001
    // =========================================================================
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0011001 && uo_out[7]===1'b0)
      begin $display("[PASS] 4  | input: ....-    | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] 4  | input: ....-    | got ssd=%07b err=%b | exp ssd=0011001 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 12: 5  ->  . . . . .
    // morseToHex: count=5, buffer=00000  (same bits as E but different count!)
    // hex2ssd(5) = 7'b1101101  ->  active-low = 7'b0010010
    // =========================================================================
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0010010 && uo_out[7]===1'b0)
      begin $display("[PASS] 5  | input: .....    | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] 5  | input: .....    | got ssd=%07b err=%b | exp ssd=0010010 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 13: 6  ->  - . . . .
    // morseToHex: count=5, buffer=00001
    // hex2ssd(6) = 7'b1111101  ->  active-low = 7'b0000010
    // =========================================================================
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0000010 && uo_out[7]===1'b0)
      begin $display("[PASS] 6  | input: -....    | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] 6  | input: -....    | got ssd=%07b err=%b | exp ssd=0000010 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 14: 7  ->  - - . . .
    // morseToHex: count=5, buffer=00011
    // hex2ssd(7) = 7'b0000111  ->  active-low = 7'b1111000
    // =========================================================================
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b1111000 && uo_out[7]===1'b0)
      begin $display("[PASS] 7  | input: --...    | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] 7  | input: --...    | got ssd=%07b err=%b | exp ssd=1111000 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 15: 8  ->  - - - . .
    // morseToHex: count=5, buffer=00111
    // hex2ssd(8) = 7'b1111111  ->  active-low = 7'b0000000
    // =========================================================================
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0000000 && uo_out[7]===1'b0)
      begin $display("[PASS] 8  | input: ---..    | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] 8  | input: ---..    | got ssd=%07b err=%b | exp ssd=0000000 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 16: 9  ->  - - - - .
    // morseToHex: count=5, buffer=01111
    // hex2ssd(9) = 7'b1100111  ->  active-low = 7'b0011000
    // =========================================================================
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[0]=1; @(posedge clk); @(negedge clk); ui_in[0]=0; @(posedge clk); // dot
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[6:0]===7'b0011000 && uo_out[7]===1'b0)
      begin $display("[PASS] 9  | input: ----.    | ssd=%07b  err=%b", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] 9  | input: ----.    | got ssd=%07b err=%b | exp ssd=0011000 err=0", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // TEST 17: INVALID  ->  - - - -  (4 dashes, no morse match)
    // Error LED uo_out[7] must be HIGH; 7-seg value does not matter
    // =========================================================================
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[1]=1; @(posedge clk); @(negedge clk); ui_in[1]=0; @(posedge clk); // dash
    @(negedge clk); ui_in[2]=1; @(posedge clk); @(negedge clk); ui_in[2]=0; @(posedge clk); // confirm
    #1;
    if (uo_out[7]===1'b1)
      begin $display("[PASS] ?  | input: ----     | ssd=%07b  err=%b  (error LED high as expected)", uo_out[6:0], uo_out[7]); pass_count=pass_count+1; end
    else
      begin $display("[FAIL] ?  | input: ----     | got ssd=%07b err=%b | exp err=1 (no morse match)", uo_out[6:0], uo_out[7]); fail_count=fail_count+1; end
    @(negedge clk); ui_in[3]=1; @(posedge clk); @(negedge clk); ui_in[3]=0; @(posedge clk); // clear

    // =========================================================================
    // Summary
    // =========================================================================
    $display("----------------------------------------");
    $display("Results: %0d passed, %0d failed", pass_count, fail_count);
    if (fail_count == 0) begin
      $display("ALL TESTS PASSED");
      $finish;
    end else begin
      $display("SOME TESTS FAILED");
      $fatal(1, "Test suite failed with %0d failure(s)", fail_count);
    end
  end

endmodule
