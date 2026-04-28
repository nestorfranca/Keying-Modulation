// =============================================================================
//  top_level.sv  –  DE2-115  EP4CE115F29C7
//  Clock base: 50 MHz
//    clk_ce_dac  : 50 MHz  / 8       = 6,25 MHz
//    clk_ce_cos  : 6,25 MHz / 64     ≈ 97,656 kHz
//    square_out  : 6,25 MHz / 625000 = 10 Hz → T = 100 ms
// =============================================================================
module top_level_ASK #(
    parameter int CLK_FREQ   = 50_000_000,
    parameter int DIV_DAC    = 8,
    parameter int DIV_COS    = 64,
    parameter int DIV_SQUARE = 625000
)(
    input  logic clk,
    input  logic rst,
    output logic dac_out,
    output logic square_out
);

    localparam int Q = 14;

    logic clk_ce_cos;
    logic clk_ce_dac;

    logic signed [(Q+1):0] mod_out;
    logic signed [(Q+1):0] scaled_out;

    int counter_dac;
    int counter_cos;
    int counter_sq;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_dac <= 0;
            clk_ce_dac  <= 1'b0;
        end else begin
            if (counter_dac == (DIV_DAC - 1)) begin
                counter_dac <= 0;
                clk_ce_dac  <= 1'b1;
            end else begin
                counter_dac <= counter_dac + 1;
                clk_ce_dac  <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_cos <= 0;
            clk_ce_cos  <= 1'b0;
        end else begin
            clk_ce_cos <= 1'b0;
            if (clk_ce_dac) begin
                if (counter_cos == (DIV_COS - 1)) begin
                    counter_cos <= 0;
                    clk_ce_cos  <= 1'b1;
                end else begin
                    counter_cos <= counter_cos + 1;
                end
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_sq <= 0;
            square_out <= 1'b0;
        end else if (clk_ce_dac) begin
            if (counter_sq == (DIV_SQUARE/2) - 1) begin
                counter_sq <= 0;
                square_out <= ~square_out;
            end else begin
                counter_sq <= counter_sq + 1;
            end
        end
    end

    ASK #(
        .Q        (Q),
        .CLK_FREQ (97_656)
    ) u_mod (
        .clk     (clk),
        .clk_ce  (clk_ce_cos),
        .rst     (rst),
        .data_in (square_out),
        .out     (mod_out)
    );

    reescala #(.Q(Q), .SHIFT(3)) u_scale (
        .in  (mod_out),
        .out (scaled_out)
    );

    sigma_delta #(.Q(Q)) u_dac (
        .clk          (clk),
        .clk_ce       (clk_ce_dac),
        .rst          (rst),
        .input_signal (scaled_out),
        .out          (dac_out)
    );

endmodule