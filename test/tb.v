`default_nettype none
`timescale 1ns/1ps

module tb ();
  // this is only used for waveform dumping
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end
endmodule