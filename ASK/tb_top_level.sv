// =============================================================================
//  tb_top_level.sv  –  Testbench para top_level com ASK e onda quadrada
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
    top_level_ASK #(
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

        // diagnóstico logo após o reset
        @(posedge clk);
        $display("--- Diagnóstico pós-reset ---");
        $display("  square_out = %b", dut.square_out);
        $display("  data_in    = %b", dut.u_mod.data_in);
        $display("  gain       = %0d", dut.u_mod.gain);
        $display("  yn1        = %0d", dut.u_mod.yn1);
        $display("  coef       = %0d", dut.u_mod.COEF);
        $display("  clk_ce_cos = %b", dut.clk_ce_cos);

        // aguarda primeiro pulso do clk_ce_cos e verifica novamente
        @(posedge dut.clk_ce_cos);
        $display("--- Primeiro pulso clk_ce_cos ---");
        $display("  square_out = %b", dut.square_out);
        $display("  gain       = %0d", dut.u_mod.gain);
        $display("  yn1        = %0d", dut.u_mod.yn1);
        $display("  out        = %0d", dut.u_mod.out);
        $display("  scaled_out = %0d", dut.scaled_out);

        // roda 300 ms
        #300_000_000;

        $display("Simulação concluída em %0t ns.", $time);
        $stop;
    end

    // -------------------------------------------------------------------------
    //  Monitor — imprime a cada troca da square_out
    // -------------------------------------------------------------------------
    always @(square_out) begin
        $display("  %0t ns → square_out = %b → ASK: %s",
            $time,
            square_out,
            square_out ? "SILENCIO (gain=0)" : "SINAL (gain=16384)"
        );
    end

    // -------------------------------------------------------------------------
    //  Monitor — imprime gain e out a cada pulso do clk_ce_cos
    //  (só os primeiros 20 pulsos para não encher o transcript)
    // -------------------------------------------------------------------------
    int pulse_count = 0;
    always @(posedge clk) begin
        if (!rst && dut.clk_ce_cos && pulse_count < 20) begin
            $display("  pulso %0d | square=%b | gain=%0d | yn1=%0d | out=%0d | scaled=%0d",
                pulse_count,
                dut.square_out,
                dut.u_mod.gain,
                dut.u_mod.yn1,
                dut.u_mod.out,
                dut.scaled_out
            );
            pulse_count++;
        end
    end

endmodule