// =============================================================================
//  tb_top_level.sv  –  Testbench para top_level com PSK e onda quadrada
//
//  Clock base: 50 MHz (20 ns)
//  square_out: 10 Hz → T = 100 ms → 50 ms por estado
//  Simula 300 ms = 3 ciclos completos
// =============================================================================
`timescale 1ns/1ps

module tb_top_level;

    localparam real CLK_PERIOD = 20.0;

    logic clk;
    logic rst;
    logic dac_out;
    logic square_out;

    // -------------------------------------------------------------------------
    //  DUT
    // -------------------------------------------------------------------------
    top_level_PSK #(
        .CLK_FREQ   (50_000_000),
        .DIV_DAC    (8),
        .DIV_COS    (64),
        .DIV_SQUARE (625000)
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
    //  Estímulos
    // -------------------------------------------------------------------------
    initial begin
        rst = 1'b1;
        repeat (10) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        #300_000_000;

        $display("Simulação concluída em %0t ns.", $time);
        $stop;
    end

    // -------------------------------------------------------------------------
    //  Monitor — imprime cada troca da onda quadrada
    // -------------------------------------------------------------------------
    always @(square_out) begin
        $display("  %0t ns → square_out = %b → PSK: fase %s",
            $time,
            square_out,
            square_out ? "180° (phase=-16384)" : "0° (phase=+16384)"
        );
    end

endmodule