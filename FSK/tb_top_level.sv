// =============================================================================
//  tb_top_level.sv  –  Testbench para top_level com FSK e onda quadrada
//
//  Clock base: 50 MHz (20 ns)
//
//  Cadeia de clock:
//    clk_ce_dac : 50 MHz / 8       = 6,25 MHz
//    clk_ce_cos : 6,25 MHz / 64    ≈ 97,656 kHz
//    square_out : 6,25 MHz / 625000 = 10 Hz  → T = 100 ms
//
//  Simula 3 ciclos completos da onda quadrada = 300 ms
//  Cada meio ciclo (50 ms) = 1 estado do FSK
// =============================================================================
`timescale 1ns/1ps

module tb_top_level;

    localparam real CLK_PERIOD = 20.0;  // 50 MHz

    logic clk;
    logic rst;
    logic dac_out;
    logic square_out;

    // -------------------------------------------------------------------------
    //  DUT
    // -------------------------------------------------------------------------
    top_level_FSK #(
        .CLK_FREQ   (50_000_000),
        .DIV_DAC    (8),
        .DIV_COS    (64),
        .DIV_SQUARE (625000)    // 10 Hz → T = 100 ms → 50 ms por estado
    ) dut (
        .clk        (clk),
        .rst        (rst),
        .dac_out    (dac_out),
        .square_out (square_out)
    );

    // -------------------------------------------------------------------------
    //  Clock
    // -------------------------------------------------------------------------
    initial clk = 0;
    always #(CLK_PERIOD / 2.0) clk = ~clk;

    // -------------------------------------------------------------------------
    //  Estímulos — reset e roda 3 ciclos completos da onda quadrada (300 ms)
    // -------------------------------------------------------------------------
    initial begin
        rst = 1'b1;
        repeat (10) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        // 300 ms = 3 ciclos completos da onda quadrada de 10 Hz
        #300_000_000;

        $display("Simulação concluída em %0t ns.", $time);
        $stop;
    end

    // -------------------------------------------------------------------------
    //  Monitor — imprime cada troca da onda quadrada
    // -------------------------------------------------------------------------
    always @(posedge square_out or negedge square_out) begin
        $display("  %0t ns → square_out = %b → FSK: %s",
            $time,
            square_out,
            square_out ? "COEF_2 / 10000 Hz" : "COEF_1 / 1000 Hz"
        );
    end

endmodule