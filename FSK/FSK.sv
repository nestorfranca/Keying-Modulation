// =============================================================================
//  FSK.sv  –  Modulador FSK (Frequency Shift Keying)
//  Chaveamento pelo sinal externo data_in (onda quadrada do top_level)
//
//  data_in = 0 → COEF_1 (1000 Hz)
//  data_in = 1 → COEF_2 (10000 Hz)
//
//  Melhorias aplicadas:
//    - COEF ímpares para melhor comportamento em ponto fixo
//    - YN2_INIT correto para 1000 Hz
//    - Clamp em yn_v para evitar divergência numérica em longa duração
// =============================================================================
module FSK #(
    parameter int Q        = 14,
    parameter int CLK_FREQ = 97_656,

    parameter logic signed [(Q+1):0] COEF_1   = 'sd32699,  // 1000 Hz (ímpar)
    parameter logic signed [(Q+1):0] COEF_2   = 'sd26215,  // 10000 Hz (ímpar)
    parameter logic signed [(Q+1):0] YN1_INIT = 'sd16384,
    parameter logic signed [(Q+1):0] YN2_INIT = 'sd16375   // calculado para 1000 Hz
)(
    input  logic clk,
    input  logic clk_ce,
    input  logic rst,
    input  logic data_in,               // onda quadrada vinda do top_level
    output logic signed [(Q+1):0] out
);

    logic signed [(Q+1):0]   yn1, yn2;
    logic signed [(Q+1):0]   coef;

    logic signed [(Q*2+3):0] temp_v;
    logic signed [(Q+1):0]   yn_v;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            yn1  <= YN1_INIT;
            yn2  <= YN2_INIT;
            coef <= COEF_1;
            out  <= '0;
        end else if (clk_ce) begin

            // chaveamento direto pelo data_in
            if (data_in == 1'b0)
                coef <= COEF_1;
            else
                coef <= COEF_2;

            // oscilador IIR
            temp_v = coef * yn1;
            yn_v   = (temp_v >>> Q) - yn2;

            // clamp para evitar divergência numérica em longa duração
            if (yn_v > (1 <<< Q))
                yn_v = (1 <<< Q);
            else if (yn_v < -(1 <<< Q))
                yn_v = -(1 <<< Q);

            yn2 <= yn1;
            yn1 <= yn_v;
            out <= yn_v;
        end
    end

endmodule