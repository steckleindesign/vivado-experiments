`timescale 1ns / 1ps

// Experiment with case vs if else, parallel mux stuff
// Integrate a RAM
// Constrain pins

module experiment_top(
    // Next synth a few clks with a PLL
    // Analyze CDC related timing constraints/reports
    input  wire        clk,
    
    // Shift regs, DSP logic
    input  wire        a1,
    input  wire        b1,
    input  wire        c1,
    input  wire        d1,
    
    // Not used currently
    input  wire  [7:0] a8,
    input  wire  [7:0] b8,
    input  wire  [7:0] c8,
    input  wire  [7:0] d8,
    
    // Used for DSP logic
    input  wire [17:0] a18,
    input  wire [17:0] b18,
    input  wire [24:0] a25,
    input  wire [24:0] b25,
    
    
    // Outputs of DSP/SRL logic
    output reg         out0a,
    output reg         out0b,
    output reg         out0c,
    output reg  [41:0] out42a,
    output reg  [41:0] out42b,
    
    output reg   [7:0] out_sr_other
);

    // separating combinatorial vs sequential logic
    reg          out0a_d  = 'b0;
    reg          out0b_d  = 'b0;
    reg          out0c_d  = 'b0;
    reg   [41:0] out42a_d = 'b0;
    reg   [41:0] out42b_d = 'b0;
    
    // Shift register
    // 8, 16, 32, 64, 96, 128, 196, 256-bit SRs
    // Examine use of SRLs from tools
    // MC outputs? Q still used? sync or async?
    reg    [7:0] sr8    = 'b0;
    reg   [15:0] sr16   = 'b0;
    reg   [31:0] sr32   = 'b0;
    reg   [63:0] sr64   = 'b0;
    reg   [95:0] sr96   = 'b0;
    reg  [127:0] sr128  = 'b0;
    reg  [195:0] sr196  = 'b0;
    reg  [255:0] sr256  = 'b0;
    
    // Q outputs, always sync outs?
    reg   [10:0] sr11   = 'b0;
    reg   [37:0] sr37   = 'b0;
    
    reg    [7:0] out_sr_other_d = 'b0;
    
    // Use existing inputs to analuze SRL use
    always @(posedge clk)
    begin
        sr8   <= {  sr8  [6:0], a1};
        sr16  <= { sr16 [14:0], a1};
        sr32  <= { sr32 [31:0], a1};
        sr64  <= { sr64 [63:0], b1};
        sr96  <= { sr96 [95:0], b1};
        sr128 <= {sr128[127:0], c1};
        sr196 <= {sr196[195:0], c1};
        sr256 <= {sr256[255:0], c1};
        
        // Check if outputs are correct
        // (ADDR input to SRL)
        // Also analyze sync vs. async out
        sr11  <= { sr11 [10:0], d1};
        sr37  <= { sr37 [36:0], d1};
    end

    always @(posedge clk)
    begin
        out0a        <= out0a_d;
        out0b        <= out0b_d;
        out0c        <= out0c_d;
        out42a       <= out42a_d;
        out42b       <= out42b_d;
        out_sr_other <= out_sr_other_d;
    end
    
    // DSP48 logic
    always @(*)
    begin
        // Cascades 2 DSP48s
        out42a_d <= a25 * a18;
        
        out42b_d <= b18 * b25 + d1;
    end
    
    // Read from SRL outs
    always @(*)
    begin
        out0a_d        =  sr8 [7];
        out0b_d        = sr16[15];
        out0c_d        = sr32[31];
        
        // Throw other SR out lines to bus to consolidate results
        out_sr_other_d = {
            sr96  [95],
            sr128[127],
            sr96  [95],
            sr128[127],
            sr196[195],
            sr256[255],
            sr11  [10],
            sr37  [36]
        };
    end
    
endmodule