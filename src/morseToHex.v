`default_nettype none

/*
 * Copyright (c) 2024 Noah Laforet
 * SPDX-License-Identifier: Apache-2.0
 */
 
// Morse Code to Hex Lookup Table
// Maps a morse code input buffer and symbol count to a 4-bit hex digit (0-F)
//
// Encoding: dots are stored as 0, dashes as 1
// New symbols shift in from the MSB: buffer <= {new_bit, buffer[4:1]}
// After all symbols entered, the first symbol is in the highest
// occupied bit position, the last symbol entered is in buffer[0]
//
// Trace examples:
//   E: dot                       -> 00000, count=1
//   A: dot, dash                 -> 10000, count=2
//   D: dash, dot, dot            -> 00100, count=3
//   B: dash, dot, dot, dot       -> 00010, count=4
//   1: dot, dash, dash, dash, dash -> 11110, count=5
//   6: dash, dot, dot, dot, dot  -> 00001, count=5
//
// Morse table:
//   0: -----   1: .----   2: ..---   3: ...--   4: ....-
//   5: .....   6: -....   7: --...   8: ---..   9: ----.
//   A: .-      B: -...    C: -.-.    D: -..     E: .
//   F: ..-.

module morseToHex (
    input  wire [2:0] count_i,   // number of symbols entered (1-5)
    input  wire [4:0] buffer_i,  // morse buffer
    output reg  [3:0] hex_o,     // decoded hex digit
    output reg        valid_o    // high if the pattern is a valid hex morse code
);

    always @(*) begin
        // Defaults
        hex_o   = 4'h0;
        valid_o = 1'b0;

        case (count_i)
            // 1 symbol: only E (dot)
            3'd1: begin
                case (buffer_i[4:0])
                    5'b00000: begin hex_o = 4'hE; valid_o = 1'b1; end // E: .
                    default: ;
                endcase
            end

            // 2 symbols: only A (dot, dash)
            3'd2: begin
                case (buffer_i[4:0])
                    5'b10000: begin hex_o = 4'hA; valid_o = 1'b1; end // A: .-
                    default: ;
                endcase
            end

            // 3 symbols: only D (dash, dot, dot)
            3'd3: begin
                case (buffer_i[4:0])
                    5'b00100: begin hex_o = 4'hD; valid_o = 1'b1; end // D: -..
                    default: ;
                endcase
            end

            // 4 symbols: B, C, F
            3'd4: begin
                case (buffer_i[4:0])
                    5'b00010: begin hex_o = 4'hB; valid_o = 1'b1; end // B: -...
                    5'b01010: begin hex_o = 4'hC; valid_o = 1'b1; end // C: -.-.
                    5'b01000: begin hex_o = 4'hF; valid_o = 1'b1; end // F: ..-.
                    default: ;
                endcase
            end

            // 5 symbols: digits 0-9
            3'd5: begin
                case (buffer_i[4:0])
                    5'b11111: begin hex_o = 4'h0; valid_o = 1'b1; end // 0: -----
                    5'b11110: begin hex_o = 4'h1; valid_o = 1'b1; end // 1: .----
                    5'b11100: begin hex_o = 4'h2; valid_o = 1'b1; end // 2: ..---
                    5'b11000: begin hex_o = 4'h3; valid_o = 1'b1; end // 3: ...--
                    5'b10000: begin hex_o = 4'h4; valid_o = 1'b1; end // 4: ....-
                    5'b00000: begin hex_o = 4'h5; valid_o = 1'b1; end // 5: .....
                    5'b00001: begin hex_o = 4'h6; valid_o = 1'b1; end // 6: -....
                    5'b00011: begin hex_o = 4'h7; valid_o = 1'b1; end // 7: --...
                    5'b00111: begin hex_o = 4'h8; valid_o = 1'b1; end // 8: ---..
                    5'b01111: begin hex_o = 4'h9; valid_o = 1'b1; end // 9: ----.
                    default: ;
                endcase
            end

            default: ; // count 0 or >5 is invalid
        endcase
    end

endmodule