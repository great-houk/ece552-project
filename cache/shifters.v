module one_hot_128 (
    input  [6:0] sel,
    output [127:0] one_hot
);
    wire [63:0] lower;
    wire high_bit = sel[6];

    one_hot_64 sub (.sel(sel[5:0]), .one_hot(lower));
    assign one_hot[63:0]   = ~high_bit ? lower : 64'b0;
    assign one_hot[127:64] =  high_bit ? lower : 64'b0;
endmodule


module one_hot_64 (
    input  [5:0] sel,
    output [63:0] one_hot
);
    wire [15:0] lower;
    wire [3:0] enable;

    assign enable[0] = (sel[5:4] == 2'd0);
    assign enable[1] = (sel[5:4] == 2'd1);
    assign enable[2] = (sel[5:4] == 2'd2);
    assign enable[3] = (sel[5:4] == 2'd3);

    one_hot_16 sub (.sel(sel[3:0]), .one_hot(lower));
    assign one_hot[15:0]   = enable[0] ? lower : 16'b0;
    assign one_hot[31:16]  = enable[1] ? lower : 16'b0;
    assign one_hot[47:32]  = enable[2] ? lower : 16'b0;
    assign one_hot[63:48]  = enable[3] ? lower : 16'b0;
endmodule


module one_hot_16 (
    input  [3:0] sel,
    output [15:0] one_hot
);
    wire [3:0] lower;
    wire [3:0] enable;

    assign enable[0] = (sel[3:2] == 2'd0);
    assign enable[1] = (sel[3:2] == 2'd1);
    assign enable[2] = (sel[3:2] == 2'd2);
    assign enable[3] = (sel[3:2] == 2'd3);

    one_hot_4 sub0 (.sel(sel[1:0]), .one_hot(lower));
    assign one_hot[3:0]    = enable[0] ? lower : 4'b0;
    assign one_hot[7:4]    = enable[1] ? lower : 4'b0;
    assign one_hot[11:8]   = enable[2] ? lower : 4'b0;
    assign one_hot[15:12]  = enable[3] ? lower : 4'b0;
endmodule


module one_hot_8 (
    input  [2:0] sel,
    output [7:0] one_hot
);
    wire [3:0] lower;
    wire high_bit = sel[2];
    one_hot_4 sub (.sel(sel[1:0]), .one_hot(lower));
    assign one_hot[3:0] = ~high_bit ? lower : 4'b0;
    assign one_hot[7:4] =  high_bit ? lower : 4'b0;
endmodule

module one_hot_4 (
    input  [1:0] sel,
    output [3:0] one_hot
);
    assign one_hot = {
        (sel == 2'd3),
        (sel == 2'd2),
        (sel == 2'd1),
        (sel == 2'd0)
    };
endmodule


